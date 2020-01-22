CREATE TABLE fare_demographics (
  demographic_id TEXT PRIMARY KEY NOT NULL,
  demographic_preset INT NOT NULL CHECK (demographic_preset >= 0),
  demographic_detail TEXT NOT NULL
);
CREATE TABLE fare_demographic_prices (
  demographic_id TEXT NOT NULL REFERENCES fare_demographics(demographic_id),
  fare_id TEXT NOT NULL REFERENCES fare_attributes(fare_id),
  adjusted_price REAL NOT NULL,
  PRIMARY KEY (demographic_id, fare_id)
);