const express = require("express");
const session = require("express-session");
const bcrypt = require("bcryptjs");
const path = require("path");
const pool = require("./db");

const app = express();
const enProduccion = process.env.NODE_ENV === "production";

// Detrás del proxy de Render (HTTPS) hay que confiar en él para que la cookie segura funcione.
if (enProduccion) app.set("trust proxy", 1);
if (enProduccion && !process.env.SESSION_SECRET) {
  throw new Error("Falta la variable de entorno SESSION_SECRET.");
}

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public")));
app.use(session({
  secret: process.env.SESSION_SECRET || "cinedb-proyecto-final-il356",
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    maxAge: 8 * 60 * 60 * 1000,
    // Para que el inicio de sesión funcione dentro de un iframe (Google Sites) la cookie debe ser
    // SameSite=None, Secure y Partitioned (cookie particionada por sitio, compatible con Chrome).
    ...(enProduccion ? { secure: true, sameSite: "none", partitioned: true } : {}),
  },
}));

// Protección contra peticiones POST enviadas desde otro sitio (CSRF): como la cookie puede viajar
// dentro de un iframe, se rechaza todo POST cuyo origen no sea esta misma aplicación.
app.use((req, res, next) => {
  if (req.method === "POST") {
    const sitio = req.get("sec-fetch-site");
    let origenValido = true;
    const origen = req.get("origin");
    if (origen && origen !== "null") {
      try { origenValido = new URL(origen).host === req.get("host"); } catch (e) { origenValido = false; }
    }
    if ((sitio && sitio !== "same-origin" && sitio !== "none") || !origenValido) {
      return res.status(403).send("Solicitud bloqueada: el origen no coincide con la aplicación.");
    }
  }
  next();
});

// Ruta sin inicio de sesión para que el hosting compruebe que la app y la base responden.
app.get("/healthz", async (req, res) => {
  try {
    await pool.query("SELECT 1");
    res.send("ok");
  } catch (e) {
    res.status(500).send("sin conexión a la base");
  }
});

// Las credenciales de demostración se muestran en la pantalla de acceso salvo que SHOW_DEMO_HINT=false.
const mostrarDemo = process.env.SHOW_DEMO_HINT !== "false";

function fail(res, status, mensaje) {
  res.status(status).render("error", { mensaje, status, active: "" });
}

// ---- Middlewares ----
function requireLogin(req, res, next) {
  if (!req.session.user) return res.redirect("/login");
  res.locals.user = req.session.user;
  next();
}
function requireAdmin(req, res, next) {
  if (req.session.user.rol !== "administrador") {
    return fail(res, 403, "Acceso denegado: se requiere rol de administrador.");
  }
  next();
}

// ---- Auth ----
app.get("/login", (req, res) => {
  res.render("login", { error: null, mostrarDemo });
});

app.post("/login", async (req, res) => {
  const { nombre_usuario, contrasena } = req.body;
  try {
    const { rows } = await pool.query(
      "SELECT * FROM usuario WHERE nombre_usuario = $1",
      [nombre_usuario]
    );
    if (rows.length === 0) {
      return res.render("login", { error: "Usuario no encontrado.", mostrarDemo });
    }
    const ok = await bcrypt.compare(contrasena, rows[0].contrasena_hash);
    if (!ok) {
      return res.render("login", { error: "Contraseña incorrecta.", mostrarDemo });
    }
    req.session.user = { id: rows[0].id_usuario, nombre: rows[0].nombre_usuario, rol: rows[0].rol };
    res.redirect("/");
  } catch (e) {
    console.error(e);
    res.render("login", { error: "Error de conexión a la base de datos.", mostrarDemo });
  }
});

app.get("/logout", (req, res) => {
  req.session.destroy(() => res.redirect("/login"));
});

