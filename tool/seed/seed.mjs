// Datos de prueba de G62-2 (ficticios)

import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

const PROJECT = 'reservas-g62-2';
const PASSWORD = process.env.SEED_PASSWORD;
if (!PASSWORD || PASSWORD.length < 6) {
  console.error('Define SEED_PASSWORD (minimo 6 caracteres).');
  process.exit(1);
}

const API_KEY = process.env.FIREBASE_API_KEY
  ?? readFileSync('lib/firebase_options.dart', 'utf8').match(/apiKey: '([^']+)'/)[1];

function oauthToken() {
  if (process.env.GOOGLE_OAUTH_TOKEN) return process.env.GOOGLE_OAUTH_TOKEN;
  const cfg = JSON.parse(readFileSync(join(homedir(), '.config/configstore/firebase-tools.json'), 'utf8'));
  if (!cfg.tokens || cfg.tokens.expires_at < Date.now() + 60_000) {
    console.error('Token vencido: ejecuta cualquier comando de firebase (ej. firebase projects:list) y reintenta.');
    process.exit(1);
  }
  return cfg.tokens.access_token;
}
const TOKEN = oauthToken();

// Cuentas
const CUENTAS = [
  { key: 'cliente', email: 'cliente@g62reservas.test', nombre: 'Laura Cliente', rol: 'cliente' },
  { key: 'cliente2', email: 'cliente2@g62reservas.test', nombre: 'Mateo Cliente', rol: 'cliente' },
  { key: 'admin', email: 'admin@g62reservas.test', nombre: 'Sara Admin', rol: 'admin_salon' },
  { key: 'anfitrion', email: 'anfitrion@g62reservas.test', nombre: 'Tomas Anfitrion', rol: 'anfitrion' },
];

async function authCall(method, body) {
  const res = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:${method}?key=${API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...body, returnSecureToken: true }),
  });
  return { ok: res.ok, data: await res.json() };
}

async function cuenta({ email, nombre }) {
  let r = await authCall('signUp', { email, password: PASSWORD, displayName: nombre });
  if (!r.ok && r.data.error?.message === 'EMAIL_EXISTS') {
    r = await authCall('signInWithPassword', { email, password: PASSWORD });
  }
  if (!r.ok) throw new Error(`${email}: ${r.data.error?.message}`);
  return r.data.localId;
}

// Firestore REST
function valor(v) {
  if (v === null) return { nullValue: null };
  if (v instanceof Date) return { timestampValue: v.toISOString() };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (Number.isInteger(v)) return { integerValue: String(v) };
  if (typeof v === 'number') return { doubleValue: v };
  return { stringValue: String(v) };
}

async function setDoc(path, data) {
  const fields = Object.fromEntries(Object.entries(data).map(([k, v]) => [k, valor(v)]));
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/${path}`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${TOKEN}`, 'Content-Type': 'application/json', 'x-goog-user-project': PROJECT },
    body: JSON.stringify({ fields }),
  });
  if (!res.ok) throw new Error(`${path}: ${res.status} ${await res.text()}`);
}

// Fechas (hora local)
const dos = (n) => String(n).padStart(2, '0');
const diaId = (d) => `${d.getFullYear()}-${dos(d.getMonth() + 1)}-${dos(d.getDate())}`;
const franjaId = (d) => `${diaId(d).replaceAll('-', '')}-${dos(d.getHours())}${dos(d.getMinutes())}`;
function franja(diasDesdeHoy, hora, minuto) {
  const d = new Date();
  d.setDate(d.getDate() + diasDesdeHoy);
  d.setHours(hora, minuto, 0, 0);
  return d;
}

// Main
const uid = {};
for (const c of CUENTAS) {
  uid[c.key] = await cuenta(c);
  await setDoc(`users/${uid[c.key]}`, {
    uid: uid[c.key], email: c.email, nombre: c.nombre, rol: c.rol, createdAt: new Date(),
  });
  console.log(`cuenta ${c.rol.padEnd(11)} ${c.email}`);
}

const MESAS = { M01: ['Mesa 1 · Ventana', 2], M03: ['Mesa 3 · Salon', 4], M06: ['Mesa 6 · Terraza', 6], M07: ['Mesa 7 · Reservado', 8] };

