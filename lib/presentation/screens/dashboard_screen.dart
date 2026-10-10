import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/sleep_utils.dart';
import '../../core/widgets/estado_pantalla.dart';
import '../../core/widgets/boton_degradado.dart';
import '../../domain/entities/registro_sueno.dart';
import '../../domain/services/sleep_score_service.dart';
import '../../domain/services/recomendaciones_service.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../../presentation/controllers/sleep_controller.dart';
import 'devices_screen.dart';
import 'statistics_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SleepController>();
    final usuario = context.watch<ProfileController>().usuario;
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
    final registros = controller.registros;
    final sleepController = context.read<SleepController>();
    final puntaje = registros.isEmpty
        ? 0
        : const SleepScoreService()
              .calcular(
                registro: registros.first,
                metaHoras: usuario.metaHoras,
                recientes: registros.take(7).toList(),
              )
              .total;
    return RefreshIndicator(
      onRefresh: controller.cargar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUENAS NOCHES',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 2,
                        color: AppConstants.coral,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Hola, ${usuario.nombre}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Icono de luna',
                child: const CircleAvatar(
                  radius: 25,
                  backgroundColor: AppConstants.superficieAlta,
                  child: Icon(
                    Icons.nightlight_round,
                    color: AppConstants.ambar,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: BotonDegradado(
                  onPressed: sleepController.inicioEnCurso != null
                      ? null
                      : () async {
                          try {
                            await sleepController.iniciarSueno();
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No se pudo iniciar: $error'),
                                ),
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.bedtime_outlined),
                  label: const Text('Me voy a dormir'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: sleepController.inicioEnCurso != null
                      ? () async {
                          try {
                            await sleepController.terminarSueno();
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No se pudo cerrar: $error'),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  icon: const Icon(Icons.wb_sunny_outlined),
                  label: const Text('Ya desperté'),
                ),
              ),
            ],
          ),
          if (sleepController.inicioEnCurso != null) ...[
            const SizedBox(height: 8),
            const Text('Registro de sueño en curso'),
          ],
          const SizedBox(height: 16),
          if (registros.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.bedtime_outlined),
                title: Text('Aún no hay noches registradas'),
                subtitle: Text('Empieza con el registro manual o rápido.'),
              ),
            )
          else ...[
            _SleepScoreCard(puntaje: puntaje),
            const SizedBox(height: 16),
            _TarjetaUltimoRegistro(
              registro: registros.first,
              progreso:
                  (registros.first.duracion.inMinutes /
                          (usuario.metaHoras * 60))
                      .clamp(0.0, 1.0),
              meta: usuario.metaHoras,
            ),
            const SizedBox(height: 18),
            _GraficaSemanal(registros: registros),
            const SizedBox(height: 18),
            _Resumen(registros: registros, meta: usuario.metaHoras),
            const SizedBox(height: 18),
            ...const RecomendacionesService()
                .generar(registros: registros, metaHoras: usuario.metaHoras)
                .map(
                  (recomendacion) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.tips_and_updates_outlined),
                      title: Text(recomendacion.titulo),
                      subtitle: Text(recomendacion.detalle),
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights, color: AppConstants.coral),
              title: const Text('Tus estadísticas'),
              subtitle: const Text('Explora tus patrones de descanso'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StatisticsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.watch_outlined),
              title: const Text('Dispositivos inteligentes'),
              subtitle: const Text('Sincroniza con un wearable'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const DevicesScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaUltimoRegistro extends StatelessWidget {
  const _TarjetaUltimoRegistro({
    required this.registro,
    required this.progreso,
    required this.meta,
  });
  final RegistroSueno registro;
  final double progreso;
  final double meta;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    child: Container(
      decoration: const BoxDecoration(gradient: AppConstants.degradado),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime, color: AppConstants.coral),
              const SizedBox(width: 9),
              const Expanded(child: Text('Sueño de anoche')),
              Text(
                SleepUtils.fecha(registro.inicio),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            SleepUtils.formatoDuracion(registro.duracion),
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < registro.calidad
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 22,
                color: AppConstants.ambar,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.arrow_downward,
                size: 16,
                color: AppConstants.coral,
              ),
              const SizedBox(width: 6),
              Text(SleepUtils.hora(registro.inicio)),
              const SizedBox(width: 20),
              const Icon(
                Icons.wb_sunny_outlined,
                size: 16,
                color: AppConstants.ambar,
              ),
              const SizedBox(width: 6),
              Text(SleepUtils.hora(registro.fin)),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progreso),
              duration: const Duration(milliseconds: 700),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Meta: ${meta.toStringAsFixed(1)} h',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _SleepScoreCard extends StatelessWidget {
  const _SleepScoreCard({required this.puntaje});

  final int puntaje;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: puntaje / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 7,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    '$puntaje',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntaje de sueño',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                const Text('Duración, calidad y regularidad'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _GraficaSemanal extends StatelessWidget {
  const _GraficaSemanal({required this.registros});
  final List<RegistroSueno> registros;

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final datos = List.generate(7, (indice) {
      final dia = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
      ).subtract(Duration(days: 6 - indice));
      final registro = registros
          .where(
            (item) =>
                item.inicio.year == dia.year &&
                item.inicio.month == dia.month &&
                item.inicio.day == dia.day,
          )
          .firstOrNull;
      return (
        SleepUtils.dia(dia),
        registro?.duracion.inMinutes.toDouble() ?? 0,
      );
    });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Últimos 7 días',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: datos.map((dato) {
                  final alto = dato.$2 == 0
                      ? 5.0
                      : math.max(8.0, dato.$2 / 600 * 76);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: alto),
                          duration: const Duration(milliseconds: 650),
                          builder: (context, value, _) => Container(
                            height: value,
                            width: 18,
                            decoration: BoxDecoration(
                              color: dato.$2 == 0
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                  : null,
                              gradient: dato.$2 == 0
                                  ? null
                                  : AppConstants.degradado,
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dato.$1,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.registros, required this.meta});
  final List<RegistroSueno> registros;
  final double meta;

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final inicioDia = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
    ).subtract(const Duration(days: 6));
    final semana = registros
        .where((registro) => !registro.inicio.isBefore(inicioDia))
        .toList();
    final promedio = semana.isEmpty
        ? 0.0
        : semana.map((r) => r.duracion.inMinutes).reduce((a, b) => a + b) /
              semana.length /
              60;
    return Row(
      children: [
        Expanded(
          child: _DatoResumen(
            titulo: 'Promedio semanal',
            valor: SleepUtils.formatoHoras(promedio),
            icono: Icons.auto_awesome,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DatoResumen(
            titulo: 'Meta nocturna',
            valor: '${meta.toStringAsFixed(1)} h',
            icono: Icons.flag_outlined,
          ),
        ),
      ],
    );
  }
}

class _DatoResumen extends StatelessWidget {
  const _DatoResumen({
    required this.titulo,
    required this.valor,
    required this.icono,
  });
  final String titulo;
  final String valor;
  final IconData icono;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: AppConstants.coral),
          const SizedBox(height: 12),
          Text(valor, style: Theme.of(context).textTheme.titleLarge),
          Text(titulo, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}
