import 'package:flutter/material.dart';
import 'package:logbook_app_090/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  void _nextStep() {
    setState(() {
      step++;
    });

    if (step > 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  String _getContent() {
    switch (step) {
      case 1:
        return "Selamat datang di LogBook Counter!\nAplikasi untuk mencatat aktivitas hitunganmu.";
      case 2:
        return "Kamu bisa menambah, mengurangi,\ndan melihat riwayat aktivitas.";
      case 3:
        return "Yuk mulai dengan login\nuntuk menggunakan aplikasi!";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Onboarding"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center( // <-- Tambahan supaya fix di tengah layar
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Tengah vertikal
            crossAxisAlignment: CrossAxisAlignment.center, // Tengah horizontal
            mainAxisSize: MainAxisSize.min, // Supaya tidak full tinggi
            children: [
              Text(
                "Step $step / 3",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                _getContent(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _nextStep,
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
