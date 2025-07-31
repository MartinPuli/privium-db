DROP TABLE IF EXISTS listings;

CREATE TABLE listings (
  id               BIGINT AUTO_INCREMENT PRIMARY KEY,
  title            VARCHAR(255)    NOT NULL,
  description      TEXT,
  price            DECIMAL(10,2)   NOT NULL,

  accepts_barter   TINYINT(1),
  accepts_cash     TINYINT(1),
  accepts_transfer TINYINT(1),
  accepts_card     TINYINT(1),

  type             VARCHAR(20)     NOT NULL,
  CONSTRAINT ck_listings_type
    CHECK (type IN ('PRODUCTO','SERVICIO','INMUEBLE','VEHICULO','MUEBLE')),

  `condition`      TINYINT NOT NULL DEFAULT 2,
  CONSTRAINT ck_listings_condition
    CHECK (`condition` IN (1,2)),

  brand            VARCHAR(255),
  user_id          BIGINT,
  main_image       LONGTEXT,
  status           INT             NOT NULL,
  created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT FK_us_listings
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_listings_created_at ON listings(created_at);
CREATE INDEX idx_listings_price ON listings(price);
CREATE INDEX idx_listings_type ON listings(type);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_user_id ON listings(user_id);
