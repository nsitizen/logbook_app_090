import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  // LOAD DATA PER USER
  Future<void> loadFromDisk(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('user_logs_$username');

    if (data != null) {
      final List decoded = jsonDecode(data);
      logsNotifier.value =
          decoded.map((e) => LogModel.fromMap(e)).toList();
    } else {
      logsNotifier.value = [];
    }
  }

  // CREATE
  Future<void> addLog(String username, String title, String desc) async {
    final newLog = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toString(),
    );

    logsNotifier.value = [...logsNotifier.value, newLog];
    await saveToDisk(username);
  }

  // UPDATE
  Future<void> updateLog(
      String username, int index, String title, String desc) async {
    final updatedList = List<LogModel>.from(logsNotifier.value);

    updatedList[index] = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toString(),
    );

    logsNotifier.value = updatedList;
    await saveToDisk(username);
  }

  // DELETE
  Future<void> removeLog(String username, int index) async {
    final updatedList = List<LogModel>.from(logsNotifier.value);
    updatedList.removeAt(index);

    logsNotifier.value = updatedList;
    await saveToDisk(username);
  }

  // SAVE PER USER
  Future<void> saveToDisk(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final String encodedData = jsonEncode(
      logsNotifier.value.map((e) => e.toMap()).toList(),
    );

    await prefs.setString('user_logs_$username', encodedData);
  }
}