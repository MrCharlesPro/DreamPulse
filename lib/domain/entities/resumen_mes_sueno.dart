import 'registro_sueno.dart';

class ResumenDiaSueno {
  const ResumenDiaSueno({required this.dia, this.registro});
  final int dia;
  final RegistroSueno? registro;
}

class ResumenMesSueno {
  const ResumenMesSueno({
    required this.noches,
    required this.promedio,
    required this.nochesVerdes,
    required this.nochesRojas,
    this.mejor,
    this.peor,
  });

  final List<ResumenDiaSueno> noches;
  final double promedio;
  final int nochesVerdes;
  final int nochesRojas;
  final RegistroSueno? mejor;
  final RegistroSueno? peor;
}
