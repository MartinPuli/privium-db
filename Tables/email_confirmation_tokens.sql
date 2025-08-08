DROP TABLE IF EXISTS email_confirmation_tokens;

CREATE TABLE email_confirmation_tokens (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id         BIGINT            NOT NULL,
  token           VARCHAR(100)      NOT NULL UNIQUE,
  proof_message   VARCHAR(500),
  proof_image_url VARCHAR(1000),
  created_at      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_email_token_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT chk_email_token_proof_not_both_null
    CHECK (proof_message IS NOT NULL OR proof_image_url IS NOT NULL),

    INDEX idx_email_token (token)
  ,INDEX idx_email_tokens_user_id (user_id)
  );

