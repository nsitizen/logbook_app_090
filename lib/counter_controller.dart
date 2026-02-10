class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<String> _history = []; // riwayat aktivitas

  int get value => _counter;
  int get step => _step;
  List<String> get history => List.unmodifiable(_history);

  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  void increment() {
    _counter += _step;
    _addHistory("Menambah $_step");
  }

  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addHistory("Mengurangi $_step");
    } else {
      _counter = 0;
      _addHistory("Mengurangi sampai 0");
    }
  }

  void reset() {
    _counter = 0;
    _addHistory("Reset nilai");
  }

  // private helper (manipulasi list)
  void _addHistory(String activity) {
    final time =
        "${DateTime.now().hour.toString().padLeft(2, '0')}:"
        "${DateTime.now().minute.toString().padLeft(2, '0')}";

    _history.insert(0, "$activity pada $time");

    // hanya simpan 5 terakhir
    if (_history.length > 5) {
      _history.removeLast();
    }
  }
}
