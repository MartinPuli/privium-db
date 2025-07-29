DELIMITER //

/*---------------------------------------------------------------
  SP: GetAuxImages
  Propósito: Devuelve las imágenes auxiliares de una publicación
             dado su ID, retornando el número de imagen y la URL.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetAuxImages//

CREATE PROCEDURE GetAuxImages(
  IN p_ListingId BIGINT
)
BEGIN
  -- Validar existencia de la publicación
  IF NOT EXISTS (SELECT 1 FROM listings WHERE id = p_ListingId) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Publicación inexistente.';
  END IF;

  -- Seleccionar número de imagen y URL de imágenes auxiliares
  SELECT
    image_number AS imgNumber,
    image_url    AS imgUrl
  FROM listing_images
  WHERE listing_id = p_ListingId
  ORDER BY image_number;
END//

DELIMITER ;