// ---- Dashboard ----
app.get("/", requireLogin, async (req, res) => {
  const counts = {};
  const t = ["pelicula", "director", "actor", "genero"];
  for (const tabla of t) {
    const { rows } = await pool.query(`SELECT COUNT(*) FROM ${tabla}`);
    counts[tabla] = rows[0].count;
  }
  const { rows: top } = await pool.query("SELECT * FROM vista_top_peliculas LIMIT 5");
  res.render("dashboard", { counts, top });
});

// ---- Peliculas ----
app.get("/peliculas", requireLogin, async (req, res) => {
  const { genero, anio, q, rating_min, director } = req.query;
  let sql = "SELECT * FROM vista_catalogo_completo WHERE 1=1";
  const params = [];
  if (q) { params.push(`%${q}%`); sql += ` AND titulo ILIKE $${params.length}`; }
  if (anio) { params.push(anio); sql += ` AND anio = $${params.length}`; }
  if (genero) { params.push(`%${genero}%`); sql += ` AND generos ILIKE $${params.length}`; }
  if (rating_min) { params.push(rating_min); sql += ` AND calificacion >= $${params.length}`; }
  if (director) { params.push(`%${director}%`); sql += ` AND nombre_director ILIKE $${params.length}`; }
  sql += " ORDER BY id_pelicula LIMIT 100";
  const { rows } = await pool.query(sql, params);
  const { rows: generos } = await pool.query("SELECT * FROM genero ORDER BY nombre_genero");
  res.render("peliculas/list", { peliculas: rows, generos, query: req.query });
});

app.get("/peliculas/nueva", requireLogin, requireAdmin, async (req, res) => {
  const { rows: directores } = await pool.query("SELECT * FROM director ORDER BY nombre_director");
  const { rows: generos } = await pool.query("SELECT * FROM genero ORDER BY nombre_genero");
  res.render("peliculas/form", { pelicula: null, directores, generos, seleccionados: [] });
});

app.post("/peliculas/nueva", requireLogin, requireAdmin, async (req, res) => {
  const { titulo, descripcion, anio, duracion_minutos, calificacion, votos, recaudacion_millones, metascore, id_director, generos } = req.body;
  try {
    const { rows } = await pool.query(
      `INSERT INTO pelicula (titulo, descripcion, anio, duracion_minutos, calificacion, votos, recaudacion_millones, metascore, id_director)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING id_pelicula`,
      [titulo, descripcion, anio, duracion_minutos || null, calificacion || null, votos || null, recaudacion_millones || null, metascore || null, id_director || null]
    );
    const idPelicula = rows[0].id_pelicula;
    const generosArr = Array.isArray(generos) ? generos : (generos ? [generos] : []);
    for (const g of generosArr) {
      await pool.query("INSERT INTO pelicula_genero (id_pelicula, id_genero) VALUES ($1,$2)", [idPelicula, g]);
    }
    res.redirect("/peliculas");
  } catch (e) {
    console.error(e);
    fail(res, 400, "Error al guardar: " + e.message);
  }
});

app.get("/peliculas/:id/editar", requireLogin, requireAdmin, async (req, res) => {
  const { rows } = await pool.query("SELECT * FROM pelicula WHERE id_pelicula = $1", [req.params.id]);
  if (rows.length === 0) return fail(res, 404, "Película no encontrada.");
  const { rows: directores } = await pool.query("SELECT * FROM director ORDER BY nombre_director");
  const { rows: generos } = await pool.query("SELECT * FROM genero ORDER BY nombre_genero");
  const { rows: sel } = await pool.query("SELECT id_genero FROM pelicula_genero WHERE id_pelicula = $1", [req.params.id]);
  res.render("peliculas/form", { pelicula: rows[0], directores, generos, seleccionados: sel.map(r => r.id_genero) });
});

