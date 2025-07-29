DELIMITER //

DROP PROCEDURE IF EXISTS GetListingImages//

CREATE PROCEDURE GetListingImages(
  IN p_ListingId BIGINT
)
BEGIN
  -- Declaraciones de variables deben ir al inicio del BEGIN
  DECLARE v_mainUrl TEXT;

  -- Validar existencia de la publicación
  IF NOT EXISTS (SELECT 1 FROM listings WHERE id = p_ListingId) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La publicación no existe.';
  END IF;

  -- Obtener URL de la imagen principal
  SELECT main_image
    INTO v_mainUrl
    FROM listings
   WHERE id = p_ListingId;

  -- Seleccionar la principal y hasta 4 auxiliares
  SELECT
    v_mainUrl                                AS mainImage,
    MAX(CASE WHEN rn = 1 THEN image_url END) AS aux1,
    MAX(CASE WHEN rn = 2 THEN image_url END) AS aux2,
    MAX(CASE WHEN rn = 3 THEN image_url END) AS aux3,
    MAX(CASE WHEN rn = 4 THEN image_url END) AS aux4
  FROM (
    SELECT
      image_url,
      ROW_NUMBER() OVER (ORDER BY image_number) AS rn
    FROM listing_images
    WHERE listing_id = p_ListingId
  ) AS Aux;
END//

DELIMITER ;
