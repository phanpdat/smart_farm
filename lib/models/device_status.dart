class DeviceStatus {
  final bool pump;
  final bool fan;
  final bool light;
  final bool roof;

  DeviceStatus({
    required this.pump,
    required this.fan,
    required this.light,
    required this.roof,
  });

  factory DeviceStatus.fromMap(Map<dynamic, dynamic> map) {
    return DeviceStatus(
      pump: map['pump'] ?? false,
      fan: map['fan'] ?? false,
      light: map['light'] ?? false,
      roof: map['roof'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'pump': pump, 'fan': fan, 'light': light, 'roof': roof};
  }

  DeviceStatus copyWith({bool? pump, bool? fan, bool? light, bool? roof}) {
    return DeviceStatus(
      pump: pump ?? this.pump,
      fan: fan ?? this.fan,
      light: light ?? this.light,
      roof: roof ?? this.roof,
    );
  }
}

class SensorData {
  final double temperature;
  final double humidity;
  final int lightIntensity;
  final String airQuality;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.airQuality,
  });

  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    return SensorData(
      temperature: (map['temp'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      lightIntensity: map['light'] ?? 0,
      airQuality: map['air'] ?? 'Unknown',
    );
  }
}
