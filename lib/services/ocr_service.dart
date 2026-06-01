import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../core/exceptions.dart';

/// Wraps Google ML Kit's on-device text recognition.
class OcrService {
  /// Creates an [OcrService].
  const OcrService();

  /// Runs on-device OCR over [imageFile] and returns the full recognised text,
  /// with newlines preserved between blocks.
  ///
  /// Throws [OcrException] if recognition fails.
  Future<String> extractText(File imageFile) async {
    final TextRecognizer recognizer =
        TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognized =
          await recognizer.processImage(inputImage);
      return recognized.blocks
          .map((TextBlock block) => block.text)
          .join('\n');
    } catch (error) {
      throw OcrException('On-device text recognition failed.', error);
    } finally {
      await recognizer.close();
    }
  }
}
