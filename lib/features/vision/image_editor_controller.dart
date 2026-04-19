import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageEditorController extends ChangeNotifier {
  final String imagePath;

  img.Image? _originalImage;
  Uint8List? displayBytes;
  bool isProcessing = true;

  String activeFilter = 'Original';
  double brightnessValue = 1.0;

  ImageEditorController({required this.imagePath}) {
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      _originalImage = img.decodeImage(bytes);
      if (_originalImage != null) {
        _updateDisplay(_originalImage!);
      }
    } catch (e) {
      debugPrint("Gagal memuat gambar: $e");
      isProcessing = false;
      notifyListeners();
    }
  }

  void _updateDisplay(img.Image image) {
    displayBytes = Uint8List.fromList(img.encodeJpg(image));
    isProcessing = false;
    notifyListeners();
  }

  // Dipanggil saat slider digeser (sebelum dilepas) agar UI merespons tanpa lag
  void updateBrightnessValue(double val) {
    brightnessValue = val;
    notifyListeners();
  }

  // --- ALGORITMA HISTOGRAM EQUALIZATION MANUAL ---
  img.Image _histogramEqualization(img.Image src) {
    img.Image result = src.clone();
    img.Image gray = img.grayscale(src.clone());

    List<int> hist = List.filled(256, 0);
    for (var p in gray) {
      hist[p.r.toInt()]++;
    }

    List<int> cdf = List.filled(256, 0);
    cdf[0] = hist[0];
    for (int i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + hist[i];
    }

    int cdfMin = cdf.firstWhere((x) => x > 0);
    int totalPixels = gray.width * gray.height;
    List<int> map = List.filled(256, 0);

    for (int i = 0; i < 256; i++) {
      map[i] = ((cdf[i] - cdfMin) / (totalPixels - cdfMin) * 255).round().clamp(
        0,
        255,
      );
    }

    final grayIterator = gray.iterator..moveNext();
    for (var p in result) {
      int oldLum = grayIterator.current.r.toInt();
      if (oldLum > 0) {
        int newLum = map[oldLum];
        double ratio = newLum / oldLum;
        p.r = (p.r * ratio).round().clamp(0, 255);
        p.g = (p.g * ratio).round().clamp(0, 255);
        p.b = (p.b * ratio).round().clamp(0, 255);
      }
      grayIterator.moveNext();
    }
    return result;
  }

  // --- ALGORITMA MEDIAN FILTER MANUAL ---
  img.Image _medianFilter(img.Image src) {
    img.Image result = src.clone();
    final w = src.width;
    final h = src.height;

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        List<num> rList = [];
        List<num> gList = [];
        List<num> bList = [];

        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final p = src.getPixel(x + dx, y + dy);
            rList.add(p.r);
            gList.add(p.g);
            bList.add(p.b);
          }
        }

        rList.sort();
        gList.sort();
        bList.sort();
        result.setPixelRgb(x, y, rList[4], gList[4], bList[4]);
      }
    }
    return result;
  }

  // --- FUNGSI PENGOLAHAN CITRA DASAR FLUTTER ---
  Future<void> applyFilter(String filterType) async {
    if (_originalImage == null) return;

    isProcessing = true;
    activeFilter = filterType;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 50));

    img.Image resultImage = _originalImage!.clone();

    try {
      switch (filterType) {
        case 'Inverse':
          img.invert(resultImage);
          break;
        case 'Gaussian':
          resultImage = img.gaussianBlur(resultImage, radius: 5);
          break;
        case 'Mean':
          final meanMatrix = [1, 1, 1, 1, 1, 1, 1, 1, 1];
          resultImage = img.convolution(
            resultImage,
            filter: meanMatrix,
            div: 9,
            offset: 0,
          );
          break;
        case 'Median':
          resultImage = _medianFilter(resultImage);
          break;
        case 'Edge':
          resultImage = img.sobel(resultImage);
          break;
        case 'Sharpening':
          final highPassMatrix = [-1, -1, -1, -1, 9, -1, -1, -1, -1];
          resultImage = img.convolution(
            resultImage,
            filter: highPassMatrix,
            div: 1,
            offset: 0,
          );
          break;
        case 'Hist. Equal':
          resultImage = _histogramEqualization(resultImage);
          break;
        case 'Brightness':
          resultImage = img.adjustColor(
            resultImage,
            gamma: 1 / brightnessValue,
          );
          break;
        case 'Original':
        default:
          brightnessValue = 1.0;
          resultImage = _originalImage!.clone();
          break;
      }
      _updateDisplay(resultImage);
    } catch (e) {
      debugPrint("Error PCD: $e");
      isProcessing = false;
      notifyListeners();
    }
  }

  // Fungsi simpan mengembalikan boolean (true jika sukses)
  Future<bool> saveImage() async {
    if (displayBytes == null) return false;
    try {
      final String newPath = imagePath.replaceAll(
        '.jpg',
        '_pcd_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await File(newPath).writeAsBytes(displayBytes!);
      return true;
    } catch (e) {
      return false;
    }
  }
}
