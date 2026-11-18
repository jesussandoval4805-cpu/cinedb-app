CREATE TABLE director (
  id_director SERIAL PRIMARY KEY,
  nombre_director VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE genero (
  id_genero SERIAL PRIMARY KEY,
  nombre_genero VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE actor (
  id_actor SERIAL PRIMARY KEY,
  nombre_actor VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE pelicula (
  id_pelicula SERIAL PRIMARY KEY,
  rank_original INT,
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT,
  anio INT NOT NULL,
  duracion_minutos INT,
  calificacion NUMERIC(3,1),
  votos INT,
  recaudacion_millones NUMERIC(8,2),
  metascore INT,
  id_director INT REFERENCES director(id_director)
);

CREATE TABLE pelicula_genero (
  id_pelicula INT REFERENCES pelicula(id_pelicula) ON DELETE CASCADE,
  id_genero INT REFERENCES genero(id_genero) ON DELETE CASCADE,
  PRIMARY KEY (id_pelicula, id_genero)
);

CREATE TABLE pelicula_actor (
  id_pelicula INT REFERENCES pelicula(id_pelicula) ON DELETE CASCADE,
  id_actor INT REFERENCES actor(id_actor) ON DELETE CASCADE,
  orden_reparto INT,
  PRIMARY KEY (id_pelicula, id_actor)
);

CREATE TABLE usuario (
  id_usuario SERIAL PRIMARY KEY,
  nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
  contrasena_hash VARCHAR(255) NOT NULL,
  rol VARCHAR(20) NOT NULL CHECK (rol IN ('administrador','analista')),
  fecha_creacion DATE DEFAULT CURRENT_DATE
);