app.post("/peliculas/:id/editar", requireLogin, requireAdmin, async (req, res) => {
  const { titulo, descripcion, anio, duracion_minutos, calificacion, votos, recaudacion_millones, metascore, id_director, generos } = req.body;
  try {
    await pool.query(
      `UPDATE pelicula SET titulo=$1, descripcion=$2, anio=$3, duracion_minutos=$4, calificacion=$5,
         votos=$6, recaudacion_millones=$7, metascore=$8, id_director=$9 WHERE id_pelicula=$10`,
      [titulo, descripcion, anio, duracion_minutos || null, calificacion || null, votos || null, recaudacion_millones || null, metascore || null, id_director || null, req.params.id]
    );
    await pool.query("DELETE FROM pelicula_genero WHERE id_pelicula = $1", [req.params.id]);
    const generosArr = Array.isArray(generos) ? generos : (generos ? [generos] : []);
    for (const g of generosArr) {
      await pool.query("INSERT INTO pelicula_genero (id_pelicula, id_genero) VALUES ($1,$2)", [req.params.id, g]);
    }
    res.redirect("/peliculas/" + req.params.id);
  } catch (e) {
    console.error(e);
    fail(res, 400, "Error al guardar: " + e.message);
  }
});

app.get("/peliculas/:id", requireLogin, async (req, res) => {
  const { rows } = await pool.query("SELECT * FROM vista_catalogo_completo WHERE id_pelicula = $1", [req.params.id]);
  if (rows.length === 0) return fail(res, 404, "Película no encontrada.");
  const { rows: extra } = await pool.query(
    "SELECT descripcion, duracion_minutos, votos, metascore FROM pelicula WHERE id_pelicula = $1", [req.params.id]);
  Object.assign(rows[0], extra[0]);
  const { rows: reparto } = await pool.query(
    `SELECT a.nombre_actor, pa.orden_reparto FROM pelicula_actor pa
     JOIN actor a ON a.id_actor = pa.id_actor WHERE pa.id_pelicula = $1 ORDER BY pa.orden_reparto`,
    [req.params.id]
  );
  res.render("peliculas/detalle", { pelicula: rows[0], reparto });
});

app.post("/peliculas/:id/eliminar", requireLogin, requireAdmin, async (req, res) => {
  await pool.query("DELETE FROM pelicula WHERE id_pelicula = $1", [req.params.id]);
  res.redirect("/peliculas");
});

// ---- Directores ----
app.get("/directores", requireLogin, async (req, res) => {
  const { rows } = await pool.query(
    `SELECT d.id_director, d.nombre_director, COUNT(p.id_pelicula) AS num_peliculas
     FROM director d LEFT JOIN pelicula p ON p.id_director = d.id_director
     GROUP BY d.id_director, d.nombre_director ORDER BY d.nombre_director`
  );
  res.render("directores", { directores: rows });
});
app.post("/directores/nuevo", requireLogin, requireAdmin, async (req, res) => {
  await pool.query("INSERT INTO director (nombre_director) VALUES ($1) ON CONFLICT DO NOTHING", [req.body.nombre_director]);
  res.redirect("/directores");
});

app.post("/directores/:id/editar", requireLogin, requireAdmin, async (req, res) => {
  try {
    await pool.query("UPDATE director SET nombre_director = $1 WHERE id_director = $2", [req.body.nombre_director, req.params.id]);
    res.redirect("/directores");
  } catch (e) {
    fail(res, 400, "No se pudo actualizar: " + e.message);
  }
});
app.post("/directores/:id/eliminar", requireLogin, requireAdmin, async (req, res) => {
  try {
    await pool.query("DELETE FROM director WHERE id_director = $1", [req.params.id]);
    res.redirect("/directores");
  } catch (e) {
    fail(res, 400, "No se puede eliminar este registro porque está en uso por una o más películas.");
  }
});

