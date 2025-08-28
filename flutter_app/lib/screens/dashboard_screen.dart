import 'package:flutter/material.dart';
import 'dart:async';
import '../models/sensor_data.dart';
import '../services/websocket_service.dart';
import '../utils/alert_sound_player.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late WebSocketService _webSocketService;
  final List<SensorData> _allSensorData = [];
  String? _selectedSensor;
  final AlertSoundPlayer _alertPlayer = AlertSoundPlayer();
  bool _isConnected = false;
  StreamSubscription<SensorData>? _sensorSubscription;
  Timer? _connectionTimer;
  Timer? _offlineCheckTimer;

  // Custom alert functionality
  final List<String> _customAlerts = [];
  final _alertController = TextEditingController();

  // Three specific sensors for this project
  final List<String> _sensorTypes = [
    'Flame Sensor',
    'MQ-6 Gas Sensor',
    'DHT-22 (Temp & Humidity)',
  ];

  // Expected sensor identifiers from the WebSocket
  final Map<String, String> _expectedSensors = {
    'flame': 'Flame Sensor',
    'mq6': 'MQ-6 Gas Sensor',
    'dht22': 'DHT-22 (Temp & Humidity)',
  };

  // Track last seen time for each sensor
  final Map<String, DateTime> _lastSeenTime = {};

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
    _setupWebSocketConnection();
    _startPeriodicChecks();
  }

  void _setupWebSocketConnection() {
    _sensorSubscription = _webSocketService.sensorStream.listen(
      (sensorData) {
        if (mounted) {
          setState(() {
            // Update last seen time
            _lastSeenTime[sensorData.sensor] = DateTime.now();

            // Update or add sensor data
            final existingIndex = _allSensorData.indexWhere(
              (item) => item.sensor == sensorData.sensor,
            );

            if (existingIndex != -1) {
              _allSensorData[existingIndex] = sensorData;
            } else {
              _allSensorData.add(sensorData);
            }

            // Play alert sound if this is a danger alert
            if (sensorData.safetyStatus == 'DANGER') {
              _alertPlayer.playAlertSound();
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
      },
    );

    // Monitor connection status
    _connectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _isConnected = _webSocketService.isConnected;
        });
      }
    });
  }

  void _startPeriodicChecks() {
    // Check for offline sensors every 10 seconds
    _offlineCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _checkOfflineSensors();
      }
    });
  }

  void _checkOfflineSensors() {
    final now = DateTime.now();
    final offlineThreshold = const Duration(seconds: 30);

    setState(() {
      // Check each expected sensor
      for (final expectedSensorKey in _expectedSensors.keys) {
        final lastSeen = _lastSeenTime[expectedSensorKey];

        if (lastSeen == null || now.difference(lastSeen) > offlineThreshold) {
          // Create or update offline sensor entry
          final existingIndex = _allSensorData.indexWhere(
            (item) => item.sensor == expectedSensorKey,
          );

          final offlineSensorData = SensorData(
            sensor: expectedSensorKey,
            value: 'OFFLINE',
            status: 'OFFLINE',
            timestamp: now,
          );

          if (existingIndex != -1) {
            _allSensorData[existingIndex] = offlineSensorData;
          } else {
            _allSensorData.add(offlineSensorData);
          }
        }
      }
    });
  }

  void _addCustomAlert() {
    if (_alertController.text.trim().isNotEmpty) {
      setState(() {
        _customAlerts.add(_alertController.text.trim());
        _alertController.clear();
      });
    }
  }

  void _removeCustomAlert(int index) {
    setState(() {
      _customAlerts.removeAt(index);
    });
  }

  // Test button functions with simplified sensor data
  void _addTestFlameAlert() {
    final testData = SensorData(
      sensor: 'flame',
      value: 'Fire Detected!',
      status: 'Danger',
      timestamp: DateTime.now(),
    );
    setState(() {
      final existingIndex = _allSensorData.indexWhere(
        (item) => item.sensor == 'flame',
      );
      if (existingIndex != -1) {
        _allSensorData[existingIndex] = testData;
      } else {
        _allSensorData.add(testData);
      }
      _lastSeenTime['flame'] = DateTime.now();
    });
    _alertPlayer.playAlertSound();
  }

  void _addTestGasAlert() {
    final testData = SensorData(
      sensor: 'mq6',
      value: 'Gas Leak Detected!',
      status: 'Danger',
      timestamp: DateTime.now(),
    );
    setState(() {
      final existingIndex = _allSensorData.indexWhere(
        (item) => item.sensor == 'mq6',
      );
      if (existingIndex != -1) {
        _allSensorData[existingIndex] = testData;
      } else {
        _allSensorData.add(testData);
      }
      _lastSeenTime['mq6'] = DateTime.now();
    });
    _alertPlayer.playAlertSound();
  }

  void _addTestTempAlert() {
    final testData = SensorData(
      sensor: 'dht22',
      value: 'Temperature: 45°C, Humidity: 85%',
      status: 'Warning',
      timestamp: DateTime.now(),
    );
    setState(() {
      final existingIndex = _allSensorData.indexWhere(
        (item) => item.sensor == 'dht22',
      );
      if (existingIndex != -1) {
        _allSensorData[existingIndex] = testData;
      } else {
        _allSensorData.add(testData);
      }
      _lastSeenTime['dht22'] = DateTime.now();
    });
    _alertPlayer.playAlertSound();
  }

  List<SensorData> get _filteredSensorData {
    if (_selectedSensor == null || _selectedSensor == 'All Sensors') {
      return _allSensorData;
    }

    // Map display name back to sensor type
    String? sensorType;
    for (final entry in _expectedSensors.entries) {
      if (entry.value == _selectedSensor) {
        sensorType = entry.key;
        break;
      }
    }

    if (sensorType != null) {
      return _allSensorData
          .where((sensor) => sensor.sensor == sensorType)
          .toList();
    }

    return _allSensorData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Network Alarm Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Connected' : 'Offline',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF16213E),
            child: Row(
              children: [
                const Text(
                  'Filter by Sensor: ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSensor,
                        hint: const Text(
                          'All Sensors',
                          style: TextStyle(color: Colors.white70),
                        ),
                        dropdownColor: const Color(0xFF16213E),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'All Sensors',
                            child: Text('All Sensors'),
                          ),
                          ..._sensorTypes.map((String sensorType) {
                            return DropdownMenuItem<String>(
                              value: sensorType,
                              child: Text(sensorType),
                            );
                          }),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSensor = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Custom Alert Input Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF0E3B43),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _alertController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter custom alert message...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF1A1A2E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _addCustomAlert(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addCustomAlert,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF357A7A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add Alert'),
                    ),
                  ],
                ),
                if (_customAlerts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Active Custom Alerts:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _customAlerts.asMap().entries.map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.value,
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removeCustomAlert(entry.key),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Test Buttons Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF16213E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Sensor Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addTestFlameAlert,
                        icon: const Icon(Icons.local_fire_department, size: 20),
                        label: const Text('Test Fire'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addTestGasAlert,
                        icon: const Icon(Icons.cloud, size: 20),
                        label: const Text('Test Gas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addTestTempAlert,
                        icon: const Icon(Icons.thermostat, size: 20),
                        label: const Text('Test Temp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sensor Data List
          Expanded(
            child: Container(
              color: const Color(0xFF1A1A2E),
              child:
                  _filteredSensorData.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sensors_off,
                              size: 64,
                              color: Colors.white38,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No sensor data available',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Waiting for sensor connections...',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredSensorData.length,
                        itemBuilder: (context, index) {
                          final sensor = _filteredSensorData[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    sensor.safetyStatus == 'DANGER'
                                        ? Colors.red
                                        : sensor.status == 'OFFLINE'
                                        ? Colors.grey
                                        : sensor.safetyStatus == 'WARNING'
                                        ? Colors.orange
                                        : Colors.green,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (sensor.safetyStatus == 'DANGER'
                                          ? Colors.red
                                          : sensor.status == 'OFFLINE'
                                          ? Colors.grey
                                          : sensor.safetyStatus == 'WARNING'
                                          ? Colors.orange
                                          : Colors.green)
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        sensor.safetyStatus == 'DANGER'
                                            ? Icons.warning
                                            : sensor.status == 'OFFLINE'
                                            ? Icons.wifi_off
                                            : sensor.safetyStatus == 'WARNING'
                                            ? Icons.warning_amber
                                            : Icons.check_circle,
                                        color:
                                            sensor.safetyStatus == 'DANGER'
                                                ? Colors.red
                                                : sensor.status == 'OFFLINE'
                                                ? Colors.grey
                                                : sensor.safetyStatus ==
                                                    'WARNING'
                                                ? Colors.orange
                                                : Colors.green,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sensor.displayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Status: ${sensor.safetyStatus}',
                                              style: TextStyle(
                                                color:
                                                    sensor.safetyStatus ==
                                                            'DANGER'
                                                        ? Colors.red
                                                        : sensor.status ==
                                                            'OFFLINE'
                                                        ? Colors.grey
                                                        : sensor.safetyStatus ==
                                                            'WARNING'
                                                        ? Colors.orange
                                                        : Colors.green,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1A2E),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reading:',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          sensor.displayValue,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Last Updated: ${sensor.timestamp.hour.toString().padLeft(2, '0')}:${sensor.timestamp.minute.toString().padLeft(2, '0')}:${sensor.timestamp.second.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _connectionTimer?.cancel();
    _offlineCheckTimer?.cancel();
    _webSocketService.dispose();
    _alertController.dispose();
    super.dispose();
  }
}
