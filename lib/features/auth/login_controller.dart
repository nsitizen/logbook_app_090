// login_controller.dart
class LoginController {
  // Database sederhana Multiple Users
  final Map<String, String> _users = {
    "admin": "123",
    "siti": "456",
    "user": "789",
  };

  int _failedAttempts = 0;
  final int _maxAttempts = 3;

  int get failedAttempts => _failedAttempts;
  bool get isLocked => _failedAttempts >= _maxAttempts;

  void resetAttempts() {
    _failedAttempts = 0;
  }

  bool login(String username, String password) {
    if (_users.containsKey(username) &&
        _users[username] == password) {
      _failedAttempts = 0;
      return true;
    } else {
      _failedAttempts++;
      return false;
    }
  }
}
