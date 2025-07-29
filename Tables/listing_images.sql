DROP TABLE IF EXISTS listing_images;

CREATE TABLE listing_images (
  listing_id   BIGINT       NOT NULL,
  image_number INT          NOT NULL,
  image_url    VARCHAR(2048) NOT NULL,

  PRIMARY KEY (listing_id, image_number),
  CONSTRAINT FK_li_listings
    FOREIGN KEY (listing_id) REFERENCES listings(id)
    ON DELETE CASCADE
);
