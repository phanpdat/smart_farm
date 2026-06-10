import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_status.dart';
import '../models/tomato_status.dart';
import '../models/diagnostic_record.dart';

class FarmProvider extends ChangeNotifier {
  TomatoStatus _tomatoStatus = TomatoStatus.initial();
  TomatoStatus get tomatoStatus => _tomatoStatus;

  List<DiagnosticRecord> _savedScans = [];
  List<DiagnosticRecord> get savedScans => _savedScans;

  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://smart-farm-pbl5-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref();

  DeviceStatus _deviceStatus = DeviceStatus(
    pump: false,
    fan: false,
    light: false,
    roof: false,
    led: false,
  );
  SensorData _sensorData = SensorData(
    temperature: 0.0,
    humidity: 0.0,
    lightIntensity: 0,
    airQuality: 'Offline',
    gas: 0,
    humid: 0.0,
    rain: 0,
    soil: 0,
    water: 0,
  );
  bool _isAuto = true;
  bool _isLoading = true;
  String _cameraUrl = 'http://172.20.10.2:81/stream';

  DeviceStatus get deviceStatus => _deviceStatus;
  SensorData get sensorData => _sensorData;
  bool get isAuto => _isAuto;
  bool get isLoading => _isLoading;
  String get cameraUrl => _cameraUrl;

  int _selectedScanIndex = 0;
  int get selectedScanIndex => _selectedScanIndex;

  final SharedPreferences _prefs;

  void setSelectedScanIndex(int index) {
    if (index >= 0 && index < _savedScans.length) {
      _selectedScanIndex = index;
      notifyListeners();
    }
  }

  void setCameraUrl(String url) {
    _cameraUrl = url;
    notifyListeners();
  }

  FarmProvider(this._prefs) {
    _init();
  }

  Future<void> _init() async {
    await loadHistoryFromLocal();
    _initListeners();
  }

  void _initListeners() {
    _dbRef.child('devices').onValue.listen((event) {
      debugPrint('Device data: ${event.snapshot.value}');
      if (event.snapshot.value != null) {
        try {
          final rawValue = event.snapshot.value;
          if (rawValue is Map) {
            final data = Map<dynamic, dynamic>.from(rawValue);
            _deviceStatus = DeviceStatus.fromMap(data);
            _isLoading = false;
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error parsing devices: $e');
        }
      }
    });

    _dbRef.child('settings').onValue.listen((event) {
      debugPrint('Settings data: ${event.snapshot.value}');
      if (event.snapshot.value != null) {
        try {
          final rawValue = event.snapshot.value;
          if (rawValue is Map) {
            final data = Map<dynamic, dynamic>.from(rawValue);
            _isAuto = data['auto'] ?? true;
            debugPrint('Updated isAuto to: $_isAuto');
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error parsing settings: $e');
        }
      } else {
        _isAuto = true;
        notifyListeners();
      }
    });
    _dbRef.child('sensors').onValue.listen((event) {
      debugPrint('Sensor data: ${event.snapshot.value}');
      if (event.snapshot.value != null) {
        try {
          final rawValue = event.snapshot.value;
          if (rawValue is Map) {
            final data = Map<dynamic, dynamic>.from(rawValue);
            _sensorData = SensorData.fromMap(data);
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error parsing sensors: $e');
        }
      }
    });

    _dbRef.child('tomato_status').onValue.listen((event) {
      debugPrint('Tomato status data: ${event.snapshot.value}');
      if (event.snapshot.value != null) {
        try {
          final rawValue = event.snapshot.value;
          if (rawValue is Map) {
            final data = Map<dynamic, dynamic>.from(rawValue);
            _tomatoStatus = TomatoStatus.fromMap(data);
            notifyListeners();
            // Automatically save as a new scan / sector
            saveDiagnostic(_tomatoStatus);
          } else {
            debugPrint('tomato_status data is not a Map: $rawValue');
          }
        } catch (e) {
          debugPrint('Error parsing tomato_status: $e');
        }
      }
    });
  }

  Future<void> setDevice(String deviceName, bool status) async {
    try {
      await _dbRef.child('devices').update({deviceName: status});
    } catch (e) {
      debugPrint('Error setting device: $e');
    }
  }

  Future<void> setAutoMode(bool auto) async {
    _isAuto = auto;
    notifyListeners();

    try {
      debugPrint('Setting auto mode to: $auto');
      await _dbRef.child('settings').update({'auto': auto});
    } catch (e) {
      debugPrint('Error setting auto mode: $e');
    }
  }

  Future<void> loadHistoryFromLocal() async {
    try {
      final String? jsonStr = _prefs.getString('saved_scans');
      debugPrint('SharedPreferences raw saved_scans: $jsonStr');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _savedScans = decoded
            .map(
              (item) => DiagnosticRecord.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        debugPrint(
          'Successfully loaded ${_savedScans.length} scans from SharedPreferences.',
        );
        if (_savedScans.isNotEmpty) {
          _selectedScanIndex =
              _savedScans.length - 1; // Select the most recent one
        }
        notifyListeners();
      } else {
        debugPrint('No saved scans found in SharedPreferences.');
      }
    } catch (e) {
      debugPrint('Error loading saved scans: $e');
    }
  }

  Future<String> _downloadAndSaveImage(String url, int timestamp) async {
    try {
      if (url.isEmpty || !url.startsWith('http')) {
        return url;
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/scan_$timestamp.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Downloaded and saved image locally to: $filePath');
        return filePath;
      } else {
        debugPrint(
          'Failed to download image: status code ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error downloading and saving image: $e');
    }
    return url;
  }

  Future<void> saveDiagnostic(TomatoStatus status) async {
    if (status.lastUpdate == 0) return;

    final isDuplicate = _savedScans.any(
      (r) => r.lastUpdate == status.lastUpdate,
    );
    if (isDuplicate) return;

    final localImageUrl = await _downloadAndSaveImage(
      status.imageUrl,
      status.lastUpdate,
    );

    final newRecord = DiagnosticRecord(
      diseaseName: status.diseaseName,
      diseaseStatus: status.diseaseStatus,
      imageUrl: localImageUrl,
      lastUpdate: status.lastUpdate,
      treatmentStepByStep: status.treatmentStepByStep,
      ripenessLevel: status.ripenessLevel,
      ripenessStage: status.ripenessStage,
      harvestRecommendation: status.harvestRecommendation,
    );

    _savedScans.add(newRecord);
    _selectedScanIndex = _savedScans.length - 1;
    notifyListeners();

    await _saveHistoryToLocal();
  }

  Future<void> deleteDiagnostic(int lastUpdate) async {
    try {
      final record = _savedScans.firstWhere((r) => r.lastUpdate == lastUpdate);
      if (record.imageUrl.isNotEmpty && !record.imageUrl.startsWith('http')) {
        final file = File(record.imageUrl);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted local image file: ${record.imageUrl}');
        }
      }
    } catch (e) {
      debugPrint('Error deleting local image file: $e');
    }

    _savedScans.removeWhere((r) => r.lastUpdate == lastUpdate);
    if (_selectedScanIndex >= _savedScans.length) {
      _selectedScanIndex = _savedScans.isNotEmpty ? _savedScans.length - 1 : 0;
    }
    notifyListeners();

    await _saveHistoryToLocal();
  }

  Future<void> _saveHistoryToLocal() async {
    try {
      final toEncode = _savedScans.map((r) => r.toJson()).toList();
      final jsonStr = jsonEncode(toEncode);
      await _prefs.setString('saved_scans', jsonStr);
      debugPrint('Saved scans to SharedPreferences: $jsonStr');
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }
}
