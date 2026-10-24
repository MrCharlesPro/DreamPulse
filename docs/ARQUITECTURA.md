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
        │     └── services/      Reglas de estadísticas, logros e insights
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
| `MetaSueno` | Representa la meta de descanso utilizada para evaluar una noche. |
| `EtiquetaSueno` | Catálogo de etiquetas contextuales asociadas a una noche. |
| `PuntajeSueno` | Desglosa el puntaje de 0 a 100 entre duración, calidad y regularidad. |
| `Logro` | Describe progreso y desbloqueo de hitos de descanso. |
| `ResumenDiaSueno`, `ResumenMesSueno` | Agregados diarios/mensuales para la tabla de sueño. |
| `OrigenRegistro` | Distingue registros manuales, simulados y automáticos. |
| `Usuario` | Perfil, objetivo en horas y hora ideal para dormir. |
| `Dispositivo`, `NocheDispositivo`, `EstadoDispositivo` | Modelan el wearable y datos/estado de conexión. |
| `EstadisticasSueno` | Resultados agregados de un periodo elegido. |
| `Recomendacion` | Consejo generado por reglas locales. |
| `SleepRepository`, `ProfileRepository` | Contratos de acceso a noches y perfil. |
| `EstadisticasService` | Filtra periodos y calcula promedio, calidad, variación y deuda. |
| `RecomendacionesService` | Aplica reglas sencillas de higiene del sueño. |
| `MonthlySleepService` | Clasifica duración/calidad por bandas y agrega los resúmenes del mes. |
| `SleepScoreService` | Calcula puntaje por duración, calidad y regularidad de horarios. |
| `AchievementService` | Calcula rachas y logros locales. |
| `SleepInsightService` | Busca asociaciones simples entre etiquetas y calidad. |

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
| `ExportService` | Genera CSV/PDF compartibles y respalda/restaura datos en JSON local. |
| `HiveAuthSessionRepository` | Conserva únicamente el indicador booleano de sesión en una caja Hive separada. |

### Presentación

| Clase | Responsabilidad |
|---|---|
| `SleepController` | Estado, carga, guardado y eliminación del historial. |
| `ExportController` | Expone estados de carga/error/vacío para exportar y restaurar respaldos. |
| `ProfileController` | Carga y actualización del perfil. |
| `HistoryController` | Búsqueda, rango de fechas, origen y orden del historial. |
| `StatsController` | Selección del periodo y exposición de agregados/recomendaciones. |
| `DeviceController` | Cambia entre modo demo/BLE, búsqueda, conexión y sincronización. |
| `SettingsController` | Estado persistente del recordatorio diario. |
| `AuthController` | Carga el indicador de sesión, autentica, aplica bloqueo temporal y cierra sesión sin exponer datos sensibles. |
| `HomeScreen` | Navegación inferior con estado local de pestaña. |
| `AuthGate` | Muestra carga/login o la navegación principal según el estado de sesión. |
| `LoginScreen` | Captura credenciales con longitud limitada y contraseña oculta; presenta errores genéricos. |
| `DashboardScreen` | Resumen del sueño, barras semanales, consejos y accesos rápidos. |
| `RecordScreen` | Alta/edición manual con validación de duración. |
| `HistoryScreen` | Lista y filtros; elimina con confirmación y opción deshacer. |
| `ProfileScreen` | Edición de preferencias personales y recordatorio. |
| `StatisticsScreen` | Visualización con `fl_chart` para 7/30 días. |
| `MonthlySleepGrid` | Tabla mensual animada, resumen del mes y detalle de cada noche. |
| `AchievementsScreen` | Visualiza racha actual y logros desbloqueados/pendientes. |
| `ExportScreen` | Acciones para compartir exportaciones y restaurar respaldos. |
| `DevicesScreen` | Búsqueda y vinculación BLE/demo con estado visible. |

## Persistencia y flujo

Las cajas Hive son `registros`, `perfil` y `ajustes`. Al abrir por primera vez, si no existen noches locales, el repositorio importa el JSON y escribe la marca `datosInicialesCargados`. El registro manual guarda directamente a través de `SleepController`; el flujo de wearable pasa por `SyncService`, deduplica por fecha de inicio y luego recarga el controlador para reflejar cambios en inicio e historial. El inicio rápido guarda su marca temporal en `ajustes`; CSV/PDF se generan en el directorio temporal para compartirlos, mientras que el respaldo JSON se elige mediante el selector de archivos.

El acceso requiere una sesión local booleana en la caja `sesion`. `LoginValidator` valida campos en el dominio; `AuthenticationService` aplica SHA-256 con sal a la clave de demostración; `AuthController` gestiona intentos y bloqueo de 30 segundos. No se guardan contraseñas ni se escriben datos del formulario en logs. Es un acceso local de demostración, no autenticación de producción.
