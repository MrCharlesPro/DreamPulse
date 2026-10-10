enum EtiquetaSueno {
  cafe('Café', '☕'),
  estres('Estrés', '🌧'),
  ejercicio('Ejercicio', '🏃'),
  pantalla('Pantalla', '📱'),
  alcohol('Alcohol', '🍷');

  const EtiquetaSueno(this.titulo, this.emoticon);
  final String titulo;
  final String emoticon;

  static EtiquetaSueno? desdeNombre(String nombre) {
    for (final etiqueta in values) {
      if (etiqueta.name == nombre) return etiqueta;
    }
    return null;
  }
}
