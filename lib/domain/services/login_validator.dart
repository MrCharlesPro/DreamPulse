enum LoginValidationError {
  usuarioVacio,
  usuarioLongitudExcedida,
  contrasenaVacia,
  contrasenaDemasiadoCorta,
  contrasenaLongitudExcedida,
}

class LoginValidator {
  const LoginValidator();

  static const longitudMaximaUsuario = 30;
  static const longitudMinimaContrasena = 8;
  static const longitudMaximaContrasena = 64;

  LoginValidationError? validar({
    required String usuario,
    required String contrasena,
  }) {
    if (usuario.trim().isEmpty) return LoginValidationError.usuarioVacio;
    if (usuario.length > longitudMaximaUsuario) {
      return LoginValidationError.usuarioLongitudExcedida;
    }
    if (contrasena.isEmpty) return LoginValidationError.contrasenaVacia;
    if (contrasena.length < longitudMinimaContrasena) {
      return LoginValidationError.contrasenaDemasiadoCorta;
    }
    if (contrasena.length > longitudMaximaContrasena) {
      return LoginValidationError.contrasenaLongitudExcedida;
    }
    return null;
  }
}
