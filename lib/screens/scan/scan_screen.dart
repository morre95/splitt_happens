import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app.dart';
import '../../models/bill.dart';
import '../../providers/bill_provider.dart';
import 'image_review_widget.dart';

/// Camera screen: capture (or pick) a receipt photo, confirm it, then run the
/// OCR + LLM parse pipeline behind a loading overlay.
class ScanScreen extends ConsumerStatefulWidget {
  /// Creates a [ScanScreen].
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  File? _captured;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final CameraDescription camera = cameras.firstWhere(
        (CameraDescription c) =>
            c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final CameraController controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException {
      // Falls back to the gallery picker; no camera available.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final XFile shot = await controller.takePicture();
    if (!mounted) return;
    setState(() => _captured = File(shot.path));
  }

  Future<void> _pickFromGallery() async {
    final XFile? picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => _captured = File(picked.path));
  }

  Future<void> _process() async {
    final File? image = _captured;
    if (image == null) return;
    setState(() => _processing = true);

    await ref.read(billControllerProvider.notifier).startScan(image);
    if (!mounted) return;

    final AsyncValue<Bill> result = ref.read(billControllerProvider);
    setState(() => _processing = false);

    result.when(
      data: (_) => context.go(Routes.review),
      loading: () {},
      error: (Object error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_messageFor(error)),
            action: SnackBarAction(label: 'Retry', onPressed: _process),
            duration: const Duration(seconds: 6),
          ),
        );
      },
    );
  }

  String _messageFor(Object error) {
    final String text = error.toString();
    return text.length > 140 ? '${text.substring(0, 140)}…' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scan receipt'),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          if (_captured != null)
            ImageReviewWidget(
              imageFile: _captured!,
              onConfirm: _process,
              onRetake: () => setState(() => _captured = null),
            )
          else
            _buildCameraView(),
          if (_processing) const _ReadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        final CameraController? controller = _controller;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: <Widget>[
            Expanded(
              child: controller != null && controller.value.isInitialized
                  ? CameraPreview(controller)
                  : const _NoCameraPlaceholder(),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      iconSize: 36,
                      color: Colors.white,
                      icon: const Icon(Icons.photo_library),
                      tooltip: 'Pick from gallery',
                      onPressed: _pickFromGallery,
                    ),
                    _CaptureButton(
                      enabled: controller != null &&
                          controller.value.isInitialized,
                      onTap: _capture,
                    ),
                    const SizedBox(width: 52),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? Colors.white : Colors.white24,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: const Icon(Icons.camera_alt, color: Colors.black),
      ),
    );
  }
}

class _NoCameraPlaceholder extends StatelessWidget {
  const _NoCameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.no_photography, color: Colors.white54, size: 48),
          SizedBox(height: 12),
          Text(
            'No camera available.\nPick a photo from the gallery instead.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ReadingOverlay extends StatelessWidget {
  const _ReadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Reading receipt…',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
