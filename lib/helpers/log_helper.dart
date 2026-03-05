import 'dart:developer' as dev;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    try {
      final now = DateTime.now();

      /// Ambil konfigurasi dari .env
      final int configLevel =
          int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;

      final String muteList = dotenv.env['LOG_MUTE'] ?? '';

      /// SOURCE FILTER
      final mutedSources =
          muteList.split(',').map((e) => e.trim()).toList();

      if (mutedSources.contains(source)) return;

      /// FORMAT TIME
      String consoleTime = DateFormat('HH:mm:ss').format(now);
      String fileTime = DateFormat('HH:mm:ss').format(now);
      String fileDate = DateFormat('dd-MM-yyyy').format(now);

      String label = _getLabel(level);
      String color = _getColor(level);

      /// DEBUG CONSOLE (DevTools)
      dev.log(
        message,
        name: source,
        time: now,
        level: level * 100,
      );

      /// VERBOSITY CONTROL
      /// log ke terminal hanya jika level <= LOG_LEVEL
      if (level <= configLevel) {
        print(
          '$color[$consoleTime][$label][$source] -> $message\x1B[0m',
        );
      }

      /// FILE LOGGING (Audit Trail)
      final directory = Directory("logs");

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File("logs/$fileDate.log");

      final logLine =
          "[$fileTime][$label][$source] -> $message\n";

      await file.writeAsString(
        logLine,
        mode: FileMode.append,
      );
    } catch (e) {
      dev.log(
        "Logging failed: $e",
        name: "SYSTEM",
        level: 1000,
      );
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m'; // merah
      case 2:
        return '\x1B[32m'; // hijau
      case 3:
        return '\x1B[34m'; // biru
      default:
        return '\x1B[0m';
    }
  }
}
