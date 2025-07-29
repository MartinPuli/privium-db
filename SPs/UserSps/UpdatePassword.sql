DELIMITER //

/*---------------------------------------------------------------
  SP: UpdatePassword
  Propósito: Validar token de recuperación en password_reset_tokens,
             actualizar la contraseña en users y eliminar el token.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS UpdatePassword//

CREATE PROCEDURE UpdatePassword(
  IN p_Token             VARCHAR(100),
  IN p_NewPasswordHash   VARCHAR(255)
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

  START TRANSACTION;

  -- 2) Actualizar la contraseña del usuario
  UPDATE users
     SET password_hash = p_NewPasswordHash
   WHERE id = v_UserId;
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error al actualizar contraseña';
  END IF;

  -- 3) Eliminar el token usado
  DELETE FROM password_reset_tokens
   WHERE user_id = v_UserId;
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error al eliminar token de recuperación';
  END IF;

  COMMIT;

  -- 4) Respuesta exitosa
  SELECT
    0 AS code,
    'Contraseña actualizada correctamente' AS description;
END//

DELIMITER ;
