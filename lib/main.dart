import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<Map<dynamic, dynamic>>('registros'),
    Hive.openBox<Map<dynamic, dynamic>>('perfil'),
    Hive.openBox<Map<dynamic, dynamic>>('ajustes'),
  ]);
  final notificaciones = NotificationService(FlutterLocalNotificationsPlugin());
  try {
    await notificaciones.inicializar();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'DreamPulse',
        context: ErrorDescription('al iniciar las notificaciones locales'),
      ),
    );
  }
  runApp(DreamPulseApp(notificationService: notificaciones));
}
