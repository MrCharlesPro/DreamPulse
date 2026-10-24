import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/widgets/boton_degradado.dart';
import '../../domain/services/login_validator.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _usuario.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final controlador = context.read<AuthController>();
    final concedido = await controlador.iniciarSesion(
      usuario: _usuario.text,
      contrasena: _contrasena.text,
    );
    _contrasena.clear();
    if (!mounted) return;
    if (concedido) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Acceso concedido')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<AuthController>();
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.nightlight_round,
                    size: 64,
                    color: AppConstants.coral,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DreamPulse',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _usuario,
                    enabled:
                        !controlador.procesando &&
                        controlador.segundosBloqueo == 0,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    inputFormatters: [
                      FilteringTextInputFormatter.singleLineFormatter,
                      LengthLimitingTextInputFormatter(
                        LoginValidator.longitudMaximaUsuario,
                      ),
                    ],
                    maxLength: LoginValidator.longitudMaximaUsuario,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contrasena,
                    enabled:
                        !controlador.procesando &&
                        controlador.segundosBloqueo == 0,
                    obscureText: !_mostrarContrasena,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    inputFormatters: [
                      FilteringTextInputFormatter.singleLineFormatter,
                      LengthLimitingTextInputFormatter(
                        LoginValidator.longitudMaximaContrasena,
                      ),
                    ],
                    maxLength: LoginValidator.longitudMaximaContrasena,
                    onSubmitted: (_) => _iniciarSesion(),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _mostrarContrasena
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        onPressed: () => setState(
                          () => _mostrarContrasena = !_mostrarContrasena,
                        ),
                        icon: Icon(
                          _mostrarContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (controlador.error != null ||
                      controlador.segundosBloqueo > 0)
                    Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          controlador.segundosBloqueo > 0
                              ? 'Demasiados intentos. Intenta de nuevo en ${controlador.segundosBloqueo} s.'
                              : controlador.error!,
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            color: tema.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  BotonDegradado(
                    onPressed:
                        controlador.procesando ||
                            controlador.segundosBloqueo > 0
                        ? null
                        : _iniciarSesion,
                    icon: controlador.procesando
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: const Text('Iniciar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
