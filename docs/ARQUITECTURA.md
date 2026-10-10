# Arquitectura de DreamPulse

## Capas y dependencias

```text
main.dart
  └── app.dart (Hive, inyección de dependencias, Provider y tema)
        ├── presentation/
        │     ├── screens/       Interacción, accesibilidad y composición visual
        │     ├── widgets/       Componentes de presentación reutilizables
        │     └── controllers/   Estado de pantalla y coordinación de casos de uso
        ├── domain/
        │     ├── entities/      Modelos inmutables y enumeraciones
        │     ├── repositories/  Contratos de persistencia
        │     └── services/      Reglas de estadísticas y recomendaciones
        ├── data/
        │     ├── datasources/   Hive y JSON local inicial
        │     └── repositories/  Implementaciones de contratos
        ├── services/            Adaptadores BLE, recordatorio y sincronización
        └── core/                Tema, constantes, formato y estados compartidos
```

Las pantallas dependen de controladores y contratos del dominio, no de Hive. `app.dart` crea implementaciones concretas y las inyecta con Provider. La carga de demostración usa una marca persistente en la caja `ajustes`.

## Clases

### Dominio

| Clase | Responsabilidad |
|---|---|
| `RegistroSueno` | Representa una noche y convierte su contenido a/desde mapas Hive. |
| `OrigenRegistro` | Distingue registros manuales, simulados y automáticos. |
| `Usuario` | Perfil, objetivo en horas y hora ideal para dormir. |
| `Dispositivo`, `NocheDispositivo`, `EstadoDispositivo` | Modelan el wearable y datos/estado de conexión. |
| `EstadisticasSueno` | Resultados agregados de un periodo elegido. |
| `Recomendacion` | Consejo generado por reglas locales. |
| `SleepRepository`, `ProfileRepository` | Contratos de acceso a noches y perfil. |
| `EstadisticasService` | Filtra periodos y calcula promedio, calidad, variación y deuda. |
| `RecomendacionesService` | Aplica reglas sencillas de higiene del sueño. |

### Datos

| Clase | Responsabilidad |
|---|---|
| `HiveSleepDataSource` | Lee/escribe/elimina mapas de noches en Hive. |
| `MockSleepDataSource` | Decodifica noches de `assets/mock_sleep.json`. |
| `HiveSleepRepository` | Implementa el contrato de sueño y realiza una sola importación de datos iniciales. |
| `HiveProfileRepository` | Persiste el perfil como mapa Hive. |

### Servicios

| Clase | Responsabilidad |
|---|---|
| `WearableService` | API común de búsqueda, conexión y lectura de noches de wearable. |
| `BleWearableService` | Permisos Android, descubrimiento y conexión BLE; informa incompatibilidad de protocolo con claridad. |
| `SimulatedWearableService` | Proporciona wearables y noches sintéticas deterministas para pruebas y demostración. |
| `SyncService` | Convierte noches del wearable a `RegistroSueno` y evita repetir fechas existentes. |
| `NotificationService` | Programa/cancela recordatorios diarios por hora local y solicita permiso. |

### Presentación

| Clase | Responsabilidad |
|---|---|
| `SleepController` | Estado, carga, guardado y eliminación del historial. |
| `ProfileController` | Carga y actualización del perfil. |
| `HistoryController` | Búsqueda, rango de fechas, origen y orden del historial. |
| `StatsController` | Selección del periodo y exposición de agregados/recomendaciones. |
| `DeviceController` | Cambia entre modo demo/BLE, búsqueda, conexión y sincronización. |
| `SettingsController` | Estado persistente del recordatorio diario. |
| `HomeScreen` | Navegación inferior con estado local de pestaña. |
| `DashboardScreen` | Resumen del sueño, barras semanales, consejos y accesos rápidos. |
| `RecordScreen` | Alta/edición manual con validación de duración. |
| `HistoryScreen` | Lista y filtros; elimina con confirmación y opción deshacer. |
| `ProfileScreen` | Edición de preferencias personales y recordatorio. |
| `StatisticsScreen` | Visualización con `fl_chart` para 7/30 días. |
| `DevicesScreen` | Búsqueda y vinculación BLE/demo con estado visible. |

## Persistencia y flujo

Las cajas Hive son `registros`, `perfil` y `ajustes`. Al abrir por primera vez, si no existen noches locales, el repositorio importa el JSON y escribe la marca `datosInicialesCargados`. El registro manual guarda directamente a través de `SleepController`; el flujo de wearable pasa por `SyncService`, deduplica por fecha de inicio y luego recarga el controlador para reflejar cambios en inicio e historial.
