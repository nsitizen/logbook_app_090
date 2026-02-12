import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  Color _getHistoryColor(String text) {
    if (text.contains("Menambah")) {
      return Colors.green;
    } else if (text.contains("Mengurangi")) {
      return Colors.red;
    } else if (text.contains("Reset")) {
      return Colors.grey;
    }
    return Colors.black;
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
            onPressed: () {
              setState(() {
                _controller.reset();
              });
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
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("LogBook Counter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // COUNTER
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),

            const SizedBox(height: 10),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'dec',
                  backgroundColor: Colors.red,
                  onPressed: () => setState(() => _controller.decrement()),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'inc',
                  backgroundColor: Colors.green,
                  onPressed: () => setState(() => _controller.increment()),
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

            // HISTORY
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Aktivitas (5 Terakhir)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      Icons.history,
                      color: _getHistoryColor(_controller.history[index]),
                    ),
                    title: Text(
                      _controller.history[index],
                      style: TextStyle(
                        color: _getHistoryColor(_controller.history[index]),
                      ),
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
