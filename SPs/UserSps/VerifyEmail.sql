DELIMITER //

/*---------------------------------------------------------------
  SP: VerifyEmail
  Propósito: Validar token de verificación desde email_confirmation_tokens,
    marcar email verificado en users y crear prueba de residencia.
    - Verifica que el token exista en email_confirmation_tokens.
    - Si el email ya estaba verificado, arroja error específico.
    - Marca verified_email = 1, actualiza status = 1 si verified_residence = 1.
    - Inserta la prueba de residencia y elimina el token.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS VerifyEmail//

CREATE PROCEDURE VerifyEmail(
  IN p_Token VARCHAR(100)
)
BEGIN
  DECLARE v_UserId          BIGINT;
  DECLARE v_AlreadyVerified TINYINT;
  DECLARE v_ProofMessage    VARCHAR(500);
  DECLARE v_ProofImageUrl   VARCHAR(1000);

  -- 1) Buscar el user_id y datos de prueba en email_confirmation_tokens
  SELECT user_id, proof_message, proof_image_url
    INTO v_UserId, v_ProofMessage, v_ProofImageUrl
    FROM email_confirmation_tokens
   WHERE token = p_Token
   LIMIT 1;

  IF v_UserId IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Token inválido o ya utilizado';
  END IF;

  -- 2) Comprobar si el email ya estaba verificado
  SELECT verified_email
    INTO v_AlreadyVerified
    FROM users
   WHERE id = v_UserId
   LIMIT 1;

  IF v_AlreadyVerified = 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El email ya está verificado';
  END IF;

  START TRANSACTION;

  -- 3) Marcar email verificado y, si aplica, activar status
  UPDATE users
     SET verified_email = 1,
         status = CASE
                    WHEN verified_residence = 1 THEN 1
                    ELSE status
                  END
   WHERE id = v_UserId;
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error al actualizar estado de verificación de email';
  END IF;

  -- 4) Crear registro de prueba de residencia
  INSERT INTO residence_proofs (
    user_id, proof_message, proof_image_url, created_at
  ) VALUES (
    v_UserId, v_ProofMessage, v_ProofImageUrl, NOW()
  );

  -- 5) Eliminar el token usado
  DELETE FROM email_confirmation_tokens
   WHERE token = p_Token;
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error al eliminar token de confirmación';
  END IF;

  COMMIT;

  -- 6) Respuesta exitosa
  SELECT
    0 AS code,
    'Email verificado correctamente' AS description;
END//

DELIMITER ;
