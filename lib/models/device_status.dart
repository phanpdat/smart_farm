class DeviceStatus {
  final bool pump;
  final bool fan;
  final bool light;
  final bool roof;
  final bool led;

  DeviceStatus({
    required this.pump,
    required this.fan,
    required this.light,
    required this.roof,
    required this.led,
  });

  factory DeviceStatus.fromMap(Map<dynamic, dynamic> map) {
    return DeviceStatus(
      pump: map['pump'] ?? false,
      fan: map['fan'] ?? false,
      light: map['light'] ?? false,
      roof: map['roof'] ?? false,
      led: map['led'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pump': pump,
      'fan': fan,
      'light': light,
      'roof': roof,
      'led': led,
    };
  }

  DeviceStatus copyWith({
    bool? pump,
    bool? fan,
    bool? light,
    bool? roof,
    bool? led,
  }) {
    return DeviceStatus(
      pump: pump ?? this.pump,
      fan: fan ?? this.fan,
      light: light ?? this.light,
      roof: roof ?? this.roof,
      led: led ?? this.led,
    );
  }
}

class SensorData {
  final double temperature;
  final double humidity;
  final int lightIntensity;
  final String airQuality;
  final int gas;
  final double humid;
  final int rain;
  final int soil;
  final int water;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.airQuality,
    required this.gas,
    required this.humid,
    required this.rain,
    required this.soil,
    required this.water,
  });

  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    return SensorData(
      temperature: (map['temp'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      lightIntensity: map['light'] ?? 0,
      airQuality: map['air'] ?? 'Unknown',
      gas: map['gas'] ?? 0,
      humid: (map['humid'] ?? 0.0).toDouble(),
      rain: map['rain'] ?? 0,
      soil: map['soil'] ?? 0,
      water: map['water'] ?? 0,
    );
  }
}
