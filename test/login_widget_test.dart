import 'package:dreampulse/core/theme/app_theme.dart';
import 'package:dreampulse/domain/repositories/auth_session_repository.dart';
import 'package:dreampulse/domain/services/authentication_service.dart';
import 'package:dreampulse/presentation/controllers/auth_controller.dart';
import 'package:dreampulse/presentation/screens/auth_gate.dart';
import 'package:dreampulse/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class SessionMemory implements AuthSessionRepository {
  @override
  Future<void> cerrarSesion() async {}
  @override
  Future<void> guardarSesion() async {}
  @override
  Future<bool> tieneSesion() async => false;
}

void main() {
  testWidgets('login oculta contraseña y muestra error genérico', (
    tester,
  ) async {
    final auth = AuthController(const AuthenticationService(), SessionMemory());
    await auth.cargarSesion();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(theme: AppTheme.oscuro(), home: const AuthGate()),
      ),
    );

    final campoContrasena = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Contraseña',
      ),
    );
    expect(campoContrasena.obscureText, isTrue);
    expect(campoContrasena.maxLength, 64);
    expect(find.text('Usuario'), findsOneWidget);

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Credenciales inválidas'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pumpAndSettle();
    final visible = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Contraseña',
      ),
    );
    expect(visible.obscureText, isFalse);
    auth.dispose();
  });
}
