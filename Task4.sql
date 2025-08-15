
/*
Task 4. Оновлення лічильників навичок
Оновити skill_variants.cnt, щоб значення дорівнювало кількості унікальних кандидатів із цією навичкою (зв’язки — у candidate_skills).
 Форма рішення — через UPDATE ... JOIN (SELECT ... GROUP BY).
*/

SET SQL_SAFE_UPDATES = 0;

UPDATE skill_variants sv
JOIN (
    SELECT variant_id, COUNT(*) AS cnt
    FROM candidate_skills
    GROUP BY variant_id
) AS cs_count ON sv.id = cs_count.variant_id
SET sv.cnt = cs_count.cnt
;
 
