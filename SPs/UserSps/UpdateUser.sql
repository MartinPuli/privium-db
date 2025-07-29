DELIMITER //

/*---------------------------------------------------------------
  SP: UpdateUser
  Propósito: Editar teléfono de un usuario existente.
    - No puede modificar email, password, DNI, nombre, apellido ni tokens.
    - Verifica que el usuario exista y no esté eliminado (status ≠ -1).
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS UpdateUser//

CREATE PROCEDURE UpdateUser(
  IN p_UserId BIGINT,
  IN p_Phone  VARCHAR(20)
)
BEGIN
  -- 1) Verificar que el usuario exista y no esté eliminado (status ≠ -1)
  IF NOT EXISTS (
    SELECT 1 FROM users
     WHERE id = p_UserId
       AND status <> -1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario no encontrado';
  END IF;

  START TRANSACTION;

  -- 2) Actualizar el teléfono de contacto
  UPDATE users
     SET contact_phone = p_Phone
   WHERE id = p_UserId;

  -- 3) Verificar que la actualización se haya aplicado
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error al actualizar usuario';
  END IF;

  COMMIT;

  -- 4) Devolver resultado
  SELECT
    0 AS code,
    'Usuario actualizado' AS description;
END//

DELIMITER ;
