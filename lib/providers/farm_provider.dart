import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/device_status.dart';

class FarmProvider extends ChangeNotifier {
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
  );
  SensorData _sensorData = SensorData(
    temperature: 0.0,
    humidity: 0.0,
    lightIntensity: 0,
    airQuality: 'Offline',
  );
  bool _isAuto = true;
  bool _isLoading = true;

  DeviceStatus get deviceStatus => _deviceStatus;
  SensorData get sensorData => _sensorData;
  bool get isAuto => _isAuto;
  bool get isLoading => _isLoading;

  FarmProvider() {
    _initListeners();
  }

  void _initListeners() {
    _dbRef.child('devices').onValue.listen((event) {
      debugPrint('Device data: ${event.snapshot.value}');
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _deviceStatus = DeviceStatus.fromMap(data);
        _isLoading = false;
        notifyListeners();
      }
    });

    _dbRef.child('settings').onValue.listen((event) {
      debugPrint('Settings data: ${event.snapshot.value}');
      if (event.snapshot.value != null) {
        try {
          final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
          _isAuto = data['auto'] ?? true;
          debugPrint('Updated isAuto to: $_isAuto');
          notifyListeners();
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
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _sensorData = SensorData.fromMap(data);
        notifyListeners();
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
