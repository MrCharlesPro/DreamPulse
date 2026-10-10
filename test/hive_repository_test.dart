import 'dart:io';

import 'package:dreampulse/data/datasources/hive_sleep_data_source.dart';
import 'package:dreampulse/data/datasources/mock_sleep_data_source.dart';
import 'package:dreampulse/data/repositories/hive_sleep_repository.dart';
import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class MockEnMemoria extends MockSleepDataSource {
  MockEnMemoria(this.registros);
  final List<RegistroSueno> registros;

  @override
  Future<List<RegistroSueno>> cargar() async => registros;
}

void main() {
  late Directory directorio;
  late Box<Map<dynamic, dynamic>> noches;
  late Box<Map<dynamic, dynamic>> ajustes;

  setUpAll(() async {
    directorio = await Directory.systemTemp.createTemp('dreampulse_hive_');
    Hive.init(directorio.path);
  });

  setUp(() async {
    noches = await Hive.openBox<Map<dynamic, dynamic>>('registros_test');
    ajustes = await Hive.openBox<Map<dynamic, dynamic>>('ajustes_test');
    await noches.clear();
    await ajustes.clear();
  });

  tearDown(() async {
    await noches.close();
    await ajustes.close();
    await Hive.deleteBoxFromDisk('registros_test');
    await Hive.deleteBoxFromDisk('ajustes_test');
  });

  tearDownAll(() async {
    await Hive.close();
    await directorio.delete(recursive: true);
  });

  test('guarda y recupera registros persistidos en Hive', () async {
    final origen = RegistroSueno(
      id: 'local',
      inicio: DateTime(2026, 10, 8, 23),
      fin: DateTime(2026, 10, 9, 7),
      calidad: 4,
      origen: OrigenRegistro.manual,
    );
    final repo = HiveSleepRepository(
      HiveSleepDataSource(noches),
      MockEnMemoria(const []),
      ajustes,
    );

    await repo.guardar(origen);

    final cargados = await repo.obtenerTodos();
    expect(cargados, hasLength(1));
    expect(cargados.single.toMap(), origen.toMap());
  });

  test(
    'solo importa los datos simulados al inicializar la primera vez',
    () async {
      final origen = RegistroSueno(
        id: 'seed',
        inicio: DateTime(2026, 10, 8, 23),
        fin: DateTime(2026, 10, 9, 7),
        calidad: 4,
        origen: OrigenRegistro.simulado,
      );
      final repo = HiveSleepRepository(
        HiveSleepDataSource(noches),
        MockEnMemoria([origen]),
        ajustes,
      );

      expect((await repo.obtenerTodos()).single.toMap(), origen.toMap());
      await repo.eliminar(origen.id);
      expect(await repo.obtenerTodos(), isEmpty);
    },
  );
}
