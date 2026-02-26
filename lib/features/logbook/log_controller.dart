import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  final ValueNotifier<List<LogModel>> filteredLogs =
      ValueNotifier<List<LogModel>>([]);

  // LOAD
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

    filteredLogs.value = logsNotifier.value;
  }

  // SEARCH
  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogs.value = logsNotifier.value;
    } else {
      filteredLogs.value = logsNotifier.value
          .where((log) =>
              log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // CREATE
  Future<void> addLog(String username, String title,
      String desc, String category) async {
    final newLog = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
    );

    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogs.value = logsNotifier.value;

    await saveToDisk(username);
  }

  // UPDATE
  Future<void> updateLog(String username, int index,
      String title, String desc, String category) async {
    final updatedList = List<LogModel>.from(logsNotifier.value);

    updatedList[index] = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      category: category,
    );

    logsNotifier.value = updatedList;
    filteredLogs.value = logsNotifier.value;

    await saveToDisk(username);
  }

  // DELETE
  Future<void> removeLog(String username, int index) async {
    final updatedList = List<LogModel>.from(logsNotifier.value);
    updatedList.removeAt(index);

    logsNotifier.value = updatedList;
    filteredLogs.value = logsNotifier.value;

    await saveToDisk(username);
  }

  // SAVE
  Future<void> saveToDisk(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final listMap =
        logsNotifier.value.map((log) => log.toMap()).toList();

    final jsonString = jsonEncode(listMap);

    await prefs.setString('user_logs_$username', jsonString);
  }
}