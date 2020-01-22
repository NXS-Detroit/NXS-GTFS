-- This should give me the number of buses on each route at a given time

DROP TABLE IF EXISTS temp.variables;
CREATE TEMP TABLE variables AS
SELECT
  '17:00:00' AS query_time;

DROP TABLE IF EXISTS temp.buses_per_route;
CREATE TEMP TABLE buses_per_route AS
SELECT
  route_id AS "route",
  COUNT(trip_id) AS "buses"
FROM trips
WHERE trip_id IN (
  SELECT DISTINCT trip_id FROM stop_times
  WHERE departure_time >= (SELECT query_time FROM variables)
) AND trip_id IN (
  SELECT DISTINCT trip_id FROM stop_times
  WHERE arrival_time <= (SELECT query_time FROM variables)
) AND (service_id = 'weekday' OR service_id = 'weekdaynoph' OR service_id = 'weekdaynorf')
GROUP BY route_id;

SELECT * FROM buses_per_route;

SELECT
  buses,
  COUNT("route") AS "# of routes",
  GROUP_CONCAT("route", ', ') AS "list of routes",
  buses * COUNT("route") AS "total buses"
FROM buses_per_route
GROUP BY buses;

SELECT sum(buses) FROM buses_per_route;

-- Part two: Get sums for all hours

DROP TABLE IF EXISTS temp.trip_time_info;
CREATE TABLE temp.trip_time_info AS
SELECT
  trip_id AS id,
  NULL AS start_time,
  NULL AS end_time
FROM trips
WHERE service_id = 'weekday'
  OR service_id = 'weekdaynoph'
  OR service_id = 'weekdaynorf';

UPDATE trip_time_info
SET start_time = (
  SELECT MIN(departure_time)
  FROM stop_times
  WHERE trip_id = id
);

UPDATE trip_time_info
SET end_time = (
  SELECT MAX(arrival_time)
  FROM stop_times
  WHERE trip_id = id
);

DROP TABLE IF EXISTS temp.time_counts;
CREATE TABLE temp.time_counts AS
SELECT
  hour10 || hour1 || ':' || minute10 || minute1 || ':00' AS "time",
  NULL as "starting",
  NULL as "persistent",
  NULL as "ending"
FROM temp.hour10 JOIN temp.hour JOIN temp.minute10 JOIN temp.minute;

UPDATE time_counts
SET "starting" = (
  SELECT COUNT(id)
  FROM trip_time_info
  WHERE start_time = "time"
);

UPDATE time_counts
SET "persistent" = (
  SELECT COUNT(id)
  FROM trip_time_info
  WHERE start_time < "time"
    AND end_time > "time"
);

UPDATE time_counts
SET "ending" = (
  SELECT COUNT(id)
  FROM trip_time_info
  WHERE end_time = "time"
);

SELECT * FROM time_counts;
