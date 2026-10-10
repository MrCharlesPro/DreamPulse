import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/sleep_utils.dart';
import '../../domain/entities/registro_sueno.dart';
import '../../domain/entities/resumen_mes_sueno.dart';
import '../../domain/services/monthly_sleep_service.dart';
import '../screens/record_screen.dart';

class MonthlySleepGrid extends StatefulWidget {
  const MonthlySleepGrid({
    super.key,
    required this.noches,
    required this.metaHoras,
    this.onMonthChanged,
  });

  final List<RegistroSueno> noches;
  final double metaHoras;
  final ValueChanged<DateTime>? onMonthChanged;

  @override
  State<MonthlySleepGrid> createState() => _MonthlySleepGridState();
}

class _MonthlySleepGridState extends State<MonthlySleepGrid>
    with SingleTickerProviderStateMixin {
  late DateTime _mes;
  late final AnimationController _animacion;
  bool _verCalidad = false;
  bool _reducirMovimiento = false;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _mes = DateTime(ahora.year, ahora.month);
    _animacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _animacion.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducirMovimiento = MediaQuery.of(context).disableAnimations;
    if (_reducirMovimiento && _animacion.value != 1) {
      _animacion.value = 1;
    }
  }

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  void _cambiarMes(int delta) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + delta);
      _animacion
        ..reset()
        ..forward();
    });
    widget.onMonthChanged?.call(_mes);
  }

  @override
  Widget build(BuildContext context) {
    final resumen = const MonthlySleepService().resumir(
      registros: widget.noches,
      mes: _mes,
      metaHoras: widget.metaHoras,
    );
    final registroPorDia = {
      for (final noche in resumen.noches)
        if (noche.registro != null) noche.dia: noche.registro!,
    };
    final escala = Theme.of(context).extension<SleepScale>()!;
    final mesTexto = const [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ][_mes.month - 1];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mes anterior',
                  onPressed: () => _cambiarMes(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '$mesTexto ${_mes.year}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Mes siguiente',
                  onPressed: () => _cambiarMes(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Center(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Horas')),
                  ButtonSegment(value: true, label: Text('Calidad')),
                ],
                selected: {_verCalidad},
                onSelectionChanged: (seleccion) =>
                    setState(() => _verCalidad = seleccion.first),
              ),
            ),
            const SizedBox(height: 12),
            _encabezado(context),
            const SizedBox(height: 4),
            RepaintBoundary(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    Column(
                      children: [
                        for (var dia = 1; dia <= resumen.noches.length; dia++)
                          _fila(
                            context,
                            dia,
                            registroPorDia[dia],
                            escala,
                            resumen.noches.length,
                          ),
                      ],
                    ),
                    Positioned(
                      left:
                          23 +
                          (constraints.maxWidth - 85) * widget.metaHoras / 12,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          width: 2,
                          color: AppConstants.coral.withValues(alpha: .72),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _leyenda(context, escala),
            const SizedBox(height: 14),
            _resumen(context, resumen),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) => Row(
    children: [
      const SizedBox(width: 23),
      Expanded(
        child: Row(
          children: List.generate(
            12,
            (index) => Expanded(
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 54,
        child: Text(
          'Calidad',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    ],
  );

  Widget _fila(
    BuildContext context,
    int dia,
    RegistroSueno? registro,
    SleepScale escala,
    int totalDias,
  ) {
    final horas = registro == null ? 0.0 : registro.duracion.inMinutes / 60.0;
    final color = registro == null
        ? Colors.transparent
        : _verCalidad
        ? escala.forQuality(registro.calidad)
        : escala.forHours(horas, widget.metaHoras);
    final progresoFila = (dia - 1) / totalDias * .72;
    return AnimatedBuilder(
      animation: _animacion,
      builder: (context, _) {
        final progreso =
            _reducirMovimiento || MediaQuery.disableAnimationsOf(context)
            ? 1.0
            : ((_animacion.value - progresoFila) / (1 - progresoFila)).clamp(
                0.0,
                1.0,
              );
        final aparicion = Curves.easeOutCubic.transform(progreso);
        final actual = horas * aparicion;
        final calidadVisible = progreso.clamp(0, 1);
        return SizedBox(
          height: 24,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: registro == null
                  ? null
                  : () => _detalle(context, registro),
              child: Row(
                children: [
                  SizedBox(
                    width: 23,
                    child: Text(
                      '$dia',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: List.generate(12, (indice) {
                        final relleno = (actual - indice).clamp(0.0, 1.0);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: 5,
                            ),
                            child: CustomPaint(
                              painter: _CeldaPintor(
                                color: color,
                                fraccion: relleno,
                                borde: AppConstants.textoSecundario.withValues(
                                  alpha: .22,
                                ),
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 54,
                    child: Row(
                      children: List.generate(5, (index) {
                        final activo =
                            registro != null &&
                            index < registro.calidad &&
                            calidadVisible > 0;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: activo
                                    ? escala.forQuality(registro.calidad)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: AppConstants.textoSecundario
                                      .withValues(alpha: .22),
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _leyenda(BuildContext context, SleepScale escala) => Wrap(
    spacing: 8,
    runSpacing: 6,
    children: [
      _leyendaPunto(context, escala.excellent, 'Meta+'),
      _leyendaPunto(context, escala.good, '90–99%'),
      _leyendaPunto(context, escala.fair, '75–89%'),
      _leyendaPunto(context, escala.low, '60–74%'),
      _leyendaPunto(context, escala.poor, '<60%'),
      _leyendaPunto(context, Colors.transparent, 'Sin registro', borde: true),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 2, height: 12, color: AppConstants.coral),
          const SizedBox(width: 4),
          const Text('Meta'),
        ],
      ),
    ],
  );

  Widget _leyendaPunto(
    BuildContext context,
    Color color,
    String texto, {
    bool borde = false,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: borde
              ? Border.all(color: AppConstants.textoSecundario)
              : null,
        ),
      ),
      const SizedBox(width: 4),
      Text(texto, style: Theme.of(context).textTheme.labelSmall),
    ],
  );

  Widget _resumen(BuildContext context, ResumenMesSueno resumen) {
    final mejor = resumen.mejor;
    final peor = resumen.peor;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _dato(context, 'Promedio', '${resumen.promedio.toStringAsFixed(1)} h'),
        _dato(context, 'En meta', '${resumen.nochesVerdes} noches'),
        _dato(context, 'Bajo 60%', '${resumen.nochesRojas} noches'),
        _dato(
          context,
          'Mejor',
          mejor == null
              ? '—'
              : '${mejor.inicio.day} · ${SleepUtils.formatoDuracion(mejor.duracion)}',
        ),
        _dato(
          context,
          'Peor',
          peor == null
              ? '—'
              : '${peor.inicio.day} · ${SleepUtils.formatoDuracion(peor.duracion)}',
        ),
      ],
    );
  }

  Widget _dato(BuildContext context, String titulo, String valor) => Chip(
    label: Text('$titulo: $valor'),
    backgroundColor: AppConstants.superficieAlta,
  );

  Future<void> _detalle(BuildContext context, RegistroSueno registro) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Material(
          color: AppConstants.superficie,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SleepUtils.fecha(registro.inicio),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Duración: ${SleepUtils.formatoDuracion(registro.duracion)}',
                ),
                Text(
                  'Horario: ${SleepUtils.hora(registro.inicio)} → ${SleepUtils.hora(registro.fin)}',
                ),
                Text('Calidad: ${registro.calidad} / 5'),
                Text(
                  'Origen: ${switch (registro.origen) {
                    OrigenRegistro.manual => 'Manual',
                    OrigenRegistro.simulado => 'Simulado',
                    OrigenRegistro.automatico => 'Automático',
                  }}',
                ),
                if (registro.notas.isNotEmpty) Text('Nota: ${registro.notas}'),
                if (registro.etiquetas.isNotEmpty)
                  Text(
                    'Etiquetas: ${registro.etiquetas.map((e) => e.titulo).join(', ')}',
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(this.context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => RecordScreen(registro: registro),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CeldaPintor extends CustomPainter {
  const _CeldaPintor({
    required this.color,
    required this.fraccion,
    required this.borde,
  });
  final Color color;
  final double fraccion;
  final Color borde;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    if (fraccion > 0) {
      final ancho = math.max(0.0, (size.width - 1) * fraccion);
      final relleno = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, ancho, size.height),
        const Radius.circular(3),
      );
      canvas.drawRRect(relleno, Paint()..color = color);
    }
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borde
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  @override
  bool shouldRepaint(covariant _CeldaPintor oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.fraccion != fraccion ||
      oldDelegate.borde != borde;
}
