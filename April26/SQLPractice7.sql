--CLEANING DATA

--Sometimes when handling databases, mistakes will be made. In today's practice, we'll be exploring how to clean tables from these misshaps

-- 1. Finding duplicates.

SELECT company,
       street,
       city,
       st,
       count(*) AS address_count
FROM meat_poultry_egg_establishments
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;


-- 2. Grouping data and finding non functional data.
SELECT st, 
       count(*) AS st_count
FROM meat_poultry_egg_establishments
GROUP BY st
ORDER BY st;

-- Now with these grouped, we can now find those elements that carry null data sets.

SELECT establishment_number,
       company,
       city,
       st,
       zip
FROM meat_poultry_egg_establishments
WHERE st IS NULL;


-- It doesn have to be exlcusivly NULLS, you can also sort by inconsistent or outdated data.

SELECT company,
       count(*) AS company_count
FROM meat_poultry_egg_establishments
GROUP BY company
ORDER BY company ASC;


/* 3. Creating new columns and sorting the table through it.
Basically, create an extra column in the table that will flag the row if
contains a specific characteristic that is needed. An example using the 
meat_poultry_egg_establishments would be. */

-- First we add a column to distinguish if the meat is processed.
ALTER TABLE meat_poultry_egg_establishments ADD COLUMN meat_processing boolean;

-- Then we fill the column with the logical condition based on other columns info. 
UPDATE meat_poultry_egg_establishments set meat_processing = true WHERE activities LIKE '%Meat Processing%';


-- Extra. You can always keep a record of duplicates using functions like max. These are called aggregrate functions.

SELECT max(establishment_number)
FROM meat_pultry_egg_establishments
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;


-- And this last one will then be cleaned as such: 

DELETE FROM meat_pultry_egg_establishments
WHERE establishment_number not in (
       SELECT max(establishment_number)
       FROM meat_pultry_egg_establishments
       GROUP BY company, street, city, st
);



-- IMPORTANT NOTICE
-- Always mkake a backup table when cleaning data, just in case anything goes wrong.

CREATE TABLE meat_poultry_egg_establishments_backup AS
SELECT * FROM meat_poultry_egg_establishments;


-- Transactions. When done, you should always perform a transaction to add to the database without saving.
-- Transactions work because they implement the changes made but can always be rollbacked and are actually never saved remotely.
-- It is important that everyone do transactions during coding. 

start transaction

UPDATE meat_pultry_egg_establishments SET company = 'wrong data';

rollback;


-- If one ever needed to save, it would be done using commit;


-- If you do wish to save
