DELIMITER //

/*---------------------------------------------------------------
  SP: SetEmailConfirmationToken
  Propósito: Insertar o reemplazar el token de confirmación
             en email_confirmation_tokens dado un user_id.
             Guarda también datos de prueba de residencia
             (mensaje y URL de la imagen).
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS SetEmailConfirmationToken//

CREATE PROCEDURE SetEmailConfirmationToken(
  IN p_UserId        BIGINT,
  IN p_Token         VARCHAR(100),
  IN p_ProofMessage  VARCHAR(500),
  IN p_ProofImageUrl VARCHAR(1000)
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

  -- 2) Validar que al menos haya mensaje o imagen
  IF p_ProofMessage IS NULL AND p_ProofImageUrl IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Se requiere mensaje o imagen para la prueba de residencia';
  END IF;

  START TRANSACTION;

    -- 3) Eliminar token previo si existe
    DELETE FROM email_confirmation_tokens
     WHERE user_id = p_UserId;

    -- 4) Insertar nuevo token con datos de prueba
    INSERT INTO email_confirmation_tokens (
      user_id, token, proof_message, proof_image_url, created_at
    ) VALUES (
      p_UserId, p_Token, p_ProofMessage, p_ProofImageUrl, NOW()
    );

  COMMIT;

  -- Devolver resultado
  SELECT
    0 AS code,
    'Token de confirmación generado' AS description;
END//

DELIMITER ;
