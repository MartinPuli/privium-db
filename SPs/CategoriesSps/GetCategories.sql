DELIMITER //

/*---------------------------------------------------------------
  SP: GetCategories
  Propósito
    - Si no recibe parámetros → devuelve TODA la tabla.
    - Si se pasa p_RootId     → devuelve la rama (root + subcategorías).
    - Si se pasa p_LeafId     → devuelve solo esa hoja exacta.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetCategories //

CREATE PROCEDURE GetCategories(
  IN p_RootId VARCHAR(20),
  IN p_LeafId VARCHAR(20)
)
BEGIN
  -- Validación: no permitir ambos parámetros
  IF p_RootId IS NOT NULL AND p_LeafId IS NOT NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usar p_RootId O p_LeafId, no ambos.';
  END IF;

  -- Consulta principal
  SELECT
    id,
    name,
    hasChild
  FROM categories
  WHERE
       (p_RootId IS NULL AND p_LeafId IS NULL)                                -- todo
    OR (p_RootId IS NOT NULL 
        AND (id = p_RootId OR id LIKE CONCAT(p_RootId, '>%')))               -- rama
    OR (p_LeafId IS NOT NULL AND id = p_LeafId)                              -- hoja
  ORDER BY id;
END //

DELIMITER ;
