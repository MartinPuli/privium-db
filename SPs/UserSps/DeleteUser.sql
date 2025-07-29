DELIMITER //

/*---------------------------------------------------------------
  SP: DeleteUser
  Propósito: "Eliminar" un usuario (borrado lógico).
    - Verifica que el usuario exista y no esté ya eliminado (status ≠ -1).
    - Cambia status a -1.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS DeleteUser//

CREATE PROCEDURE DeleteUser(
  IN p_UserId BIGINT
)
BEGIN
  -- Verificar que el usuario exista y no esté eliminado (status ≠ -1)
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = p_UserId AND status <> -1
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado';
  END IF;

  START TRANSACTION;

  -- Marcar como eliminado lógicamente
  UPDATE users
    SET status = -1
  WHERE id = p_UserId;

  -- Si no se actualizó ninguna fila, hay un error
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al eliminar usuario';
  END IF;

  COMMIT;

  -- Devolver resultado
  SELECT
    0 AS code,
    'Usuario eliminado' AS description;
END//

DELIMITER ;
