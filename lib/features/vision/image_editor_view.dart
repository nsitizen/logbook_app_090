import 'package:flutter/material.dart';
import 'image_editor_controller.dart'; 

class ImageEditorView extends StatefulWidget {
  final String imagePath;
  const ImageEditorView({super.key, required this.imagePath});

  @override
  State<ImageEditorView> createState() => _ImageEditorViewState();
}

class _ImageEditorViewState extends State<ImageEditorView> {
  late ImageEditorController _controller;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller saat halaman dibuka
    _controller = ImageEditorController(imagePath: widget.imagePath);
  }

  @override
  void dispose() {
    // Bersihkan memori controller saat halaman ditutup
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() async {
    bool success = await _controller.saveImage();
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gambar berhasil disimpan!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menyimpan"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder akan mem-build ulang UI HANYA ketika controller memanggil notifyListeners()
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.deepPurple.shade50,
          appBar: AppBar(
            title: const Text(
              "PCD Editor",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.deepPurpleAccent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _handleSave,
                tooltip: "Simpan Gambar",
              ),
            ],
          ),
          body: Column(
            children: [
              // AREA KANVAS GAMBAR
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: _controller.isProcessing || _controller.displayBytes == null
                        ? const CircularProgressIndicator(
                            color: Colors.deepPurpleAccent,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.15),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _controller.displayBytes!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // PANEL BAWAH (KONTROL)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.activeFilter == 'Brightness') ...[
                      Row(
                        children: [
                          Icon(
                            Icons.dark_mode,
                            color: Colors.deepPurple.shade300,
                            size: 20,
                          ),
                          Expanded(
                            child: Slider(
                              value: _controller.brightnessValue,
                              min: 0.1,
                              max: 3.0,
                              activeColor: Colors.deepPurpleAccent,
                              inactiveColor: Colors.deepPurple.shade100,
                              onChanged: (val) {
                                _controller.updateBrightnessValue(val);
                              },
                              onChangeEnd: (val) {
                                _controller.applyFilter('Brightness');
                              },
                            ),
                          ),
                          Icon(
                            Icons.light_mode,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 32,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _controller.brightnessValue.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 140, 115, 207),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Original', Icons.restore),
                          _buildFilterChip('Brightness', Icons.tune),
                          _buildFilterChip('Hist. Equal', Icons.bar_chart),
                          _buildFilterChip('Inverse', Icons.invert_colors),
                          _buildFilterChip('Mean', Icons.blur_linear),
                          _buildFilterChip('Median', Icons.lens_blur),
                          _buildFilterChip('Gaussian', Icons.blur_circular),
                          _buildFilterChip('Edge', Icons.polyline),
                          _buildFilterChip('Sharpening', Icons.grid_4x4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isActive = _controller.activeFilter == label;
    return GestureDetector(
      onTap: () => _controller.applyFilter(label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepPurpleAccent : Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.deepPurpleAccent : Colors.deepPurple.shade100,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.deepPurple.shade700,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}