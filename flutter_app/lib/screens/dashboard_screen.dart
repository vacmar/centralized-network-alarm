import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../utils/alert_sound_player.dart';

class DashboardScreen extends StatelessWidget {
  final String customAlert;
  final List<SensorData> sensorDataList;

  const DashboardScreen({
    super.key,
    this.customAlert = '',
    required this.sensorDataList,
  });

  @override
  Widget build(BuildContext context) {
    final alertPlayer = AlertSoundPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasDanger = sensorDataList.any(
        (sensor) => sensor.status == 'Danger',
      );
      if (hasDanger) {
        alertPlayer.playAlertSound();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontFamily: 'monospace', color: Colors.white),
        ),
      ),
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (customAlert.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Alert: $customAlert',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.orange,
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: sensorDataList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final sensor = sensorDataList[index];
                  final isDanger = sensor.status == 'Danger';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isDanger
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.sensor,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sensor.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status: ${sensor.status}',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            color: isDanger ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
