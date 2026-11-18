-- ================== VISTAS ==================

CREATE OR REPLACE VIEW vista_catalogo_completo AS
SELECT p.id_pelicula, p.titulo, p.anio, p.calificacion, p.recaudacion_millones,
       d.nombre_director,
       string_agg(DISTINCT g.nombre_genero, ', ' ORDER BY g.nombre_genero) AS generos
FROM pelicula p
LEFT JOIN director d ON d.id_director = p.id_director
LEFT JOIN pelicula_genero pg ON pg.id_pelicula = p.id_pelicula
LEFT JOIN genero g ON g.id_genero = pg.id_genero
GROUP BY p.id_pelicula, p.titulo, p.anio, p.calificacion, p.recaudacion_millones, d.nombre_director;

CREATE OR REPLACE VIEW vista_top_peliculas AS
SELECT p.titulo, p.anio, p.calificacion, d.nombre_director
FROM pelicula p
JOIN director d ON d.id_director = p.id_director
ORDER BY p.calificacion DESC NULLS LAST, p.votos DESC NULLS LAST, p.id_pelicula
LIMIT 10;

CREATE OR REPLACE VIEW vista_recaudacion_por_genero AS
SELECT g.nombre_genero,
       ROUND(SUM(p.recaudacion_millones)::numeric, 2) AS recaudacion_total_millones,
       ROUND(AVG(p.calificacion)::numeric, 2) AS calificacion_promedio
FROM genero g
JOIN pelicula_genero pg ON pg.id_genero = g.id_genero
JOIN pelicula p ON p.id_pelicula = pg.id_pelicula
GROUP BY g.nombre_genero
ORDER BY recaudacion_total_millones DESC;

-- ================== DISPARADORES ==================

-- 1) Tabla de auditoria para el trigger de borrado
CREATE TABLE pelicula_auditoria (
  id_auditoria SERIAL PRIMARY KEY,
  id_pelicula_eliminada INT,
  titulo_eliminado VARCHAR(200),
  fecha_eliminacion TIMESTAMP DEFAULT now(),
  accion VARCHAR(20)
);

CREATE OR REPLACE FUNCTION fn_auditar_eliminacion()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO pelicula_auditoria (id_pelicula_eliminada, titulo_eliminado, accion)
  VALUES (OLD.id_pelicula, OLD.titulo, 'DELETE');
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditar_eliminacion
AFTER DELETE ON pelicula
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_eliminacion();

-- 2) Trigger de validacion de calificacion (regla de negocio: 0 a 10)
CREATE OR REPLACE FUNCTION fn_validar_calificacion()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.calificacion IS NOT NULL AND (NEW.calificacion < 0 OR NEW.calificacion > 10) THEN
    RAISE EXCEPTION 'La calificacion debe estar entre 0 y 10 (valor recibido: %)', NEW.calificacion;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_calificacion
BEFORE INSERT OR UPDATE ON pelicula
FOR EACH ROW
EXECUTE FUNCTION fn_validar_calificacion();

