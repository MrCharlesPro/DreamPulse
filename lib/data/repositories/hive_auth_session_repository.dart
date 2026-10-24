import 'package:hive/hive.dart';

import '../../domain/repositories/auth_session_repository.dart';

class HiveAuthSessionRepository implements AuthSessionRepository {
  HiveAuthSessionRepository(this._box);

  final Box<bool> _box;
  static const _claveSesion = 'activa';

  @override
  Future<bool> tieneSesion() async =>
      _box.get(_claveSesion, defaultValue: false)!;

  @override
  Future<void> guardarSesion() async {
    await _box.put(_claveSesion, true);
  }

  @override
  Future<void> cerrarSesion() async {
    await _box.delete(_claveSesion);
  }
}
