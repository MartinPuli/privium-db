DROP TABLE IF EXISTS listings_categories;

CREATE TABLE listings_categories (
  product_id   BIGINT       NOT NULL,
  category_id  VARCHAR(20)  NOT NULL,
  PRIMARY KEY (product_id, category_id),
  CONSTRAINT FK_pc_listings
    FOREIGN KEY (product_id) REFERENCES listings(id) ON DELETE CASCADE,
  CONSTRAINT FK_pc_categories
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);
