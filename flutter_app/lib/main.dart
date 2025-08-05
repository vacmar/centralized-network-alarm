import 'package:flutter/material.dart';
import 'models/sensor_data.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centralized Alarm System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const HomeWrapper(),
    );
  }
}

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Mocked data for now
    final List<SensorData> data = [
      SensorData(
        sensor: 'Temperature & Humidity',
        value: '28°C / 60%',
        status: 'Normal',
      ),
      SensorData(sensor: 'Smoke (MQ-6)', value: 'Safe', status: 'Normal'),
      SensorData(
        sensor: 'Flame Sensor',
        value: '🔥 Flame Detected!',
        status: 'Danger',
      ),
    ];

    return DashboardScreen(
      customAlert: 'Evacuate Immediately!',
      sensorDataList: data,
    );
  }
}
