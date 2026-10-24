import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/hive_sleep_data_source.dart';
import 'data/datasources/mock_sleep_data_source.dart';
import 'data/repositories/hive_profile_repository.dart';
import 'data/repositories/hive_sleep_repository.dart';
import 'data/repositories/hive_auth_session_repository.dart';
import 'domain/services/authentication_service.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/profile_controller.dart';
import 'presentation/controllers/device_controller.dart';
import 'presentation/controllers/export_controller.dart';
import 'presentation/controllers/history_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/controllers/sleep_controller.dart';
import 'presentation/controllers/stats_controller.dart';
import 'presentation/screens/auth_gate.dart';
import 'domain/services/estadisticas_service.dart';
import 'domain/services/achievement_service.dart';
import 'domain/services/monthly_sleep_service.dart';
import 'domain/services/recomendaciones_service.dart';
import 'domain/services/sleep_insight_service.dart';
import 'domain/services/sleep_score_service.dart';
import 'services/ble_wearable_service.dart';
import 'services/notification_service.dart';
import 'services/export_service.dart';
import 'services/simulated_wearable_service.dart';
import 'services/sync_service.dart';

class DreamPulseApp extends StatelessWidget {
  const DreamPulseApp({super.key, required this.notificationService});
  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    final ajustes = Hive.box<Map<dynamic, dynamic>>('ajustes');
    final sleepRepository = HiveSleepRepository(
      HiveSleepDataSource(Hive.box<Map<dynamic, dynamic>>('registros')),
      MockSleepDataSource(),
      ajustes,
    );
    final profileRepository = HiveProfileRepository(
      Hive.box<Map<dynamic, dynamic>>('perfil'),
    );
    final ble = BleWearableService();
    final simulated = SimulatedWearableService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            const AuthenticationService(),
            HiveAuthSessionRepository(Hive.box<bool>('sesion')),
          )..cargarSesion(),
        ),
        ChangeNotifierProvider(
          create: (_) => SleepController(sleepRepository, ajustes)..cargar(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileController(profileRepository)..cargar(),
        ),
        ChangeNotifierProvider(create: (_) => HistoryController()),
        ChangeNotifierProvider(
          create: (_) => StatsController(
            estadisticasService: const EstadisticasService(),
            recomendacionesService: const RecomendacionesService(),
            monthlySleepService: const MonthlySleepService(),
            sleepInsightService: const SleepInsightService(),
            sleepScoreService: const SleepScoreService(),
            achievementService: const AchievementService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExportController(ExportService()),
        ),
        ChangeNotifierProvider(
          create: (_) => DeviceController(
            bleService: ble,
            simulatedService: simulated,
            crearSyncService: (servicio) =>
                SyncService(servicio, sleepRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SettingsController(ajustes, notificationService)..cargar(),
        ),
      ],
      child: MaterialApp(
        title: 'DreamPulse',
        debugShowCheckedModeBanner: false,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: AppTheme.oscuro(),
        home: const AuthGate(),
      ),
    );
  }
}
