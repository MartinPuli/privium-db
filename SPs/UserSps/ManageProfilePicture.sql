DELIMITER //

/*---------------------------------------------------------------
  SP: ManageProfilePicture
  Propósito: Crear o eliminar la foto de perfil de un usuario
    - Valida que p_UserId no sea NULL y que el usuario exista y esté activo.
    - Si p_ProfilePicture tiene valor, actualiza la columna.
    - Si p_ProfilePicture es NULL o vacío, elimina la foto (pone NULL).
    - Usa transacción interna y, ante cualquier error, hace ROLLBACK y SIGNAL.
    - Al finalizar exitosamente, devuelve código 0 y descripción.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS ManageProfilePicture//

CREATE PROCEDURE ManageProfilePicture(
  IN p_UserId         BIGINT,
  IN p_ProfilePicture VARCHAR(255)
)
BEGIN
  -- 1) Validación de UserId
  IF p_UserId IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El id de usuario es obligatorio';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM users 
     WHERE id = p_UserId 
       AND status = 1
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado o no activo';
  END IF;

  START TRANSACTION;

  -- 2) Si no se pasa p_ProfilePicture, eliminamos la foto
  IF p_ProfilePicture IS NULL OR TRIM(p_ProfilePicture) = '' THEN
    UPDATE users
       SET profile_picture = NULL
     WHERE id = p_UserId;
    IF ROW_COUNT() = 0 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al eliminar foto de perfil';
    END IF;

    COMMIT;
    SELECT 0 AS code, 'Foto de perfil eliminada' AS description;

  ELSE
    -- 3) En caso contrario, actualizamos (o creamos) la foto
    UPDATE users
       SET profile_picture = p_ProfilePicture
     WHERE id = p_UserId;
    IF ROW_COUNT() = 0 THEN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al actualizar foto de perfil';
    END IF;

    COMMIT;
    SELECT 0 AS code, 'Foto de perfil actualizada' AS description;
  END IF;
END//

DELIMITER ;
