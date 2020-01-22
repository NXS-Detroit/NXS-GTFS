DROP TABLE IF EXISTS nexuses;

CREATE TABLE nexuses (
  stop_id TEXT PRIMARY KEY REFERENCES stops(stop_id),
  loc TEXT NOT NULL,
  detail TEXT
);

INSERT INTO nexuses VALUES
  ('10087', 'Rosa Parks', 'Bay #3'),
  ('10245', 'Rosa Parks', 'Bay #12'),
  ('10278', 'Rosa Parks', 'Bay #11'),
  ('1058', 'New Center', 'SB Woodward'),
  ('1103', 'Troy', 'Eastbound'),
  ('1138', 'Troy', 'Westbound'),
  ('12', 'Metro Airport', null),
  ('12344', 'Rosa Parks', 'Bay #13'),
  ('12366', 'Rosa Parks', 'Bay #9'),
  ('1244', 'Roseville', null),
  ('12646', 'Sterling Heights', 'Southbound'),
  ('12647', 'Sterling Heights', 'Northbound'),
  ('13498', 'Roseville', 'NB Gratiot'),
  ('13499', 'Roseville', 'SB Gratiot'),
  ('14', 'Dearborn', 'EB Michigan'),
  ('1431', 'Rosa Parks', 'Bay #4'),
  ('1710', 'Rosa Parks', 'Bay #8'),
  ('1774', 'Southgate', 'Southbound'),
  ('1850', 'Southgate', 'Northbound'),
  ('1912', 'Rosa Parks', 'Bay #14'),
  ('2037', 'Rosa Parks', 'Bay #10'),
  ('2311', 'Rosa Parks', 'Bay #1'),
  ('2579', 'Rosa Parks', 'Bay #2'),
  ('2599', 'New Center', 'NB Cass'),
  ('2668', 'Southfield', null),
  ('268', 'Dearborn', 'Westbound'),
  ('2794', 'Southfield', 'EB 9 Mile'),
  ('2865', 'New Center', 'SB Cass'),
  ('2882', 'Rosa Parks', 'Bay #15'),
  ('3193', 'Rosa Parks', 'Bay #6'),
  ('3683', 'Grosse Pointe', 'Westbound'),
  ('3762', 'Rosa Parks', 'Bay #5'),
  ('380', 'Dearborn', 'Eastbound'),
  ('3844', 'Grosse Pointe', 'Eastbound'),
  ('3895', 'Rosa Parks', 'Bay #7'),
  ('54', 'Royal Oak', 'Northbound'),
  ('61', 'Pontiac', null),
  ('63', 'Royal Oak', 'Southbound'),
  ('7', 'Dearborn', 'WB Michigan'),
  ('782', 'New Center', 'NB Woodward');

SELECT
  loc AS "Nexus",
  detail AS "Detail",
  count(trip_id) AS "# Departures"
FROM nexuses
  LEFT JOIN stop_times USING (stop_id)
  LEFT JOIN trips USING (trip_id)
WHERE service_id IN ('weekday', 'weekdaynoph', 'weekdaynorf')
  AND stop_sequence < (
    SELECT max(stop_sequence)
    FROM stop_times AS inner_trips
    WHERE inner_trips.trip_id = trips.trip_id
  )
  AND timepoint = 1
GROUP BY stop_id;