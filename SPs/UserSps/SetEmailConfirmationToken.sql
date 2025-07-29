DELIMITER //

/*---------------------------------------------------------------
  SP: SetEmailConfirmationToken
  Propósito: Insertar o reemplazar el token de confirmación
             en email_confirmation_tokens dado un user_id.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS SetEmailConfirmationToken//

CREATE PROCEDURE SetEmailConfirmationToken(
  IN p_UserId BIGINT,
  IN p_Token  VARCHAR(100)
)
BEGIN
  -- Manejador de errores: rollback y señal en caso de excepción
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error al insertar token de confirmación';
  END;

  -- 1) Verificar que exista el usuario y no esté eliminado
  IF NOT EXISTS (
    SELECT 1 FROM users
     WHERE id = p_UserId
       AND status <> -1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario inexistente';
  END IF;

  START TRANSACTION;

    -- 2) Eliminar token previo si existe
    DELETE FROM email_confirmation_tokens
     WHERE user_id = p_UserId;

    -- 3) Insertar nuevo token
    INSERT INTO email_confirmation_tokens (
      user_id, token, created_at
    ) VALUES (
      p_UserId, p_Token, NOW()
    );

  COMMIT;

  -- Devolver resultado
  SELECT
    0 AS code,
    'Token de confirmación generado' AS description;
END//

DELIMITER ;
