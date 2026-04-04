import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logbook_app_090/features/logbook/log_controller.dart';
import 'package:logbook_app_090/services/mongo_service.dart';
import 'package:logbook_app_090/features/logbook/models/log_model.dart';

// 1. MOCK CLASSES
class MockMongoService extends Mock implements MongoService {}
class MockLogBox extends Mock implements Box<LogModel> {}
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  // Wajib ditambahkan agar Flutter Framework inisialisasi binding untuk test
  TestWidgetsFlutterBinding.ensureInitialized(); 

  late LogController logController;
  late MockMongoService mockMongoService;
  late MockLogBox mockLogBox;
  late MockConnectivity mockConnectivity; // Deklarasikan mock

  setUpAll(() {
    registerFallbackValue(LogModel(
      id: 'dummy_id',
      title: 'dummy',
      description: 'dummy',
      date: '2026-04-04T00:00:00.000Z',
      type: 'Task',
      category: 'General',
      authorId: 'u1',
      teamId: 't1',
      isPublic: false,
    ));
  });

  setUp(() {
    mockMongoService = MockMongoService();
    mockLogBox = MockLogBox();
    mockConnectivity = MockConnectivity(); 

    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]); 
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value([ConnectivityResult.wifi])); 

    // Inject semua mock ke dalam controller
    logController = LogController(
      mongoService: mockMongoService, 
      logBox: mockLogBox,
      connectivity: mockConnectivity, 
    );

    // Arrange default mock responses untuk Hive Box
    when(() => mockLogBox.values).thenReturn([]);
    when(() => mockLogBox.add(any())).thenAnswer((_) async => 1);
  });

  group('Modul 4: Save Data to Cloud Service Test', () {

    test('TC01: addLog should insert data to local and sync to cloud successfully', () async {
      // 1. SETUP (Arrange)
      // Mensimulasikan insertLog di MongoDB berjalan sukses tanpa melempar error
      when(() => mockMongoService.insertLog(any())).thenAnswer((_) async => {});

      // 2. EXERCISE (Act)
      await logController.addLog(
        'Test Cloud', 'Sync Sukses', 'Task', 'Frontend', 'u1', 't1', true
      );

      // 3. VERIFY (Assert)
      // Memastikan state lokal bertambah
      expect(logController.logsNotifier.value.isNotEmpty, true);
      expect(logController.logsNotifier.value.last.title, 'Test Cloud');
      
      // Memastikan fungsi insertLog (Save to Cloud) benar-benar dipanggil 1 kali
      verify(() => mockMongoService.insertLog(any())).called(1);
    });

    test('TC02: addLog should handle cloud exception gracefully (Offline Fallback)', () async {
      // 1. SETUP (Arrange)
      // Mensimulasikan koneksi database putus/timeout dengan melempar Exception
      when(() => mockMongoService.insertLog(any())).thenThrow(Exception('Koneksi Timeout'));

      // 2. EXERCISE (Act)
      await logController.addLog(
        'Test Offline', 'Koneksi Putus', 'Bug', 'Backend', 'u1', 't1', false
      );

      // 3. VERIFY (Assert)
      // Meskipun cloud error, data harus tetap tersimpan di lokal (Offline First)
      expect(logController.logsNotifier.value.isNotEmpty, true);
      expect(logController.logsNotifier.value.last.title, 'Test Offline');
      // Memastikan fungsi insertLog tetap dipanggil meskipun error
      verify(() => mockMongoService.insertLog(any())).called(1);
      
      // Memastikan status isSyncing dimatikan pada blok finally agar UI tidak loading selamanya
      expect(logController.isSyncing.value, false);
    });

    test('TC03: updateLog should update data locally and sync changes to cloud', () async {
      // 1. SETUP (Arrange)
      final dummyLog = LogModel(
        id: '65a1234567890',
        title: 'Lama',
        description: 'Lama',
        date: DateTime.now().toIso8601String(),
        type: 'Task',
        category: 'Frontend',
        authorId: 'u1',
        teamId: 't1',
        isPublic: false,
      );

      // Setup state Hive box seolah-olah sudah ada data
      when(() => mockLogBox.values).thenReturn([dummyLog]);
      when(() => mockLogBox.putAt(any(), any())).thenAnswer((_) async => {});
      when(() => mockMongoService.updateLog(any())).thenAnswer((_) async => {});
      
      logController.logsNotifier.value = [dummyLog];

      // 2. EXERCISE (Act)
      await logController.updateLog(
        dummyLog, 'Baru', 'Revisi', 'Task', 'Frontend', true
      );

      // 3. VERIFY (Assert)
      // Verifikasi operasi update di cloud dipanggil 1 kali
      verify(() => mockMongoService.updateLog(any())).called(1);
      
      // Verifikasi bahwa status isSyncing telah selesai di blok finally
      expect(logController.isSyncing.value, false);
    });
  });
}