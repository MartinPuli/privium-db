DELIMITER //

/*---------------------------------------------------------------
  SP: ApproveResidence
  Propósito: Aprobar o rechazar prueba de residencia de un usuario.
    - Verifica que el solicitante (p_AdminId) sea ADMIN.
    - Verifica que el usuario exista y no esté eliminado (status ≠ -1).
    - Si intenta aprobar y ya está aprobado, arroja error.
    - Actualiza verified_residence.
    - Si tanto email como residencia quedan verificados, pone status = 1.
    - Elimina el registro de residencia de residence_proofs.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS ApproveResidence//

CREATE PROCEDURE ApproveResidence(
  IN p_AdminId  BIGINT,   -- quien ejecuta, debe ser ADMIN
  IN p_UserId   BIGINT,   -- usuario a aprobar/rechazar
  IN p_Approved TINYINT   -- 1 = aprobar, 0 = rechazar
)
BEGIN
  -- 0) Permisos: solo ADMIN puede ejecutar
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = p_AdminId AND role = 'ADMIN'
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No tienes permisos para aprobar o rechazar residencia';
  END IF;

  -- 1) Verificar que el usuario exista y no esté eliminado (status ≠ -1)
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = p_UserId AND status <> -1
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Usuario no encontrado';
  END IF;

  -- 2) Validar “ya verificado”
  IF p_Approved = 1 
     AND EXISTS (
       SELECT 1 FROM users 
        WHERE id = p_UserId 
          AND verified_residence = 1
     ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Residencia ya está verificada';
  END IF;

  START TRANSACTION;

  -- 3) Actualizar estado de residencia y, si aplica, activar status
  UPDATE users
    SET verified_residence = p_Approved,
        status = CASE 
                   WHEN p_Approved = 1 
                        AND verified_email = 1 
                   THEN 1 
                   ELSE status 
                 END
  WHERE id = p_UserId;
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error al actualizar residencia';
  END IF;

  -- 4) Eliminar prueba de residencia
  DELETE FROM residence_proofs
   WHERE user_id = p_UserId;

  COMMIT;

  -- 5) Devolver resultado
  SELECT
    0 AS code,
    CASE 
      WHEN p_Approved = 1 THEN 'Residencia aprobada'
      ELSE 'Residencia rechazada y prueba eliminada'
    END AS description;
END//

DELIMITER ;
