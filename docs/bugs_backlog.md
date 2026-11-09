# Backlog de bugs · G62-2 Reservas

**Build evaluada:** 1.0.0+1 (BUG-01 a BUG-13); correcciones incluidas en 1.0.0+2
**Fechas:** 2026-10-22 a 2026-11-09

## Criterio de prioridad

Prioridad = impacto + riesgo + posibilidad de continuar. No es gusto personal.

| Nivel | Significado | Ejemplo |
|-------|-------------|---------|
| **P1 · Bloqueante** | Impide completar el flujo principal | No se puede iniciar sesión; dos reservas ocupan la misma mesa |
| **P2 · Importante** | Degrada seriamente la experiencia, pero hay alternativa | Un error sin opción de reintentar |
| **P3 · Menor** | Detalle visual o deuda secundaria | Texto desalineado |

---

## BUG-01 · El registro podía crear el perfil dos veces y fallar

- **Build:** 1.0.0+1 (antes de la corrección)
- **Pasos:** Registrar una cuenta nueva desde la app.
- **Esperado:** Se crea `users/{uid}` con `rol: cliente` y entra a la app.
- **Obtenido:** Detectado en revisión de código: `createUserWithEmailAndPassword` dispara `authStateChanges` antes de que `register` escriba el perfil. `AuthGate` llamaba a `loadPerfil`, no encontraba el documento y lo creaba; luego `register` lo volvía a escribir con `set`, que para las reglas es un *update* que cambia `createdAt` → `permission-denied` y el registro mostraba error aunque la cuenta existía.
- **Prioridad:** **P1**
- **Estado:** Corregido · `FirebaseAuthService` guarda un `Completer` del registro en curso y `loadPerfil` lo espera en vez de crear otro perfil.
- **Verificación:** 2026-10-31, CP-01 en el APK release: el registro de `qa.registro.1031@g62reservas.test` entra directo como Cliente, sin error, y Firestore tiene un solo perfil con `rol=cliente`.

---

## BUG-02 · Al abrir la app con sesión, el perfil se cargaba dos veces

- **Build:** 1.0.0+1 (antes de la corrección)
- **Pasos:** Abrir la app con una sesión ya iniciada.
- **Esperado:** Una sola lectura de `users/{uid}`.
- **Obtenido:** `AuthGate` cargaba el perfil en `initState` y otra vez con la primera emisión de `authStateChanges` (mismo uid), repitiendo la lectura y el spinner.
- **Prioridad:** **P3**
- **Estado:** Corregido · el listener solo recarga si cambia el uid.

---

## BUG-03 · Sin Auth habilitado el login mostraba un error genérico

- **Build:** 1.0.0+1 (antes de la corrección)
- **Pasos:** Intentar iniciar sesión en un proyecto sin el proveedor Correo/contraseña.
- **Esperado:** Un mensaje que explique la causa.
- **Obtenido:** La API responde `CONFIGURATION_NOT_FOUND` (comprobado con `accounts:signUp` por REST: HTTP 400). Ese código no estaba mapeado y caía en "No fue posible completar la operación".
- **Prioridad:** **P3**
- **Estado:** Corregido · `mensajeDeCodigo` lo traduce a "El inicio con correo no está habilitado en el proyecto" (cubierto por `test/auth_messages_test.dart`).

---

## BUG-04 · El proveedor Correo/contraseña no está habilitado en `reservas-g62-2`

- **Build:** 1.0.0+1
- **Pasos:** `POST accounts:signUp` con la API key del proyecto.
- **Esperado:** Se crea la cuenta.
- **Obtenido:** `HTTP 400 CONFIGURATION_NOT_FOUND`. Habilitarlo por API exige facturación (Identity Platform); en la consola es un clic.
- **Prioridad:** **P1** (bloquea todos los flujos con sesión)
- **Estado:** Cerrado (2026-10-23) · habilitado en Firebase Console. Verificado: `signInWithPassword` con un usuario inexistente ahora responde `INVALID_LOGIN_CREDENTIALS` en vez de `CONFIGURATION_NOT_FOUND`.
- **Nota:** Era configuración del proyecto, no código. Después de habilitarlo se ejecutaron los casos que estaban pendientes (ver matriz).

---

## BUG-05 · `DocumentSnapshot.data()` con `serverTimestampBehavior` no compilaba

- **Build:** desarrollo (antes de 1.0.0+1)
- **Pasos:** `flutter analyze`.
- **Esperado:** 0 errores.
- **Obtenido:** `undefined_named_parameter`: en FlutterFire `data()` no recibe ese parámetro.
- **Prioridad:** **P3**
- **Estado:** Corregido · los `serverTimestamp` pendientes llegan como `null` y `fromMap` usa la hora del teléfono mientras llega el valor real.

