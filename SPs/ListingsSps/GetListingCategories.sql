DELIMITER //

/*---------------------------------------------------------------
  SP: GetListingCategories
  Propósito: Devuelve las categorías de una publicación dado su ID,
             retornando el id de categoría y su descripción (name).
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetListingCategories//

CREATE PROCEDURE GetListingCategories(
  IN p_ListingId BIGINT
)
BEGIN
  -- Validar existencia de la publicación
  IF NOT EXISTS (SELECT 1 FROM listings WHERE id = p_ListingId) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Publicación inexistente.';
  END IF;

  -- Seleccionar id y descripción de categorías asociadas
  SELECT
    c.id   AS categoryId,
    c.name AS description
  FROM categories c
  JOIN listings_categories lc
    ON lc.category_id = c.id
  WHERE lc.product_id = p_ListingId;
END//

DELIMITER ;
