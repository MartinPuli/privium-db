DELIMITER //

/*---------------------------------------------------------------
  SP: SetAuxImages
  Guarda (o reemplaza) hasta 4 imágenes auxiliares
  de una publicación; la imagen principal queda en listings.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS SetAuxImages//

CREATE PROCEDURE SetAuxImages(
  IN p_ListingId BIGINT,    -- id en listings
  IN p_Images    TEXT       -- CSV 'url1,url2,url3,url4'
)
BEGIN
  DECLARE v_count INT;
  DECLARE v_json  JSON;
  DECLARE v_imgs  TEXT;
  DECLARE v_item  VARCHAR(2048);

  -- Validar existencia de la publicación
  IF NOT EXISTS (SELECT 1 FROM listings WHERE id = p_ListingId) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Publicación inexistente.';
  END IF;

  START TRANSACTION;

  IF p_Images IS NULL OR TRIM(p_Images) = '' THEN
    -- Si no envían imágenes, borramos las existentes (1 a 4)
    DELETE FROM listing_images
     WHERE listing_id   = p_ListingId
       AND image_number BETWEEN 1 AND 4;

  ELSE
    -- Convertir lista separada por CHAR(31) a JSON array
    SET v_imgs = TRIM(p_Images);
    SET v_json = JSON_ARRAY();
    WHILE v_imgs <> '' DO
      SET v_item = SUBSTRING_INDEX(v_imgs, CHAR(31), 1);
      SET v_json = JSON_ARRAY_APPEND(v_json, '$', TRIM(v_item));
      IF INSTR(v_imgs, CHAR(31)) = 0 THEN
        SET v_imgs = '';
      ELSE
        SET v_imgs = SUBSTRING(v_imgs, INSTR(v_imgs, CHAR(31)) + 1);
      END IF;
    END WHILE;

    -- Validar máximo 4 imágenes
    SET v_count = JSON_LENGTH(v_json);
    IF v_count > 4 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Máximo 4 imágenes auxiliares por publicación.';
    END IF;

    -- Borrar auxiliares previas
    DELETE FROM listing_images
     WHERE listing_id   = p_ListingId
       AND image_number BETWEEN 1 AND 4;

    -- Insertar nuevas auxiliares numeradas del 1 al N
    INSERT INTO listing_images (listing_id, image_number, image_url)
    SELECT
      p_ListingId,
      jt.ordinality,
      jt.url
    FROM JSON_TABLE(v_json, '$[*]'
      COLUMNS (
        ordinality FOR ORDINALITY,
        url        VARCHAR(2048) PATH '$'
      )
    ) AS jt;

    -- Verificar que al menos una fila se insertó
    IF ROW_COUNT() = 0 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al guardar imágenes auxiliares';
    END IF;
  END IF;

  COMMIT;

  -- Devolver resultado
  SELECT 0 AS code,
         'Imágenes auxiliares guardadas' AS description;
END//

DELIMITER ;
