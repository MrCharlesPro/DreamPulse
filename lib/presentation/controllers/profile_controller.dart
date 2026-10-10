import 'package:flutter/foundation.dart';

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);
  final ProfileRepository _repository;
  Usuario _usuario = Usuario.inicial();
  bool _cargando = true;
  String? _error;

  Usuario get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargar() async {
    try {
      _usuario = await _repository.obtener();
      _error = null;
    } catch (error) {
      _error = 'No se pudo cargar el perfil: $error';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> guardar(Usuario usuario) async {
    await _repository.guardar(usuario);
    _usuario = usuario;
    notifyListeners();
  }
}
