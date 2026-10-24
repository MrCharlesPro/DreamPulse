import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.inicializando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.errorSesion != null && !auth.autenticado) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(height: 12),
                Text(auth.errorSesion!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: auth.cargarSesion,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return auth.autenticado ? const HomeScreen() : const LoginScreen();
  }
}
