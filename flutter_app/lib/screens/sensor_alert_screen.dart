import 'package:flutter/material.dart';

class SensorAlertScreen extends StatefulWidget {
  const SensorAlertScreen({super.key});

  @override
  State<SensorAlertScreen> createState() => _SensorAlertScreenState();
}

class _SensorAlertScreenState extends State<SensorAlertScreen> {
  final TextEditingController _customAlertController = TextEditingController();
  String _customAlert = '';

  void _submitAlert() {
    setState(() {
      _customAlert = _customAlertController.text.trim();
    });
    _customAlertController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_customAlert.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Custom Alert: $_customAlert',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.orange,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _customAlertController,
              decoration: InputDecoration(
                labelText: 'Enter custom alert for students & staff',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Raise Alert'),
            ),
            const SizedBox(height: 24),
            // You can add your regular sensor list view below
            const Expanded(
              child: Center(child: Text('Sensor data goes here...')),
            ),
          ],
        ),
      ),
    );
  }
}
