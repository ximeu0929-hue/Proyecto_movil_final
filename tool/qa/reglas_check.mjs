
import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

const PROJECT = 'reservas-g62-2';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;
const API_KEY = readFileSync('lib/firebase_options.dart', 'utf8').match(/apiKey: '([^']+)'/)[1];
const PASSWORD = process.env.SEED_PASSWORD;
if (!PASSWORD) { console.error('Define SEED_PASSWORD'); process.exit(1); }

async function login(email) {
  const res = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: PASSWORD, returnSecureToken: true }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`${email}: ${data.error?.message}`);
  return { token: data.idToken, uid: data.localId };
}

const v = (x) => x === null ? { nullValue: null }
  : x instanceof Date ? { timestampValue: x.toISOString() }
  : Number.isInteger(x) ? { integerValue: String(x) }
  : { stringValue: String(x) };
const fields = (o) => Object.fromEntries(Object.entries(o).map(([k, x]) => [k, v(x)]));

async function call(token, method, path, body) {
  const res = await fetch(`${BASE}${path}`, {
    method, headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined,
  });
  return res.status;
}

const commit = (token, writes) => call(token, 'POST', ':commit', { writes });

const dos = (n) => String(n).padStart(2, '0');
const diaId = (d) => `${d.getFullYear()}-${dos(d.getMonth() + 1)}-${dos(d.getDate())}`;
const franjaId = (d) => `${diaId(d).replaceAll('-', '')}-${dos(d.getHours())}${dos(d.getMinutes())}`;
function franja(dias, h, m) { const d = new Date(); d.setDate(d.getDate() + dias); d.setHours(h, m, 0, 0); return d; }

let fallos = 0;
function caso(id, descripcion, obtenido, esperado) {
  const ok = obtenido === esperado;
  if (!ok) fallos++;
  console.log(`${ok ? 'PASA' : 'FALLA'}  ${id.padEnd(6)} ${descripcion.padEnd(62)} HTTP ${obtenido} (esperado ${esperado})`);
}

const cliente = await login('cliente@g62reservas.test');
const cliente2 = await login('cliente2@g62reservas.test');
const admin = await login('admin@g62reservas.test');
const host = await login('anfitrion@g62reservas.test');

// Seguridad por cuenta y rol
caso('R-01', 'cliente lee su propia reserva', await call(cliente.token, 'GET', '/reservas/seed-solicitada'), 200);
caso('R-02', 'cliente lee la reserva de otro cliente', await call(cliente.token, 'GET', '/reservas/seed-solicitada-2'), 403);
caso('R-03', 'cliente se cambia el rol a admin_salon',
  await call(cliente.token, 'PATCH', `/users/${cliente.uid}?updateMask.fieldPaths=rol`, { fields: fields({ rol: 'admin_salon' }) }), 403);
caso('R-04', 'cliente confirma su propia reserva',
  await call(cliente.token, 'PATCH', '/reservas/seed-solicitada?updateMask.fieldPaths=estado&updateMask.fieldPaths=version',
    { fields: fields({ estado: 'CONFIRMADA', version: 2 }) }), 403);
caso('R-05', 'anfitrion lee reservas de un cliente', await call(host.token, 'GET', '/reservas/seed-solicitada'), 200);
caso('R-06', 'anfitrion confirma (accion de admin)',
  await call(host.token, 'PATCH', '/reservas/seed-solicitada?updateMask.fieldPaths=estado&updateMask.fieldPaths=version',
    { fields: fields({ estado: 'CONFIRMADA', version: 2 }) }), 403);
caso('R-07', 'nadie borra reservas (historial)', await call(admin.token, 'DELETE', '/reservas/seed-ausente'), 403);

