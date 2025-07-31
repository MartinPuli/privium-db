DELIMITER //

/*---------------------------------------------------------------
  SP: AddListing
  - Crea una publicación (PRODUCTO | SERVICIO | INMUEBLE | VEHICULO | MUEBLE)
  - Hasta 10 categorías CSV (‘2,5,8’), sin IDs duplicados
  - Inicia transacción, valida usuario, tipo y categorías,
    inserta en listings y tabla puente listings_categories.
  - Devuelve la publicación recién creada.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS AddListing//

CREATE PROCEDURE AddListing(
  IN p_UserId          BIGINT,
  IN p_Title           VARCHAR(255),
  IN p_Description     TEXT,
  IN p_Brand           VARCHAR(50),
  IN p_Price           DECIMAL(10,2),
  IN p_MainImage       TEXT,
  IN p_Condition       TINYINT,
  IN p_AcceptsBarter   TINYINT,
  IN p_AcceptsCash     TINYINT,
  IN p_AcceptsTransfer TINYINT,
  IN p_AcceptsCard     TINYINT,
  IN p_Type            VARCHAR(20),
  IN p_CategoryIds     TEXT     -- CSV: '2,5,8'
)
BEGIN
  DECLARE v_count   INT;
  DECLARE v_NewId   BIGINT;
  DECLARE v_json    JSON;
  DECLARE v_cats    TEXT;
  DECLARE v_item    VARCHAR(255);

  -- Validar usuario existe y activo
  SELECT COUNT(*) INTO v_count
    FROM users
   WHERE id = p_UserId
     AND status = 1;
  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario inexistente o no activo.';
  END IF;

  -- Validar usuario verificado
  SELECT COUNT(*) INTO v_count
    FROM users
   WHERE id = p_UserId
     AND (verified_email = 0 OR verified_residence = 0);
  IF v_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario no verificado (email y/o residencia).';
  END IF;

  -- Validar tipo
  SET p_Type = UPPER(p_Type);
  IF p_Type NOT IN('PRODUCTO','SERVICIO','INMUEBLE','VEHICULO','MUEBLE') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Tipo inválido. Debe ser PRODUCTO, SERVICIO, INMUEBLE, VEHICULO o MUEBLE.';
  END IF;

  -- Validaciones simples
  IF p_Title IS NULL OR TRIM(p_Title) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La publicación debe tener un título.';
  END IF;
  IF p_Condition NOT IN(1,2) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La condición debe ser 1(nuevo) o 2(usado).';
  END IF;
  IF p_MainImage IS NULL OR TRIM(p_MainImage) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto debe tener una imagen principal.';
  END IF;
  IF p_Price IS NULL OR p_Price <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser un número positivo.';
  END IF;

  -- Iniciar transacción
  START TRANSACTION;

  -- Procesar categorías si se proporcionan
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

    -- 1) Verificar duplicados
    SELECT COUNT(*) INTO v_count FROM (
      SELECT j.category_id, COUNT(*) AS cnt
      FROM JSON_TABLE(v_json, '$[*]' COLUMNS(category_id VARCHAR(20) PATH '$')) AS j
      GROUP BY j.category_id
      HAVING cnt > 1
    ) AS dup;
    IF v_count > 0 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La lista de categorías contiene IDs duplicados.';
    END IF;

    -- 2) Contar categorías únicas
    SELECT COUNT(*) INTO v_count FROM (
      SELECT DISTINCT j.category_id
      FROM JSON_TABLE(v_json, '$[*]' COLUMNS(category_id VARCHAR(20) PATH '$')) AS j
    ) AS uniq_cats;
    IF v_count > 10 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permiten más de 10 categorías por publicación.';
    END IF;

    -- 3) Validar existencia en categories
    SELECT COUNT(*) INTO v_count FROM (
      SELECT DISTINCT j.category_id AS cat_id
      FROM JSON_TABLE(v_json, '$[*]' COLUMNS(category_id VARCHAR(20) PATH '$')) AS j
    ) AS s
    LEFT JOIN categories c ON c.id = s.cat_id
    WHERE c.id IS NULL;
    IF v_count > 0 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una o más categorías no existen.';
    END IF;
  END IF;

  -- Insertar listing
  INSERT INTO listings (
    title, description, brand, price, `condition`, main_image,
    accepts_barter, accepts_cash, accepts_transfer, accepts_card,
    type, user_id, status, created_at
  ) VALUES (
    p_Title, p_Description, p_Brand, p_Price, p_Condition, p_MainImage,
    p_AcceptsBarter, p_AcceptsCash, p_AcceptsTransfer, p_AcceptsCard,
    p_Type, p_UserId, 1, NOW()
  );

  SET v_NewId = LAST_INSERT_ID();

  -- Insertar categorías (si las hay)
  IF p_CategoryIds IS NOT NULL AND TRIM(p_CategoryIds) <> '' THEN
    INSERT INTO listings_categories (product_id, category_id)
    SELECT v_NewId, j.category_id
    FROM JSON_TABLE(v_json, '$[*]' COLUMNS(category_id VARCHAR(20) PATH '$')) AS j
    GROUP BY j.category_id;
  END IF;

  COMMIT;

  -- Devolver la nueva publicación
  SELECT
    l.id, l.title, l.description, l.brand, l.price,
    l.`condition`, l.accepts_barter   AS acceptsBarter,
    l.accepts_cash     AS acceptsCash,
    l.accepts_transfer AS acceptsTransfer,
    l.accepts_card     AS acceptsCard,
    l.type, l.user_id             AS userId,
    l.main_image                 AS mainImage,
    l.status, l.created_at       AS createdAt
  FROM listings AS l
  WHERE l.id = v_NewId;
END//

DELIMITER ;
