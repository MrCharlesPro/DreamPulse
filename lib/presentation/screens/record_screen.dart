import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/sleep_utils.dart';
import '../../domain/entities/registro_sueno.dart';
import '../controllers/sleep_controller.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, this.registro});
  final RegistroSueno? registro;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late DateTime _inicio;
  late DateTime _fin;
  double _calidad = 4;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _inicio =
        widget.registro?.inicio ??
        DateTime(
          ahora.year,
          ahora.month,
          ahora.day,
        ).subtract(const Duration(days: 1)).add(const Duration(hours: 23));
    _fin = widget.registro?.fin ?? _inicio.add(const Duration(hours: 8));
    _calidad = (widget.registro?.calidad ?? 4).toDouble();
  }

  Future<DateTime?> _seleccionar(DateTime valor) async {
    final dia = await showDatePicker(
      context: context,
      initialDate: valor,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Selecciona el día',
    );
    if (!mounted || dia == null) return null;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(valor),
      helpText: 'Selecciona la hora',
    );
    if (!mounted || hora == null) return null;
    return DateTime(dia.year, dia.month, dia.day, hora.hour, hora.minute);
  }

  Future<void> _guardar() async {
    final finEfectivo = SleepUtils.fechaDespertar(_inicio, _fin);
    final duracion = finEfectivo.difference(_inicio);
    if (duracion.inMicroseconds <= 0 || duracion > const Duration(hours: 18)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La duración debe ser mayor a 0 y menor o igual a 18 horas.',
          ),
        ),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      await context.read<SleepController>().guardar(
        RegistroSueno(
          id: widget.registro?.id ?? const Uuid().v4(),
          inicio: _inicio,
          fin: finEfectivo,
          calidad: _calidad.round(),
          origen: widget.registro?.origen ?? OrigenRegistro.manual,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.registro == null
                ? '¡Sueño guardado!'
                : 'Registro actualizado',
          ),
        ),
      );
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duracion = SleepUtils.duracion(_inicio, _fin);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          widget.registro == null ? 'Registra tu sueño' : 'Editar registro',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text('Cada noche cuenta. Registra cómo descansaste.'),
        const SizedBox(height: 24),
        _SelectorHorario(
          titulo: 'Me fui a dormir',
          valor: _inicio,
          icono: Icons.nightlight_round,
          onTap: () async {
            final valor = await _seleccionar(_inicio);
            if (valor != null) setState(() => _inicio = valor);
          },
        ),
        const SizedBox(height: 12),
        _SelectorHorario(
          titulo: 'Me desperté',
          valor: _fin,
          icono: Icons.wb_sunny_outlined,
          onTap: () async {
            final valor = await _seleccionar(_fin);
            if (valor != null) setState(() => _fin = valor);
          },
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.hourglass_bottom, color: Color(0xFFC9BFFF)),
                const SizedBox(width: 12),
                const Expanded(child: Text('Duración total')),
                Text(
                  SleepUtils.formatoDuracion(duracion),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Cómo fue tu descanso?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Calidad'),
                    const Spacer(),
                    Text(
                      '${_calidad.round()} / 5',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Slider(
                  value: _calidad,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '${_calidad.round()} estrellas',
                  onChanged: (valor) => setState(() => _calidad = valor),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (indice) => Icon(
                      indice < _calidad.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_guardando ? 'Guardando…' : 'Guardar registro'),
          ),
        ),
      ],
    );
  }
}

class _SelectorHorario extends StatelessWidget {
  const _SelectorHorario({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.onTap,
  });
  final String titulo;
  final DateTime valor;
  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minVerticalPadding: 14,
      leading: Icon(icono, color: const Color(0xFFC9BFFF)),
      title: Text(titulo),
      subtitle: Text('${SleepUtils.fecha(valor)} · ${SleepUtils.hora(valor)}'),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onTap,
    ),
  );
}
