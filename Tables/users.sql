DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
  name               VARCHAR(100)   NOT NULL,
  lastname           VARCHAR(100)   NOT NULL,
  email              VARCHAR(150)   NOT NULL UNIQUE,
  password_hash      VARCHAR(255)   NOT NULL,
  dni                VARCHAR(20)    UNIQUE,
  contact_phone      VARCHAR(20),
  verified_email     TINYINT(1)     NOT NULL DEFAULT 0,
  verified_residence TINYINT(1)     NOT NULL DEFAULT 0,
  status             SMALLINT       NOT NULL DEFAULT 0,
  country_id         BIGINT,
  profile_picture    VARCHAR(255),
  created_at         DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  role               VARCHAR(20)    NOT NULL DEFAULT 'USER',

  FOREIGN KEY (country_id) REFERENCES countries(id),
  CONSTRAINT chk_users_role CHECK (role IN ('USER','ADMIN'))
);

CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);