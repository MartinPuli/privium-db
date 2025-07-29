DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
  id       VARCHAR(20)   NOT NULL,
  name     VARCHAR(100)  NOT NULL,
  hasChild INT           NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
);
