import 'package:flutter/material.dart';

import 'package:mrz_scanner/mrz_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key, required this.scannerType}) : super(key: key);
  final ScannerType scannerType;
  static MaterialPageRoute<dynamic> page(ScannerType scannerType) {
    return MaterialPageRoute(
      builder: (_) => CameraScreen(
        scannerType: scannerType,
      ),
    );
  }

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String? qrCode = '';
  MRZResult? mrzResult;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MRZScanner(
            scannerType: widget.scannerType,
            onQrCode: (String? result) {
              setState(() {
                qrCode = result;
              });
            },
            onMRZ: (result) async {
              setState(() {
                mrzResult = result;
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              child: Container(
                height: 150,
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qrCode ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Ovog :  ${mrzResult?.surnames ?? ''}\nName :   ${mrzResult?.givenNames ?? ''}\nDate of Birth : ${mrzResult?.birthDate.toString()}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
