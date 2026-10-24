import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_session_repository.dart';
import '../../domain/services/authentication_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authenticationService, this._sessionRepository);

  static const maxIntentos = 5;
  static const duracionBloqueo = Duration(seconds: 30);

  final AuthenticationService _authenticationService;
  final AuthSessionRepository _sessionRepository;
  Timer? _temporizadorBloqueo;
  DateTime? _bloqueadoHasta;
  int _intentosFallidos = 0;
  bool _inicializando = true;
  bool _autenticado = false;
  bool _procesando = false;
  String? _error;
  String? _errorSesion;

  bool get inicializando => _inicializando;
  bool get autenticado => _autenticado;
  bool get procesando => _procesando;
  String? get error => _error;
  String? get errorSesion => _errorSesion;
  int get segundosBloqueo {
    final restante =
        _bloqueadoHasta?.difference(DateTime.now()).inMilliseconds ?? 0;
    return (restante / 1000).ceil().clamp(0, duracionBloqueo.inSeconds);
  }

  Future<void> cargarSesion() async {
    _inicializando = true;
    _error = null;
    _errorSesion = null;
    notifyListeners();
    try {
      _autenticado = await _sessionRepository.tieneSesion();
    } catch (_) {
      _autenticado = false;
      _errorSesion = 'No se pudo verificar la sesión. Intenta de nuevo.';
    } finally {
      _inicializando = false;
      notifyListeners();
    }
  }

  Future<bool> iniciarSesion({
    required String usuario,
    required String contrasena,
  }) async {
    if (_procesando || _actualmenteBloqueado) return false;
    _procesando = true;
    _error = null;
    notifyListeners();
    try {
      if (!_authenticationService.autenticar(
        usuario: usuario,
        contrasena: contrasena,
      )) {
        _registrarIntentoFallido();
        _error = 'Credenciales inválidas';
        return false;
      }
      try {
        await _sessionRepository.guardarSesion();
      } catch (_) {
        _error = 'No se pudo iniciar sesión. Intenta de nuevo.';
        return false;
      }
      _autenticado = true;
      _intentosFallidos = 0;
      _error = null;
      return true;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<bool> cerrarSesion() async {
    _procesando = true;
    _error = null;
    notifyListeners();
    try {
      await _sessionRepository.cerrarSesion();
      _autenticado = false;
      _intentosFallidos = 0;
      _bloqueadoHasta = null;
      _temporizadorBloqueo?.cancel();
      _temporizadorBloqueo = null;
      return true;
    } catch (_) {
      _error = 'No se pudo cerrar la sesión. Intenta de nuevo.';
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  bool get _actualmenteBloqueado => segundosBloqueo > 0;

  void _registrarIntentoFallido() {
    _intentosFallidos++;
    if (_intentosFallidos < maxIntentos) return;

    _intentosFallidos = 0;
    _bloqueadoHasta = DateTime.now().add(duracionBloqueo);
    _temporizadorBloqueo?.cancel();
    _temporizadorBloqueo = Timer.periodic(const Duration(seconds: 1), (_) {
      if (segundosBloqueo == 0) {
        _temporizadorBloqueo?.cancel();
        _temporizadorBloqueo = null;
        _bloqueadoHasta = null;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _temporizadorBloqueo?.cancel();
    super.dispose();
  }
}
