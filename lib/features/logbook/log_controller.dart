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
    final String? jsonString =
        prefs.getString('user_logs_$username');

    if (jsonString != null) {
      final List decodedList = jsonDecode(jsonString);

      logsNotifier.value =
          decodedList.map((e) => LogModel.fromMap(e)).toList();
    } else {
      logsNotifier.value = [];
    }
  }

  // CREATE
  Future<void> addLog(
      String username, String title, String desc) async {
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

  // SERIALIZATION + SAVE
  Future<void> saveToDisk(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final listMap =
        logsNotifier.value.map((log) => log.toMap()).toList();

    final jsonString = jsonEncode(listMap);

    await prefs.setString('user_logs_$username', jsonString);
  }
}