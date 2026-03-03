import 'package:flutter/material.dart';
import 'models/log_model.dart';
import '../../services/mongo_service.dart';

class LogController {
  final MongoService _mongoService = MongoService();

  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  final ValueNotifier<List<LogModel>> filteredLogs =
      ValueNotifier<List<LogModel>>([]);

  /// LOAD FROM MONGODB
  Future<void> loadFromCloud() async {
    final logs = await _mongoService.getLogs();
    logsNotifier.value = logs;
    filteredLogs.value = logs;
  }

  /// SEARCH
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

  /// CREATE
  Future<void> addLog(
      String title, String desc, String category) async {
    final newLog = LogModel(
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      category: category,
    );

    await _mongoService.insertLog(newLog);

    await loadFromCloud();
  }

  /// UPDATE
  Future<void> updateLog(
      LogModel log, String title, String desc, String category) async {
    final updatedLog = LogModel(
      id: log.id,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      category: category,
    );

    await _mongoService.updateLog(updatedLog);

    await loadFromCloud();
  }

  /// DELETE
  Future<void> removeLog(LogModel log) async {
    if (log.id != null) {
      await _mongoService.deleteLog(log.id!);
      await loadFromCloud();
    }
  }
}