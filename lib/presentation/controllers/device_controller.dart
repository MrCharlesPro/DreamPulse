import 'package:flutter/foundation.dart';

import '../../domain/entities/dispositivo.dart';
import '../../services/ble_wearable_service.dart';
import '../../services/simulated_wearable_service.dart';
import '../../services/sync_service.dart';
import '../../services/wearable_service.dart';

class DeviceController extends ChangeNotifier {
  DeviceController({
    required this._bleService,
    required this._simulatedService,
    required this._crearSyncService,
  }) {
    _usarSimulado(true);
  }

  final BleWearableService _bleService;
  final SimulatedWearableService _simulatedService;
  final SyncService Function(WearableService) _crearSyncService;
  late WearableService _servicio;
  late SyncService _syncService;
  final List<Dispositivo> _dispositivos = [];
  EstadoDispositivo _estado = EstadoDispositivo.desconectado;
  String? _error;
  bool _simulado = true;

  List<Dispositivo> get dispositivos => List.unmodifiable(_dispositivos);
  EstadoDispositivo get estado => _estado;
  String? get error => _error;
  bool get simulado => _simulado;
  bool get conectado => _estado == EstadoDispositivo.conectado;

  void _usarSimulado(bool simulado) {
    _simulado = simulado;
    _servicio = simulado ? _simulatedService : _bleService;
    _syncService = _crearSyncService(_servicio);
  }

  Future<void> seleccionarModo(bool simulado) async {
    if (conectado) await _servicio.desconectar();
    _dispositivos.clear();
    _estado = EstadoDispositivo.desconectado;
    _error = null;
    _usarSimulado(simulado);
    notifyListeners();
  }

  Future<void> buscar() async {
    _estado = EstadoDispositivo.buscando;
    _error = null;
    _dispositivos.clear();
    notifyListeners();
    try {
      await for (final encontrados in _servicio.buscar()) {
        _dispositivos
          ..clear()
          ..addAll(encontrados);
        notifyListeners();
      }
      if (_dispositivos.isEmpty) _estado = EstadoDispositivo.desconectado;
    } catch (error) {
      _estado = EstadoDispositivo.error;
      _error = error.toString();
    }
    notifyListeners();
  }

  Future<void> conectar(Dispositivo dispositivo) async {
    try {
      await _servicio.conectar(dispositivo);
      _estado = EstadoDispositivo.conectado;
      _error = null;
    } catch (error) {
      _estado = EstadoDispositivo.error;
      _error = error.toString();
    }
    notifyListeners();
  }

  Future<void> desconectar() async {
    try {
      await _servicio.desconectar();
      _estado = EstadoDispositivo.desconectado;
    } catch (error) {
      _estado = EstadoDispositivo.error;
      _error = error.toString();
    }
    notifyListeners();
  }

  Future<int> sincronizar() async {
    try {
      return await _syncService.sincronizar();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }
}
