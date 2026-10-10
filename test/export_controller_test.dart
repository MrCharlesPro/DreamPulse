import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:dreampulse/presentation/controllers/export_controller.dart';
import 'package:dreampulse/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

class ExportacionFalsa extends ExportService {
  bool falla = false;
  bool csvCompartido = false;

  @override
  Future<void> compartirCsv(List<RegistroSueno> registros) async {
    if (falla) throw StateError('fallo de prueba');
    csvCompartido = true;
  }

  @override
  Future<void> compartirPdf(List<RegistroSueno> registros) async {}

  @override
  Future<void> compartirRespaldo(List<RegistroSueno> registros) async {}

  @override
  Future<List<RegistroSueno>?> seleccionarRespaldo() async => [];
}

RegistroSueno registro() => RegistroSueno(
  id: 'test',
  inicio: DateTime(2026, 4, 1, 22),
  fin: DateTime(2026, 4, 2, 6),
  calidad: 4,
  origen: OrigenRegistro.manual,
);

void main() {
  test('expone el estado vacío cuando no existen registros', () async {
    final controlador = ExportController(ExportacionFalsa());

    await controlador.csv([]);

    expect(controlador.sinRegistros, isTrue);
    expect(controlador.cargando, isFalse);
    expect(controlador.error, isNull);
  });

  test('expone carga terminada y error de exportación', () async {
    final servicio = ExportacionFalsa();
    final controlador = ExportController(servicio);

    await controlador.csv([registro()]);
    expect(servicio.csvCompartido, isTrue);
    expect(controlador.cargando, isFalse);

    servicio.falla = true;
    await expectLater(
      controlador.csv([registro()]),
      throwsA(isA<StateError>()),
    );
    expect(controlador.error, contains('fallo de prueba'));
    expect(controlador.cargando, isFalse);
  });

  test(
    'restauración delega al servicio y finaliza el estado de carga',
    () async {
      final controlador = ExportController(ExportacionFalsa());

      final registros = await controlador.restaurar();

      expect(registros, isEmpty);
      expect(controlador.cargando, isFalse);
      expect(controlador.error, isNull);
    },
  );
}
