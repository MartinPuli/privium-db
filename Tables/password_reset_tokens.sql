DROP TABLE IF EXISTS password_reset_tokens;

CREATE TABLE password_reset_tokens (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id      BIGINT          NOT NULL,
  token        VARCHAR(100)    NOT NULL UNIQUE,
  created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_reset_token_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_reset_token (token)
  ,INDEX idx_reset_token_user_id (user_id)
  );

