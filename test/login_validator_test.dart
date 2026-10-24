import 'package:dreampulse/domain/services/login_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validador = LoginValidator();

  test('rechaza los dos campos vacíos', () {
    expect(
      validador.validar(usuario: '', contrasena: ''),
      LoginValidationError.usuarioVacio,
    );
  });

  test('rechaza usuario compuesto por espacios', () {
    expect(
      validador.validar(usuario: '   \t', contrasena: '12345678'),
      LoginValidationError.usuarioVacio,
    );
  });

  test('rechaza contraseña con menos de ocho caracteres', () {
    expect(
      validador.validar(usuario: 'demo', contrasena: '1234567'),
      LoginValidationError.contrasenaDemasiadoCorta,
    );
  });

  test('rechaza entradas que superan sus longitudes máximas', () {
    expect(
      validador.validar(
        usuario: List.filled(31, 'u').join(),
        contrasena: '12345678',
      ),
      LoginValidationError.usuarioLongitudExcedida,
    );
    expect(
      validador.validar(
        usuario: 'demo',
        contrasena: List.filled(65, 'p').join(),
      ),
      LoginValidationError.contrasenaLongitudExcedida,
    );
  });

  test('acepta datos que cumplen la política', () {
    expect(
      validador.validar(usuario: ' demo ', contrasena: '12345678'),
      isNull,
    );
  });
}
