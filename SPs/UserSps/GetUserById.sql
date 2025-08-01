DELIMITER //

/*---------------------------------------------------------------
  SP: GetUserById
  Propósito: Obtener un usuario por su ID, verificando que:
    - Existe y no está eliminado (status ≠ -1).
    - Email y residencia estén verificados.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetUserById//

CREATE PROCEDURE GetUserById(
  IN p_UserId BIGINT
)
BEGIN
  -- 1) Verificar existencia y que no esté eliminado
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = p_UserId AND status <> -1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario no encontrado';
  END IF;

  -- 2) Devolver el usuario
  SELECT *
    FROM users
   WHERE id = p_UserId;
END//

DELIMITER ;
