enum OrigenRegistro { manual, simulado, automatico }

class RegistroSueno {
  const RegistroSueno({
    required this.id,
    required this.inicio,
    required this.fin,
    required this.calidad,
    required this.origen,
  });

  final String id;
  final DateTime inicio;
  final DateTime fin;
  final int calidad;
  final OrigenRegistro origen;

  Duration get duracion => fin.difference(inicio);
  DateTime get fecha => DateTime(inicio.year, inicio.month, inicio.day);

  Map<String, Object> toMap() => {
    'id': id,
    'inicio': inicio.toIso8601String(),
    'fin': fin.toIso8601String(),
    'calidad': calidad,
    'origen': origen.name,
  };

  factory RegistroSueno.fromMap(Map<dynamic, dynamic> map) => RegistroSueno(
    id: map['id'] as String,
    inicio: DateTime.parse(map['inicio'] as String),
    fin: DateTime.parse(map['fin'] as String),
    calidad: (map['calidad'] as num).toInt(),
    origen: OrigenRegistro.values.firstWhere(
      (valor) => valor.name == map['origen'],
      orElse: () => OrigenRegistro.manual,
    ),
  );
}
