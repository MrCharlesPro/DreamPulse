import 'package:flutter/material.dart';

import '../../domain/entities/registro_sueno.dart';

class HistoryController extends ChangeNotifier {
  DateTime? _desde;
  DateTime? _hasta;
  OrigenRegistro? _origen;
  bool _masRecientePrimero = true;
  String _busqueda = '';
  DateTime _mesSeleccionado = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime? get desde => _desde;
  DateTime? get hasta => _hasta;
  OrigenRegistro? get origen => _origen;
  bool get masRecientePrimero => _masRecientePrimero;
  String get busqueda => _busqueda;
  DateTime get mesSeleccionado => _mesSeleccionado;

  List<RegistroSueno> filtrar(List<RegistroSueno> registros) {
    final resultado =
        registros.where((registro) {
          final fechaRegistro = DateTime(
            registro.inicio.year,
            registro.inicio.month,
            registro.inicio.day,
          );
          final coincideFecha =
              (_desde == null || !fechaRegistro.isBefore(_desde!)) &&
              (_hasta == null ||
                  !fechaRegistro.isAfter(
                    DateTime(_hasta!.year, _hasta!.month, _hasta!.day),
                  ));
          final coincideBusqueda =
              _busqueda.isEmpty ||
              '${registro.inicio.day.toString().padLeft(2, '0')}/${registro.inicio.month.toString().padLeft(2, '0')}/${registro.inicio.year}'
                  .contains(_busqueda) ||
              '${registro.inicio.day}/${registro.inicio.month}/${registro.inicio.year}'
                  .contains(_busqueda);
          final coincideMes =
              fechaRegistro.year == _mesSeleccionado.year &&
              fechaRegistro.month == _mesSeleccionado.month;
          return coincideFecha &&
              coincideMes &&
              coincideBusqueda &&
              (_origen == null || registro.origen == _origen);
        }).toList()..sort(
          (a, b) => _masRecientePrimero
              ? b.inicio.compareTo(a.inicio)
              : a.inicio.compareTo(b.inicio),
        );
    return resultado;
  }

  void cambiarMes(int delta) {
    _mesSeleccionado = DateTime(
      _mesSeleccionado.year,
      _mesSeleccionado.month + delta,
    );
    notifyListeners();
  }

  void seleccionarRango(DateTimeRange? rango) {
    _desde = rango?.start;
    _hasta = rango?.end;
    notifyListeners();
  }

  void seleccionarOrigen(OrigenRegistro? origen) {
    _origen = origen;
    notifyListeners();
  }

  void alternarOrden() {
    _masRecientePrimero = !_masRecientePrimero;
    notifyListeners();
  }

  void buscar(String valor) {
    _busqueda = valor.trim();
    notifyListeners();
  }
}
