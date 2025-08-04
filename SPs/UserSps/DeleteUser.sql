DELIMITER //

/*---------------------------------------------------------------
  SP: DeleteUser
  Propósito: Realiza una eliminación lógica del usuario y sus publicaciones.
    - Verifica que el usuario exista y no esté eliminado.
    - Marca al usuario con status = -1.
    - Marca sus publicaciones con status = -1.
    - Borra las imágenes auxiliares de dichas publicaciones.
----------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS DeleteUser//

CREATE PROCEDURE DeleteUser(
  IN p_UserId BIGINT
)
BEGIN
  -- Verificar que el usuario exista y no esté eliminado
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = p_UserId AND status <> -1
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado';
  END IF;

  START TRANSACTION;

  -- Marcar publicaciones del usuario como eliminadas
  UPDATE listings
     SET status = -1
   WHERE user_id = p_UserId;

  -- Borrar imágenes auxiliares de sus publicaciones
  DELETE FROM listing_images
   WHERE listing_id IN (
           SELECT id FROM listings WHERE user_id = p_UserId
         );

  -- Marcar al usuario como eliminado
  UPDATE users
     SET status = -1
   WHERE id = p_UserId;

  -- Verificar que se actualizó el usuario
  IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al eliminar usuario';
  END IF;

  COMMIT;

  -- Devolver resultado
  SELECT
    0 AS code,
    'Usuario desactivado, publicaciones e imágenes eliminadas' AS description;
END//

DELIMITER ;
