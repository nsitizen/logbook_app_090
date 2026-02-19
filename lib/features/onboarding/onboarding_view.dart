import 'package:flutter/material.dart';
import 'package:logbook_app_090/features/auth/login_view.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/welcome.jpeg",
      "text": "Catat setiap aktivitas hitunganmu dengan mudah.",
    },
    {
      "image": "assets/images/statistik.jpeg",
      "text": "Lihat riwayat aktivitas dengan tampilan yang rapi.",
    },
    {
      "image": "assets/images/login1.jpeg",
      "text": "Login dan mulai gunakan LogBook Counter sekarang!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 231, 255),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (index == 0)
                      Text(
                        "LogBook Counter",
                        style: GoogleFonts.poppins(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Image.asset(_pages[index]["image"]!, height: 250),
                      const SizedBox(height: 30),
                      Text(
                        _pages[index]["text"]!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // PAGE INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: _currentPage == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.deepPurpleAccent
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              if (_currentPage == _pages.length - 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text(
              _currentPage == _pages.length - 1 ? "Mulai" : "Next",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
