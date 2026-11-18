# Publicar CineDB en internet y mostrarla en Google Sites

Google Sites solo puede **mostrar** (incrustar) una página que ya esté publicada en internet: no ejecuta
servidores ni se conecta a bases de datos. Por eso el sistema se reparte en tres piezas:

| Pieza | Servicio | Qué hace |
|-------|----------|----------|
| Base de datos | **Neon** (PostgreSQL) | Guarda las 8 tablas, las vistas y los triggers |
| Aplicación | **Render** (Node.js/Express) | Es la interfaz: consultas, altas, ediciones y bajas |
| Página | **Google Sites** | Incrusta la dirección pública de la aplicación |

Orden: GitHub → Neon → cargar la base → Render → Google Sites.

---

## 1. Subir el proyecto a GitHub

1. Entren a https://github.com y creen una cuenta (o inicien sesión).
2. **New repository** → nombre `cinedb-app` → **Public** o **Private** → **Create repository**.
3. En la página del repositorio vacío, elijan **uploading an existing file**.
4. Descomprimen el .zip de este proyecto y arrastren **el contenido** (server.js, db.js, package.json,
   render.yaml, las carpetas views, public, sql, etc.), **no la carpeta que lo contiene**: `package.json`
   debe quedar en la raíz del repositorio.
5. **Commit changes**.

## 2. Crear la base en Neon

1. Entren a https://neon.com y creen una cuenta.
2. **Create project**: nombre `cinedb`, versión de Postgres 16 o 17 y la región más cercana.
3. En el panel del proyecto, botón **Connect** y copien la **Connection string**
   (se ve así: `postgresql://usuario:contraseña@ep-xxxx.neon.tech/neondb?sslmode=require`).
   Guárdenla: se usa en el paso 3 y en el paso 4. Es privada, como una contraseña.

## 3. Cargar la base de datos en Neon (desde su computadora)

El archivo `sql/cinedb_respaldo_texto_plano.sql` es el respaldo en texto plano del proyecto. Se restaura con
`psql` (no con el editor SQL de Neon, porque el respaldo usa COPY).

En el **Símbolo del sistema** de Windows (ajusten el número de versión de PostgreSQL y la ruta del archivo):

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" "AQUI_LA_CONNECTION_STRING" -f "C:\ruta\cinedb-app\sql\cinedb_respaldo_texto_plano.sql"
```

Al terminar, comprueben:

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" "AQUI_LA_CONNECTION_STRING" -c "SELECT (SELECT count(*) FROM pelicula) AS peliculas, (SELECT count(*) FROM usuario) AS usuarios;"
```

Debe dar 1000 películas y 2 usuarios.

## 4. Publicar la aplicación en Render

1. Entren a https://render.com e inicien sesión con GitHub.
2. **New +** → **Blueprint** → elijan el repositorio `cinedb-app`. Render lee `render.yaml`.
3. Cuando pida la variable **DATABASE_URL**, peguen la Connection string de Neon.
   (`SESSION_SECRET` se genera sola; `NODE_ENV` y la versión de Node ya vienen en el archivo.)
4. **Apply** y esperen unos minutos a que diga **Live**.
5. Abran la dirección pública (algo como `https://cinedb-xxxx.onrender.com`). Primero prueben
   `/healthz`: debe responder `ok`. Luego inicien sesión.

## 5. Mostrarla en Google Sites

1. Abran su sitio en Google Sites desde la computadora.
2. Panel derecho → **Insertar** → **Incrustar** → pestaña **Por URL** → peguen la dirección de Render
   → **Insertar**.
3. Estiren el recuadro al ancho de la página (o usen en **Páginas → + → Incrustación de página completa**
   para que la aplicación ocupe toda la página).
4. Agreguen también un **Botón** que apunte a la misma dirección ("Abrir CineDB en pantalla completa"):
   sirve de respaldo si el navegador bloquea las cookies dentro de la página incrustada.
5. **Publicar** (esquina superior derecha).

---

## Cosas que conviene saber antes de presentar

- **Primera carga lenta.** En el plan gratuito, Render apaga la aplicación tras 15 minutos sin visitas y la
  vuelve a encender en la siguiente petición, lo que tarda alrededor de un minuto. Abran la dirección unos
  minutos antes de la presentación. Al reiniciarse, las sesiones se pierden y hay que volver a iniciar sesión.
- **Límites gratuitos.** Render: 750 horas de instancia al mes. Neon: 0.5 GB por proyecto (esta base ocupa
  unos pocos MB). Los planes gratuitos cambian; revisen lo que muestran al registrarse.
- **Quien tenga la dirección puede entrar.** Las credenciales de demostración (admin / Admin#2026 y
  analista / Analista#2026) aparecen en la pantalla de acceso. Para ocultarlas, en Render →
  **Environment** agreguen `SHOW_DEMO_HINT` = `false` y entreguen las credenciales al profesor aparte.
  Para cambiar una contraseña, generen el hash y actualícenlo en el **SQL Editor** de Neon:

  ```
  node -e "console.log(require('bcryptjs').hashSync('NuevaClave#2026', 10))"
  ```
  ```sql
  UPDATE usuario SET contrasena_hash = 'EL_HASH_GENERADO' WHERE nombre_usuario = 'admin';
  ```
  (El comando de `node` se ejecuta dentro de la carpeta del proyecto después de `npm install`.)
- **Dejar la base limpia después de probar.** En el SQL Editor de Neon ejecuten
  `DROP SCHEMA public CASCADE; CREATE SCHEMA public;` y vuelvan a cargar el respaldo (paso 3).

## Problemas frecuentes

| Síntoma | Causa probable y solución |
|---------|---------------------------|
| Al iniciar sesión vuelve a salir la pantalla de acceso (dentro de Google Sites) | El navegador bloquea las cookies de la página incrustada (Safari, Firefox, modo incógnito). Usen el botón "Abrir en pantalla completa" o el enlace que aparece en la pantalla de acceso. |
| Google Sites muestra "rechazó la conexión" o un recuadro en blanco | Revisen que la dirección sea `https://` y que la aplicación esté Live en Render. |
| "Error de conexión a la base de datos" | `DATABASE_URL` mal copiada. En Render → **Environment** corríjanla y revisen **Logs**. |
| `/healthz` responde "sin conexión a la base" | Neon está despertando o la cadena es incorrecta; esperen unos segundos y reintenten. |
| Render: "Service Unavailable" | La aplicación está encendiéndose tras estar apagada; esperen un minuto. |

## Ejecutar en la computadora (como antes)

Sin la variable `DATABASE_URL`, la aplicación sigue usando `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD` y
`PGDATABASE` (ver README.md): `npm install` y `npm start`.