---

## BUG-06 · La app solo arranca en Android

- **Build:** 1.0.0+1
- **Pasos:** `flutter run -d windows` o `-d chrome`.
- **Esperado:** —
- **Obtenido:** `DefaultFirebaseOptions.currentPlatform` lanza `UnsupportedError` (solo se configuró Android, como pide el curso). Además `flutter pub get` avisa que compilar para Windows requiere Developer Mode (symlinks).
- **Prioridad:** **P3**
- **Estado:** Abierto · no aplica: Android es la plataforma objetivo.

---

## BUG-07 · El APK release se quedaba para siempre en el splash

- **Build:** 1.0.0+1 (antes de la corrección)
- **Pasos:** Instalar `app-release.apk` en el emulador (Android 14) y abrirla.
- **Esperado:** Pantalla de inicio de sesión.
- **Obtenido:** Splash fijo (en un intento anterior, pantalla negra). La build debug sí abría. Con marcas de diagnóstico en `main()` se vio: `PlatformException ... NoSuchMethodError: no non-static method "SharedPreferencesApiRegistrar.getAll(...)"`. R8 (solo en release) eliminó métodos de `shared_preferences` que Dart llama por JNI; `preferences.getTema()` fallaba antes de `runApp`.
- **Prioridad:** **P1** (la app entregable no abría)
- **Estado:** Corregido · `android/app/proguard-rules.pro` conserva `io.flutter.plugins.sharedpreferences.**` y `io.flutter.plugins.pathprovider.**` (este último lo usa Drift con el mismo mecanismo); `build.gradle.kts` lo incluye en `release`.
- **Lección:** probar siempre el APK release, no solo `flutter run`.

---

## BUG-08 · Los errores fatales antes de `runApp` no aparecían en ningún log

- **Build:** 1.0.0+1 (antes de la corrección)
- **Pasos:** Provocar una excepción en `main()` después de configurar Crashlytics (fue el caso de BUG-07).
- **Esperado:** El error se ve en logcat además de enviarse a Crashlytics.
- **Obtenido:** `PlatformDispatcher.instance.onError` solo llamaba a `recordError` y devolvía `true`: el error quedaba oculto y la app parecía colgada sin explicación.
- **Prioridad:** **P2**
- **Estado:** Corregido · `onError` imprime `[FATAL] error + stack` con `debugPrint` y `FlutterError.onError` llama a `FlutterError.presentError` antes de reportar.

---

## BUG-09 · Las franjas dependían de la zona horaria del teléfono

- **Build:** 1.0.0+1 (antes de la corrección)
- **Pasos:** (1) Emulador en UTC, abrir "Mis reservas" con datos creados en hora de Colombia. (2) Emulador en Bogotá, solicitar en modo avión la franja 19:30 de hoy y quitar el modo avión (el emulador vuelve a UTC al recuperar la red).
- **Esperado:** La reserva de las 19:30 se ve a las 19:30 y se guarda con `dia = 2026-10-23` y `franjaId = 20261023-1930`.
- **Obtenido:** (1) Se veía a las 00:30 del día siguiente. (2) En Firestore quedó `dia = 2026-10-24`, `franjaId = 20261024-0030`: el instante era correcto, pero el día y la franja se calcularon con la zona del teléfono al momento de enviar. El tablero del admin la habría agrupado en otro día y con un slot distinto.
- **Prioridad:** **P2** (guardaba datos inconsistentes en el servidor)
- **Estado:** Corregido · `lib/core/hora_restaurante.dart` fija la hora del restaurante (UTC-5, Colombia no tiene horario de verano). `Franja`, `Formatters` y las pantallas calculan día, franja y horas con esa zona, sin importar la del teléfono. Test nuevo `la franja es la del restaurante aunque el telefono este en UTC`. El documento corrido se borró de Firestore.

---

## BUG-10 · "Reintentar" al cargar el perfil lanzaba una excepcion en debug

- **Build:** 1.0.0+1 debug (`flutter run`), antes de la correccion
- **Pasos:** Emulador sin DNS → abrir la app con sesion → aparece "No se pudo cargar tu perfil" → tocar **Reintentar**.
- **Esperado:** Vuelve a intentar leer el perfil.
- **Obtenido:** `setState() callback argument returned a Future` en `_AuthGateState._reintentarPerfil` (`auth_gate.dart:63`). La funcion flecha `setState(() => _perfil = loadPerfil(user))` devuelve el `Future` de la asignacion y Flutter lo rechaza en debug. Crashlytics lo recibio como error de Flutter. En el APK release no se veia porque esa verificacion solo existe en debug.
- **Prioridad:** **P2** (en debug el boton Reintentar no servia; quedaba cerrar sesion)
- **Estado:** Corregido · el `Future` se crea antes y `setState` solo asigna (`setState(() { _perfil = perfil; })`). Revisados los demas `setState` del proyecto: ninguno devuelve un `Future`.

