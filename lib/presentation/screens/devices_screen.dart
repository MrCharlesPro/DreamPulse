import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/dispositivo.dart';
import '../controllers/device_controller.dart';
import '../controllers/sleep_controller.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceController>();
    final estado = switch (controller.estado) {
      EstadoDispositivo.desconectado => 'Desconectado',
      EstadoDispositivo.buscando => 'Buscando dispositivos…',
      EstadoDispositivo.conectado => 'Conectado',
      EstadoDispositivo.error => 'Error de conexión',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Dispositivos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipo de conexión',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.science_outlined),
                        label: Text('Demostración'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.bluetooth),
                        label: Text('Bluetooth'),
                      ),
                    ],
                    selected: {controller.simulado},
                    onSelectionChanged: (seleccion) =>
                        controller.seleccionarModo(seleccion.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.simulado
                        ? 'Genera un wearable y noches de prueba, sin hardware.'
                        : 'Busca dispositivos BLE cercanos compatibles.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(
                controller.conectado
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth,
                color: controller.estado == EstadoDispositivo.error
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              title: Text(estado),
              subtitle: controller.error == null
                  ? const Text('Registro manual disponible en todo momento')
                  : Text(controller.error!),
            ),
          ),
          const SizedBox(height: 16),
          if (controller.estado == EstadoDispositivo.buscando)
            const LinearProgressIndicator(),
          if (controller.dispositivos.isEmpty &&
              controller.estado != EstadoDispositivo.buscando)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.watch_off_outlined, size: 42),
                    SizedBox(height: 12),
                    Text('Sin dispositivos. Busca un wearable para comenzar.'),
                  ],
                ),
              ),
            ),
          ...controller.dispositivos.map(
            (dispositivo) => Card(
              child: ListTile(
                leading: Icon(
                  dispositivo.simulado ? Icons.watch_outlined : Icons.bluetooth,
                ),
                title: Text(dispositivo.nombre),
                subtitle: Text(
                  dispositivo.simulado ? 'Modo simulación' : dispositivo.id,
                ),
                trailing: FilledButton(
                  onPressed: controller.conectado
                      ? controller.desconectar
                      : () => controller.conectar(dispositivo),
                  child: Text(
                    controller.conectado ? 'Desvincular' : 'Vincular',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: controller.estado == EstadoDispositivo.buscando
                ? null
                : controller.buscar,
            icon: const Icon(Icons.search),
            label: const Text('Buscar dispositivos'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: controller.conectado
                ? () async {
                    final sleepController = context.read<SleepController>();
                    try {
                      final cantidad = await controller.sincronizar();
                      await sleepController.cargar();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            cantidad == 0
                                ? 'Los registros ya estaban sincronizados.'
                                : 'Se sincronizaron $cantidad noches.',
                          ),
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al sincronizar: $error')),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.sync),
            label: const Text('Sincronizar'),
          ),
          if (controller.estado == EstadoDispositivo.error)
            TextButton.icon(
              onPressed: () => controller.seleccionarModo(true),
              icon: const Icon(Icons.science_outlined),
              label: const Text('Cambiar a demostración'),
            ),
        ],
      ),
    );
  }
}
