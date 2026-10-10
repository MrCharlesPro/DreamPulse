import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../domain/entities/registro_sueno.dart';

class ExportService {
  Future<void> compartirCsv(List<RegistroSueno> registros) async {
    final filas = [
      'fecha,inicio,fin,duracion_min,calidad,origen,etiquetas,notas',
      ...registros.map(
        (registro) => [
          '${registro.inicio.year}-${registro.inicio.month.toString().padLeft(2, '0')}-${registro.inicio.day.toString().padLeft(2, '0')}',
          registro.inicio.toIso8601String(),
          registro.fin.toIso8601String(),
          '${registro.duracion.inMinutes}',
          '${registro.calidad}',
          registro.origen.name,
          registro.etiquetas.map((etiqueta) => etiqueta.name).join('|'),
          registro.notas,
        ].map(_csv).join(','),
      ),
    ];
    await _compartir('dream_pulse_historial.csv', filas.join('\r\n'));
  }

  Future<void> compartirPdf(List<RegistroSueno> registros) async {
    final documento = pw.Document();
    documento.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Header(
            level: 0,
            child: pw.Text('DreamPulse · Historial de sueño'),
          ),
          pw.TableHelper.fromTextArray(
            headers: const ['Fecha', 'Horario', 'Duración', 'Calidad'],
            data: registros
                .map(
                  (registro) => [
                    '${registro.inicio.day}/${registro.inicio.month}/${registro.inicio.year}',
                    '${registro.inicio.hour.toString().padLeft(2, '0')}:${registro.inicio.minute.toString().padLeft(2, '0')} - ${registro.fin.hour.toString().padLeft(2, '0')}:${registro.fin.minute.toString().padLeft(2, '0')}',
                    '${registro.duracion.inMinutes} min',
                    '${registro.calidad}/5',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}dream_pulse_historial.pdf',
    );
    await file.writeAsBytes(await documento.save());
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Mi historial DreamPulse'),
    );
  }

  Future<void> compartirRespaldo(List<RegistroSueno> registros) async {
    final json = const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'exportado': DateTime.now().toIso8601String(),
      'registros': registros.map((registro) => registro.toMap()).toList(),
    });
    await _compartir('dream_pulse_respaldo.json', json);
  }

  Future<List<RegistroSueno>?> seleccionarRespaldo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (resultado == null || resultado.files.isEmpty) return null;
    final archivo = resultado.files.single;
    final contenido = archivo.bytes == null
        ? await File(
            archivo.path ??
                (throw const FormatException(
                  'El archivo seleccionado no se pudo leer.',
                )),
          ).readAsString()
        : utf8.decode(archivo.bytes!);
    final datos = jsonDecode(contenido) as Map<String, dynamic>;
    final registros = datos['registros'] as List<dynamic>;
    return registros
        .map(
          (registro) => RegistroSueno.fromMap(
            Map<dynamic, dynamic>.from(registro as Map),
          ),
        )
        .toList();
  }

  Future<void> _compartir(String nombre, String contenido) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}${Platform.pathSeparator}$nombre');
    await file.writeAsString(contenido, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Exportación de DreamPulse'),
    );
  }

  String _csv(String valor) => '"${valor.replaceAll('"', '""')}"';
}
