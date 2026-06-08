import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/device_status.dart';
import '../models/tomato_status.dart';

class FarmProvider extends ChangeNotifier {
  TomatoStatus _tomatoStatus = TomatoStatus.initial();
  TomatoStatus get tomatoStatus => _tomatoStatus;
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

  void setCameraUrl(String url) {
    _cameraUrl = url;
    notifyListeners();
  }

  FarmProvider() {
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
          } else {
            debugPrint('tomato_status data is not a Map: $rawValue');
          }
        } catch (e) {
          debugPrint('Error parsing tomato_status: $e');
        }
      }
    });
  }

  Future<void> toggleDevice(String deviceName, bool currentStatus) async {
    try {
      await _dbRef.child('devices').update({deviceName: !currentStatus});
    } catch (e) {
      debugPrint('Error toggling device: $e');
    }
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
}
