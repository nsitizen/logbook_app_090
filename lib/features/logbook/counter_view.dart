import 'package:flutter/material.dart';
import 'package:logbook_app_090/features/onboarding/onboarding_view.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username;

  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  Color _getHistoryColor(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains("menambah")) {
      return Colors.green;
    } else if (lowerText.contains("mengurangi")) {
      return Colors.red;
    } else if (lowerText.contains("reset")) {
      return Colors.grey;
    }
    return Colors.black;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _controller.loadData(widget.username);
    setState(() {});
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Reset"),
        content: const Text(
          "Apakah kamu yakin ingin mereset nilai counter?\nRiwayat tetap tercatat.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _controller.reset(widget.username);

              setState(() {});
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Counter berhasil di-reset"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 1. Munculkan Dialog Konfirmasi
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text(
                      "Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang.",
                    ),
                    actions: [
                      // Tombol Batal
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context), // Menutup dialog saja
                        child: const Text("Batal"),
                      ),
                      // Tombol Ya, Logout
                      TextButton(
                        onPressed: () {
                          // Menutup dialog
                          Navigator.pop(context);

                          // 2. Navigasi kembali ke Onboarding (Membersihkan Stack)
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingView(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Ya, Keluar",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sapaan
            Text(
              "Selamat Datang, ${widget.username}!",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            const Text("Total Hitungan Anda:"),

            // COUNTER VALUE
            Text(
              '${_controller.value}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),

            const SizedBox(height: 10),

            // STEP INFO
            Text("Step: ${_controller.step}"),

            Slider(
              value: _controller.step.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _controller.step.toString(),
              onChanged: (value) {
                setState(() {
                  _controller.setStep(value.toInt());
                });
              },
            ),

            const SizedBox(height: 10),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'dec',
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await _controller.decrement(widget.username);
                    setState(() {});
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'inc',
                  backgroundColor: Colors.green,
                  onPressed: () async {
                    await _controller.increment(widget.username);
                    setState(() {});
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'reset',
                  backgroundColor: Colors.grey,
                  onPressed: () => _showResetDialog(),
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // HISTORY TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Aktivitas (5 Terakhir)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            // HISTORY LIST
            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  final text = _controller.history[index];

                  return ListTile(
                    leading: Icon(Icons.history, color: _getHistoryColor(text)),
                    title: Text(
                      text,
                      style: TextStyle(color: _getHistoryColor(text)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
