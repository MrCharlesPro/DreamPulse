import 'package:dreampulse/core/theme/app_theme.dart';
import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:dreampulse/presentation/widgets/monthly_sleep_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra calendario mensual y permite cambiar de mes', (
    tester,
  ) async {
    final ahora = DateTime.now();
    final registro = RegistroSueno(
      id: 'mensual',
      inicio: DateTime(ahora.year, ahora.month, 1, 22),
      fin: DateTime(ahora.year, ahora.month, 2, 6),
      calidad: 4,
      origen: OrigenRegistro.manual,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.oscuro(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: MonthlySleepGrid(noches: [registro], metaHoras: 8),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Horas'), findsOneWidget);
    expect(find.text('Calidad'), findsWidgets);
    expect(find.byTooltip('Mes siguiente'), findsOneWidget);
    await tester.tap(find.byTooltip('Mes siguiente'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
