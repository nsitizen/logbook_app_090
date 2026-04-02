import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_090/features/auth/login_controller.dart'; 

void main() {
  group('Module 2 - LoginController Tests', () {
    late LoginController loginController;

    setUp(() {
      // (1) setup (arrange, build)
      loginController = LoginController();
    });

    test('TC01: Login success with valid credentials', () {
      // (2) exercise (act, operate)
      final result = loginController.login('admin', '123');
      
      // (3) verify (assert, check)
      expect(result, true);
      expect(loginController.failedAttempts, 0);
    });

    test('TC02: Login fail and increment failed attempts', () {
      // (2) exercise (act, operate)
      final result = loginController.login('admin', 'salah');
      
      // (3) verify (assert, check)
      expect(result, false);
      expect(loginController.failedAttempts, 1);
    });

    test('TC03: Account should be locked after 3 failed attempts', () {
      // (2) exercise (act, operate)
      // Simulasi 3 kali gagal
      loginController.login('admin', 'x');
      loginController.login('admin', 'y');
      loginController.login('admin', 'z');

      // (3) verify (assert, check)
      expect(loginController.failedAttempts, 3);
      expect(loginController.isLocked, true);
    });
  });
}