---

## BUG-11 · Despues de correr el seed, el cliente seguia viendo copias viejas

- **Build:** 1.0.0+1 release, antes de la correccion
- **Pasos:** Con datos de un seed anterior en el telefono (por ejemplo `seed-confirmada` cancelada en CP-20, version 3), volver a correr `tool/seed/seed.mjs` y abrir Mis reservas como `cliente@`.
- **Esperado:** Ver `seed-confirmada` como CONFIRMADA el 12 nov 13:30 en Mesa 1, igual que en Firestore.
- **Obtenido:** Seguia "mar 3 nov 13:30 · Cancelada". `_fusionarRemota` descartaba todo snapshot con `version` menor que la copia local, y el seed reescribe los documentos con version 1 o 2.
- **Prioridad:** **P2** (el dia de la sustentacion se corre el seed y la demo mostraria estados equivocados)
- **Estado:** Corregido · el snapshot solo se ignora si tiene menor version **y** no es mas reciente (`updatedAt`). Tests `la escucha acepta el servidor aunque baje la version si es mas reciente` y `la escucha ignora un snapshot viejo que llega tarde`.
- **Verificacion:** 2026-11-09, APK release en el emulador sin borrar los datos de la app: despues de correr el seed, Laura ve "jue 12 nov · Confirmada · Mesa 1" y al cancelarla Firestore queda `CANCELADA` v3 sin `slots/M01_20261112-1330` ni el candado de la franja.

---

## BUG-12 · Una correccion local podia quedar marcada como sincronizada sin haberse aplicado

- **Build:** 1.0.0+1, detectado en revision de codigo
- **Pasos:** Enviar una solicitud y perder la respuesta (timeout), corregirla mientras sigue pendiente y reenviar.
- **Esperado:** Si el servidor ya tenia la version original, la correccion no se marca sincronizada y el cliente sabe por que.
- **Obtenido:** `crearReserva` devolvia el documento existente (v1, SOLICITADA) y `_enviar` llamaba a `markSynced` con la `localVersion` nueva: el telefono mostraba los datos corregidos como "Sincronizada" aunque Firestore tenia los originales.
- **Prioridad:** **P2**
- **Estado:** Corregido · `_enviar` y la escucha comparan personas, inicio y comentario; si no coinciden se guarda la version del servidor con el aviso "La solicitud original ya habia llegado al restaurante y no se modifico..." y el envio se informa como rechazado. Test `una correccion no se marca sincronizada si el envio anterior si llego`.

---

## BUG-13 · Recepcion no mostraba el resultado de la accion del anfitrion

- **Build:** 1.0.0+1 release, antes de la correccion
- **Pasos:** Como `anfitrion@`, registrar llegada o marcar ausente en Recepcion.
- **Esperado:** La tarjeta cambia de estado al confirmar.
- **Obtenido:** Firestore quedaba bien (`EN_MESA` v3, `AUSENTE` v3), pero la tarjeta seguia "Confirmada" con sus botones hasta cambiar de dia y volver. Pasó dos veces en el emulador el 2026-11-09; la escucha abierta no entrego el cambio y al abrirla de nuevo si aparecia.
- **Prioridad:** **P2** (el anfitrion podia repetir la accion y recibir un error de version)
- **Estado:** Corregido · despues de una accion exitosa, Recepcion vuelve a abrir la escucha del dia (`_cambiarDia(_dia)`, lo mismo que hace cambiar de dia). Verificado manualmente que recargar el dia muestra el estado correcto.

---

## Riesgos identificados (no reproducidos)

| Id | Riesgo | Mitigación |
|----|--------|-----------|
| R-01 | La capacidad de la mesa llega del catálogo HTTP; las reglas comparan `mesaCapacidad` enviado por el admin, no el catálogo | Documentado en límites; la app valida con el catálogo y el admin es un rol de confianza |
| R-02 | Cambiar columnas de Drift sin subir `schemaVersion` (BUG-03 de BOLETAS) | `schemaVersion` explícito y `MigrationStrategy` documentada en `app_database.dart` |
| R-03 | Reloj del teléfono desfasado para la ventana de llegada | Las reglas usan `request.time`; el servidor manda |

## Resumen

| Prioridad | Abiertos | Corregidos |
|-----------|----------|-----------|
| P1 | **0** | 3 |
| P2 | 0 | 6 |
| P3 | 1 | 3 |

No hay bloqueantes abiertos. El unico abierto es BUG-06 (P3: la app solo
arranca en Android), que es una decision de alcance del proyecto.
