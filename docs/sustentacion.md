# Guion de sustentación · G62-2

Una página por flujo. Cada integrante debe poder explicar los cuatro y abrir
los archivos señalados. Entre paréntesis, la línea de pensamiento a defender.

---

## 1. Solicitar una reserva (local-first)

**Recorrido:** `NuevaReservaScreen._enviar` → `ReservaRepositoryImpl.solicitarReserva`
→ `ReservaRules.validarSolicitud` → `ReservaLocalDataSource.save` → `_enviar`
→ `FirestoreReservaRemoteDataSource.crearReserva`.

1. La pantalla solo arma los datos (personas, franja, comentario) y llama al repository.
2. El repository valida la regla 1 (1–8 personas, franja fija, futura) y que el
   cliente no tenga otra activa en la franja.
3. Crea el `uuid` **antes** de enviar y guarda en Drift con `pendingSync = true`.
   *(Si no hay red, la solicitud igual existe.)*
4. `_enviar` nunca lanza: el resultado queda en Drift.
   - Éxito → `markSynced(id, localVersion)`.
   - `RequiereConexion` → `markError`, sigue pendiente.
   - `PermisoDenegado` (reglas) → `markConflict`, espera Corregir/Descartar.
5. `crearReserva` es una transacción: si el documento ya existe no lo toca.
   *(Un reintento no puede pisar una confirmación del admin.)*

**Preguntas probables:** ¿por qué el id se crea en el teléfono? ¿qué pasa si la
respuesta de Firestore se pierde? ¿qué es `localVersion`?

---

## 2. Confirmación atómica de mesa

**Recorrido:** `TableroAsignacionScreen._asignar` → `showAsignarMesaSheet`
(solo mesas válidas) → `ReservaRepositoryImpl.confirmar` →
`FirestoreReservaRemoteDataSource.confirmar` → `firestore.rules: adminConfirma()`.

1. El sheet usa `ReservaRules.mesasValidas`: capacidad ≥ personas y mesa sin
   `slot` en la franja. Las demás aparecen deshabilitadas con el motivo.
2. El repository vuelve a validar la máquina de estados y la capacidad.
3. La transacción lee la reserva (estado y `version`), el `slot` y el candado
   `cliente_franja`. Si el slot existe → `MesaOcupada`/`MesaBloqueada`; si el
   candado existe → `ReservaDuplicada`.
4. Escribe en la misma transacción: slot, candado y reserva `CONFIRMADA` con
   `version + 1`.
5. Las reglas exigen `!exists(slot)` antes y `getAfter(slot).reservaId == id`
   después. *(Aunque alguien salte la app, no puede ocupar una mesa ocupada.)*

**Demostración:** dos teléfonos con la cuenta admin confirman la misma mesa en
la misma franja: uno ve "Reserva confirmada", el otro "La mesa ya tiene una
reserva confirmada en esa franja".

---

## 3. Sincronización y cambio de cuenta

**Recorrido:** `HomeShell.initState` → `SyncService.start(uid)` →
`connectivity.onConnectivityChanged` → `ReservaRepository.syncPending(uid)`.

1. `SyncService` solo arranca para el cliente y con su `uid`.
2. Al volver la red llama a `syncPending(uid)`, que lee `getPending(uid)`:
   filtra por dueño y excluye conflictos.
3. Si quedan fallidas, reintenta con espera 5 s → 10 s → 20 s… máx. 2 min.
4. `iniciarEscuchaCliente(uid)` escucha `reservas where clienteUid == uid` y
   copia en Drift lo que deciden admin y anfitrión.
5. Al cerrar sesión: `SyncService.stop()` y `detenerEscuchaCliente()`.
   *(Los pendientes de Ana nunca se envían con la sesión de Beto.)*

**Preguntas probables:** ¿por qué la persistencia de Firestore no reemplaza a
Drift? ¿qué muestra la UI mientras está pendiente?

---

## 4. Seguridad, roles y Crashlytics

**Roles:** el registro crea `users/{uid}` con `rol: cliente`; las reglas
(`match /users`) solo aceptan ese valor al crear y solo permiten cambiar
`nombre`. Admin y anfitrión se asignan en Firebase Console. `HomeShell` arma la
navegación según `perfil.rol`, pero la protección real son las reglas: cada
transición tiene su función (`clienteCancela`, `adminConfirma`,
`hostRegistraLlegada`, …) con `onlyChanged([...])` para que nadie toque campos
de otro rol.

**Errores:**

| Tipo | Ejemplo | Dónde termina |
|------|---------|---------------|
| Negocio | 9 personas, mesa pequeña, fuera de la ventana | `ReservaException` → SnackBar |
| Red esperada | sin conexión, timeout | `RequiereConexion` / `ApiException` → mensaje + Reintentar, `AppLogger.warning` |
| Inesperado | bug, tipo de dato raro | `AppLogger.error` → `CrashService.recordNonFatal` (no fatal) |
| No capturado | excepción en un widget | `FlutterError.onError` / `PlatformDispatcher.onError` (instalados en `CrashService.configure()`) → Crashlytics |

El menú QA (⋮ → "Evento de prueba Crashlytics" y "Forzar crash fatal") solo
aparece con `kDebugMode`. El crash fatal cierra la app; el reporte se envía al
volver a abrirla. `AuthGate` asocia los reportes al uid con
`setUserIdentifier`, nunca al correo.

**Relación con la guía de la clase 14 (Movies a producción):**

| Guía | En este proyecto |
|------|------------------|
| `validators/auth_validators.dart` + `test/auth_validators_test.dart` | igual (correo, contraseña y nombre) |
| `AuthService` (interfaz) + `FirebaseAuthService` | `services/auth_service.dart`; además carga el perfil con el rol |
| `LoginPage` con `_isLoading`, `_isRegisterMode`, `mounted` | `views/auth/login_page.dart` |
| `AuthGate` escucha `authStateChanges()`; logout sin `Navigator` | `views/auth/auth_gate.dart` |
| `services/crash/` (servicio + stub con export condicional) | igual |
| Widget test de `LoginPage` con `FakeAuthService` | `test/login_page_test.dart` |
| Autorización por uid (en la guía solo se explica) | implementada: reglas por uid y rol, Drift filtrado por cuenta |

---

## 5. Dos bugs reales que conviene saber contar

**Hora del restaurante (BUG-09).** `lib/core/hora_restaurante.dart` fija la
zona de Bogotá (UTC-5, sin horario de verano). `Franja` calcula `id`, `dia` y
`etiqueta` con esa hora y `Formatters` muestra las horas igual. Antes, un
teléfono en UTC guardaba la reserva de las 19:30 como `20261024-0030` y el
tablero la mostraba en otro día. *(Pregunta probable: ¿por qué no usar la hora
del teléfono? Porque la franja es del restaurante, no del cliente.)*

**APK release pegado en el splash (BUG-07).** R8 (solo en release) eliminaba
métodos que `shared_preferences` llama desde Dart por JNI, y renombraba clases
de Kotlin de su firma. `android/app/proguard-rules.pro` los conserva. Se
descubrió porque `PlatformDispatcher.onError` ahora imprime `[FATAL]` en
logcat además de enviarlo a Crashlytics. *(Lección: probar siempre el APK
release, no solo `flutter run`.)*

**Modificación en vivo, ideas para practicar:**

- Cambiar el máximo de personas de 8 a 10 (constante + regla Firestore + test).
- Agregar una franja de 16:30 (`Franja.horasInicio`).
- Mostrar el motivo del bloqueo en el sheet de asignación.
- Ampliar la ventana de llegada a 20 min (constante + regla + test).
