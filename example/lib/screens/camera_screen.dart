import 'package:flutter/material.dart';
import 'package:mrz_scanner/mrz_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final MRZController controller = MRZController();

  @override
  Widget build(BuildContext context) {
    return MRZScanner(
      controller: controller,
      onSuccess: (mrzResult) async {
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.currentState?.resetScanning();
                    },
                    child: const Text('Reset Scanning'),
                  ),
                  Text('Ovog : ${mrzResult.surnames}'),
                  Text('Name : ${mrzResult.givenNames}'),
                  Text('Gender : ${mrzResult.sex.name}'),
                  Text('CountryCode : ${mrzResult.countryCode}'),
                  Text('Date of Birth : ${mrzResult.birthDate}'),
                  Text('Expiry Date : ${mrzResult.expiryDate}'),
                  Text('DocNum : ${mrzResult.documentNumber}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
