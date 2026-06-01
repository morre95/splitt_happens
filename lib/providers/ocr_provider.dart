import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/image_preprocessor.dart';
import '../services/ocr_service.dart';

part 'ocr_provider.g.dart';

/// Provides the shared [OcrService] instance.
@Riverpod(keepAlive: true)
OcrService ocrService(Ref ref) => const OcrService();

/// Provides the shared [ImagePreprocessor] instance.
@Riverpod(keepAlive: true)
ImagePreprocessor imagePreprocessor(Ref ref) => const ImagePreprocessor();

/// Pre-processes [image] and runs on-device OCR, returning the recognised
/// text. Errors surface as [OcrException](../core/exceptions.dart) through the
/// resulting [AsyncValue].
@riverpod
Future<String> ocrText(Ref ref, File image) async {
  final ImagePreprocessor preprocessor = ref.watch(imagePreprocessorProvider);
  final OcrService ocr = ref.watch(ocrServiceProvider);
  final File processed = await preprocessor.preprocess(image);
  return ocr.extractText(processed);
}
