DELIMITER $$

/*---------------------------------------------------------------
  SP: GetCountries
  Propósito : Devuelve la lista completa de “countries”  
              (barrios privados) registrados en la tabla countries,
              ordenados alfabéticamente por nombre.
              Si se pasa p_CountryId, filtra por ese ID; si no, devuelve todos.
---------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetCountries$$

CREATE PROCEDURE GetCountries(
    IN p_CountryId BIGINT  -- opcional: filtrar por un país específico
)
BEGIN
    SELECT
        id,
        name,
        province,
        city,
        postal_code AS postalCode,
        latitude,
        longitude
    FROM countries
    WHERE (p_CountryId IS NULL OR id = p_CountryId)
    ORDER BY name;
END$$

DELIMITER ;
