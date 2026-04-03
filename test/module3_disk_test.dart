import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_090/testing_controllers/log_controller_modul3.dart';

void main() {
  group('Module 3 - LogController Disk Persistence Tests', () {
    late LogController controller;

    setUp(() {
      // (1) setup (arrange, build)
      SharedPreferences.setMockInitialValues({});
      controller = LogController();
    });

    test('TC01: addLog should persist data correctly', () async {
      // (2) exercise (act, operate)
      await controller.addLog('user1', 'Tugas Akhir', 'Menyelesaikan modul 6', 'Kuliah');

      // (3) verify (assert, check)
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('user_logs_user1');
      
      expect(savedData, isNotNull);
      expect(controller.logsNotifier.value.length, 1);
    });

    test('TC02: loadFromDisk should retrieve saved logs', () async {
      // (1) setup data manual di prefs
      final prefs = await SharedPreferences.getInstance();
      final data = [{'title': 'Old Log', 'description': 'Old Desc', 'date': '2026', 'category': 'General'}];
      await prefs.setString('user_logs_user1', jsonEncode(data));

      // (2) exercise
      await controller.loadFromDisk('user1');

      // (3) verify
      expect(controller.logsNotifier.value.first.title, 'Old Log');
    });

    test('TC03: removeLog should update disk storage', () async {
      // (1) setup
      await controller.addLog('user1', 'Log to Delete', 'Desc', 'Cat');
      
      // (2) exercise
      await controller.removeLog('user1', 0);

      // (3) verify
      final prefs = await SharedPreferences.getInstance();
      final savedData = jsonDecode(prefs.getString('user_logs_user1')!);
      expect(savedData.length, 0);
    });
  });
}