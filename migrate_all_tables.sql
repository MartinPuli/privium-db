-- Migración de datos para todas las tablas de la base de datos Privium
-- Reemplaza `old_schema` y `new_schema` por los nombres de la base de datos origen y destino.
-- Ejecuta después de crear las tablas en la base de datos destino.

START TRANSACTION;

INSERT INTO new_schema.categories           SELECT * FROM old_schema.categories;
INSERT INTO new_schema.countries            SELECT * FROM old_schema.countries;
INSERT INTO new_schema.users                SELECT * FROM old_schema.users;
INSERT INTO new_schema.listings             SELECT * FROM old_schema.listings;
INSERT INTO new_schema.listing_images       SELECT * FROM old_schema.listing_images;
INSERT INTO new_schema.listings_categories  SELECT * FROM old_schema.listings_categories;
INSERT INTO new_schema.email_confirmation_tokens SELECT * FROM old_schema.email_confirmation_tokens;
INSERT INTO new_schema.password_reset_tokens     SELECT * FROM old_schema.password_reset_tokens;
INSERT INTO new_schema.residence_proofs    SELECT * FROM old_schema.residence_proofs;

COMMIT;
