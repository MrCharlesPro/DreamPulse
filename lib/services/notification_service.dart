import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._plugin);
  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> inicializar() async {
    tzdata.initializeTimeZones();
    final zona = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zona.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  Future<void> programar(String horaIdeal) async {
    final permiso = await Permission.notification.request();
    if (!permiso.isGranted && !permiso.isLimited) {
      throw StateError('Se necesita permiso para mostrar recordatorios.');
    }
    final partes = horaIdeal.split(':');
    final hora = int.parse(partes[0]);
    final minuto = int.parse(partes[1]);
    var programada = tz.TZDateTime.now(tz.local);
    programada = tz.TZDateTime(
      tz.local,
      programada.year,
      programada.month,
      programada.day,
      hora,
      minuto,
    );
    if (!programada.isAfter(tz.TZDateTime.now(tz.local))) {
      programada = programada.add(const Duration(days: 1));
    }
    const detalle = NotificationDetails(
      android: AndroidNotificationDetails(
        'dream_pulse_bedtime',
        'Recordatorio para dormir',
        channelDescription: 'Avisos diarios para prepararte para dormir',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
    await _plugin.zonedSchedule(
      id: 1,
      title: 'Es hora de bajar el ritmo',
      body: 'Tu descanso empieza con una buena rutina. ¡Buenas noches!',
      scheduledDate: programada,
      notificationDetails: detalle,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelar() => _plugin.cancel(id: 1);
}
