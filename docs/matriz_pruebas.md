# Matriz de pruebas · G62-2 Reservas

**Build final probada:** 1.0.0+1 · `G62-2_Reservas_v1.0.0+1.apk` (release, firma de depuracion)
**Fechas de ejecucion:** 2026-10-22 (automatizadas), 2026-10-23 y 2026-10-31 (APK en emulador y reglas contra el servidor), 2026-11-04 (reorganizacion segun la guia de la clase 14, tema morado y capturas repetidas), 2026-11-09 (revision final: seed nuevo, BUG-11 y BUG-12, concurrencia simultanea, reinicio sin red)
**Dispositivo:** Android Emulator `Medium_Phone` · `sdk_gphone64_x86_64` · Android 14 (API 34) · zona horaria del telefono en **UTC** a proposito (ver BUG-09)
**Origen de datos:** `https://reservas-g62-2.web.app/api/mesas.json`
**Proyecto Firebase:** `reservas-g62-2`
**Cuentas:** `cliente@`, `cliente2@`, `admin@`, `anfitrion@` (`@g62reservas.test`), creadas con `tool/seed/seed.mjs`. La clave se comparte por el medio privado del curso.

Cada caso indica precondicion, pasos, que se esperaba, que ocurrio y con que
evidencia se comprobo. Un caso sin evidencia verificable se marca NO EJECUTADO;
no se asume aprobado. Las capturas estan en [`docs/evidencia/`](evidencia/).

**Resumen:** 27 casos · 27 PASA · 0 PASA (parcial) · 0 NO EJECUTADO · 0 FALLA.

