import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/usuario.dart';
import '../controllers/profile_controller.dart';
import '../controllers/settings_controller.dart';
import 'devices_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nombre = TextEditingController();
  final _edad = TextEditingController();
  double _meta = 8;
  TimeOfDay _horaIdeal = const TimeOfDay(hour: 22, minute: 30);
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.read<ProfileController>().cargando) return;
    if (!_inicializado) {
      final usuario = context.read<ProfileController>().usuario;
      _nombre.text = usuario.nombre;
      _edad.text = usuario.edad.toString();
      _meta = usuario.metaHoras;
      final partes = usuario.horaIdeal.split(':');
      _horaIdeal = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
      _inicializado = true;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _edad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final settings = context.watch<SettingsController>();
    if (controller.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return Center(child: Text(controller.error!));
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Tu perfil', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Personaliza tus objetivos de descanso.'),
        const SizedBox(height: 24),
        TextField(
          controller: _nombre,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _edad,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Edad',
            prefixIcon: Icon(Icons.cake_outlined),
          ),
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meta de sueño',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _meta,
                  min: 4,
                  max: 12,
                  divisions: 16,
                  label: '${_meta.toStringAsFixed(1)} h',
                  onChanged: (valor) => setState(() => _meta = valor),
                ),
                Center(
                  child: Text('${_meta.toStringAsFixed(1)} horas por noche'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.alarm, color: Color(0xFFC9BFFF)),
            title: const Text('Hora ideal de dormir'),
            subtitle: Text(_horaIdeal.format(context)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final seleccion = await showTimePicker(
                context: context,
                initialTime: _horaIdeal,
              );
              if (seleccion != null) setState(() => _horaIdeal = seleccion);
            },
          ),
        ),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: () async {
            final edad = int.tryParse(_edad.text);
            if (_nombre.text.trim().isEmpty ||
                edad == null ||
                edad < 1 ||
                edad > 120) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Revisa el nombre y la edad ingresados.'),
                ),
              );
              return;
            }
            final perfilActualizado = Usuario(
              nombre: _nombre.text.trim(),
              edad: edad,
              metaHoras: _meta,
              horaIdeal:
                  '${_horaIdeal.hour.toString().padLeft(2, '0')}:${_horaIdeal.minute.toString().padLeft(2, '0')}',
            );
            final profileController = context.read<ProfileController>();
            final settingsController = context.read<SettingsController>();
            await profileController.guardar(perfilActualizado);
            if (!context.mounted) return;
            if (settingsController.recordatorioActivo) {
              await settingsController.cambiarRecordatorio(
                true,
                perfilActualizado.horaIdeal,
              );
            }
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
          },
          child: const Text('Guardar perfil'),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.watch_outlined),
            title: const Text('Dispositivos'),
            subtitle: const Text('Vincula tu wearable'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DevicesScreen()),
            ),
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Recordatorio para dormir'),
            subtitle: Text('Todos los días a ${_horaIdeal.format(context)}'),
            value: settings.recordatorioActivo,
            onChanged: (activo) async {
              try {
                await settings.cambiarRecordatorio(
                  activo,
                  '${_horaIdeal.hour.toString().padLeft(2, '0')}:${_horaIdeal.minute.toString().padLeft(2, '0')}',
                );
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo actualizar: $error')),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
