DELIMITER //

/*---------------------------------------------------------------
  SP: GetUserImages
  Propósito: Devuelve todas las URLs de imágenes de las publicaciones de un usuario,
             incluyendo la imagen principal y las imágenes auxiliares.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetUserImages//

CREATE PROCEDURE GetUserImages(
  IN p_UserId BIGINT
)
BEGIN
  -- Validar existencia del usuario (no eliminado)
  IF NOT EXISTS (
    SELECT 1
      FROM users
     WHERE id = p_UserId
       AND status <> -1
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario inexistente.';
  END IF;

  -- Seleccionar todas las imágenes (principal y auxiliares) de las publicaciones del usuario
  SELECT img.imageUrl
  FROM (
    -- Imagen principal
    SELECT l.id AS listingId,
           0 AS imgOrder,
           l.main_image AS imageUrl
      FROM listings l
     WHERE l.user_id = p_UserId
       AND l.main_image IS NOT NULL
    UNION ALL
    -- Imágenes auxiliares
    SELECT li.listing_id AS listingId,
           li.image_number AS imgOrder,
           li.image_url AS imageUrl
      FROM listings l
      JOIN listing_images li ON li.listing_id = l.id
     WHERE l.user_id = p_UserId
  ) AS img
  ORDER BY img.listingId, img.imgOrder;
END//

DELIMITER ;
