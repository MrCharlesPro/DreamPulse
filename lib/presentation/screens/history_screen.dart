import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/sleep_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/estado_pantalla.dart';
import '../../domain/entities/registro_sueno.dart';
import '../controllers/history_controller.dart';
import '../controllers/sleep_controller.dart';
import 'record_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SleepController>();
    final filtros = context.watch<HistoryController>();
    if (controller.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null && controller.registros.isEmpty) {
      return EstadoPantalla(
        mensaje: controller.error!,
        icono: Icons.error_outline,
        accion: FilledButton(
          onPressed: controller.cargar,
          child: const Text('Reintentar'),
        ),
      );
    }
    if (controller.registros.isEmpty) {
      return const EstadoPantalla(
        mensaje:
            'Tu historial aparecerá aquí cuando registres tu primera noche.',
        icono: Icons.calendar_month_outlined,
      );
    }
    final registros = filtros.filtrar(controller.registros);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu historial',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Mes anterior',
                    onPressed: () => filtros.cambiarMes(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      '${filtros.mesSeleccionado.month.toString().padLeft(2, '0')}/${filtros.mesSeleccionado.year}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Mes siguiente',
                    onPressed: () => filtros.cambiarMes(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar por fecha (dd/mm/aaaa)',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: filtros.buscar,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todas las fuentes'),
                    selected: filtros.origen == null,
                    onSelected: (_) => filtros.seleccionarOrigen(null),
                  ),
                  ...OrigenRegistro.values.map(
                    (origen) => FilterChip(
                      label: Text(switch (origen) {
                        OrigenRegistro.manual => 'Manual',
                        OrigenRegistro.simulado => 'Simulado',
                        OrigenRegistro.automatico => 'Automático',
                      }),
                      selected: filtros.origen == origen,
                      onSelected: (_) => filtros.seleccionarOrigen(
                        filtros.origen == origen ? null : origen,
                      ),
                    ),
                  ),
                  ActionChip(
                    avatar: Icon(
                      filtros.masRecientePrimero
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                    ),
                    label: const Text('Orden'),
                    onPressed: filtros.alternarOrden,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.calendar_month),
                    label: Text(
                      filtros.desde == null
                          ? 'Rango de fechas'
                          : '${SleepUtils.fecha(filtros.desde!)} – ${SleepUtils.fecha(filtros.hasta!)}',
                    ),
                    onPressed: () async {
                      final rango = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (context.mounted) filtros.seleccionarRango(rango);
                    },
                  ),
                  if (filtros.desde != null)
                    ActionChip(
                      avatar: const Icon(Icons.close),
                      label: const Text('Quitar rango'),
                      onPressed: () => filtros.seleccionarRango(null),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: registros.isEmpty
              ? const EstadoPantalla(
                  mensaje: 'No hay registros con estos filtros.',
                  icono: Icons.filter_list_off,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: registros.length,
                  itemBuilder: (context, indice) {
                    final registro = registros[indice];
                    return Dismissible(
                      key: ValueKey(registro.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar registro'),
                            content: const Text(
                              '¿Quieres eliminar esta noche de tu historial?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        return confirmed ?? false;
                      },
                      onDismissed: (_) async {
                        await context.read<SleepController>().eliminar(
                          registro.id,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Registro eliminado'),
                            action: SnackBarAction(
                              label: 'Deshacer',
                              onPressed: () => context
                                  .read<SleepController>()
                                  .guardar(registro),
                            ),
                          ),
                        );
                      },
                      child: _FilaRegistro(
                        registro: registro,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RecordScreen(registro: registro),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilaRegistro extends StatelessWidget {
  const _FilaRegistro({required this.registro, required this.onTap});
  final RegistroSueno registro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icono = switch (registro.origen) {
      OrigenRegistro.manual => Icons.edit_note,
      OrigenRegistro.simulado => Icons.science_outlined,
      OrigenRegistro.automatico => Icons.watch_outlined,
    };
    final etiqueta = switch (registro.origen) {
      OrigenRegistro.manual => 'Manual',
      OrigenRegistro.simulado => 'Simulado',
      OrigenRegistro.automatico => 'Automático',
    };
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: .13),
          child: const Icon(Icons.nightlight, color: AppConstants.coral),
        ),
        title: Text(SleepUtils.fecha(registro.inicio)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${SleepUtils.hora(registro.inicio)} → ${SleepUtils.hora(registro.fin)} · ${SleepUtils.formatoDuracion(registro.duracion)}',
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(icono, size: 15),
                  const SizedBox(width: 4),
                  Text(etiqueta, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            registro.calidad,
            (_) => const Icon(
              Icons.star_rounded,
              size: 14,
              color: AppConstants.ambar,
            ),
          ),
        ),
      ),
    );
  }
}
