import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/widgets/boton_degradado.dart';
import '../../core/utils/sleep_utils.dart';
import '../../domain/entities/etiqueta_sueno.dart';
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
  late final TextEditingController _notas;
  late final Set<EtiquetaSueno> _etiquetas;

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
    _notas = TextEditingController(text: widget.registro?.notas ?? '');
    _etiquetas = {...?widget.registro?.etiquetas};
  }

  @override
  void dispose() {
    _notas.dispose();
    super.dispose();
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
          notas: _notas.text.trim(),
          etiquetas: _etiquetas.toList(),
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

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text('Esta noche se quitará del historial.'),
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
    if (confirmar != true || !mounted) return;
    try {
      await context.read<SleepController>().eliminar(widget.registro!.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro eliminado')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final duracion = SleepUtils.duracion(_inicio, _fin);
    final formulario = ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.registro == null)
          Text(
            'Registra tu sueño',
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
                const Icon(Icons.hourglass_bottom, color: AppConstants.coral),
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
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notas de la noche',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notas,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    hintText: '¿Algo que quieras recordar?',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Etiquetas',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: EtiquetaSueno.values
                      .map(
                        (etiqueta) => FilterChip(
                          label: Text(
                            '${etiqueta.emoticon} ${etiqueta.titulo}',
                          ),
                          selected: _etiquetas.contains(etiqueta),
                          onSelected: (seleccionado) => setState(() {
                            if (seleccionado) {
                              _etiquetas.add(etiqueta);
                            } else {
                              _etiquetas.remove(etiqueta);
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        BotonDegradado(
          height: 54,
          onPressed: _guardando ? null : _guardar,
          icon: _guardando
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(
            _guardando
                ? 'Guardando…'
                : widget.registro == null
                ? 'Guardar registro'
                : 'Guardar cambios',
          ),
        ),
        if (widget.registro != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _guardando ? null : _eliminar,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
    if (widget.registro == null) {
      return SingleChildScrollView(child: formulario);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar registro'),
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Eliminar registro',
            onPressed: _guardando ? null : _eliminar,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(child: SingleChildScrollView(child: formulario)),
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
      leading: Icon(icono, color: Theme.of(context).colorScheme.primary),
      title: Text(titulo),
      subtitle: Text('${SleepUtils.fecha(valor)} · ${SleepUtils.hora(valor)}'),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onTap,
    ),
  );
}
