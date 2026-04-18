import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../main.dart';

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;

  Timer? mockTimer;
  double mockX = 0.5; 
  double mockY = 0.5; 
  final Random _random = Random();

  bool isFlashOn = false;
  bool isOverlayActive = true;
  String mockLabel = "D40"; 

  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      if (cameras.isEmpty) {
        errorMessage = "No camera detected on device.";
        notifyListeners();
        return;
      }

      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
      isInitialized = true;
      errorMessage = null;
      startMockDetection();
    } catch (e) {
      errorMessage = "Failed to initialize camera: $e";
    }
    notifyListeners();
  }

  void startMockDetection() {
    mockTimer?.cancel();
    mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      mockX = 0.2 + _random.nextDouble() * 0.6;
      mockY = 0.2 + _random.nextDouble() * 0.6;
      mockLabel = _random.nextBool() ? "D40" : "D00"; 
      notifyListeners(); 
    });
  }

  Future<void> toggleFlash() async {
    if (controller == null || !controller!.value.isInitialized) return;
    
    isFlashOn = !isFlashOn;
    await controller!.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
    notifyListeners();
  }

  void toggleOverlay() {
    isOverlayActive = !isOverlayActive;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      mockTimer?.cancel();
      cameraController.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    mockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }
}
