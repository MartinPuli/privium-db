DROP TABLE IF EXISTS email_confirmation_tokens;

CREATE TABLE email_confirmation_tokens (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT            NOT NULL,
  token       VARCHAR(100)      NOT NULL UNIQUE,
  created_at  DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_email_token_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  
  INDEX idx_email_token (token)
);
