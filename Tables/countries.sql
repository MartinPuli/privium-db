DROP TABLE IF EXISTS countries;

CREATE TABLE countries (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100)  NOT NULL,
  province     VARCHAR(100),
  city         VARCHAR(100),
  postal_code  VARCHAR(20),
  latitude     DECIMAL(10,6) NOT NULL,
  longitude    DECIMAL(10,6) NOT NULL,

  /* Validaciones básicas */
  CONSTRAINT ck_countries_lat_range CHECK (latitude  BETWEEN -90  AND  90),
  CONSTRAINT ck_countries_lon_range CHECK (longitude BETWEEN -180 AND 180)
)