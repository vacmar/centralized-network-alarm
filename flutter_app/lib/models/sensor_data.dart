class SensorData {
  final String sensor;
  final dynamic value;
  final String status;
  final DateTime timestamp;

  SensorData({
    required this.sensor,
    required this.value,
    required this.status,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      sensor: json['sensor'] ?? '',
      value: json['value'] ?? '',
      status: json['status'] ?? 'Normal',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to get formatted sensor name
  String get displayName {
    switch (sensor.toLowerCase()) {
      case 'flame':
      case 'flame_sensor':
        return 'Flame Sensor';
      case 'mq6':
      case 'mq-6':
      case 'gas':
        return 'MQ-6 Gas Sensor';
      case 'dht22':
      case 'dht-22':
      case 'temperature':
      case 'humidity':
        return 'DHT-22 (Temp & Humidity)';
      default:
        return sensor;
    }
  }

  // Helper method to get formatted value display
  String get displayValue {
    if (value is Map) {
      Map<String, dynamic> valueMap = value as Map<String, dynamic>;
      if (valueMap.containsKey('temperature') &&
          valueMap.containsKey('humidity')) {
        return '${valueMap['temperature']}°C / ${valueMap['humidity']}%';
      }
    }
    return value.toString();
  }

  // Helper method to determine status based on sensor readings
  String get safetyStatus {
    if (status.toLowerCase() == 'offline') {
      return 'OFFLINE';
    }

    if (status.toLowerCase() == 'danger' || status.toLowerCase() == 'alert') {
      return 'DANGER';
    }

    // Auto-determine danger status based on sensor values
    switch (sensor.toLowerCase()) {
      case 'flame':
      case 'flame_sensor':
        if (value.toString().toLowerCase().contains('detected') ||
            value.toString().toLowerCase().contains('fire') ||
            (value is bool && value == true) ||
            (value is num && value > 0)) {
          return 'DANGER';
        }
        break;
      case 'mq6':
      case 'mq-6':
      case 'gas':
        if (value is num && value > 300) {
          // Threshold for gas detection
          return 'DANGER';
        }
        break;
      case 'dht22':
      case 'dht-22':
      case 'temperature':
        if (value is Map) {
          Map<String, dynamic> valueMap = value as Map<String, dynamic>;
          double? temp = double.tryParse(valueMap['temperature'].toString());
          if (temp != null && (temp > 40 || temp < 0)) {
            return 'WARNING';
          }
        } else if (value is num && (value > 40 || value < 0)) {
          return 'WARNING';
        }
        break;
    }
  return 'NORMAL';
  }
}
