import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_scanner/mrz_scanner.dart';
import 'camera_view.dart';
import 'mrz_helper.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

enum ScannerType { mrz, qrCode, both }

class MRZScanner extends StatefulWidget {
  const MRZScanner({
    Key? controller,
    this.onMRZ,
    this.onQrCode,
    this.initialDirection = SensorPosition.back,
    required this.scannerType,
    this.layoutBuilder,
  }) : super(key: controller);

  final Function(MRZResult mrzResult)? onMRZ;

  final Function(String? result)? onQrCode;

  final ScannerType scannerType;

  final SensorPosition initialDirection;
  final CameraLayoutBuilder? layoutBuilder;

  @override
  MRZScannerState createState() => MRZScannerState();
}

class MRZScannerState extends State<MRZScanner> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MRZCameraView(
      initialDirection: widget.initialDirection,
      onImage: _processImage,
      layoutBuilder: widget.layoutBuilder,
    );
  }

  bool _parseScannedText(List<String> lines) {
    try {
      final data = MRZParser.parse(lines);
      _isBusy = true;
      widget.onMRZ?.call(data);
      _isBusy = false;
      return true;
    } catch (e) {
      _isBusy = false;
      return false;
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    RecognizedText? recognizedText;
    List<Barcode> barcode = [];

    final scannerType = widget.scannerType;
    if (scannerType == ScannerType.mrz || scannerType == ScannerType.both) {
      recognizedText = await _textRecognizer.processImage(inputImage);
    }
    if (scannerType == ScannerType.qrCode || scannerType == ScannerType.both) {
      barcode = await barcodeScanner.processImage(inputImage);
    }
    List<String>? result;
    List<String>? resultReversed;

    if (recognizedText != null) {
      String fullText = recognizedText.text;
      String trimmedText = fullText.replaceAll(' ', '');
      List allText = trimmedText.split('\n');

      List<String> ableToScanText = [];
      for (var e in allText) {
        if (MRZHelper.testTextLine(e).isNotEmpty) {
          ableToScanText.add(MRZHelper.testTextLine(e));
        }
      }
      result = MRZHelper.getFinalListToParse([...ableToScanText]);
      resultReversed =
          MRZHelper.getFinalListToParse([...ableToScanText.reversed]);
    }

    if (result != null) {
      final firstTry = _parseScannedText([...result]);
      if (!firstTry && resultReversed != null) {
        _parseScannedText([...resultReversed]);
      }
    } else if (barcode.isNotEmpty) {
      widget.onQrCode?.call(barcode.first.rawValue);
    }
    _isBusy = false;
  }
}
