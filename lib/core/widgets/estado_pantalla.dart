import 'package:flutter/material.dart';

class EstadoPantalla extends StatelessWidget {
  const EstadoPantalla({
    super.key,
    required this.mensaje,
    required this.icono,
    this.accion,
  });

  final String mensaje;
  final IconData icono;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(mensaje, textAlign: TextAlign.center),
          if (accion != null) ...[const SizedBox(height: 16), accion!],
        ],
      ),
    ),
  );
}
