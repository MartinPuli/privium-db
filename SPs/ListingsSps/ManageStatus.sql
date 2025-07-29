DELIMITER //

/*---------------------------------------------------------------
  SP: ManageStatus
  Propósito: Cambia el estado de una publicación:
     - PAUSE       → pone status = 0
     - REACTIVATE  → pone status = 1
     - DELETE      → pone status = -1 (eliminación lógica)
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS ManageStatus//

CREATE PROCEDURE ManageStatus(
  IN p_Action    VARCHAR(10),   -- PAUSE | REACTIVATE | DELETE
  IN p_ListingId BIGINT
)
BEGIN
  DECLARE v_currentStatus INT;

  -- Validar existencia de la publicación
  IF NOT EXISTS (SELECT 1 FROM listings WHERE id = p_ListingId) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Publicación inexistente.';
  END IF;

  -- Obtener estado actual
  SELECT status INTO v_currentStatus
    FROM listings
   WHERE id = p_ListingId;

  -- Validar acción
  SET p_Action = UPPER(p_Action);
  IF p_Action NOT IN('PAUSE','REACTIVATE','DELETE') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Acción inválida. Debe ser PAUSE, REACTIVATE o DELETE.';
  END IF;

  -- Evitar estados redundantes
  IF (p_Action = 'PAUSE'      AND v_currentStatus = 0)
   OR (p_Action = 'REACTIVATE' AND v_currentStatus = 1)
   OR (p_Action = 'DELETE'     AND v_currentStatus = -1) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El estado solicitado ya es el actual.';
  END IF;

  START TRANSACTION;

  -- Aplicar cambio según acción
  IF p_Action = 'PAUSE' THEN
    UPDATE listings SET status = 0 WHERE id = p_ListingId;
  ELSEIF p_Action = 'REACTIVATE' THEN
    UPDATE listings SET status = 1 WHERE id = p_ListingId;
  ELSE
    UPDATE listings SET status = -1 WHERE id = p_ListingId;
  END IF;

  -- Verificar éxito de la actualización
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al actualizar el estado.';
  END IF;

  COMMIT;

  -- Devolver resultado
  SELECT
    0 AS code,
    CASE p_Action
      WHEN 'PAUSE'      THEN 'Publicación pausada.'
      WHEN 'REACTIVATE' THEN 'Publicación reactivada.'
      ELSE 'Publicación eliminada.'
    END AS description;
END//

DELIMITER ;
