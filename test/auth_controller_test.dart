import 'package:dreampulse/domain/repositories/auth_session_repository.dart';
import 'package:dreampulse/domain/services/authentication_service.dart';
import 'package:dreampulse/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class SessionMemory implements AuthSessionRepository {
  bool activa = false;

  @override
  Future<void> cerrarSesion() async => activa = false;

  @override
  Future<void> guardarSesion() async => activa = true;

  @override
  Future<bool> tieneSesion() async => activa;
}

void main() {
  test('cinco intentos inválidos activan bloqueo temporal genérico', () async {
    final session = SessionMemory();
    final controller = AuthController(const AuthenticationService(), session);
    addTearDown(controller.dispose);

    for (var intento = 0; intento < AuthController.maxIntentos; intento++) {
      final resultado = await controller.iniciarSesion(
        usuario: 'usuario-incorrecto',
        contrasena: 'contrasena-incorrecta',
      );
      expect(resultado, isFalse);
    }

    expect(controller.segundosBloqueo, 30);
    expect(controller.error, 'Credenciales inválidas');
    expect(
      await controller.iniciarSesion(
        usuario: 'otro',
        contrasena: 'contrasena-incorrecta',
      ),
      isFalse,
    );
    expect(session.activa, isFalse);
  });

  test('sesión se crea y se elimina sin conservar credenciales', () async {
    final session = SessionMemory();
    final controller = AuthController(const AuthenticationService(), session);
    addTearDown(controller.dispose);

    final acceso = await controller.iniciarSesion(
      usuario: 'demo',
      contrasena: 'SuenoSeguro2026!',
    );
    expect(acceso, isTrue);
    expect(session.activa, isTrue);
    expect(controller.autenticado, isTrue);

    expect(await controller.cerrarSesion(), isTrue);
    expect(session.activa, isFalse);
    expect(controller.autenticado, isFalse);
  });
}