// Regla 1 en el servidor
const inicio = franja(5, 13, 30);
const nueva = (id, uid, personas, ini = inicio) => ({
  update: { name: `projects/${PROJECT}/databases/(default)/documents/reservas/${id}`, fields: fields({
    id, clienteUid: uid, clienteNombre: 'QA', personas, inicio: ini, franjaId: franjaId(ini), dia: diaId(ini),
    comentario: '', estado: 'SOLICITADA', createdAt: new Date(), version: 1,
  }) },
  updateTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }],
  currentDocument: { exists: false },
});
caso('R-08', 'cliente crea reserva de 9 personas', await commit(cliente.token, [nueva('qa-9p', cliente.uid, 9)]), 403);
caso('R-09', 'cliente crea reserva en el pasado', await commit(cliente.token, [nueva('qa-pasada', cliente.uid, 2, franja(-1, 13, 30))]), 403);
caso('R-10', 'cliente crea reserva a nombre de otro uid', await commit(cliente.token, [nueva('qa-suplanta', cliente2.uid, 2)]), 403);
caso('R-11', 'cliente crea reserva valida (4 personas, futura)', await commit(cliente.token, [nueva('qa-valida', cliente.uid, 4)]), 200);

// Escenarios 1 y 2: confirmacion atomica
const cena = franja(2, 19, 30);
const fId = franjaId(cena);
function confirmar(reservaId, clienteUid, mesaId, capacidad, version = 2) {
  const slotId = `${mesaId}_${fId}`;
  const doc = (p) => `projects/${PROJECT}/databases/(default)/documents/${p}`;
  return [
    { update: { name: doc(`reservas/${reservaId}`), fields: fields({
        estado: 'CONFIRMADA', mesaId, mesaNombre: mesaId, mesaCapacidad: capacidad, slotId, decididoPor: admin.uid, version }) },
      updateMask: { fieldPaths: ['estado', 'mesaId', 'mesaNombre', 'mesaCapacidad', 'slotId', 'decididoPor', 'version'] },
      updateTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }] },
    { update: { name: doc(`slots/${slotId}`), fields: fields({
        mesaId, franjaId: fId, dia: diaId(cena), tipo: 'reserva', reservaId, createdBy: admin.uid }) },
      updateTransforms: [{ fieldPath: 'createdAt', setToServerValue: 'REQUEST_TIME' }] },
    { update: { name: doc(`cliente_franja/${clienteUid}_${fId}`), fields: fields({ clienteUid, franjaId: fId, reservaId }) } },
  ];
}
caso('E1', 'admin asigna mesa de 2 a grupo de 4', await commit(admin.token, confirmar('seed-solicitada', cliente.uid, 'M01', 2)), 403);
caso('E2-a', 'admin confirma reserva A en M03', await commit(admin.token, confirmar('seed-solicitada', cliente.uid, 'M03', 4)), 200);
caso('E2-b', 'admin confirma reserva B en la MISMA mesa y franja', await commit(admin.token, confirmar('seed-solicitada-2', cliente2.uid, 'M03', 4)), 403);
caso('E2-c', 'la misma reserva B en otra mesa libre (M04)', await commit(admin.token, confirmar('seed-solicitada-2', cliente2.uid, 'M04', 4)), 200);

// Escenario 3: llegada fuera de margen
caso('E3', 'anfitrion registra llegada 3 dias antes',
  await commit(host.token, [{
    update: { name: `projects/${PROJECT}/databases/(default)/documents/reservas/seed-confirmada`,
      fields: fields({ estado: 'EN_MESA', atendidoPor: host.uid, version: 3 }) },
    updateMask: { fieldPaths: ['estado', 'atendidoPor', 'version'] },
    updateTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }, { fieldPath: 'llegadaAt', setToServerValue: 'REQUEST_TIME' }],
  }]), 403);

// Limpieza (propietario del proyecto)
const owner = JSON.parse(readFileSync(join(homedir(), '.config/configstore/firebase-tools.json'), 'utf8')).tokens.access_token;
const ownerHeaders = { Authorization: `Bearer ${owner}`, 'x-goog-user-project': PROJECT };
for (const p of ['reservas/qa-valida', `slots/M03_${fId}`, `slots/M04_${fId}`,
  `cliente_franja/${cliente.uid}_${fId}`, `cliente_franja/${cliente2.uid}_${fId}`]) {
  await fetch(`${BASE}/${p}`, { method: 'DELETE', headers: ownerHeaders });
}
console.log(`\n${fallos === 0 ? 'Todas las reglas se comportaron como se esperaba.' : `${fallos} caso(s) fallaron.`}`);
console.log('Limpieza hecha: vuelve a correr tool/seed/seed.mjs para restaurar las reservas modificadas.');
process.exit(fallos === 0 ? 0 : 1);
