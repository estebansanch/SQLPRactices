-- MANAGING DIFFERENT CHARACTERS (MISSING, TRIMMING, ETC)

-- How to do case formatting
SELECT upper('Neal7');
SELECT lower('Randy');
SELECT initcap('at the end of the day');
-- Note initcap's imperfect for acronyms
SELECT initcap('Practical SQL');

-- How to read character information
SELECT char_length(' Pat ');
SELECT length(' Pat ');
SELECT position(', ' in 'Tan, Bella');

-- How to remove characters
SELECT trim('s' from 'socks');
SELECT trim(trailing 's' from 'socks');
SELECT trim(' Pat ');
SELECT char_length(trim(' Pat ')); -- note the length change
SELECT ltrim('socks', 's');
SELECT rtrim('socks', 's');

-- How to extract and replace characters
SELECT left('703-555-1212', 3);
SELECT right('703-555-1212', 8);
SELECT replace('bat', 'b', 'c');


-- expression matching examples for regular expressions

-- Any character one or more times
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '.+');
-- One or two digits followed by a space and a.m. or p.m. in a noncapture group
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\d{1,2} (?:a.m.|p.m.)');
-- One or more word characters at the start
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '^\w+');
-- One or more word characters followed by any character at the end.
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\w+.$');
-- The words May or June
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from 'May|June');
-- Four digits
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from '\d{4}');
-- May followed by a space, digit, comma, space, and four digits.
SELECT substring('The game starts at 7 p.m. on May 2, 2024.' from 'May \d, \d{4}');

-- Regular expressions can be used in a WHERE clause
SELECT county_name
FROM us_counties_pop_est_2019
WHERE county_name ~* '(lade|lare)'
ORDER BY county_name;

SELECT county_name
FROM us_counties_pop_est_2019
WHERE county_name ~* 'ash' AND county_name !~ 'Wash'
ORDER BY county_name;

-- Regular expression functions that replace and split text

SELECT regexp_replace('05/12/2024', '\d{4}', '2023');

SELECT regexp_split_to_table('Four,score,and,seven,years,ago', ',');

SELECT regexp_split_to_array('Phil Mike Tony Steve', ' ');

-- Listing 14-3: Finding an array length

SELECT array_length(regexp_split_to_array('Phil Mike Tony Steve', ' '), 1);


-- Turning Text to Data with Regular Expression Functions

-- Create and load the crime_reports table
-- Data is being used from https://sheriff.loudoun.gov/dailycrime

CREATE TABLE crime_reports (
    crime_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    case_number text,
    date_1 timestamptz,  -- note: this is the PostgreSQL shortcut for timestamp with time zone
    date_2 timestamptz,  -- note: this is the PostgreSQL shortcut for timestamp with time zone
    street text,
    city text,
    crime_type text,
    description text,
    original_text text NOT NULL
);

COPY crime_reports (original_text)
FROM '/tmp/crime_reports.csv'
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

SELECT original_text FROM crime_reports;

-- We can use regexp_match() to find the first date
SELECT crime_id,
       regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports
ORDER BY crime_id;

-- We can use the regexp_matches() function with the 'g' flag
SELECT crime_id,
       regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
FROM crime_reports
ORDER BY crime_id;

-- We can also use regexp_match() to find the second date
-- Note that the result includes an unwanted hyphen
SELECT crime_id,
       regexp_match(original_text, '-\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports
ORDER BY crime_id;

-- By using a capture group to return only the date,
-- the hyphen is eliminated
SELECT crime_id,
       regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})')
FROM crime_reports
ORDER BY crime_id;

-- Match case number, date, crime type, and city using regexp_match()

SELECT
    regexp_match(original_text, '(?:C0|SO)[0-9]+') AS case_number,
    regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
    regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
    regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n')
        AS city
FROM crime_reports
ORDER BY crime_id;
