DELIMITER //

/*---------------------------------------------------------------
  SP: SetResetToken
  Propósito: Verificar email y residencia y asignar token de reset
             en la tabla password_reset_tokens.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS SetResetToken//

CREATE PROCEDURE SetResetToken(
  IN p_Email VARCHAR(150),
  IN p_Token VARCHAR(100)
)
BEGIN
  DECLARE v_UserId BIGINT;

  -- Manejador de errores: rollback y señal en caso de excepción
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error al generar token de recuperación';
  END;

  -- 1) Obtener user_id a partir del email
  SELECT id
    INTO v_UserId
    FROM users
   WHERE email = p_Email
   LIMIT 1;

  -- 2) Email debe existir
  IF v_UserId IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Email inexistente';
  END IF;

  -- 3) Usuario debe estar activo
  IF NOT EXISTS (
    SELECT 1 FROM users
     WHERE id = v_UserId
       AND status = 1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario no activo';
  END IF;

  -- 4) Email debe estar verificado
  IF EXISTS (
    SELECT 1 FROM users
     WHERE id = v_UserId
       AND IFNULL(verified_email,0) = 0
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Email no verificado';
  END IF;

  -- 5) Residencia debe estar aprobada
  IF EXISTS (
    SELECT 1 FROM users
     WHERE id = v_UserId
       AND IFNULL(verified_residence,0) = 0
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Prueba de residencia no aprobada';
  END IF;

  START TRANSACTION;

    -- 6) Eliminar cualquier token previo
    DELETE FROM password_reset_tokens
     WHERE user_id = v_UserId;

    -- 7) Insertar el nuevo token
    INSERT INTO password_reset_tokens (
      user_id,
      token,
      created_at
    ) VALUES (
      v_UserId,
      p_Token,
      NOW()
    );

  COMMIT;

  -- 8) Respuesta exitosa
  SELECT
    0 AS code,
    'Token de recuperación generado' AS description;
END//

DELIMITER ;
