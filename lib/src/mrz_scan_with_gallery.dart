import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:mrz_scanner/src/mrz_helper.dart';

class MrzWithGallery {
  final TextRecognizer _textRecognizer = TextRecognizer();
  Future<MRZResult?> pickImage({AndroidUiSettings? androidUiSettings, IOSUiSettings? iosUiSettings}) async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        return _processGalleryImage(File(croppedFile.path));
      }
    }
    return null;
  }

  Future<MRZResult?> _processGalleryImage(File image) async {
    final WriteBuffer allBytes = WriteBuffer();
    allBytes.putUint8List((await image.readAsBytes()));

    final inputImage = InputImage.fromFilePath(image.path);
    return _processImage(inputImage);
  }

  Future<MRZResult?> _processImage(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);

    String fullText = recognizedText.text;
    String trimmedText = fullText.replaceAll(' ', '');
    List allText = trimmedText.split('\n');

    List<String> ableToScanText = [];
    for (var e in allText) {
      if (MRZHelper.testTextLine(e).isNotEmpty) {
        ableToScanText.add(MRZHelper.testTextLine(e));
      }
    }

    List<String>? result = MRZHelper.getFinalListToParse([...ableToScanText]);

    if (result != null) {
      return _parseScannedText(result);
    } else {}
  }

  MRZResult? _parseScannedText(List<String> lines) {
    try {
      final data = MRZParser.parse(lines);
      return data;
    } catch (e) {}
  }
}