const RESERVAS = [
  { id: 'seed-solicitada', cliente: 'cliente', personas: 4, inicio: franja(2, 19, 30), estado: 'SOLICITADA', comentario: 'Cumpleanos' },
  { id: 'seed-solicitada-2', cliente: 'cliente2', personas: 3, inicio: franja(2, 19, 30), estado: 'SOLICITADA', comentario: 'Mesa tranquila' },
  { id: 'seed-solicitada-grande', cliente: 'cliente2', personas: 7, inicio: franja(2, 21, 0), estado: 'SOLICITADA', comentario: '' },
  { id: 'seed-confirmada', cliente: 'cliente', personas: 2, inicio: franja(3, 13, 30), estado: 'CONFIRMADA', mesa: 'M01' },
  { id: 'seed-rechazada', cliente: 'cliente2', personas: 8, inicio: franja(1, 21, 0), estado: 'RECHAZADA', motivo: 'Evento privado esa noche' },
  { id: 'seed-cancelada', cliente: 'cliente', personas: 3, inicio: franja(4, 18, 0), estado: 'CANCELADA' },
  { id: 'seed-finalizada', cliente: 'cliente', personas: 4, inicio: franja(-1, 19, 30), estado: 'FINALIZADA', mesa: 'M03' },
  { id: 'seed-ausente', cliente: 'cliente2', personas: 6, inicio: franja(-1, 21, 0), estado: 'AUSENTE', mesa: 'M06' },
];

for (const r of RESERVAS) {
  const fId = franjaId(r.inicio);
  const doc = {
    id: r.id, clienteUid: uid[r.cliente], clienteNombre: CUENTAS.find((c) => c.key === r.cliente).nombre,
    personas: r.personas, inicio: r.inicio, franjaId: fId, dia: diaId(r.inicio), comentario: r.comentario ?? '',
    estado: r.estado, createdAt: new Date(), updatedAt: new Date(), version: r.estado === 'SOLICITADA' ? 1 : 2,
  };
  if (r.mesa) {
    const slotId = `${r.mesa}_${fId}`;
    Object.assign(doc, { mesaId: r.mesa, mesaNombre: MESAS[r.mesa][0], mesaCapacidad: MESAS[r.mesa][1], slotId, decididoPor: uid.admin });
    await setDoc(`slots/${slotId}`, { mesaId: r.mesa, franjaId: fId, dia: diaId(r.inicio), tipo: 'reserva', reservaId: r.id, createdBy: uid.admin, createdAt: new Date() });
    await setDoc(`cliente_franja/${uid[r.cliente]}_${fId}`, { clienteUid: uid[r.cliente], franjaId: fId, reservaId: r.id });
  }
  if (r.estado === 'RECHAZADA') Object.assign(doc, { motivoRechazo: r.motivo, decididoPor: uid.admin });
  if (r.estado === 'FINALIZADA') {
    Object.assign(doc, { llegadaAt: new Date(r.inicio.getTime() + 5 * 60000), finalizadaAt: new Date(r.inicio.getTime() + 85 * 60000), atendidoPor: uid.anfitrion, version: 4 });
  }
  if (r.estado === 'AUSENTE') Object.assign(doc, { ausenteAt: new Date(r.inicio.getTime() + 20 * 60000), atendidoPor: uid.anfitrion, version: 3 });
  await setDoc(`reservas/${r.id}`, doc);
  console.log(`reserva  ${r.estado.padEnd(11)} ${diaId(r.inicio)} ${fId.slice(-4)}  ${r.personas} p`);
}

const bloqueo = franja(2, 21, 0);
const bId = `M07_${franjaId(bloqueo)}`;
const datosBloqueo = { mesaId: 'M07', franjaId: franjaId(bloqueo), dia: diaId(bloqueo), tipo: 'bloqueo', motivo: 'Mantenimiento del aire', createdBy: uid.admin, createdAt: new Date() };
await setDoc(`slots/${bId}`, datosBloqueo);
await setDoc(`bloqueos/${bId}`, { ...datosBloqueo, mesaNombre: MESAS.M07[0], inicio: bloqueo });
console.log(`bloqueo  M07 ${diaId(bloqueo)} 2100`);
console.log('Listo.');
