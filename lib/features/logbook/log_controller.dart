import 'package:flutter/material.dart';
import 'package:hive/hive.dart' as hive;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'models/log_model.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

class LogController {
  final MongoService _mongoService = MongoService();
  final Connectivity _connectivity = Connectivity();

  /// DATA STATE
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  final ValueNotifier<List<LogModel>> filteredLogs =
      ValueNotifier<List<LogModel>>([]);

  /// SEARCH & FILTER STATE
  final ValueNotifier<String> searchQuery = ValueNotifier("");
  final ValueNotifier<String> selectedCategoryFilter =
      ValueNotifier<String>("All");

  /// CONNECTIVITY STATE
  final ValueNotifier<bool> isOnline = ValueNotifier(false);
  final ValueNotifier<bool> isSyncing = ValueNotifier(false);

  final hive.Box<LogModel> _logBox = hive.Hive.box<LogModel>('offline_logs');

  String userId = "";

  LogController() {
    _checkInitialConnection();
    startConnectivityListener();
  }

  void setUser(String username) {
    userId = username;
  }

  /// APPLY FILTER (CORE LOGIC)
  void _applyFilters() {
    final query = searchQuery.value.toLowerCase();

    filteredLogs.value = logsNotifier.value.where((log) {
      final matchesSearch = query.isEmpty ||
          log.title.toLowerCase().contains(query) ||
          log.description.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategoryFilter.value == "All" ||
              log.category == selectedCategoryFilter.value;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// SEARCH
  void searchLog(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// FILTER CATEGORY (CHIPS)
  void filterByCategory(String category) {
    selectedCategoryFilter.value = category;
    _applyFilters();
  }

  /// SYNC PENDING LOGS
  Future<void> _syncPendingLogs() async {
    final logs = _logBox.values.toList();

    if (logs.isEmpty) return;

    isSyncing.value = true;

    for (var log in logs) {
      try {
        await _mongoService.insertLog(log);

        await LogHelper.writeLog(
          "SYNC SUCCESS: Offline log berhasil dikirim ke Cloud",
          level: 2,
        );
      } catch (e) {
        await LogHelper.writeLog(
          "SYNC FAILED: Log masih tersimpan lokal",
          level: 1,
        );
      }
    }

    isSyncing.value = false;
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();

    isOnline.value = result != ConnectivityResult.none;
  }

  /// CONNECTIVITY LISTENER
  void startConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((results) async {
      final isConnected = results.any((r) => r != ConnectivityResult.none);

      isOnline.value = isConnected;

      if (isConnected) {
        await _syncPendingLogs();
      }
    });
  }

  /// LOAD DATA (OFFLINE FIRST)
  Future<void> loadLogs(String teamId) async {
    final localLogs = _logBox.values.toList();

    logsNotifier.value = localLogs;
    _applyFilters();

    try {
      isSyncing.value = true;

      final cloudData = await _mongoService.getLogs(teamId);

      for (var log in cloudData) {
        final exists = _logBox.values.any((local) => local.id == log.id);

        if (!exists) {
          await _logBox.add(log);
        }
      }

      final mergedLogs = _logBox.values.toList();

      logsNotifier.value = mergedLogs;
      _applyFilters();

      await LogHelper.writeLog(
        "SYNC: Data berhasil diperbarui dari Atlas",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "OFFLINE MODE: Menggunakan cache lokal",
        level: 2,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  /// CREATE
  Future<void> addLog(
    String title,
    String desc,
    String type,
    String category,
    String authorId,
    String teamId,
    bool isPublic,
  ) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      type: type,
      category: category,
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic,
    );

    await _logBox.add(newLog);

    logsNotifier.value = [...logsNotifier.value, newLog];
    _applyFilters();

    try {
      isSyncing.value = true;

      await _mongoService.insertLog(newLog);

      await LogHelper.writeLog(
        "SUCCESS: Data tersinkron ke Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog("WARNING: Data hanya tersimpan lokal", level: 1);
    } finally {
      isSyncing.value = false;
    }
  }

  /// UPDATE
  Future<void> updateLog(
    LogModel log,
    String title,
    String desc,
    String type,
    String category,
    bool isPublic,
  ) async {
    final updatedLog = LogModel(
      id: log.id,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      type: type,
      category: category,
      authorId: log.authorId,
      teamId: log.teamId,
      isPublic: isPublic,
    );

    final index = _logBox.values.toList().indexOf(log);

    if (index != -1) {
      await _logBox.putAt(index, updatedLog);
    }

    logsNotifier.value = _logBox.values.toList();
    _applyFilters();

    try {
      isSyncing.value = true;
      await _mongoService.updateLog(updatedLog);
    } catch (_) {} finally {
      isSyncing.value = false;
    }
  }

  /// DELETE
  Future<void> removeLog(LogModel log) async {
    if (log.authorId != userId) {
      debugPrint("SECURITY: Only owner can delete this log");
      return;
    }

    final index = _logBox.values.toList().indexOf(log);

    if (index != -1) {
      await _logBox.deleteAt(index);
    }

    logsNotifier.value = _logBox.values.toList();
    _applyFilters();

    try {
      isSyncing.value = true;

      if (log.id != null && log.id!.isNotEmpty) {
        await _mongoService.deleteLog(ObjectId.fromHexString(log.id!));
      }
    } catch (_) {} finally {
      isSyncing.value = false;
    }
  }
}