| ID | Precondicion | Cuenta / rol | Pasos | Esperado | Obtenido | Estado | Version | Evidencia |
|----|--------------|--------------|-------|----------|----------|--------|---------|-----------|
| CP-01 | Correo/contrasena habilitado; correo no registrado | nuevo usuario | "No tengo cuenta" → nombre, correo, clave → Crear cuenta | Entra como Cliente; `users/{uid}.rol = cliente` | Entra a "Mesas · QA Registro · Cliente" (`qa.registro.1104@`). Firestore: `users/s1o0YqoC…` con `rol=cliente` | **PASA** | 1.0.0+1 release | `CP-01_registro_cliente.png` |
| CP-02 | Cuentas de prueba creadas | `cliente@` | (a) iniciar sesion con clave incorrecta; (b) registrar con `correo-malo` y clave `123`; (c) registrar con un correo existente | Mensajes claros, sin trazas; no se envia dos veces | (a) "Correo o contrasena incorrectos." (b) "El correo no es valido" y "Minimo 6 caracteres" sin llamar a Firebase (c) "Ya existe una cuenta con ese correo." Logcat solo `[WARNING] ... email-already-in-use` / `invalid-credential` | **PASA** | 1.0.0+1 release | `CP-02_validaciones_registro.png`, `CP-02_usuario_existente.png`, `test/auth_messages_test.dart` |
| CP-03 | Reglas desplegadas | cliente, anfitrion | UI: entrar como cliente. Servidor: `tool/qa/reglas_check.mjs` con el token de cada cuenta | El cliente no ve tableros; el servidor rechaza acciones de otro rol | La navegacion del cliente solo tiene Mesas y Mis reservas. R-03 cambiar su rol → `403`; R-04 cliente confirma → `403`; R-06 anfitrion confirma → `403`; R-07 borrar reserva → `403` | **PASA** | reglas 2026-10-23 | Seccion "Reglas contra el servidor" |
| CP-04 | Laura con reservas guardadas en el telefono | `cliente@` → `cliente2@` | Cerrar sesion, entrar como Mateo, Mis reservas → Todas | Mateo no ve nada de Laura; el servidor no le deja leerlas | Mateo ve solo las suyas (Solicitadas 6 nov, Rechazada 5 nov, Confirmada hoy 19:30 en Mesa 3). Servidor: R-02 → `403`. Test `cada cuenta solo ve y sincroniza sus propias reservas` | **PASA** | 1.0.0+1 release | `CP-04_cambio_de_cuenta.png` |
| CP-05 | Con conexion | `cliente@` | Abrir la pestana Mesas | 8 mesas como modelos `Mesa` | "8 mesas en el salon" con capacidad, ubicacion y caracteristicas. `GET` → `200`, 8 elementos | **PASA** | 1.0.0+1 release | `CP-07_reintentar_ok.png`, `test/mesa_service_test.dart` |
| CP-06 | Build con `--dart-define=CATALOGO_URL=.../mesas_vacio.json` | `cliente@` | Abrir la pestana Mesas | `EmptyView`, sin mensaje de error | "Todavia no hay mesas disponibles" | **PASA** | 1.0.0+1 debug | `CP-06_catalogo_vacio.png` |
| CP-07 | Modo avion, app reiniciada | `cliente@` | Abrir Mesas sin red → quitar modo avion → Reintentar | `ErrorView` con mensaje util y Reintentar; luego los datos | "No pudimos cargar las mesas · No hay conexion. Revisa tu internet" + Reintentar → "8 mesas en el salon". Tests de 404, 500, JSON invalido y timeout | **PASA** | 1.0.0+1 release | `CP-07_catalogo_sin_conexion.png`, `CP-07_reintentar_ok.png` |
| CP-08 | Solicitud pendiente guardada | `cliente@` | `am force-stop` y reabrir la app | La solicitud sigue en Mis reservas; la sesion se restaura | Sigue "Solicitada · Pendiente de envio" leida de Drift; entra sin pedir clave | **PASA** | 1.0.0+1 release | Ejecucion 2026-10-23 |
| CP-09 | Modo avion | `cliente@` | Solicitar reserva hoy 19:30 | Se guarda en Drift como pendiente; estado del negocio separado del de sincronizacion | Banner "Sin conexion...", aviso "Guardada en el telefono. Se enviara cuando haya conexion.", tarjeta "Solicitada" + "Pendiente de envio" + motivo, boton "Sincronizar pendientes (1)" | **PASA** | 1.0.0+1 release | Ejecucion 2026-10-23, test `sin conexion: se guarda en Drift como pendiente` |
| CP-10 | CP-09 hecho | `cliente@` | Quitar modo avion | Se envia sola, con el mismo id, una sola vez | Pasa a "Sincronizada" sin tocar nada. Firestore: 1 solo documento (`1ee30333…`, `dia=2026-10-23`, `franjaId=20261023-1930`) | **PASA** | 1.0.0+1 release | Ejecucion 2026-10-23, tests de sincronizacion |
| CP-11 | Reserva confirmada por el admin; respuesta del envio perdida | cliente + admin | Reintentar el envio del cliente | El reintento no revierte la confirmacion | Remoto y local quedan `CONFIRMADA` (la creacion es una transaccion que no sobrescribe un documento existente) | **PASA** | 1.0.0+1 (test) | `un reintento no sobrescribe la confirmacion del administrador` |
| CP-12 | El servidor rechaza la creacion | `cliente@` | Enviar; luego sincronizar; luego Corregir | Guarda el motivo, no se reenvia solo; Corregir reenvia con el mismo id | `syncPending` → `(0, 0)` mientras hay conflicto; tras corregir: mismo id, `localVersion 2`, sincronizada | **PASA** | 1.0.0+1 (test) | `rechazo del servidor...`, `corregir un intento rechazado...` |
| CP-13 | Reservas de prueba | todos | 9 personas, franja pasada, hora fuera de franja, finalizar sin EN_MESA, cancelar a menos de 2 h | Cada intento se bloquea con su mensaje | Tests de reglas (19). Servidor: R-08 9 personas → `403`, R-09 en el pasado → `403`. APK: la reserva de Laura de hoy 19:30, abierta a las 19:12, muestra "Ya no se puede cancelar: el plazo termina 2 horas antes del inicio." | **PASA** | 1.0.0+1 release | `CP-13_cancelar_fuera_de_plazo.png`, `test/reserva_rules_test.dart` |
| CP-14 | Grupo de 7 el 2 nov 21:00; M07 bloqueada | `admin@` | Asignar mesa a la solicitud de 7; asignar a la de 3 personas tocando una mesa de 2 | Una mesa pequena no se puede asignar | Hoja: "Capacidad 2/3/4/6: no alcanza para 7", M07 "Ocupada o bloqueada", "No hay mesas libres con capacidad suficiente". Tocar Mesa 1 (2 p) para el grupo de 3 no hace nada. Servidor: E1 → `403` | **PASA** | 1.0.0+1 release | Ejecuciones 2026-10-23 y 2026-10-31, test `escenario 1` |
| CP-15 | Dos solicitudes en la misma franja | `admin@` | Confirmar A y B en la misma mesa | Solo una ocupa la mesa | Servidor: E2-a `200`, E2-b misma mesa y franja `403`, E2-c otra mesa `200`. Test con `Future.wait`: 1 exito + 1 `MesaOcupada` | **PASA** | reglas 2026-10-23 | Seccion "Reglas contra el servidor" |
| CP-16 | Laura (M01) y Mateo (M03) confirmados hoy 19:30 desde la app; una reserva QA de Mateo confirmada hoy 18:00 (M02) creada por script para la ausencia | `anfitrion@` | (a) 19:11: ver Recepcion; (b) 19:15: Registrar llegada y Finalizar a Laura; (c) 19:35: Marcar ausente a la reserva QA | (a) EN_MESA bloqueado fuera del margen; (b) CONFIRMADA → EN_MESA → FINALIZADA; (c) AUSENTE solo despues de +15 min y queda en el historial | (a) "Registrar llegada" deshabilitado con "Llegada desde 19:15 hasta 19:45" (telefono en UTC). (b) A las 19:15:39 los botones se habilitan; Laura pasa a "En mesa" (En mesa 1) y luego a "Finalizada" con "Se libera Mesa 1 · Ventana". (c) La reserva de las 18:00 sale "Confirmada · vencida" con "Registrar llegada" deshabilitado y "Marcar ausente"; dialogo "Mateo Cliente no llego. La reserva queda en el historial como AUSENTE."; la tarjeta queda "Ausente". Firestore: `qa-ausente-1104` `AUSENTE`, v3, con `ausenteAt` y sin `llegadaAt`. Servidor: E3 llegada fuera de margen → `403`, R-07 borrar → `403` | **PASA** | 1.0.0+1 release | `CP-16_llegada_bloqueada_fuera_de_margen.png`, `CP-16_llegada_habilitada_en_ventana.png`, `CP-16_laura_en_mesa.png`, `CP-16_laura_finalizada.png`, `CP-16_ausente_disponible.png`, `CP-16_mateo_ausente_historial.png` |
| CP-17 | Build debug; Crashlytics habilitado | `cliente@` | (a) Menu ⋮ → "Evento de prueba Crashlytics" → Firebase Console → Crashlytics → Errores recuperables; (b) Menu ⋮ → "Forzar crash fatal" → reabrir la app | (a) El evento aparece en la consola con version y dispositivo; (b) la app se cierra y el reporte se envia al reabrir; el APK release no tiene estas opciones | (a) Consola: "Error recuperable · FlutterError - Exception: Evento de prueba controlado G62-2", version 1.0.0, 1 evento, 1 usuario (31-oct). El 4-nov el mismo evento sale por `CrashService.simulateNonFatalError` (logcat `FIREBASE CRASHLYTICS ... _eventoPruebaCrashlytics`). (b) `FATAL EXCEPTION: main · FirebaseCrashlyticsTestCrash`; al reabrir: `Initializing Firebase Crashlytics` y peticion a `crashlyticsreports-pa.googleapis.com`. El menu del APK release solo tiene "Cerrar sesion" | **PASA** | 1.0.0+1 debug / release | `CP-17_consola_crashlytics.png`, `CP-17_consola_version_usuarios.png`, `CP-17_logcat_crashlytics.txt`, `CP-17_logcat_crash_fatal.txt`, `CP-17_menu_debug.png`, `CP-17_menu_release_sin_prueba.png` |
| CP-18 | APK release instalado | los 3 roles | Recorrido: cliente solicita → admin confirma → anfitrion atiende | El flujo completo funciona en release | Instala (`Success`), sin `[FATAL]`. Laura y Mateo solicitan hoy 19:30 (Sincronizada); el admin confirma en M01 y M03 ("Solicitudes pendientes (0)"); el anfitrion registra llegada y finaliza (CP-16). Los cambios de cada rol se ven en los otros en tiempo real | **PASA** | 1.0.0+1 release | `CP-18_admin_confirma_15h.png`, capturas de CP-16 |
| CP-19 | Analizador y pruebas | — | `flutter analyze`, `flutter test` | 0 issues, todo en verde | *No issues found*; *+59: All tests passed!* | **PASA** | 1.0.0+1 | Seccion "Pruebas automatizadas" |
| CP-20 | Reserva CONFIRMADA en M01 (7 nov 13:30) | `cliente@` | Detalle → Cancelar reserva → confirmar | Queda CANCELADA y la mesa se libera en la misma transaccion | Dialogo "Se liberara la mesa asignada. Esta accion no se puede deshacer.", estado "Cancelada". Firestore: `slots/M01_20261107-1330` → `404`, reserva `seed-confirmada` `CANCELADA` v3 | **PASA** | 1.0.0+1 release | `CP-20_cancelar_libera_mesa.png` |
| CP-21 | Telefono en UTC | `cliente@` | Ver Mis reservas y crear una solicitud | Horas y franjas en hora del restaurante | El reloj del telefono marca 12:12 (00:12 UTC) y la lista muestra "19:30 - 21:00"; la solicitud de hoy 19:30 se guarda con `dia=2026-11-04` y `franjaId=20261104-1930` | **PASA** | 1.0.0+1 release | `CP-21_mis_reservas_telefono_utc.png`, test `la franja es la del restaurante aunque el telefono este en UTC` |
| CP-22 | Reservas de dias anteriores | `cliente@` | Ver Mis reservas → Activas | Una reserva activa cuya hora paso se marca vencida sin cambiar su estado | "vie 23 oct · Confirmada · vencida" | **PASA** | 1.0.0+1 release | `CP-22_reserva_vencida.png` |
| CP-23 | Telefono con datos de un seed anterior; seed corrido de nuevo el 2026-11-09 | `cliente@` | Abrir Mis reservas → Todas; abrir la del 12 nov y cancelarla | El telefono muestra lo que tiene Firestore aunque el seed haya bajado la `version` | Antes de la correccion: seguia "mar 3 nov · Cancelada" (BUG-11). Con la correccion: "jue 12 nov · Confirmada · Mesa 1"; al cancelar, Firestore `CANCELADA` v3 y `slots/M01_20261112-1330` y el candado → `404` | **PASA** | 1.0.0+1 release (2026-11-09) | Ejecucion 2026-11-09, BUG-11 |
| CP-24 | Dos solicitudes del 11 nov 19:30 (Laura 4 p, Mateo 3 p) | `admin@` | Enviar al mismo tiempo (`Promise.all`) las dos confirmaciones en M03 por la API REST con el token del admin, con las mismas escrituras que la app | Solo una ocupa la mesa | `seed-solicitada-2` → `200`; `seed-solicitada` → `403 PERMISSION_DENIED`. Firestore: un solo slot `M03_20261111-1930` | **PASA** | reglas 2026-10-23 (publicadas = repo) | Ejecucion 2026-11-09 |
| CP-25 | Laura sin conexion con una solicitud pendiente | `cliente@` | `am force-stop` y abrir la app en modo avion; quitar el modo avion | La sesion y el perfil se restauran sin red, la solicitud sigue pendiente y luego se envia sola una vez | Entra como Laura sin pedir clave, Mesas muestra "No hay conexion" + Reintentar, Mis reservas "Sincronizar pendientes (1)". Al volver la red pasa a Sincronizada sin tocar nada; Firestore: un solo documento `b1bc65e0…` | **PASA** | 1.0.0+1 release (2026-11-09) | Ejecucion 2026-11-09 |
| CP-26 | Laura confirmada hoy 13:30 (M01); reloj del emulador adelantado a 13:16 con la hora real en 13:00 | `anfitrion@` | Recepcion → Registrar llegada → Confirmar | La app habilita el boton por su reloj, pero el servidor decide con `request.time` | "El servidor rechazo la operacion por las reglas de seguridad."; Firestore sigue `CONFIRMADA` v2 | **PASA** | 1.0.0+1 release (2026-11-09) | `R-03` del backlog, ejecucion 2026-11-09 |
| CP-27 | Laura (M01) y Mateo (M02) confirmados hoy 13:30 desde el tablero del admin | `anfitrion@` | (a) 12:56: ver Recepcion; (b) 13:15: Registrar llegada a Laura; (c) Finalizar | (a) Llegada bloqueada fuera del margen; (b) CONFIRMADA → EN_MESA; (c) EN_MESA → FINALIZADA sin opcion de reactivar | (a) "Registrar llegada" deshabilitado con "Llegada desde 13:15 hasta 13:45". (b) Firestore `EN_MESA` v3 con `llegadaAt` 13:15 y `atendidoPor`. (c) Dialogo "Se libera Mesa 1 · Ventana."; `FINALIZADA` v4 con `finalizadaAt`; la tarjeta queda sin botones y el contador "En mesa" vuelve a 0 | **PASA** | 1.0.0+1 release (2026-11-09) | Ejecucion 2026-11-09 |

