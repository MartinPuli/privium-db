DELIMITER //

/*---------------------------------------------------------------
  SP: GetPasswordHashByToken
  Propósito: Verifica existencia y estado del token de recuperación
             en password_reset_tokens, valida residencia aprobada
             y retorna el hash de contraseña del usuario.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetPasswordHashByToken//

CREATE PROCEDURE GetPasswordHashByToken(
  IN p_Token VARCHAR(100)
)
BEGIN
  DECLARE v_UserId BIGINT;

  -- 1) Comprobar que el token existe y obtener user_id
  SELECT user_id
    INTO v_UserId
    FROM password_reset_tokens
   WHERE token = p_Token
   LIMIT 1;

  IF v_UserId IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Token inválido o expirado';
  END IF;

  -- 2) Validar que el usuario tenga residencia y email verificados
  IF EXISTS (
    SELECT 1
      FROM users
     WHERE id = v_UserId
       AND (IFNULL(verified_residence,0) = 0
         OR IFNULL(verified_email,0)    = 0)
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario no aprobado para cambio de contraseña';
  END IF;

  -- 3) Devolver el hash de contraseña actual
  SELECT password_hash AS passwordHash
    FROM users
   WHERE id = v_UserId;
END//

DELIMITER ;
