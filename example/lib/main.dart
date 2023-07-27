import 'dart:io';
import 'package:example/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrz_scanner/mrz_scanner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: (context) {
          return Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CameraScreen.page(ScannerType.mrz),
                    );
                  },
                  child: const Text("Scan Only MRZ"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CameraScreen.page(ScannerType.qrCode),
                    );
                  },
                  child: const Text("Scan Only QR Code"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CameraScreen.page(ScannerType.both),
                    );
                  },
                  child: const Text("Scan Both"),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
