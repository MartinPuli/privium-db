DELIMITER //

/*---------------------------------------------------------------
  SP: GetResidenceProofs
  Propósito: Obtener las pruebas de residencia,
             ordenadas por fecha de creación (más antigua → más reciente).
             Si se pasa p_UserId, filtra solo las de ese usuario.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS GetResidenceProofs//

CREATE PROCEDURE GetResidenceProofs(
  IN p_AdminId BIGINT,    -- quien ejecuta, debe ser ADMIN
  IN p_UserId  BIGINT     -- opcional: filtrar por usuario
)
BEGIN
  -- Permisos: solo ADMIN puede ejecutar
  IF NOT EXISTS (
    SELECT 1 FROM users
     WHERE id = p_AdminId
       AND role = 'ADMIN'
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No tienes permisos para ver pruebas de residencia';
  END IF;

  -- Consulta de pruebas de residencia
  SELECT
    id,
    user_id             AS userId,
    proof_message       AS proofMessage,
    proof_image_b64     AS proofImageB64,
    created_at          AS createdAt
  FROM residence_proofs
  WHERE (p_UserId IS NULL OR user_id = p_UserId)
  ORDER BY created_at ASC;
END//

DELIMITER ;
