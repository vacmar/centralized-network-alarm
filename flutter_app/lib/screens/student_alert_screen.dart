import 'package:flutter/material.dart';

class StudentAlertScreen extends StatelessWidget {
  final String customAlert;

  const StudentAlertScreen({super.key, this.customAlert = ''});
  
  @override
  Widget build(BuildContext context) {
    final sensorData = [
      {
        'label': 'Temperature & Humidity',
        'status': 'Normal',
        'value': '28°C / 60%',
      },
      {'label': 'Smoke (MQ-6)', 'status': 'Normal', 'value': 'Safe'},
      {
        'label': 'Flame Sensor',
        'status': 'Danger',
        'value': '🔥 Flame Detected!',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Student View',
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
                itemCount: sensorData.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final sensor = sensorData[index];
                  final isDanger = sensor['status'] == 'Danger';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDanger ? Colors.red.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor['label']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sensor['value']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status: ${sensor['status']}',
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
