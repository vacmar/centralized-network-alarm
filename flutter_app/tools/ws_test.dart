import 'dart:async';
import 'dart:io';

Future<void> main() async {
  final url = 'wss://obsentracore.up.railway.app';
  print('Connecting to: $url');

  try {
    final socket = await WebSocket.connect(url);
    print('Connected. Ready to receive messages...');

    socket.listen((data) {
      print('MSG: $data');
    }, onError: (e) {
      print('Socket error: $e');
    }, onDone: () {
      print('Socket closed.');
    });

    // Keep running for 60 seconds then close
    await Future.delayed(const Duration(seconds: 60));
    await socket.close();
    print('Finished test.');
  } catch (e) {
    print('Could not connect: $e');
  }
}
