DELIMITER //

/*---------------------------------------------------------------
  SP: DeleteUser
  Propósito: Elimina un usuario y sus publicaciones de forma permanente.
    - Verifica que el usuario exista.
    - Elimina el registro del usuario (borrado físico).
    - Las publicaciones e imágenes asociadas se eliminan por cascada.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS DeleteUser//

CREATE PROCEDURE DeleteUser(
  IN p_UserId BIGINT
)
BEGIN
  -- Verificar que el usuario exista
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = p_UserId
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado';
  END IF;

  START TRANSACTION;

  -- Eliminar usuario de forma permanente
  DELETE FROM users
   WHERE id = p_UserId;

  -- Si no se eliminó ninguna fila, hay un error
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al eliminar usuario';
  END IF;

  COMMIT;

  -- Devolver resultado
  SELECT
    0 AS code,
    'Usuario y publicaciones eliminados' AS description;
END//

DELIMITER ;

