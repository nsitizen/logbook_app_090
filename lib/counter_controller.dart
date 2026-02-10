class CounterController {
  int _counter = 0;
  int _step = 1; // default step

  int get value => _counter;
  int get step => _step;

  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  void increment() {
    _counter += _step;
  }

  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
    } else {
      _counter = 0;
    }
  }

  void reset() {
    _counter = 0;
  }
}
