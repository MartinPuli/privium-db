DELIMITER //

DROP PROCEDURE IF EXISTS ListListings //

CREATE PROCEDURE ListListings(
  /* ---------------------- Filtros “básicos” ---------------------- */
  IN p_UserId            BIGINT,
  IN p_Status            INT,
  IN p_SearchTerm        VARCHAR(255),
  IN p_CreatedFrom       DATETIME,
  IN p_CreatedTo         DATETIME,
  IN p_CategoryIds       TEXT,
  IN p_SortOrder         VARCHAR(4),
  IN p_CountryId         BIGINT,
  IN p_CenterCountryId   BIGINT,
  IN p_MaxDistanceKm     DECIMAL(8,2),
  IN p_ConditionFilter   TINYINT,
  IN p_BrandFilter       VARCHAR(255),
  IN p_TypeFilter        VARCHAR(50),

  /* ---------------------- Filtros de medios de pago -------------- */
  IN p_AcceptsBarter     TINYINT,
  IN p_AcceptsCash       TINYINT,
  IN p_AcceptsTransfer   TINYINT,
  IN p_AcceptsCard       TINYINT,

  /* ---------------------- Filtros de precio ---------------------- */
  IN p_MinPrice          DECIMAL(10,2),
  IN p_MaxPrice          DECIMAL(10,2),

  /* ---------------------- NUEVOS filtros ------------------------- */
  IN p_ListingId         BIGINT,      -- devolver SOLO este id
  IN p_NotShownListing   BIGINT,      -- excluir este id

  /* ---------------------- Exclusión por usuario ------------------ */
  IN p_NotShownUser      BIGINT,

  /* ---------------------- Paginación ----------------------------- */
  IN p_Page              INT,
  IN p_PageSize          INT
)
BEGIN
  /* -------- Variables internas -------- */
  DECLARE v_Page       INT DEFAULT 1;
  DECLARE v_PageSize   INT DEFAULT 10;
  DECLARE v_Order      VARCHAR(4) DEFAULT 'DESC';
  DECLARE v_json       JSON;
  DECLARE v_latitude   DECIMAL(10,6);
  DECLARE v_longitude  DECIMAL(10,6);
  DECLARE v_offset     INT;
  DECLARE v_Status     INT DEFAULT 1;

  /* ----- Valores por defecto / validaciones --------------------- */
  IF p_Page      IS NOT NULL AND p_Page      > 0 THEN SET v_Page     = p_Page;     END IF;
  IF p_PageSize  IS NOT NULL AND p_PageSize  > 0 THEN SET v_PageSize = p_PageSize; END IF;
  IF p_SortOrder IS NOT NULL                  THEN SET v_Order = UPPER(p_SortOrder); END IF;
  IF v_Order NOT IN ('ASC','DESC') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SortOrder debe ser ASC o DESC';
  END IF;

  /* Si pide un id puntual, forzamos página 1 y tamaño 1 */
  IF p_ListingId IS NOT NULL THEN
    SET v_Page = 1;
    SET v_PageSize = 1;
  END IF;

  /* ----- Categories → JSON array -------------------------------- */
  IF p_CategoryIds IS NOT NULL AND TRIM(p_CategoryIds) <> '' THEN
    SET v_json = CAST(CONCAT('["', REPLACE(TRIM(p_CategoryIds), ',', '","'), '"]') AS JSON);
  ELSE
    SET v_json = JSON_ARRAY();
  END IF;

  /* ----- Coordenadas para distancia ----------------------------- */
  IF p_CenterCountryId IS NOT NULL THEN
    SELECT latitude, longitude
      INTO v_latitude, v_longitude
      FROM countries
     WHERE id = p_CenterCountryId;
  END IF;

  SET v_offset = (v_Page - 1) * v_PageSize;

  IF p_Status IS NOT NULL THEN
    SET v_Status = p_Status;
  END IF;

  /* ======================= CONSULTA PRINCIPAL =================== */
  IF v_Order = 'ASC' THEN
    SELECT
      l.id,
      l.title,
      l.description,
      l.price,
      l.accepts_barter   AS acceptsBarter,
      l.accepts_cash     AS acceptsCash,
      l.accepts_transfer AS acceptsTransfer,
      l.accepts_card     AS acceptsCard,
      l.type,
      l.brand,
      l.user_id          AS userId,
      l.main_image       AS mainImage,
      l.status,
      l.`condition`,
      l.created_at       AS createdAt,
      u.country_id       AS countryId
    FROM listings AS l
    JOIN users      AS u  ON u.id = l.user_id
    LEFT JOIN countries cu ON cu.id = u.country_id
    WHERE
          (p_ListingId       IS NULL OR l.id      = p_ListingId)
      AND (p_NotShownListing IS NULL OR l.id     <> p_NotShownListing)
      AND (p_UserId         IS NULL OR l.user_id = p_UserId)
      AND (p_SearchTerm     IS NULL OR l.title LIKE CONCAT('%', p_SearchTerm, '%'))
      AND (p_CreatedFrom    IS NULL OR l.created_at >= p_CreatedFrom)
      AND (p_CreatedTo      IS NULL OR l.created_at <= p_CreatedTo)
      AND l.status = v_Status
      /* --------- categorías (JSON) --------- */
      AND (
            JSON_LENGTH(v_json) = 0
            OR EXISTS (
                SELECT 1
                FROM JSON_TABLE(v_json, '$[*]' COLUMNS(cat_id VARCHAR(20) PATH '$')) jt
                JOIN listings_categories lc
                  ON lc.product_id  = l.id
                 AND lc.category_id LIKE CONCAT(jt.cat_id, '%')
            )
      )
      /* --------- país y distancia ---------- */
      AND (p_CountryId IS NULL OR u.country_id = p_CountryId)
      AND (
          p_MaxDistanceKm IS NULL
          OR p_CenterCountryId IS NULL
          OR (
              cu.latitude  IS NOT NULL AND cu.longitude IS NOT NULL
              AND 111.045 * DEGREES(ACOS(
                COS(RADIANS(v_latitude)) *
                COS(RADIANS(cu.latitude)) *
                COS(RADIANS(cu.longitude - v_longitude)) +
                SIN(RADIANS(v_latitude)) *
                SIN(RADIANS(cu.latitude))
              )) <= p_MaxDistanceKm
          )
      )
      /* --------- filtros directos ---------- */
      AND (p_ConditionFilter IS NULL OR l.`condition` = p_ConditionFilter)
      AND (p_BrandFilter     IS NULL OR l.brand LIKE CONCAT('%', p_BrandFilter, '%'))
      AND (p_TypeFilter      IS NULL OR l.type  LIKE CONCAT('%', p_TypeFilter, '%'))
      /* --------- medios de pago ------------ */
      AND (p_AcceptsBarter   IS NULL OR p_AcceptsBarter   = 0 OR l.accepts_barter   = 1)
      AND (p_AcceptsCash     IS NULL OR p_AcceptsCash     = 0 OR l.accepts_cash     = 1)
      AND (p_AcceptsTransfer IS NULL OR p_AcceptsTransfer = 0 OR l.accepts_transfer = 1)
      AND (p_AcceptsCard     IS NULL OR p_AcceptsCard     = 0 OR l.accepts_card     = 1)
      /* --------- precio -------------------- */
      AND (p_MinPrice IS NULL OR l.price >= p_MinPrice)
      AND (p_MaxPrice IS NULL OR l.price <= p_MaxPrice)
      /* --------- excluir usuario ----------- */
      AND (p_NotShownUser IS NULL OR l.user_id <> p_NotShownUser)

    ORDER BY l.created_at ASC
    LIMIT v_offset, v_PageSize;
  ELSE
    SELECT
      l.id,
      l.title,
      l.description,
      l.price,
      l.accepts_barter   AS acceptsBarter,
      l.accepts_cash     AS acceptsCash,
      l.accepts_transfer AS acceptsTransfer,
      l.accepts_card     AS acceptsCard,
      l.type,
      l.brand,
      l.user_id          AS userId,
      l.main_image       AS mainImage,
      l.status,
      l.`condition`,
      l.created_at       AS createdAt,
      u.country_id       AS countryId
    FROM listings AS l
    JOIN users      AS u  ON u.id = l.user_id
    LEFT JOIN countries cu ON cu.id = u.country_id
    WHERE
          (p_ListingId       IS NULL OR l.id      = p_ListingId)
      AND (p_NotShownListing IS NULL OR l.id     <> p_NotShownListing)
      AND (p_UserId         IS NULL OR l.user_id = p_UserId)
      AND (p_SearchTerm     IS NULL OR l.title LIKE CONCAT('%', p_SearchTerm, '%'))
      AND (p_CreatedFrom    IS NULL OR l.created_at >= p_CreatedFrom)
      AND (p_CreatedTo      IS NULL OR l.created_at <= p_CreatedTo)
      AND l.status = v_Status
      /* --------- categorías (JSON) --------- */
      AND (
            JSON_LENGTH(v_json) = 0
            OR EXISTS (
                SELECT 1
                FROM JSON_TABLE(v_json, '$[*]' COLUMNS(cat_id VARCHAR(20) PATH '$')) jt
                JOIN listings_categories lc
                  ON lc.product_id  = l.id
                 AND lc.category_id LIKE CONCAT(jt.cat_id, '%')
            )
      )
      /* --------- país y distancia ---------- */
      AND (p_CountryId IS NULL OR u.country_id = p_CountryId)
      AND (
          p_MaxDistanceKm IS NULL
          OR p_CenterCountryId IS NULL
          OR (
              cu.latitude  IS NOT NULL AND cu.longitude IS NOT NULL
              AND 111.045 * DEGREES(ACOS(
                COS(RADIANS(v_latitude)) *
                COS(RADIANS(cu.latitude)) *
                COS(RADIANS(cu.longitude - v_longitude)) +
                SIN(RADIANS(v_latitude)) *
                SIN(RADIANS(cu.latitude))
              )) <= p_MaxDistanceKm
          )
      )
      /* --------- filtros directos ---------- */
      AND (p_ConditionFilter IS NULL OR l.`condition` = p_ConditionFilter)
      AND (p_BrandFilter     IS NULL OR l.brand LIKE CONCAT('%', p_BrandFilter, '%'))
      AND (p_TypeFilter      IS NULL OR l.type  LIKE CONCAT('%', p_TypeFilter, '%'))
      /* --------- medios de pago ------------ */
      AND (p_AcceptsBarter   IS NULL OR p_AcceptsBarter   = 0 OR l.accepts_barter   = 1)
      AND (p_AcceptsCash     IS NULL OR p_AcceptsCash     = 0 OR l.accepts_cash     = 1)
      AND (p_AcceptsTransfer IS NULL OR p_AcceptsTransfer = 0 OR l.accepts_transfer = 1)
      AND (p_AcceptsCard     IS NULL OR p_AcceptsCard     = 0 OR l.accepts_card     = 1)
      /* --------- precio -------------------- */
      AND (p_MinPrice IS NULL OR l.price >= p_MinPrice)
      AND (p_MaxPrice IS NULL OR l.price <= p_MaxPrice)
      /* --------- excluir usuario ----------- */
      AND (p_NotShownUser IS NULL OR l.user_id <> p_NotShownUser)

    ORDER BY l.created_at DESC
    LIMIT v_offset, v_PageSize;
  END IF;
END //

DELIMITER ;
