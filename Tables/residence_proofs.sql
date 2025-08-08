DROP TABLE IF EXISTS residence_proofs;

CREATE TABLE residence_proofs (
  id               BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id          BIGINT            NOT NULL,
  proof_message    VARCHAR(500),
  proof_image_url  VARCHAR(1000),
  created_at       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_residence_proofs_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,

  CONSTRAINT uq_residence_proofs_user UNIQUE (user_id),

  CONSTRAINT chk_proof_not_both_null
    CHECK (proof_message IS NOT NULL OR proof_image_url IS NOT NULL)
);
