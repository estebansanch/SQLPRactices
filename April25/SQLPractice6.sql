-- INDEXES

-- Indexes are used to retreive data in a fast and optimized fashion, 
-- through the use of data structures such as binary searches, hashes, and more. 
-- Thus, the query is made quicker.

-- This is an example:

CREATE TABLE new_york_addresses (
    longitude numeric(9,6),
    latitude numeric(9,6),
    street_number text,
    street text,
    unit text,
    postcode text,
    id integer CONSTRAINT new_york_key PRIMARY KEY
);

COPY new_york_addresses
FROM 'C:\YourDirectory\city_of_new_york.csv'
WITH (FORMAT CSV, HEADER);

-- Listing 8-13: Benchmark queries for index performance

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'BROADWAY';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = '52 STREET';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE';

-- Listing 8-14: Creating a B-tree index on the new_york_addresses table

CREATE INDEX street_idx ON new_york_addresses (street);
