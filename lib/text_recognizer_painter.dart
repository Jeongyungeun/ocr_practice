import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(
    this.recognizedText,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final RecognizedText recognizedText;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.red;

    final Paint background = Paint()..color = Colors.black;
    for (final textBlock in recognizedText.blocks) {
      final builder = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 12,
        textDirection: TextDirection.ltr,
      ));
      builder
          .pushStyle(ui.TextStyle(color: Colors.white, background: background));
      builder.addText(textBlock.text);
      builder.pop();
      final left = translateX(textBlock.boundingBox.left, canvasSize, imageSize,
          rotation, cameraLensDirection);
      final top = translateY(textBlock.boundingBox.top, canvasSize, imageSize,
          rotation, cameraLensDirection);
      final right = translateX(textBlock.boundingBox.right, canvasSize,
          imageSize, rotation, cameraLensDirection);

      final List<Offset> cornerPoints = [];
      for (final point in textBlock.cornerPoints) {
        double x = translateX(point.x.toDouble(), canvasSize, imageSize,
            rotation, cameraLensDirection);
        double y = translateY(point.y.toDouble(), canvasSize, imageSize,
            rotation, cameraLensDirection);

        if (Platform.isAndroid) {
          switch (cameraLensDirection) {
            case CameraLensDirection.back:
              switch (rotation) {
                case InputImageRotation.rotation90deg:
                  x = canvasSize.width -
                      translateX(point.y.toDouble(), canvasSize, imageSize,
                          rotation, cameraLensDirection);
                  y = canvasSize.width -
                      translateY(point.x.toDouble(), canvasSize, imageSize,
                          rotation, cameraLensDirection);
                case InputImageRotation.rotation0deg:
                case InputImageRotation.rotation180deg:
                case InputImageRotation.rotation270deg:
              }
            case CameraLensDirection.front:
              break;
            case CameraLensDirection.external:
              break;
          }
        }
        cornerPoints.add(Offset(x, y));
      }

      cornerPoints.add(cornerPoints.first);
      canvas.drawPoints(PointMode.polygon, cornerPoints, paint);
      canvas.drawParagraph(
          builder.build()
            ..layout(ParagraphConstraints(width: (right - left).abs())),
          Offset(left, top));
    }
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}




double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      return canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return x * canvasSize.width / imageSize.width;
        default:
          return canvasSize.width - x * canvasSize.width / imageSize.width;
      }
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return y * canvasSize.height / imageSize.height;
  }
}