## Evidencia detallada

### Reglas contra el servidor (2026-10-23)

`SEED_PASSWORD=... node tool/qa/reglas_check.mjs` · cada peticion REST lleva el
ID token de la cuenta que actua, igual que la app:

```
PASA  R-01   cliente lee su propia reserva                       HTTP 200
PASA  R-02   cliente lee la reserva de otro cliente              HTTP 403
PASA  R-03   cliente se cambia el rol a admin_salon              HTTP 403
PASA  R-04   cliente confirma su propia reserva                  HTTP 403
PASA  R-05   anfitrion lee reservas de un cliente                HTTP 200
PASA  R-06   anfitrion confirma (accion de admin)                HTTP 403
PASA  R-07   nadie borra reservas (historial)                    HTTP 403
PASA  R-08   cliente crea reserva de 9 personas                  HTTP 403
PASA  R-09   cliente crea reserva en el pasado                   HTTP 403
PASA  R-10   cliente crea reserva a nombre de otro uid           HTTP 403
PASA  R-11   cliente crea reserva valida (4 personas, futura)    HTTP 200
PASA  E1     admin asigna mesa de 2 a grupo de 4                 HTTP 403
PASA  E2-a   admin confirma reserva A en M03                     HTTP 200
PASA  E2-b   admin confirma reserva B en la MISMA mesa y franja  HTTP 403
PASA  E2-c   la misma reserva B en otra mesa libre (M04)         HTTP 200
PASA  E3     anfitrion registra llegada 3 dias antes             HTTP 403

Todas las reglas se comportaron como se esperaba.
```

