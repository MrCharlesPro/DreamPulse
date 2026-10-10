# DreamPulse

Aplicación Android Flutter para registrar noches de sueño, revisar tendencias y mantener una rutina de descanso. Los registros y ajustes se guardan localmente con Hive; no se requiere cuenta ni conexión a internet para usar las funciones principales.

## Arquitectura

```text
presentation (pantallas, widgets y ChangeNotifier)
             ↓
domain (entidades, servicios de estadísticas y contratos)
             ↑
data (repositorios y fuentes Hive / JSON)

services (BLE, simulación de wearable, sincronización y avisos locales)
```

- `domain/` define los modelos de sueño, usuario, dispositivo y estadísticas, más los contratos de repositorio y reglas independientes de UI.
- `data/` implementa la persistencia Hive y carga inicial desde `assets/mock_sleep.json`.
- `services/` encapsula el acceso Bluetooth, la fuente simulada, la sincronización y las notificaciones.
- `presentation/` contiene pantallas y controladores Provider. `DashboardScreen` e `HistoryScreen` son `StatelessWidget`; el formulario de registro, perfil y navegación conservan estado local con `StatefulWidget`.
- `core/` concentra el tema oscuro, constantes de diseño, formateo y estados vacíos compartidos.

## Funciones

- Registro manual con fecha y hora, cruce de medianoche, duración calculada, validación y calidad de 1 a 5.
- Dashboard con último descanso, estrellas, progreso contra meta, gráfico semanal y resumen.
- Historial con búsqueda por fecha, rango, origen, orden, edición y eliminación con confirmación/deshacer.
- Perfil editable con edad, hora de descanso ideal y meta de 4 a 12 horas.
- Estadísticas para rangos de 7 y 30 días, calidad, promedio, mejor/peor noche, deuda y variación de hora.
- Consejos de higiene del sueño y recordatorio diario configurable.
- Wearable simulado para demostración sin reloj. El modo Bluetooth busca y conecta dispositivos BLE cercanos.

## Requisitos y ejecución

- Flutter/Dart compatibles con `environment.sdk: ^3.12.2`.
- Android con permisos Bluetooth y notificaciones; la primera compilación necesita resolver dependencias Gradle.

```powershell
flutter pub get
flutter run
```

La app carga `assets/mock_sleep.json` una única vez en el almacenamiento inicial. Si se borran los datos de la aplicación, se inicializa de nuevo desde el JSON.

## Pruebas y compilación

```powershell
flutter analyze
flutter test
flutter build apk --release
```

APK generado en `build/app/outputs/flutter-apk/app-release.apk`.

## Decisiones y limitaciones

- Hive almacena mapas sin generadores ni sincronización remota; los datos permanecen en el dispositivo.
- La fuente simulada crea noches ficticias y permite demostrar búsqueda, vinculación y sincronización de forma offline.
- BLE es dependiente del fabricante. La app maneja permisos, búsqueda, conexión y desconexión, pero no hay un perfil GATT universal para noches de sueño; integrar lecturas reales requiere el servicio/características documentados por el wearable objetivo.
- `flutter_blue_plus` requiere cumplir su licencia correspondiente al tipo de distribución. Esta versión selecciona la categoría educativa/no lucrativa.
- Google Fonts tiene desactivada la descarga en ejecución para mantener el comportamiento offline; si Poppins no está disponible localmente se usa la fuente de sistema.
- El APK usa firma de depuración para facilitar la instalación de evaluación. Para publicar en Play Store, configura firma de release propia.

## Capturas

Pendientes de agregar desde un dispositivo o emulador Android.
