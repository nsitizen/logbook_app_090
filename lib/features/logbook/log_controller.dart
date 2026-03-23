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

  /// =========================
  /// DATA STATE
  /// =========================

  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  final ValueNotifier<List<LogModel>> filteredLogs =
      ValueNotifier<List<LogModel>>([]);

  /// =========================
  /// CONNECTIVITY STATE
  /// =========================

  final ValueNotifier<bool> isOnline = ValueNotifier(false);
  final ValueNotifier<bool> isSyncing = ValueNotifier(false);

  final hive.Box<LogModel> _logBox = hive.Hive.box<LogModel>('offline_logs');

  final String userId = "user_002";

  LogController() {
    startConnectivityListener();
  }

  /// =========================
  /// SYNC PENDING LOGS
  /// =========================

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

  /// =========================
  /// CONNECTIVITY LISTENER
  /// =========================

  void startConnectivityListener() {

    _connectivity.onConnectivityChanged.listen((result) async {

      if (result != ConnectivityResult.none) {

        isOnline.value = true;

        await _syncPendingLogs();

      } else {

        isOnline.value = false;

      }

    });

  }

  /// =========================
  /// LOAD DATA (OFFLINE FIRST)
  /// =========================

  Future<void> loadLogs(String teamId) async {

    /// LOAD LOCAL CACHE
    final localLogs = _logBox.values.toList();

    logsNotifier.value = localLogs;
    filteredLogs.value = localLogs;

    try {

      isSyncing.value = true;

      final cloudData = await _mongoService.getLogs(teamId);

      /// MERGE CLOUD DATA
      for (var log in cloudData) {

        final exists = _logBox.values.any((local) => local.id == log.id);

        if (!exists) {
          await _logBox.add(log);
        }
      }

      final mergedLogs = _logBox.values.toList();

      logsNotifier.value = mergedLogs;
      filteredLogs.value = mergedLogs;

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

  /// =========================
  /// SEARCH
  /// =========================

  void searchLog(String query) {

    if (query.isEmpty) {

      filteredLogs.value = logsNotifier.value;

    } else {

      final lowerQuery = query.toLowerCase();

      filteredLogs.value = logsNotifier.value
          .where((log) =>
              log.title.toLowerCase().contains(lowerQuery) ||
              log.description.toLowerCase().contains(lowerQuery))
          .toList();
    }
  }

  /// =========================
  /// CREATE
  /// =========================

  Future<void> addLog(
      String title,
      String desc,
      String category,
      String authorId,
      String teamId,
      bool isPublic) async {

    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      category: category,
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic,
    );

    /// SIMPAN KE HIVE
    await _logBox.add(newLog);

    logsNotifier.value = [
      ...logsNotifier.value,
      newLog,
    ];

    filteredLogs.value = logsNotifier.value;

    /// SYNC CLOUD
    try {

      isSyncing.value = true;

      await _mongoService.insertLog(newLog);

      await LogHelper.writeLog(
        "SUCCESS: Data tersinkron ke Cloud",
        source: "log_controller.dart",
      );

    } catch (e) {

      await LogHelper.writeLog(
        "WARNING: Data hanya tersimpan lokal",
        level: 1,
      );

    } finally {

      isSyncing.value = false;

    }
  }

  /// =========================
  /// UPDATE
  /// =========================

  Future<void> updateLog(
      LogModel log,
      String title,
      String desc,
      String category,
      bool isPublic) async {

    final updatedLog = LogModel(
      id: log.id,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
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
    filteredLogs.value = logsNotifier.value;

    try {

      isSyncing.value = true;

      await _mongoService.updateLog(updatedLog);

    } catch (_) {} finally {

      isSyncing.value = false;

    }
  }

  /// =========================
  /// DELETE (OWNER ONLY)
  /// =========================

  Future<void> removeLog(LogModel log) async {

    /// OWNER ONLY SECURITY
    if (log.authorId != userId) {

      debugPrint("SECURITY: Only owner can delete this log");
      return;

    }

    final index = _logBox.values.toList().indexOf(log);

    if (index != -1) {
      await _logBox.deleteAt(index);
    }

    logsNotifier.value = _logBox.values.toList();
    filteredLogs.value = logsNotifier.value;

    try {

      isSyncing.value = true;

      if (log.id != null) {
        await _mongoService.deleteLog(
            ObjectId.fromHexString(log.id!));
      }

    } catch (_) {} finally {

      isSyncing.value = false;

    }
  }
}