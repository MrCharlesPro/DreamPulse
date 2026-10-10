import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/entities/dispositivo.dart';
import 'wearable_service.dart';

class BleWearableService implements WearableService {
  BluetoothDevice? _dispositivo;

  Future<void> _solicitarPermisos() async {
    if (!Platform.isAndroid) return;
    final permisos = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    final denegado = permisos.entries
        .where(
          (elemento) =>
              elemento.key == Permission.bluetoothScan ||
              elemento.key == Permission.bluetoothConnect,
        )
        .where(
          (elemento) =>
              elemento.value.isDenied || elemento.value.isPermanentlyDenied,
        )
        .map((elemento) => elemento.key.toString())
        .toList();
    if (denegado.isNotEmpty) {
      throw StateError(
        'Se requieren permisos Bluetooth para buscar dispositivos.',
      );
    }
  }

  @override
  Stream<List<Dispositivo>> buscar() async* {
    await _solicitarPermisos();
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
      await FlutterBluePlus.isScanning
          .where((buscando) => !buscando)
          .first
          .timeout(const Duration(seconds: 10));
      final resultados = FlutterBluePlus.lastScanResults;
      yield resultados
          .map(
            (resultado) => Dispositivo(
              id: resultado.device.remoteId.str,
              nombre: resultado.device.platformName.isEmpty
                  ? 'Dispositivo Bluetooth'
                  : resultado.device.platformName,
              simulado: false,
              conectado: resultado.device.isConnected,
            ),
          )
          .toList();
    } on FlutterBluePlusException catch (error) {
      throw StateError('Falló la búsqueda BLE: ${error.description}');
    } catch (error) {
      throw StateError('No se pudieron buscar wearables: $error');
    } finally {
      await FlutterBluePlus.stopScan();
    }
  }

  @override
  Future<void> conectar(Dispositivo dispositivo) async {
    await _solicitarPermisos();
    try {
      final encontrado = FlutterBluePlus.connectedDevices
          .where((device) => device.remoteId.str == dispositivo.id)
          .firstOrNull;
      _dispositivo = encontrado ?? BluetoothDevice.fromId(dispositivo.id);
      await _dispositivo!.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 15),
      );
    } catch (error) {
      _dispositivo = null;
      throw StateError('No se pudo conectar al wearable: $error');
    }
  }

  @override
  Future<void> desconectar() async {
    await _dispositivo?.disconnect();
    _dispositivo = null;
  }

  @override
  Future<List<NocheDispositivo>> leerSueno() async {
    final dispositivo = _dispositivo;
    if (dispositivo == null || !dispositivo.isConnected) {
      throw StateError('No hay un wearable BLE conectado.');
    }
    try {
      final servicios = await dispositivo.discoverServices();
      if (servicios.isEmpty) {
        throw StateError(
          'El dispositivo no expone un perfil BLE de sueño compatible.',
        );
      }
      throw StateError(
        'El wearable se conectó, pero no ofrece un formato de sueño compatible con DreamPulse.',
      );
    } catch (error) {
      if (error is StateError) rethrow;
      throw StateError('No se pudieron leer datos del wearable: $error');
    }
  }
}