// ---- Actores ----
app.get("/actores", requireLogin, async (req, res) => {
  const { rows } = await pool.query(
    `SELECT a.id_actor, a.nombre_actor, COUNT(pa.id_pelicula) AS num_peliculas
     FROM actor a LEFT JOIN pelicula_actor pa ON pa.id_actor = a.id_actor
     GROUP BY a.id_actor, a.nombre_actor ORDER BY a.nombre_actor LIMIT 200`
  );
  res.render("actores", { actores: rows });
});
app.post("/actores/nuevo", requireLogin, requireAdmin, async (req, res) => {
  await pool.query("INSERT INTO actor (nombre_actor) VALUES ($1) ON CONFLICT DO NOTHING", [req.body.nombre_actor]);
  res.redirect("/actores");
});

app.post("/actores/:id/editar", requireLogin, requireAdmin, async (req, res) => {
  try {
    await pool.query("UPDATE actor SET nombre_actor = $1 WHERE id_actor = $2", [req.body.nombre_actor, req.params.id]);
    res.redirect("/actores");
  } catch (e) {
    fail(res, 400, "No se pudo actualizar: " + e.message);
  }
});
app.post("/actores/:id/eliminar", requireLogin, requireAdmin, async (req, res) => {
  try {
    await pool.query("DELETE FROM actor WHERE id_actor = $1", [req.params.id]);
    res.redirect("/actores");
  } catch (e) {
    fail(res, 400, "No se puede eliminar este registro porque está en uso por una o más películas.");
  }
});

// ---- Generos ----
app.get("/generos", requireLogin, async (req, res) => {
  const { rows } = await pool.query(
    `SELECT g.id_genero, g.nombre_genero, COUNT(pg.id_pelicula) AS num_peliculas
     FROM genero g LEFT JOIN pelicula_genero pg ON pg.id_genero = g.id_genero
     GROUP BY g.id_genero, g.nombre_genero ORDER BY num_peliculas DESC`
  );
  res.render("generos", { generos: rows });
});
app.post("/generos/nuevo", requireLogin, requireAdmin, async (req, res) => {
  await pool.query("INSERT INTO genero (nombre_genero) VALUES ($1) ON CONFLICT DO NOTHING", [req.body.nombre_genero]);
  res.redirect("/generos");
});

app.post("/generos/:id/editar", requireLogin, requireAdmin, async (req, res) => {
  try {
    await pool.query("UPDATE genero SET nombre_genero = $1 WHERE id_genero = $2", [req.body.nombre_genero, req.params.id]);
    res.redirect("/generos");
  } catch (e) {
    fail(res, 400, "No se pudo actualizar: " + e.message);
  }
});
app.post("/generos/:id/eliminar", requireLogin, requireAdmin, async (req, res) => {
  try {
    await pool.query("DELETE FROM genero WHERE id_genero = $1", [req.params.id]);
    res.redirect("/generos");
  } catch (e) {
    fail(res, 400, "No se puede eliminar este registro porque está en uso por una o más películas.");
  }
});

// ---- Bitácora ----
app.get("/auditoria", requireLogin, requireAdmin, async (req, res) => {
  const { rows } = await pool.query("SELECT * FROM pelicula_auditoria ORDER BY id_auditoria DESC");
  res.render("auditoria", { registros: rows });
});

// ---- Reportes ----
app.get("/reportes/top", requireLogin, async (req, res) => {
  const { rows } = await pool.query("SELECT * FROM vista_top_peliculas");
  res.render("reportes/top", { top: rows });
});
app.get("/reportes/recaudacion", requireLogin, async (req, res) => {
  const { rows } = await pool.query("SELECT * FROM vista_recaudacion_por_genero");
  res.render("reportes/recaudacion", { datos: rows });
});

// Errores no controlados (por ejemplo, la base no responde): mensaje claro en lugar de la traza.
app.use((err, req, res, next) => {
  console.error(err);
  if (res.headersSent) return next(err);
  fail(res, 500, "Ocurrió un error en el servidor. Intenta de nuevo en unos segundos.");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`CineDB app escuchando en http://localhost:${PORT}`));
