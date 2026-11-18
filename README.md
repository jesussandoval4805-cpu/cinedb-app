# CineDB — Aplicación web (Node.js/Express + PostgreSQL)

Proyecto final IL356 Bases de Datos — Sistema de Gestión y Consulta del Catálogo IMDB Top 1000
(dataset: "IMDB Movie Dataset", Kaggle).

> Para publicarla en internet e incrustarla en Google Sites, sigue **DESPLIEGUE.md**.

## Requisitos
- Node.js 18 o superior
- PostgreSQL 14 o superior

## 1. Crear y restaurar la base de datos

Opción A — desde el respaldo en texto plano (`cinedb_respaldo_texto_plano.sql`):

```bash
createdb -U postgres cinedb
psql -U postgres -d cinedb -f cinedb_respaldo_texto_plano.sql
```

Opción B — desde el respaldo en formato personalizado (`cinedb_respaldo_custom.backup`):

```bash
createdb -U postgres cinedb
pg_restore -U postgres -d cinedb cinedb_respaldo_custom.backup
```

Opción C — reconstruir desde los scripts de la carpeta `sql/` (en este orden):

```bash
createdb -U postgres cinedb
psql -U postgres -d cinedb -f sql/01_esquema.sql
psql -U postgres -d cinedb -f sql/02_datos.sql
psql -U postgres -d cinedb -f sql/03_vistas_disparadores.sql
```

Cualquiera de las tres opciones deja la base con 1000 películas, 644 directores, 1985 actores,
20 géneros, 2 usuarios, 3 vistas y 2 disparadores.

## 2. Crear el usuario de conexión de la aplicación (una sola vez)

```sql
CREATE ROLE cinedb_app LOGIN PASSWORD 'cinedb_app_2026';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO cinedb_app;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO cinedb_app;
```

(Ejecutar conectado a la base `cinedb`.) Para usar otra configuración, define las variables de
entorno `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD` y `PGDATABASE` antes de iniciar.

## 3. Ejecutar

```bash
npm install
npm start
```

Abrir http://localhost:3000

## Usuarios de prueba

| Usuario  | Contraseña    | Rol           |
|----------|---------------|---------------|
| admin    | Admin#2026    | administrador |
| analista | Analista#2026 | analista      |

## Funcionalidad

- Inicio de sesión con roles (contraseñas con hash bcrypt) y permisos validados en el servidor.
- Dashboard con estadísticas reales y top 5 (vista `vista_top_peliculas`).
- Catálogo de películas con filtros por título, año, género, calificación mínima y director
  (vista `vista_catalogo_completo`) y detalle con reparto.
- Alta, edición y baja de películas (solo administrador).
- Alta, edición de nombre y baja de directores, actores y géneros (solo administrador); la base
  impide eliminar un director con películas asociadas.
- Reglas de negocio en la base de datos: el disparador `trg_validar_calificacion` rechaza
  calificaciones fuera de 0 a 10, y `trg_auditar_eliminacion` registra cada película eliminada.
- Bitácora de eliminaciones (solo administrador), leída de la tabla `pelicula_auditoria`.
- Reportes: top 10 por calificación y recaudación por género (vistas de la base de datos).

## Estructura

```
server.js        rutas, sesión y permisos
db.js            conexión a PostgreSQL (pg)
views/           plantillas EJS
public/css/      estilos
sql/             esquema, datos, vistas y disparadores
```
