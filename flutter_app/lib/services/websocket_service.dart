import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/sensor_data.dart';

class WebSocketService {
  // Singleton instance
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketService._internal() {
    _connect();
  }

  late WebSocketChannel _channel;
  final StreamController<SensorData> _controller =
      StreamController<SensorData>.broadcast();
  bool _isConnected = false;
  Timer? _reconnectTimer;

  // Railway WebSocket URL
  static const String _websocketUrl = 'wss://obsentracore.up.railway.app';

  void _connect() {
    try {
  print('Connecting to WebSocket: $_websocketUrl');
      _channel = WebSocketChannel.connect(Uri.parse(_websocketUrl));
  _isConnected = true;
  print('WebSocket connected to $_websocketUrl');

  // Listen for messages and errors
  _channel.stream.listen(_onMessage, onError: _onError, onDone: _onDone);
    } catch (e) {
      print('WebSocket connection error: $e');
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      print('Received WebSocket message: $message');

      dynamic decoded;
      try {
        decoded = json.decode(message);
      } catch (e) {
        // Not JSON - keep the raw message
        decoded = message;
      }

      if (decoded is Map<String, dynamic>) {
        SensorData sensorData = _parseSensorData(decoded);
        _controller.add(sensorData);
        return;
      }

      if (decoded is String) {
        // Try a simple 'sensor:value' or 'sensor|value' format from legacy senders
        final raw = decoded;
        if (raw.contains(':')) {
          final parts = raw.split(':');
          final sensor = parts.first.trim();
          final value = parts.sublist(1).join(':').trim();
          final map = {'sensor': sensor, 'value': value, 'status': 'Normal'};
          SensorData sensorData = _parseSensorData(map);
          _controller.add(sensorData);
          return;
        }
        if (raw.contains('|')) {
          final parts = raw.split('|');
          final sensor = parts[0].trim();
          final value = parts.length > 1 ? parts[1].trim() : '';
          final map = {'sensor': sensor, 'value': value, 'status': 'Normal'};
          SensorData sensorData = _parseSensorData(map);
          _controller.add(sensorData);
          return;
        }
      }

      // If we got here, we didn't understand the message format
      print('Unrecognized WebSocket message format (ignored): $message');
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  SensorData _parseSensorData(Map<String, dynamic> data) {
    // Handle different data formats from Railway
    String sensor = '';
    dynamic value = '';
    String status = 'Normal';
    DateTime timestamp = DateTime.now();

    // Parse sensor type
    if (data.containsKey('sensor')) {
  sensor = data['sensor'].toString().toLowerCase();
    } else if (data.containsKey('type')) {
  sensor = data['type'].toString().toLowerCase();
    }

    // Parse sensor value
    if (data.containsKey('value')) {
      value = data['value'];
    } else if (data.containsKey('data')) {
      value = data['data'];
    }

    // Parse status
    if (data.containsKey('status')) {
      status = data['status'].toString();
    } else if (data.containsKey('alert')) {
      status = data['alert'] == true ? 'Danger' : 'Normal';
    }

    // Parse timestamp
    if (data.containsKey('timestamp')) {
      timestamp =
          DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now();
    }

    // Handle specific sensor data formats
    if (sensor.toLowerCase().contains('dht') ||
        sensor.toLowerCase().contains('temperature')) {
      // DHT-22 might send temperature and humidity separately or together
      if (data.containsKey('temperature') && data.containsKey('humidity')) {
        value = {
          'temperature': data['temperature'],
          'humidity': data['humidity'],
        };
      }
    }

    return SensorData(
      sensor: sensor,
      value: value,
      status: status,
      timestamp: timestamp,
    );
  }

  void _onError(error) {
  print('WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _onDone() {
  print('WebSocket connection closed');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      print('Attempting to reconnect...');
      _connect();
    });
  }

  Stream<SensorData> get sensorStream => _controller.stream;
  // Backwards-compatible getter used across the app
  Stream<SensorData> get sensorStreamBroadcast => _controller.stream;
  bool get isConnected => _isConnected;

  void dispose() {
    _reconnectTimer?.cancel();
    _channel.sink.close();
    _controller.close();
  }
}
