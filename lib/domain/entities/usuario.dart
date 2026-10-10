class Usuario {
  const Usuario({
    required this.nombre,
    required this.edad,
    required this.metaHoras,
    required this.horaIdeal,
  });

  final String nombre;
  final int edad;
  final double metaHoras;
  final String horaIdeal;

  factory Usuario.inicial() =>
      const Usuario(nombre: 'Alex', edad: 25, metaHoras: 8, horaIdeal: '22:30');

  Map<String, Object> toMap() => {
    'nombre': nombre,
    'edad': edad,
    'metaHoras': metaHoras,
    'horaIdeal': horaIdeal,
  };

  factory Usuario.fromMap(Map<dynamic, dynamic> map) => Usuario(
    nombre: map['nombre'] as String? ?? 'Alex',
    edad: (map['edad'] as num?)?.toInt() ?? 25,
    metaHoras: (map['metaHoras'] as num?)?.toDouble() ?? 8,
    horaIdeal: map['horaIdeal'] as String? ?? '22:30',
  );
}
