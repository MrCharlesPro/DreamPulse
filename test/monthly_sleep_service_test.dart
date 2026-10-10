import 'package:dreampulse/domain/services/monthly_sleep_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clasifica las horas según su cercanía a la meta', () {
    expect(MonthlySleepService.bandForHours(8, 8), SleepBand.green);
    expect(MonthlySleepService.bandForHours(7.2, 8), SleepBand.lime);
    expect(MonthlySleepService.bandForHours(6, 8), SleepBand.amber);
    expect(MonthlySleepService.bandForHours(4.8, 8), SleepBand.orange);
    expect(MonthlySleepService.bandForHours(4, 8), SleepBand.red);
    expect(MonthlySleepService.bandForHours(0, 8), SleepBand.empty);
  });

  test('clasifica las cinco bandas de calidad', () {
    expect(MonthlySleepService.bandForQuality(5), SleepBand.green);
    expect(MonthlySleepService.bandForQuality(4), SleepBand.lime);
    expect(MonthlySleepService.bandForQuality(3), SleepBand.amber);
    expect(MonthlySleepService.bandForQuality(2), SleepBand.orange);
    expect(MonthlySleepService.bandForQuality(1), SleepBand.red);
  });
}
