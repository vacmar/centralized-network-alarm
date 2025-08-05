import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final TextEditingController _alertController = TextEditingController();

  void _sendCustomAlert() async {
    final text = _alertController.text.trim();
    if (text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('alerts').doc('custom').set({
        'text': text,
        'timestamp': DateTime.now(),
      });
      _alertController.clear();
    }
  }

  Widget _buildSensorCard(String title, String value, bool isDanger) {
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
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 6),
          Text(
            'Status: ${isDanger ? "Danger" : "Normal"}',
            style: TextStyle(
              color: isDanger ? Colors.red : Colors.green,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff Dashboard',
          style: TextStyle(fontFamily: 'monospace'),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Custom Alert Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _alertController,
                    decoration: const InputDecoration(
                      hintText: 'Enter custom alert',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendCustomAlert,
                  child: const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Show Current Custom Alert
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('alerts')
                      .doc('custom')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists)
                  return const SizedBox();
                final data = snapshot.data!;
                final text = data['text'] ?? '';
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Alert: $text',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (timestamp != null)
                        Text(
                          'Sent at: ${timestamp.toLocal()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Dummy Sensor Data for Now
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('sensors')
                        .doc('sensorData')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  bool fire = data['fire'] ?? false;
                  bool smoke = data['smoke'] ?? false;
                  double temp = (data['temperature'] ?? 0).toDouble();
                  double humidity = (data['humidity'] ?? 0).toDouble();

                  return ListView(
                    children: [
                      _buildSensorCard(
                        'Fire Sensor',
                        fire ? 'Flame Detected' : 'No Flame',
                        fire,
                      ),
                      const SizedBox(height: 10),
                      _buildSensorCard(
                        'Smoke Sensor',
                        smoke ? 'Smoke Detected' : 'No Smoke',
                        smoke,
                      ),
                      const SizedBox(height: 10),
                      _buildSensorCard(
                        'Temperature',
                        '${temp.toStringAsFixed(1)} °C',
                        temp > 45,
                      ),
                      const SizedBox(height: 10),
                      _buildSensorCard(
                        'Humidity',
                        '${humidity.toStringAsFixed(1)}%',
                        humidity < 20,
                      ),
                    ],
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
