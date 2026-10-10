import 'package:dreampulse/core/theme/app_theme.dart';
import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:dreampulse/domain/entities/usuario.dart';
import 'package:dreampulse/domain/repositories/profile_repository.dart';
import 'package:dreampulse/domain/repositories/sleep_repository.dart';
import 'package:dreampulse/presentation/controllers/profile_controller.dart';
import 'package:dreampulse/presentation/controllers/sleep_controller.dart';
import 'package:dreampulse/presentation/controllers/history_controller.dart';
import 'package:dreampulse/presentation/screens/dashboard_screen.dart';
import 'package:dreampulse/presentation/screens/home_screen.dart';
import 'package:dreampulse/presentation/screens/history_screen.dart';
import 'package:dreampulse/presentation/screens/record_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class MemoriaSueno implements SleepRepository {
  final List<RegistroSueno> valores;

  MemoriaSueno([List<RegistroSueno>? inicial]) : valores = inicial ?? [];

  @override
  Future<void> eliminar(String id) async =>
      valores.removeWhere((registro) => registro.id == id);

  @override
  Future<void> guardar(RegistroSueno registro) async {
    valores.removeWhere((valor) => valor.id == registro.id);
    valores.add(registro);
  }

  @override
  Future<List<RegistroSueno>> obtenerTodos() async =>
      valores.toList()..sort((a, b) => b.inicio.compareTo(a.inicio));
}

class PerfilMemoria implements ProfileRepository {
  Usuario usuario = Usuario.inicial();

  @override
  Future<Usuario> obtener() async => usuario;

  @override
  Future<void> guardar(Usuario usuario) async => this.usuario = usuario;
}

RegistroSueno registroEjemplo({String id = 'ejemplo'}) => RegistroSueno(
  id: id,
  inicio: DateTime(2026, 10, 8, 23),
  fin: DateTime(2026, 10, 9, 7),
  calidad: 4,
  origen: OrigenRegistro.manual,
);

Widget envolver(Widget pantalla, {List<RegistroSueno>? inicial}) {
  final sleep = SleepController(MemoriaSueno(inicial))..cargar();
  final profile = ProfileController(PerfilMemoria())..cargar();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: sleep),
      ChangeNotifierProvider.value(value: profile),
      ChangeNotifierProvider(create: (_) => HistoryController()),
    ],
    child: MaterialApp(
      theme: AppTheme.oscuro(),
      home: Scaffold(body: pantalla),
    ),
  );
}

void main() {
  testWidgets('Dashboard muestra la duración y la meta', (tester) async {
    await tester.pumpWidget(
      envolver(const DashboardScreen(), inicial: [registroEjemplo()]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sueño de anoche'), findsOneWidget);
    expect(find.text('8h 00m'), findsWidgets);
    expect(find.text('Meta: 8.0 h'), findsOneWidget);
  });

  testWidgets('Registrar muestra formulario y duración en vivo', (
    tester,
  ) async {
    await tester.pumpWidget(envolver(const RecordScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Registra tu sueño'), findsOneWidget);
    expect(find.text('8h 00m'), findsWidgets);
    expect(find.text('Guardar registro'), findsOneWidget);
  });

  testWidgets('Historial muestra el registro guardado', (tester) async {
    await tester.pumpWidget(
      envolver(const HistoryScreen(), inicial: [registroEjemplo()]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tu historial'), findsOneWidget);
    expect(find.textContaining('23:00 → 07:00'), findsOneWidget);
    expect(find.text('Manual'), findsWidgets);
  });

  testWidgets('flujo de registro aparece en historial e inicio', (
    tester,
  ) async {
    final repositorio = MemoriaSueno();
    final sleep = SleepController(repositorio)..cargar();
    final profile = ProfileController(PerfilMemoria())..cargar();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sleep),
          ChangeNotifierProvider.value(value: profile),
          ChangeNotifierProvider(create: (_) => HistoryController()),
        ],
        child: MaterialApp(theme: AppTheme.oscuro(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('Registra tu sueño'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar registro'));
    await tester.pumpAndSettle();
    expect(repositorio.valores, hasLength(1));
    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
    expect(find.text('Manual'), findsWidgets);
    expect(find.textContaining('8h 00m'), findsOneWidget);
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Sueño de anoche'), findsOneWidget);
    expect(find.text('8h 00m'), findsOneWidget);
  });
}
