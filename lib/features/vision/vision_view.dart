import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'vision_controller.dart';
import 'damage_painter.dart';
import 'package:permission_handler/permission_handler.dart';

class VisionView extends StatefulWidget {
  const VisionView({super.key});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView> {
  late VisionController _visionController;

  @override
  void initState() {
    super.initState();
    _visionController = VisionController();
  }

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  Widget _buildVisionStack() {
    final size = MediaQuery.of(context).size;
    final camera = _visionController.controller!;

    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
          width: size.width,
          height: size.height,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.width * camera.value.aspectRatio,
              child: CameraPreview(camera),
            ),
          ),
        ),

        if (_visionController.isOverlayActive)
          Positioned.fill(
            child: CustomPaint(
              painter: DamagePainter(
                mockX: _visionController.mockX,
                mockY: _visionController.mockY,
                label: _visionController.mockLabel,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _visionController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text(
              "Smart-Patrol Vision",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurpleAccent,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  _visionController.isFlashOn
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: _visionController.isFlashOn
                      ? Colors.yellow
                      : Colors.white,
                ),
                onPressed: () => _visionController.toggleFlash(),
              ),
              IconButton(
                icon: Icon(
                  _visionController.isOverlayActive
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () => _visionController.toggleOverlay(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_visionController.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _visionController.errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: const Text("Buka Pengaturan"),
            ),
          ],
        ),
      );
    }

    if (!_visionController.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurpleAccent),
            SizedBox(height: 16),
            Text(
              "Menghubungkan ke Sensor Visual...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return _buildVisionStack();
  }
}
