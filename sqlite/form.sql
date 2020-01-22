DROP TABLE IF EXISTS feed_info;
DROP TABLE IF EXISTS pathways;
DROP TABLE IF EXISTS transfers;
DROP TABLE IF EXISTS frequencies;
DROP TABLE IF EXISTS shapes;
DROP TABLE IF EXISTS shape_ids;
DROP TABLE IF EXISTS fare_rules;
DROP TABLE IF EXISTS fare_demographic_prices;
DROP TABLE IF EXISTS fare_demographics;
DROP TABLE IF EXISTS fare_attributes;
DROP TABLE IF EXISTS calendar_dates;
DROP TABLE IF EXISTS calendar;
DROP TABLE IF EXISTS stop_times;
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS stops;
DROP TABLE IF EXISTS fare_zones;
DROP TABLE IF EXISTS levels;
DROP TABLE IF EXISTS agency;
CREATE TABLE agency (
  agency_id TEXT PRIMARY KEY NOT NULL DEFAULT '1',
  agency_name TEXT NOT NULL,
  agency_url TEXT NOT NULL,
  agency_timezone TEXT NOT NULL,
  agency_lang TEXT,
  agency_phone TEXT,
  agency_fare_url TEXT,
  agency_email TEXT
);
CREATE TABLE levels (
  level_id TEXT PRIMARY KEY NOT NULL,
  level_index REAL NOT NULL,
  level_name TEXT
);
CREATE TABLE fare_zones (zone_id TEXT PRIMARY KEY NOT NULL);
CREATE TABLE stops (
  stop_id TEXT PRIMARY KEY NOT NULL,
  stop_code TEXT,
  stop_name TEXT,
  stop_desc TEXT,
  stop_lat REAL CHECK (
    stop_lat BETWEEN -90.0
    AND 90.0
  ),
  stop_lon REAL CHECK (
    stop_lon BETWEEN -180.0
    AND 180.0
  ),
  zone_id TEXT REFERENCES fare_zones,
  stop_url TEXT,
  location_type INTEGER NOT NULL DEFAULT 0 CHECK (
    location_type BETWEEN 0
    AND 4
  ),
  parent_station TEXT REFERENCES stops(stop_id),
  stop_timezone TEXT,
  wheelchair_boarding INTEGER NOT NULL DEFAULT 0 CHECK (
    wheelchair_boarding BETWEEN 0
    AND 2
  ),
  level TEXT REFERENCES levels(level_id),
  platform_code TEXT,
  CHECK (
    CASE
      location_type
      WHEN 0 THEN stop_lat IS NOT NULL
      AND stop_lon IS NOT NULL
      AND stop_name IS NOT NULL
      WHEN 1 THEN stop_lat IS NOT NULL
      AND stop_lon IS NOT NULL
      AND stop_name IS NOT NULL
      AND parent_station IS NULL
      WHEN 2 THEN stop_lat IS NOT NULL
      AND stop_lon IS NOT NULL
      AND stop_name IS NOT NULL
      AND parent_station IS NOT NULL
      WHEN 3 THEN parent_station IS NOT NULL
      WHEN 4 THEN parent_station IS NOT NULL
    END
  )
);
CREATE TABLE routes (
  route_id TEXT PRIMARY KEY NOT NULL,
  agency_id TEXT NOT NULL DEFAULT '1' REFERENCES agency(agency_id),
  route_short_name TEXT,
  route_long_name TEXT,
  route_desc TEXT,
  route_type INTEGER NOT NULL CHECK (
    route_type BETWEEN 0
    AND 7
  ),
  route_url TEXT,
  route_color TEXT NOT NULL DEFAULT 'FFFFFF',
  route_text_color TEXT NOT NULL DEFAULT '000000',
  route_sort_order INTEGER CHECK (route_sort_order >= 0),
  CHECK (
    route_short_name IS NOT NULL
    OR route_long_name IS NOT NULL
  )
);
CREATE TABLE calendar (
  service_id TEXT PRIMARY KEY NOT NULL,
  monday INTEGER NOT NULL CHECK (
    monday BETWEEN 0
    AND 1
  ),
  tuesday INTEGER NOT NULL CHECK (
    tuesday BETWEEN 0
    AND 1
  ),
  wednesday INTEGER NOT NULL CHECK (
    wednesday BETWEEN 0
    AND 1
  ),
  thursday INTEGER NOT NULL CHECK (
    thursday BETWEEN 0
    AND 1
  ),
  friday INTEGER NOT NULL CHECK (
    friday BETWEEN 0
    AND 1
  ),
  saturday INTEGER NOT NULL CHECK (
    saturday BETWEEN 0
    AND 1
  ),
  sunday INTEGER NOT NULL CHECK (
    sunday BETWEEN 0
    AND 1
  ),
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL
);
CREATE TABLE shape_ids (shape_id TEXT PRIMARY KEY NOT NULL);
CREATE TABLE shapes (
  shape_id TEXT NOT NULL REFERENCES shape_ids(shape_id),
  shape_pt_lat REAL NOT NULL CHECK (
    shape_pt_lat BETWEEN -90.0
    AND 90.0
  ),
  shape_pt_lon REAL NOT NULL CHECK (
    shape_pt_lon BETWEEN -180.0
    AND 180.0
  ),
  shape_pt_sequence INTEGER NOT NULL CHECK (shape_pt_sequence >= 0),
  shape_dist_traveled REAL CHECK (shape_dist_traveled >= 0),
  PRIMARY KEY (shape_id, shape_pt_sequence)
);
CREATE TABLE trips (
  route_id TEXT NOT NULL REFERENCES routes(route_id),
  service_id TEXT NOT NULL REFERENCES calendar(service_id),
  trip_id TEXT PRIMARY KEY NOT NULL,
  trip_headsign TEXT,
  trip_short_name TEXT,
  direction_id INTEGER CHECK (
    direction_id BETWEEN 0
    AND 1
  ),
  block_id TEXT,
  shape_id TEXT REFERENCES shape_ids(shape_id),
  wheelchair_accessible INTEGER NOT NULL DEFAULT 0 CHECK (
    wheelchair_accessible BETWEEN 0
    AND 2
  ),
  bikes_allowed INTEGER NOT NULL DEFAULT 0 CHECK (
    bikes_allowed BETWEEN 0
    AND 2
  )
);
CREATE TABLE stop_times (
  trip_id TEXT NOT NULL REFERENCES trips(trip_id),
  arrival_time TEXT,
  departure_time TEXT CHECK (departure_time >= arrival_time),
  stop_id TEXT NOT NULL REFERENCES stops(stop_id),
  stop_sequence INTEGER NOT NULL CHECK (stop_sequence >= 0),
  stop_headsign TEXT,
  pickup_type INTEGER NOT NULL DEFAULT 0 CHECK (
    pickup_type BETWEEN 0
    AND 3
  ),
  drop_off_type INTEGER NOT NULL DEFAULT 0 CHECK (
    drop_off_type BETWEEN 0
    AND 3
  ),
  shape_dist_traveled REAL CHECK (shape_dist_traveled >= 0),
  timepoint INTEGER NOT NULL DEFAULT 1 CHECK (
    timepoint BETWEEN 0
    AND 1
  ),
  PRIMARY KEY (trip_id, stop_sequence)
);
CREATE TABLE calendar_dates (
  service_id TEXT NOT NULL REFERENCES calendar(service_id),
  date TEXT NOT NULL,
  exception_type INTEGER NOT NULL CHECK (
    exception_type BETWEEN 1
    AND 2
  ),
  PRIMARY KEY (service_id, date)
);
CREATE TABLE fare_attributes (
  fare_id TEXT PRIMARY KEY NOT NULL,
  price REAL NOT NULL CHECK (price >= 0),
  currency_type TEXT NOT NULL,
  payment_method INTEGER NOT NULL CHECK (
    payment_method BETWEEN 0
    AND 1
  ),
  transfers INTEGER,
  agency_id TEXT NOT NULL DEFAULT '1' REFERENCES agency(agency_id),
  transfer_duration INTEGER CHECK (transfer_duration >= 0)
);
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
CREATE TABLE fare_rules (
  fare_id TEXT NOT NULL REFERENCES fare_attributes(fare_id),
  route_id TEXT REFERENCES routes(route_id),
  origin_id TEXT REFERENCES fare_zones(zone_id),
  destination_id TEXT REFERENCES fare_zones(zone_id),
  contains_id TEXT REFERENCES fare_zones(zone_id),
  UNIQUE(
    fare_id,
    route_id,
    origin_id,
    destination_id,
    contains_id
  )
);
CREATE TABLE frequencies (
  trip_id TEXT NOT NULL REFERENCES trips(trip_id),
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL CHECK (end_time > start_time),
  headway_secs INTEGER NOT NULL CHECK (headway_secs > 0),
  exact_times INTEGER NOT NULL CHECK (
    exact_times BETWEEN 0
    AND 1
  ),
  PRIMARY KEY (trip_id, start_time)
);
-- This table supports a proposed Google Transit Extension
CREATE TABLE transfers (
  from_stop_id TEXT NOT NULL REFERENCES stops(stop_id),
  to_stop_id TEXT NOT NULL REFERENCES stops(stop_id),
  transfer_type INTEGER NOT NULL DEFAULT 0 CHECK (
    transfer_type BETWEEN 0
    AND 3
  ),
  min_transfer_time INTEGER CHECK (min_transfer_time >= 0),
  from_route_id TEXT REFERENCES routes(route_id),
  to_route_id TEXT REFERENCES routes(route_id),
  from_trip_id TEXT REFERENCES trips(trip_id),
  to_trip_id TEXT REFERENCES trips(trip_id),
  CHECK (
    min_transfer_time IS NOT NULL
    OR transfer_type <> 2
  )
);
CREATE TABLE pathways (
  pathway_id TEXT PRIMARY KEY NOT NULL,
  from_stop_id TEXT NOT NULL REFERENCES stops(stop_id),
  to_stop_id TEXT NOT NULL REFERENCES stops(stop_id),
  pathway_mode INT NOT NULL CHECK (
    pathway_mode BETWEEN 1
    AND 7
  ),
  is_bidirectional INT NOT NULL CHECK (
    is_bidirectional BETWEEN 0
    AND 1
  ),
  "length" REAL CHECK ("length" >= 0),
  traversal_time INT CHECK (traversal_time > 0),
  stair_count INT,
  max_slope REAL,
  min_width REAL CHECK (min_width > 0),
  signposted_as TEXT,
  reverse_signposted_as TEXT
);
CREATE TABLE feed_info (
  feed_publisher_name TEXT NOT NULL,
  feed_publisher_url TEXT NOT NULL,
  feed_lang TEXT NOT NULL,
  feed_start_date TEXT,
  feed_end_date TEXT,
  feed_version TEXT,
  feed_context_email TEXT,
  feed_contact_url TEXT
);