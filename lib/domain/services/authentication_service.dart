import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'login_validator.dart';

abstract final class CredencialesDemostracion {
  static const usuario = 'demo';
  static const salt = 'DreamPulse-AccesoSeguro-v1';
  static const hashContrasena =
      'b3b6fe5037948e9d85edf15c1186d4293710a7700d0cadb779433f1d86ef76b8';
}

class AuthenticationService {
  const AuthenticationService({this.validator = const LoginValidator()});

  final LoginValidator validator;

  LoginValidationError? validar({
    required String usuario,
    required String contrasena,
  }) => validator.validar(usuario: usuario, contrasena: contrasena);

  bool autenticar({required String usuario, required String contrasena}) {
    if (validar(usuario: usuario, contrasena: contrasena) != null) {
      return false;
    }
    final digest = sha256
        .convert(utf8.encode('${CredencialesDemostracion.salt}:$contrasena'))
        .toString();
    return usuario.trim() == CredencialesDemostracion.usuario &&
        _comparacionConstante(digest, CredencialesDemostracion.hashContrasena);
  }

  bool _comparacionConstante(String actual, String esperado) {
    if (actual.length != esperado.length) return false;
    var diferencia = 0;
    for (var indice = 0; indice < actual.length; indice++) {
      diferencia |= actual.codeUnitAt(indice) ^ esperado.codeUnitAt(indice);
    }
    return diferencia == 0;
  }
}
