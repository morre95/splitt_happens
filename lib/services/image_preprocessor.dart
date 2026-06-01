import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/exceptions.dart';

/// Pre-processes receipt photographs to improve on-device OCR accuracy,
/// which matters most for low-contrast thermal receipt paper.
class ImagePreprocessor {
  /// Creates an [ImagePreprocessor].
  const ImagePreprocessor();

  /// Luminance threshold (0–255) above which a pixel is considered "content"
  /// when auto-cropping to the receipt's bounding box.
  static const int _contentLuminanceThreshold = 110;

  /// Decodes [source], auto-crops it to the largest high-contrast region,
  /// boosts contrast, converts to grayscale, and re-encodes as a JPEG written
  /// to a temporary file.
  ///
  /// Returns the new [File]. Throws [OcrException] if the image cannot be
  /// decoded or processed.
  Future<File> preprocess(File source) async {
    try {
      final Uint8List bytes = await source.readAsBytes();
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const OcrException('Could not decode the selected image.');
      }

      final img.Image cropped = _autoCrop(decoded);
      final img.Image contrasted =
          img.adjustColor(cropped, contrast: 1.3);
      final img.Image grayscale = img.grayscale(contrasted);

      final Uint8List encoded = img.encodeJpg(grayscale, quality: 90);

      final Directory tempDir = await getTemporaryDirectory();
      final String path = p.join(
        tempDir.path,
        'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final File output = File(path);
      await output.writeAsBytes(encoded);
      return output;
    } on OcrException {
      rethrow;
    } catch (error) {
      throw OcrException('Failed to pre-process the receipt image.', error);
    }
  }

  /// Finds the largest high-contrast rectangle by computing, for each row and
  /// column, whether it contains content brighter than the luminance
  /// threshold, then crops to the bounding box of all content rows/columns.
  img.Image _autoCrop(img.Image image) {
    int top = image.height;
    int bottom = 0;
    int left = image.width;
    int right = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final img.Pixel pixel = image.getPixel(x, y);
        final num luminance = img.getLuminance(pixel);
        if (luminance > _contentLuminanceThreshold) {
          if (y < top) top = y;
          if (y > bottom) bottom = y;
          if (x < left) left = x;
          if (x > right) right = x;
        }
      }
    }

    // No content detected — return the image unchanged.
    if (right <= left || bottom <= top) {
      return image;
    }

    return img.copyCrop(
      image,
      x: left,
      y: top,
      width: right - left,
      height: bottom - top,
    );
  }
}
