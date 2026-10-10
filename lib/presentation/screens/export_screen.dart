import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/export_controller.dart';
import '../controllers/sleep_controller.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExportController>();
    final sleep = context.watch<SleepController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar y respaldo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tus datos permanecen en tu dispositivo. Comparte una copia o restaura un respaldo JSON.',
          ),
          const SizedBox(height: 18),
          if (controller.cargando) const LinearProgressIndicator(),
          if (controller.sinRegistros)
            const Text('Aún no hay registros para exportar.'),
          if (controller.error != null)
            Text(
              controller.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          _accion(
            context,
            icono: Icons.table_chart_outlined,
            texto: 'Compartir historial CSV',
            onTap: () =>
                _ejecutar(context, () => controller.csv(sleep.registros)),
          ),
          _accion(
            context,
            icono: Icons.picture_as_pdf_outlined,
            texto: 'Compartir informe PDF',
            onTap: () =>
                _ejecutar(context, () => controller.pdf(sleep.registros)),
          ),
          _accion(
            context,
            icono: Icons.backup_outlined,
            texto: 'Crear respaldo JSON',
            onTap: () =>
                _ejecutar(context, () => controller.respaldo(sleep.registros)),
          ),
          _accion(
            context,
            icono: Icons.restore_outlined,
            texto: 'Restaurar respaldo JSON',
            onTap: () async {
              try {
                final seleccion = await controller.restaurar();
                if (seleccion == null || !context.mounted) return;
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Restaurar respaldo'),
                    content: Text(
                      'Se importarán ${seleccion.length} noches. Los registros existentes con el mismo ID se actualizarán.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Restaurar'),
                      ),
                    ],
                  ),
                );
                if (confirmar != true || !context.mounted) return;
                final sleepController = context.read<SleepController>();
                for (final registro in seleccion) {
                  await sleepController.guardar(registro);
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Respaldo restaurado')),
                );
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Falló la restauración: $error')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _accion(
    BuildContext context, {
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
  }) => Card(
    child: ListTile(
      minVerticalPadding: 10,
      leading: Icon(icono),
      title: Text(texto),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );

  Future<void> _ejecutar(
    BuildContext context,
    Future<void> Function() accion,
  ) async {
    try {
      await accion();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar la exportación: $error')),
      );
    }
  }
}
