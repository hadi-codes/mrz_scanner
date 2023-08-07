import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class MRZCameraView extends StatefulWidget {
  const MRZCameraView({
    Key? key,
    required this.onImage,
    this.initialDirection = SensorPosition.back,
    this.layoutBuilder,
  }) : super(key: key);

  final Function(InputImage inputImage) onImage;
  final SensorPosition initialDirection;
  final CameraLayoutBuilder? layoutBuilder;

  @override
  _MRZCameraViewState createState() => _MRZCameraViewState();
}

class _MRZCameraViewState extends State<MRZCameraView> {
  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.previewOnly(
      previewFit: CameraPreviewFit.fitWidth,
      onImageForAnalysis: analyzeImage,
      builder: (state, previewSize, previewRect) =>
          widget.layoutBuilder?.call(state, previewSize, previewRect) ??
          const SizedBox.shrink(),
      sensorConfig: SensorConfig.single(
        sensor: Sensor.position(
          widget.initialDirection,
        ),
        aspectRatio: CameraAspectRatios.ratio_1_1,
      ),
      imageAnalysisConfig: AnalysisConfig(
        // Android specific options
        androidOptions: const AndroidAnalysisOptions.nv21(
          // Target width (CameraX will chose the closest resolution to this width)
          width: 1024,
        ),
        // Wether to start automatically the analysis (true by default)
        autoStart: true,
        // Max frames per second, null for no limit (default)
        // maxFramesPerSecond: 15,
      ),
    );
  }

  Future analyzeImage(AnalysisImage img) async {
    final imageInupt = img.toInputImage();
    widget.onImage(imageInupt);
  }
}

extension MLKitUtils on AnalysisImage {
  InputImage toInputImage() {
    return when(
      nv21: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            rotation: inputImageRotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes.first.bytesPerRow,
            size: image.size,
          ),
        );
      },
      bgra8888: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            rotation: inputImageRotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes.first.bytesPerRow,
            size: image.size,
          ),
        );
      },
    )!;
  }

  InputImageRotation get inputImageRotation =>
      InputImageRotation.values.byName(rotation.name);

  InputImageFormat get inputImageFormat {
    switch (format) {
      case InputAnalysisImageFormat.bgra8888:
        return InputImageFormat.bgra8888;
      case InputAnalysisImageFormat.nv21:
        return InputImageFormat.nv21;
      default:
        return InputImageFormat.yuv420;
    }
  }
}
