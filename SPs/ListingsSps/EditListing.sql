DELIMITER //

/*---------------------------------------------------------------
  SP: EditListing
  - Edita una publicación (status 0 o 1).
  - Permite editar el título, descripción, precio, imagen principal,
    marca y tipo.
  - Reemplaza categorías (CSV, máx 10) si se envían.
  - Valida existencia, estado, título, tipo, precio y categorías.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS EditListing//

CREATE PROCEDURE EditListing(
  IN p_ListingId       BIGINT,
  IN p_Title           VARCHAR(255),
  IN p_Description     TEXT,
  IN p_Price           DECIMAL(10,2),
  IN p_MainImage       TEXT,
  IN p_AcceptsBarter   TINYINT,
  IN p_AcceptsCash     TINYINT,
  IN p_AcceptsTransfer TINYINT,
  IN p_AcceptsCard     TINYINT,
  IN p_Type            VARCHAR(20),
  IN p_Brand           VARCHAR(255),
  IN p_CategoryIds     TEXT     -- CSV: '2,5,8'
)
BEGIN
  DECLARE v_count INT;
  DECLARE v_json  JSON;
  DECLARE v_cats  TEXT;
  DECLARE v_item  VARCHAR(255);

  -- 1) La publicación debe existir y estar en status 0 o 1
  SELECT COUNT(*) INTO v_count
    FROM listings
   WHERE id = p_ListingId
     AND status IN (0,1);
  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Publicación inexistente o estado inválido.';
  END IF;

  -- 2) Título no vacío si se envía
  IF p_Title IS NOT NULL AND TRIM(p_Title) = '' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El título no puede estar vacío.';
  END IF;

  -- 3) Tipo válido si se envía
  IF p_Type IS NOT NULL THEN
    SET p_Type = UPPER(p_Type);
    IF p_Type NOT IN('PRODUCTO','SERVICIO','INMUEBLE','VEHICULO','MUEBLE') THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo inválido. Debe ser PRODUCTO, SERVICIO, INMUEBLE, VEHICULO o MUEBLE.';
    END IF;
  END IF;

  -- 4) Precio positivo si se envía
  IF p_Price IS NOT NULL AND p_Price <= 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El precio no puede ser negativo ni cero.';
  END IF;

  -- 5) Iniciar transacción
  START TRANSACTION;

  -- 6) Procesar categorías si se envían
  IF p_CategoryIds IS NOT NULL AND TRIM(p_CategoryIds) <> '' THEN
    -- Convertir CSV a JSON array
    SET v_cats = TRIM(p_CategoryIds);
    SET v_json = JSON_ARRAY();
    WHILE v_cats <> '' DO
      SET v_item = SUBSTRING_INDEX(v_cats, ',', 1);
      SET v_json = JSON_ARRAY_APPEND(v_json, '$', TRIM(v_item));
      IF INSTR(v_cats, ',') = 0 THEN
        SET v_cats = '';
      ELSE
        SET v_cats = SUBSTRING(v_cats, INSTR(v_cats, ',') + 1);
      END IF;
    END WHILE;

    -- 6.1) Detectar duplicados
    SELECT COUNT(*) INTO v_count FROM (
      SELECT j.category_id, COUNT(*) AS cnt
      FROM JSON_TABLE(v_json, '$[*]'
        COLUMNS (category_id VARCHAR(20) PATH '$')
      ) AS j
      GROUP BY j.category_id
      HAVING cnt > 1
    ) dup;
    IF v_count > 0 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La lista de categorías contiene IDs duplicados.';
    END IF;

    -- 6.2) Validar máximo 10 categorías
    SELECT COUNT(*) INTO v_count FROM (
      SELECT DISTINCT j.category_id
      FROM JSON_TABLE(v_json, '$[*]'
        COLUMNS (category_id VARCHAR(20) PATH '$')
      ) AS j
    ) uniq;
    IF v_count > 10 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se permiten más de 10 categorías.';
    END IF;

    -- 6.3) Validar existencia en tabla categories
    SELECT COUNT(*) INTO v_count FROM (
      SELECT DISTINCT j.category_id AS cat_id
      FROM JSON_TABLE(v_json, '$[*]'
        COLUMNS (category_id VARCHAR(20) PATH '$')
      ) AS j
    ) s
    LEFT JOIN categories c ON c.id = s.cat_id
    WHERE c.id IS NULL;
    IF v_count > 0 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Una o más categorías no existen.';
    END IF;

    -- 6.4) Reemplazar categorías
    DELETE FROM listings_categories
     WHERE product_id = p_ListingId;

    INSERT INTO listings_categories (product_id, category_id)
    SELECT p_ListingId, j.category_id
    FROM JSON_TABLE(v_json, '$[*]'
      COLUMNS (category_id VARCHAR(20) PATH '$')
    ) AS j
    GROUP BY j.category_id;
  END IF;

  -- 7) Actualizar campos de listings
  UPDATE listings
  SET
    title            = COALESCE(p_Title, title),
    description      = COALESCE(p_Description, description),
    price            = COALESCE(p_Price, price),
    main_image       = COALESCE(p_MainImage, main_image),
    accepts_barter   = COALESCE(p_AcceptsBarter, accepts_barter),
    accepts_cash     = COALESCE(p_AcceptsCash, accepts_cash),
    accepts_transfer = COALESCE(p_AcceptsTransfer, accepts_transfer),
    accepts_card     = COALESCE(p_AcceptsCard, accepts_card),
    type             = COALESCE(p_Type, type),
    brand            = COALESCE(p_Brand, brand)
  WHERE id = p_ListingId;

  -- 8) Confirmar cambios
  COMMIT;

  -- 9) Devolver resultado
  SELECT 0 AS code, 'Publicación actualizada correctamente.' AS description;
END//

DELIMITER ;
