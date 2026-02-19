import 'package:flutter/material.dart';
import 'package:logbook_app_090/features/auth/login_controller.dart';
import 'package:logbook_app_090/features/logbook/counter_view.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;
  bool _isButtonDisabled = false;
  int _secondsRemaining = 10;
  // Inisialisasi Otak dan Controller Input
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _handleLogin() {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    // VALIDASI FIELD KOSONG
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
        ),
      );
      return;
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      if (_controller.isLocked) {
        _startLockTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terlalu banyak percobaan! Tunggu 10 detik."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login gagal! Sisa percobaan: ${3 - _controller.failedAttempts}",),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
    }
  }

  void _startLockTimer() {
    setState(() {
      _isButtonDisabled = true;
      _secondsRemaining = 10;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() {
          _isButtonDisabled = false;
          _controller.resetAttempts();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 231, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Login",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),

                const SizedBox(height: 20),

                Image.asset(
                  "assets/images/login2.jpeg",
                  height: 200,
                ),

                const SizedBox(height: 30),

                // USERNAME FIELD
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD FIELD
                TextField(
                  controller: _passController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // BUTTON LOGIN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isButtonDisabled ? null : _handleLogin,
                    child: _isButtonDisabled
                      ? Text(
                          "Tunggu $_secondsRemaining detik",
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 243, 231, 255), 
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          "Masuk",
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 243, 231, 255), 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
