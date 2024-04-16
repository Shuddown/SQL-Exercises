REM: Running nobel.sql
@D:\Programming\SQL\Ex-2\nobel.sql
REM: 1. Display the nobel laureate(s) who born after 1 Jul 1960.
SELECT * 
FROM nobel 
WHERE (dob > DATE '1960-07-01');  
REM: 2. Display the Indian laureate (name, category, field, country, year awarded) who was awarded in the Chemistry category
SELECT name, category, field, country, year_award 
FROM nobel 
WHERE country = 'India' 
AND category = 'Che';
REM: 3. Display the laureates (name, category,field and year of award) who was awarded between 2000 and 2005 for the Physics or Chemistry category.
SELECT name, category, field, year_award
FROM nobel 
WHERE year_award BETWEEN 2000 AND 2005 
AND (category = 'Phy' OR category = 'Che'); 
REM: 4. Display the laureates name with their age at the time of award for the Peace category.
SELECT name, year_award - EXTRACT(YEAR FROM dob) AS age 
FROM nobel 
WHERE category = 'Pea';
REM: 5. Display the laureates (name,category,aff_role,country) whose name starts with “A” or ends with “a”, but not from Isreal.
SELECT name, category, aff_role, country 
FROM nobel 
WHERE (name LIKE 'A%' 
OR name LIKE '%a')
AND country <> 'Isreal';
REM: 6. Display the name, gender, affiliation, dob and country of laureates who was born in ‘1950’s. Label the dob column as Born 1950. 
SELECT name, gender, aff_role, dob as "Born 1950", country 
FROM nobel 
WHERE EXTRACT(YEAR FROM dob) BETWEEN 1950 AND 1959;
REM: 7. Display the laureates (name,gender,category,aff_role,country) whose name starts with A, D or H. Remove the laureate if he/she do not have any affiliation. Sort the results in ascending order of name.
SELECT name, gender, category, aff_role, country 
FROM nobel 
WHERE (name LIKE 'D%' OR name LIKE 'H%')
AND aff_role IS NOT NULL
ORDER BY name;  
REM: 8. Display the university name(s) that has to its credit by having at least 2 nobel laureate with them.
SELECT aff_role AS university 
FROM nobel 
WHERE aff_role LIKE '%University%'
GROUP BY aff_role
HAVING COUNT(aff_role) >= 2;
REM: 9. List the date of birth of youngest and eldest laureates by country Wise, Label the column as Younger, Elder respectively. Include only the country having more than one laureate.  Sort the output in the alphabetic order of country.
SELECT country, MAX(dob) AS youngest, MIN(dob) AS oldest 
FROM nobel
GROUP BY country
HAVING COUNT(country) >= 2;
REM: 10. Show the details (year award,category,field) where the award is shared among the laureates in the same category and field. Exclude the laureates from USA. Use TCL Statements.
SELECT year_award, category, field
FROM nobel
WHERE country <> 'USA'
GROUP BY category, field, year_award
HAVING COUNT(laureate_id) >= 2;

REM: 11.Creating intermediate SAVEPOINT

SAVEPOINT save1;

REM: 12. Insert a new tuple into the nobel relation. 

INSERT INTO nobel 
VALUES(129, 'Malala Yousafzai', 'f', 'Pea', 'Education', 2014, NULL, '12-jul-1997', 'Pakistan');

REM: 13. Update the aff_role of literature laureates as 'Linguists'.
UPDATE nobel
SET aff_role = 'Linguists'
WHERE category = 'Lit';

REM: 14. Delete the laureate(s) who was awarded in Enzymes field. 
DELETE FROM nobel
WHERE field = 'Enzymes';

REM: rolling back to intermediate savepoint
ROLLBACK TO save1;

REM: commiting changes
COMMIT;