Despues de la prueba se borraron los documentos creados y se volvio a correr
`tool/seed/seed.mjs`.

### Endpoint HTTP

```
mesas          -> 200 application/json   (8 mesas)
mesas_vacio    -> 200 application/json   ([])
mesas_invalido -> 200 application/json   (JSON roto)
no_existe      -> 404 text/html
```

### APK release

```
flutter build apk --release
√ Built build\app\outputs\flutter-apk\app-release.apk (60.1MB)

adb install -r G62-2_Reservas_v1.0.0+1.apk
Success

dumpsys package co.edu.udem.reservas_g62
versionCode=1 minSdk=24 targetSdk=36
versionName=1.0.0
```

Historia: en la primera prueba (2026-10-22) el release se quedaba en el splash
(BUG-07, R8 eliminaba metodos que `shared_preferences` usa por JNI) y el
emulador no tenia memoria. Ambos se corrigieron; desde el 2026-10-23 el release
abre y se recorrio con los tres roles.

### Crashlytics

El SDK registra el evento no fatal, lo envia por DataTransport al reiniciar y
borra la copia local (`evidencia/CP-17_logcat_crashlytics.txt`). En la consola
(Crashlytics → filtro "Errores recuperables") aparece "Exception: Evento de
prueba controlado G62-2" en la version 1.0.0 (`evidencia/CP-17_consola_crashlytics.png`).
El evento se envia con `fatal: false`: los errores del negocio y de red no se
reportan, solo `AppLogger.error` (inesperados) y los no capturados.

