class SensorData {
  final String sensor;
  final String value;
  final String status;

  SensorData({required this.sensor, required this.value, required this.status});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      sensor: json['sensor'] ?? '',
      value: json['value'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
