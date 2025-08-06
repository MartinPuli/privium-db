DELIMITER //

/*---------------------------------------------------------------
  SP: GetUserByEmail
  Propósito: 
    - Buscar un usuario por email, siempre que no esté eliminado (status ≠ -1).
    - El email debe estar verificado.
    - La residencia debe estar aprobada; en caso contrario se indica si está pendiente o rechazada.
    - Devuelve todos los campos de la tabla users.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetUserByEmail//

CREATE PROCEDURE GetUserByEmail(
  IN p_Email VARCHAR(150)
)
BEGIN
  -- 1) Verificar existencia y que no esté eliminado
  IF NOT EXISTS (
    SELECT 1
      FROM users
     WHERE email = p_Email
       AND status <> -1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario no encontrado';
  END IF;

  -- 2) El email debe estar verificado
  IF EXISTS (
    SELECT 1
      FROM users
     WHERE email = p_Email
       AND (verified_email = 0 OR verified_email IS NULL)
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Email no verificado';
  END IF;

  -- 3) La residencia debe estar aprobada
  IF EXISTS (
    SELECT 1
      FROM users
     WHERE email = p_Email
       AND (verified_residence = 0 OR verified_residence IS NULL)
  ) THEN
    IF EXISTS (
      SELECT 1
        FROM residence_proofs rp
        JOIN users u ON rp.user_id = u.id
       WHERE u.email = p_Email
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prueba de residencia pendiente';
    ELSE
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Prueba de residencia rechazada';
    END IF;
  END IF;

  -- 4) Devolver el usuario
  SELECT *
    FROM users
   WHERE email = p_Email;
END//

DELIMITER ;
