const { Pool } = require("pg");

// En la nube se usa DATABASE_URL (Neon, Render, etc.).
// En la computadora local se siguen usando PGHOST, PGPORT, PGUSER, PGPASSWORD y PGDATABASE.
let config;
if (process.env.DATABASE_URL) {
  config = { connectionString: process.env.DATABASE_URL };
  let host = "";
  try { host = new URL(process.env.DATABASE_URL).hostname; } catch (e) { /* URL no estándar */ }
  const esLocal = host === "localhost" || host === "127.0.0.1" || host === "";
  // Fuera de la computadora local la conexión debe ir cifrada (SSL).
  if (!esLocal && !/sslmode=/.test(process.env.DATABASE_URL)) {
    config.ssl = { rejectUnauthorized: true };
  }
} else {
  config = {
    host: process.env.PGHOST || "localhost",
    port: process.env.PGPORT || 5432,
    user: process.env.PGUSER || "cinedb_app",
    password: process.env.PGPASSWORD || "cinedb_app_2026",
    database: process.env.PGDATABASE || "cinedb",
  };
}

const pool = new Pool({ ...config, max: 5, idleTimeoutMillis: 10000 });

// Si el servicio de base de datos cierra una conexión inactiva (Neon lo hace al suspenderse),
// se registra el aviso y el pool abre otra; sin este manejador, el proceso se caería.
pool.on("error", (err) => console.error("Conexión inactiva cerrada por la base:", err.message));

module.exports = pool;
