import 'dart:io';

import 'package:flutter/material.dart';

/// Full-screen preview of a captured receipt with confirm / retake actions.
class ImageReviewWidget extends StatelessWidget {
  /// Creates an [ImageReviewWidget] for [imageFile].
  const ImageReviewWidget({
    required this.imageFile,
    required this.onConfirm,
    required this.onRetake,
    super.key,
  });

  /// The captured image to preview.
  final File imageFile;

  /// Called when the user accepts the image.
  final VoidCallback onConfirm;

  /// Called when the user wants to retake.
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.black,
            width: double.infinity,
            child: Image.file(imageFile, fit: BoxFit.contain),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetake,
                    icon: const Icon(Icons.replay),
                    label: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Looks good'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
