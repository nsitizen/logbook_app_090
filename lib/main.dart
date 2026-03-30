import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/mongo_service.dart';
import 'package:logbook_app_090/features/onboarding/onboarding_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/logbook/models/log_model.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(LogModelAdapter());
  await Hive.openBox<LogModel>('offline_logs');

  await MongoService().connect();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogBook Counter',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurpleAccent,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      home: const OnboardingView(),
    );
  }
}
