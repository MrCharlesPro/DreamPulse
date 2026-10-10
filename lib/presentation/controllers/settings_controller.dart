import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../services/notification_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._box, this._notificationService);

  final Box<Map<dynamic, dynamic>> _box;
  final NotificationService _notificationService;
  bool _recordatorioActivo = false;

  bool get recordatorioActivo => _recordatorioActivo;

  Future<void> cargar() async {
    _recordatorioActivo =
        _box.get('recordatorioActivo')?['valor'] as bool? ?? false;
    notifyListeners();
  }

  Future<void> cambiarRecordatorio(bool activo, String horaIdeal) async {
    if (activo) {
      await _notificationService.programar(horaIdeal);
    } else {
      await _notificationService.cancelar();
    }
    await _box.put('recordatorioActivo', {'valor': activo});
    _recordatorioActivo = activo;
    notifyListeners();
  }
}
