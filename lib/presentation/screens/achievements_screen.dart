import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../controllers/profile_controller.dart';
import '../controllers/sleep_controller.dart';
import '../controllers/stats_controller.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sueno = context.watch<SleepController>();
    final meta = context.watch<ProfileController>().usuario.metaHoras;
    if (sueno.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (sueno.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Logros')),
        body: Center(child: Text(sueno.error!)),
      );
    }
    final logros = context.watch<StatsController>().logros(
      sueno.registros,
      meta,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Logros')),
      body: sueno.registros.isEmpty
          ? const Center(
              child: Text('Registra noches para desbloquear tus logros.'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: AppConstants.coral,
                          size: 34,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Racha actual',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${logros.first.progreso} noches cumpliendo tu meta',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...logros.map(
                  (logro) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: logro.desbloqueado
                            ? AppConstants.ambar.withValues(alpha: .16)
                            : AppConstants.superficieAlta,
                        child: Text(logro.icono),
                      ),
                      title: Text(logro.titulo),
                      subtitle: Text(
                        '${logro.detalle}\n${logro.progreso}/${logro.objetivo}',
                      ),
                      isThreeLine: true,
                      trailing: Icon(
                        logro.desbloqueado
                            ? Icons.check_circle
                            : Icons.lock_outline,
                        color: logro.desbloqueado
                            ? AppConstants.ambar
                            : AppConstants.textoSecundario,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
