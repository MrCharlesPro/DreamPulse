import 'package:dreampulse/core/theme/app_theme.dart';
import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:dreampulse/domain/entities/usuario.dart';
import 'package:dreampulse/domain/repositories/auth_session_repository.dart';
import 'package:dreampulse/domain/repositories/profile_repository.dart';
import 'package:dreampulse/domain/repositories/sleep_repository.dart';
import 'package:dreampulse/domain/services/authentication_service.dart';
import 'package:dreampulse/presentation/controllers/auth_controller.dart';
import 'package:dreampulse/presentation/controllers/profile_controller.dart';
import 'package:dreampulse/presentation/controllers/sleep_controller.dart';
import 'package:dreampulse/presentation/screens/auth_gate.dart';
import 'package:dreampulse/presentation/screens/home_screen.dart';
import 'package:dreampulse/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _SesionMemoria implements AuthSessionRepository {
  bool activa = false;

  @override
  Future<void> cerrarSesion() async => activa = false;

  @override
  Future<void> guardarSesion() async => activa = true;

  @override
  Future<bool> tieneSesion() async => activa;
}

class _SuenoMemoria implements SleepRepository {
  @override
  Future<void> eliminar(String id) async {}

  @override
  Future<void> guardar(RegistroSueno registro) async {}

  @override
  Future<List<RegistroSueno>> obtenerTodos() async => [];
}

class _PerfilMemoria implements ProfileRepository {
  @override
  Future<Usuario> obtener() async => Usuario.inicial();

  @override
  Future<void> guardar(Usuario usuario) async {}
}

void main() {
  testWidgets('login válido cambia el AuthGate a la navegación principal', (
    tester,
  ) async {
    final auth = AuthController(
      const AuthenticationService(),
      _SesionMemoria(),
    );
    final sleep = SleepController(_SuenoMemoria());
    final profile = ProfileController(_PerfilMemoria());
    addTearDown(auth.dispose);
    addTearDown(sleep.dispose);
    addTearDown(profile.dispose);
    await Future.wait([auth.cargarSesion(), sleep.cargar(), profile.cargar()]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: sleep),
          ChangeNotifierProvider.value(value: profile),
        ],
        child: MaterialApp(theme: AppTheme.oscuro(), home: const AuthGate()),
      ),
    );
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Usuario'), 'demo');
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Contraseña',
      ),
      'SuenoSeguro2026!',
    );
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Acceso concedido'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
