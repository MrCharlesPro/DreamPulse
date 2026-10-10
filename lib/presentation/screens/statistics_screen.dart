import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../../presentation/controllers/sleep_controller.dart';
import '../controllers/stats_controller.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsController = context.watch<StatsController>();
    final sleepController = context.watch<SleepController>();
    final profile = context.watch<ProfileController>().usuario;
    if (sleepController.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (sleepController.error != null && sleepController.registros.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estadísticas')),
        body: Center(child: Text(sleepController.error!)),
      );
    }
    final datos = statsController.calcular(
      sleepController.registros,
      profile.metaHoras,
    );
    final recomendaciones = statsController.recomendaciones(
      sleepController.registros,
      profile.metaHoras,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: sleepController.registros.isEmpty
          ? const Center(
              child: Text('Registra algunas noches para ver estadísticas.'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 7, label: Text('7 días')),
                    ButtonSegment(value: 30, label: Text('30 días')),
                  ],
                  selected: {statsController.dias},
                  onSelectionChanged: (value) =>
                      statsController.cambiarRango(value.first),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ResumenMetrica(
                        titulo: 'Promedio',
                        valor: '${datos.promedioHoras.toStringAsFixed(1)} h',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ResumenMetrica(
                        titulo: 'Calidad',
                        valor:
                            '${datos.promedioCalidad.toStringAsFixed(1)} / 5',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ResumenMetrica(
                        titulo: 'Deuda promedio',
                        valor: '${datos.deudaHoras.toStringAsFixed(1)} h',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ResumenMetrica(
                        titulo: 'Variación al dormir',
                        valor:
                            '${datos.consistenciaHorario.toStringAsFixed(1)} h',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horas de sueño',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 190,
                          child: BarChart(
                            BarChartData(
                              minY: 0,
                              maxY: 12,
                              gridData: const FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: _titulos(datos.etiquetas),
                              barGroups: List.generate(
                                datos.horasPorNoche.length,
                                (index) => BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: datos.horasPorNoche[index],
                                      color: AppConstants.violeta,
                                      width: 14,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            duration: const Duration(milliseconds: 350),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calidad del descanso',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 160,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 5,
                              gridData: const FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: _titulos(datos.etiquetas),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                    datos.calidadPorNoche.length,
                                    (index) => FlSpot(
                                      index.toDouble(),
                                      datos.calidadPorNoche[index],
                                    ),
                                  ),
                                  isCurved: true,
                                  color: AppConstants.ambar,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppConstants.ambar.withValues(
                                      alpha: .12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(milliseconds: 350),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ritmo de descanso',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mejor noche: ${datos.mejorHoras.toStringAsFixed(1)} h · '
                          'Menor descanso: ${datos.peorHoras.toStringAsFixed(1)} h',
                        ),
                        Text(
                          'Hora media para dormir: ${datos.promedioInicio.toStringAsFixed(1)} h',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recomendaciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...recomendaciones.map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.tips_and_updates_outlined),
                      title: Text(item.titulo),
                      subtitle: Text(item.detalle),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  FlTitlesData _titulos(List<String> etiquetas) => FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: etiquetas.length > 10 ? 5 : 1,
        getTitlesWidget: (value, meta) {
          final indice = value.toInt();
          if (indice < 0 || indice >= etiquetas.length) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(etiquetas[indice], style: const TextStyle(fontSize: 9)),
          );
        },
      ),
    ),
  );
}

class _ResumenMetrica extends StatelessWidget {
  const _ResumenMetrica({required this.titulo, required this.valor});
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(titulo, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}