### Pruebas automatizadas

`flutter test` · 59 casos en verde:

- `test/reserva_rules_test.dart` (19): reglas 1–4, maquina de estados, terminales, franja en hora del restaurante.
- `test/reserva_repository_test.dart` (15): offline, sync sin duplicados, reintento vs confirmacion, conflicto, correccion, version local, correccion que no llego (BUG-12), escucha despues del seed y snapshot viejo (BUG-11), aislamiento por cuenta, escenarios 1 y 2.
- `test/mesa_service_test.dart` (7): 200, vacio, 404, 500, JSON invalido, sin conexion, timeout.
- `test/widget_test.dart` (5): `LoadingView`, `EmptyView`, `ErrorView` + Reintentar, `EstadoChip`, `SyncBadge`.
- `test/auth_validators_test.dart` (8): correo, contrasena y nombre del formulario (`AuthValidators`).
- `test/login_page_test.dart` (3): `LoginPage` con un `FakeAuthService`: formulario vacio sin llamar al servicio, error de credenciales y modo registro.
- `test/auth_messages_test.dart` (1) y `test/sync_service_test.dart` (1).

## Como reproducir

1. `firebase login` y `$env:SEED_PASSWORD="<clave>"; node tool/seed/seed.mjs` (las fechas se calculan desde el dia en que se corre).
2. `flutter build apk --release` e instalar `build/app/outputs/flutter-apk/app-release.apk`.
3. Emulador recomendado en un PC de 16 GB: `emulator -avd <avd> -memory 1536 -gpu host -no-snapshot -dns-server 8.8.8.8` (compilar con el emulador cerrado).
4. Reglas: `node tool/qa/reglas_check.mjs` y despues volver a correr el seed.
   Si el telefono ya tenia datos de un seed anterior, borrar los datos de la app antes de probar: las reservas `seed-*` se reescriben con una version menor que la copia local y la app conserva la copia (ignora snapshots con version mas vieja).
5. Catalogo vacio o con error: `flutter run --dart-define=CATALOGO_URL=https://reservas-g62-2.web.app/api/mesas_vacio.json` (o `mesas_invalido.json`, `no_existe.json`).
6. Escenario 3: crear una reserva para la proxima franja, confirmarla y entrar como anfitrion; "Registrar llegada" solo se habilita de 15 min antes a 15 min despues del inicio, y "Marcar ausente" despues de los 15 min.
