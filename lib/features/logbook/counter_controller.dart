import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<String> _history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history => List.unmodifiable(_history);

  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  // ===============================
  // LOAD DATA SAAT LOGIN
  // ===============================
  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();

    _counter = prefs.getInt("counter_$username") ?? 0;

    final historyString = prefs.getString("history_$username");
    if (historyString != null) {
      final List<dynamic> decoded = jsonDecode(historyString);
      _history.clear();
      _history.addAll(decoded.cast<String>());
    }
  }

  // ===============================
  // SAVE DATA
  // ===============================
  Future<void> _saveData(String username) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("counter_$username", _counter);
    await prefs.setString(
      "history_$username",
      jsonEncode(_history),
    );
  }

  // ===============================
  // ACTIONS
  // ===============================

  Future<void> increment(String username) async {
    _counter += _step;
    _addHistory("User $username menambah +$_step");
    await _saveData(username);
  }

  Future<void> decrement(String username) async {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addHistory("User $username mengurangi -$_step");
    } else {
      _counter = 0;
      _addHistory("User $username mengurangi sampai 0");
    }
    await _saveData(username);
  }

  Future<void> reset(String username) async {
    _counter = 0;
    _addHistory("User $username reset nilai");
    await _saveData(username);
  }

  void _addHistory(String activity) {
    final time =
        "${DateTime.now().hour.toString().padLeft(2, '0')}:"
        "${DateTime.now().minute.toString().padLeft(2, '0')}";

    _history.insert(0, "$activity pada $time");

    if (_history.length > 5) {
      _history.removeLast();
    }
  }
}