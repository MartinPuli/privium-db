DELIMITER //

/*---------------------------------------------------------------
  SP: CreateUser
  Propósito:
    - Crear un nuevo usuario.
    - Devolver el registro del usuario.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS CreateUser//

CREATE PROCEDURE CreateUser(
  IN p_Name          VARCHAR(100),
  IN p_Lastname      VARCHAR(100),
  IN p_Email         VARCHAR(150),
  IN p_PasswordHash  VARCHAR(255),
  IN p_Dni           VARCHAR(20),
  IN p_CountryId     BIGINT,
  IN p_Phone         VARCHAR(20)
)
BEGIN
  DECLARE v_NewUserId BIGINT;

  -- Validaciones obligatorias
  IF p_Name          IS NULL OR TRIM(p_Name)          = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre es obligatorio'; END IF;
  IF p_Lastname      IS NULL OR TRIM(p_Lastname)      = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido es obligatorio'; END IF;
  IF p_Email         IS NULL OR TRIM(p_Email)         = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El email es obligatorio'; END IF;
  IF p_PasswordHash  IS NULL OR TRIM(p_PasswordHash)  = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña es obligatoria'; END IF;
  IF p_Dni           IS NULL OR TRIM(p_Dni)           = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI es obligatorio'; END IF;
  IF p_CountryId     IS NULL                         THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El barrio privado es obligatorio'; END IF;

  -- Unicidad y existencia
  IF EXISTS(SELECT 1 FROM users     WHERE email = p_Email)  THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email ya registrado'; END IF;
  IF EXISTS(SELECT 1 FROM users     WHERE dni   = p_Dni)    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DNI ya registrado'; END IF;
  IF NOT EXISTS(SELECT 1 FROM countries WHERE id = p_CountryId) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Barrio privado inexistente'; END IF;

  -- Inserción en transacción
  START TRANSACTION;
    INSERT INTO users (
      name, lastname, email, password_hash,
      dni, contact_phone, country_id,
      verified_email, verified_residence,
      status, created_at
    ) VALUES (
      p_Name, p_Lastname, p_Email, p_PasswordHash,
      p_Dni,  p_Phone,     p_CountryId,
      0,      0,
      0,      NOW()
    );
    SET v_NewUserId = LAST_INSERT_ID();
  COMMIT;

  -- Devolver el usuario creado
  SELECT
    v_NewUserId           AS id,
    p_Name                AS name,
    p_Lastname            AS lastname,
    p_Email               AS email,
    p_PasswordHash        AS password_hash,
    p_Dni                 AS dni,
    p_Phone               AS contact_phone,
    0                     AS verified_email,
    0                     AS verified_residence,
    0                     AS status,
    p_CountryId           AS country_id,
    NULL                  AS profile_picture,
    NOW()                 AS created_at,
    'USER'                AS role;
    
END//

DELIMITER ;
