import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/mongo_service.dart';
import 'package:logbook_app_090/features/onboarding/onboarding_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/logbook/models/log_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  /// INIT HIVE
  await Hive.initFlutter();

  /// REGISTER ADAPTER
  Hive.registerAdapter(LogModelAdapter());

  /// OPEN BOX
  await Hive.openBox<LogModel>('offline_logs');

  /// CONNECT DATABASE
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
      ),
      home: const OnboardingView(),
    );
  }
}