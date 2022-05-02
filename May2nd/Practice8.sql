-- DATE AND TIME.

-- Today let's practice how to use date, time and intervals, timestamp (date, time and time zone).

-- Let's extract components of a timestamp using date_part().

SELECT
    date_part('year', '2022-12-01 18:37:12 EST'::timestamptz) AS year,
    date_part('month', '2022-12-01 18:37:12 EST'::timestamptz) AS month,
    date_part('day', '2022-12-01 18:37:12 EST'::timestamptz) AS day,
    date_part('hour', '2022-12-01 18:37:12 EST'::timestamptz) AS hour,
    date_part('minute', '2022-12-01 18:37:12 EST'::timestamptz) AS minute,
    date_part('seconds', '2022-12-01 18:37:12 EST'::timestamptz) AS seconds,
    date_part('timezone_hour', '2022-12-01 18:37:12 EST'::timestamptz) AS tz,
    date_part('week', '2022-12-01 18:37:12 EST'::timestamptz) AS week,
    date_part('quarter', '2022-12-01 18:37:12 EST'::timestamptz) AS quarter,
    date_part('epoch', '2022-12-01 18:37:12 EST'::timestamptz) AS epoch;
	
-- We can also use SQL-standard extract() for similar datetime parsing:

SELECT extract(year from '2022-12-01 18:37:12 EST'::timestamptz) AS year;

-- Let's start by retrieving the current date and time.

SELECT
    current_timestamp,
    localtimestamp,
    current_date,
    current_time,
    localtime,
    now();
    
-- In this next part, we'll be comparing
-- current_timestamp and clock_timestamp() during row insert.

CREATE TABLE current_time_example (
    time_id integer GENERATED ALWAYS AS IDENTITY,
    current_timestamp_col timestamptz,
    clock_timestamp_col timestamptz
);

INSERT INTO current_time_example
            (current_timestamp_col, clock_timestamp_col)
    (SELECT current_timestamp,
            clock_timestamp()
     FROM generate_series(1,1000));

SELECT * FROM current_time_example;

-- TIME ZONES.

-- By using timezone line, you can view your current time zone setting.

SHOW timezone; -- Note: You can see all run-time defaults with SHOW ALL;
SELECT current_setting('timezone');

-- What happens when using current_setting() inside another function? :

SELECT make_timestamptz(2022, 2, 22, 18, 4, 30.3, current_setting('timezone'));

-- Executing the following Query will allow us to view the time zones sorted by abbreviations and name.

SELECT * FROM pg_timezone_abbrevs ORDER BY abbrev;
SELECT * FROM pg_timezone_names ORDER BY name;

-- This can later be filtered to only view specific time zones. 

SELECT * FROM pg_timezone_names
WHERE name LIKE 'Europe%'
ORDER BY name;

-- You can also set the time zone for a client session.

SET TIME ZONE 'US/Pacific';

CREATE TABLE time_zone_test (
    test_date timestamptz
);
INSERT INTO time_zone_test VALUES ('2023-01-01 4:00');

SELECT test_date
FROM time_zone_test;

SET TIME ZONE 'US/Eastern';

SELECT test_date
FROM time_zone_test;

SELECT test_date AT TIME ZONE 'Asia/Seoul'
FROM time_zone_test;

-- MATH USING DATES.
-- You can use math with the date data tpes for all kinds of purposes.
-- A commmon example would be to simply check the day or year differences between two dates.

SELECT '1929-09-30'::date - '1929-09-27'::date; --Difference displayed in days
SELECT '1929-09-30'::date + '5 years'::interval;

-- And now, something completely different.

-- TAXI RIDES.

-- Let's do a little query sim with some nyc taxi's, by
-- creating a table and importing NYC yellow taxi data.

CREATE TABLE nyc_yellow_taxi_trips (
    trip_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vendor_id text NOT NULL,
    tpep_pickup_datetime timestamptz NOT NULL,
    tpep_dropoff_datetime timestamptz NOT NULL,
    passenger_count integer NOT NULL,
    trip_distance numeric(8,2) NOT NULL,
    pickup_longitude numeric(18,15) NOT NULL,
    pickup_latitude numeric(18,15) NOT NULL,
    rate_code_id text NOT NULL,
    store_and_fwd_flag text NOT NULL,
    dropoff_longitude numeric(18,15) NOT NULL,
    dropoff_latitude numeric(18,15) NOT NULL,
    payment_type text NOT NULL,
    fare_amount numeric(9,2) NOT NULL,
    extra numeric(9,2) NOT NULL,
    mta_tax numeric(5,2) NOT NULL,
    tip_amount numeric(9,2) NOT NULL,
    tolls_amount numeric(9,2) NOT NULL,
    improvement_surcharge numeric(9,2) NOT NULL,
    total_amount numeric(9,2) NOT NULL
);

COPY nyc_yellow_taxi_trips (
    vendor_id,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    pickup_longitude,
    pickup_latitude,
    rate_code_id,
    store_and_fwd_flag,
    dropoff_longitude,
    dropoff_latitude,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount
   )
FROM '/tmp/nyc_yellow_taxi_trips.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX tpep_pickup_idx
ON nyc_yellow_taxi_trips (tpep_pickup_datetime);

-- Now we count the trip records.

SELECT count(*) FROM nyc_yellow_taxi_trips;

-- And we can also count taxi trips by the hour.

SET TIME ZONE 'US/Eastern'; -- Set this if your PostgreSQL server defaults to a time zone other than US/Eastern

SELECT
    date_part('hour', tpep_pickup_datetime) AS trip_hour,
    count(*)
FROM nyc_yellow_taxi_trips
GROUP BY trip_hour
ORDER BY trip_hour;


-- QUERY CHALLENGE: CALCULATE THE DURATION OF EACH RIDE. SORT FROM LONGEST TO SHORTEST.

SELECT tpep_dropoff_datetime - tpep_pickup_datetime AS trip_duration, trip_id
FROM nyc_yellow_taxi_trips
ORDER BY trip_duration desc;
