import 'package:hive/hive.dart';

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/profile_repository.dart';

class HiveProfileRepository implements ProfileRepository {
  HiveProfileRepository(this._box);
  final Box<Map<dynamic, dynamic>> _box;

  @override
  Future<Usuario> obtener() async {
    final datos = _box.get('usuario');
    return datos == null ? Usuario.inicial() : Usuario.fromMap(datos);
  }

  @override
  Future<void> guardar(Usuario usuario) => _box.put('usuario', usuario.toMap());
}
