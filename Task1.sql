/*
Повернути список кандидатів з early_statuses, для яких одночасно виконується:
1.	Є хоча б один статус із type_id = 1 (“Lead”) у вказаному діапазоні дат (creation_date).

2.	Немає жодного пізнішого статусу по тому ж кандидату і тій самій вакансії.

3.	Немає жодного резюме з відправкою (sent_at IS NOT NULL) по тій самій парі кандидат–вакансія.

4.	І кандидат, і вакансія доступні поточному HR (Alice, hr_id = 1) згідно з таблицею access (entity_type IN ('candidate','vacancy'), right_code='Read').
*/


SELECT DISTINCT 
   candidate_id as 'candidate_id',
   full_name as 'full_name',
   linkedin_url as 'linkedin_url', 
   ES.vacancy_id as 'vacancy_id',
   V.title as 'vacancy_title',
   creation_date as 'creation_date', 
   comment_text as 'comment_text', 
   is_friend as 'is_friend',
   is_pro as 'is_pro'
FROM early_statuses ES
  JOIN candidates C  -- Для виводу повного імені кандидата
    ON C.id = ES.user_uid
  JOIN vacancies V   -- Для виводу V.title
    ON ES.vacancy_id = V.id
  LEFT JOIN resumes R   -- 3.	Немає жодного резюме з відправкою (sent_at IS NOT NULL) по тій самій парі кандидат–вакансія.
    ON R.candidate_id = ES.user_uid AND
       R.vacancy_id = ES.vacancy_id AND       
       R.sent_at IS NOT NULL
  JOIN access AC    -- 4.	І кандидат, і вакансія доступні поточному HR (Alice, hr_id = 1) згідно з таблицею access (entity_type IN ('candidate','vacancy'), right_code='Read').
    ON AC.entity_id = ES.user_uid AND
       AC.hr_id = 1  AND
       AC.entity_type = 'candidate'  AND
       AC.right_code = 'Read'
  JOIN access AV      -- 4.	І кандидат, і вакансія доступні поточному HR (Alice, hr_id = 1) згідно з таблицею access (entity_type IN ('candidate','vacancy'), right_code='Read').
    ON AV.entity_id = ES.vacancy_id AND
       AV.hr_id = 1  AND
       AV.entity_type = 'vacancy'  AND
       AV.right_code = 'Read'
 WHERE 
   type_id = 1 AND creation_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()   -- Є хоча б один статус із type_id = 1 (“Lead”) у вказаному діапазоні дат 
   AND not exists (    -- Немає жодного пізнішого статусу по тому ж кандидату і тій самій вакансії.
      select 1
      from  early_statuses SUB_ES
      where ES.user_uid = SUB_ES.user_uid 
            and ES.vacancy_id = SUB_ES.vacancy_id 
            and ES.type_id < SUB_ES.type_id
      ) 
   AND R.id IS NULL -- 3.	Немає жодного резюме з відправкою (sent_at IS NOT NULL) по тій самій парі кандидат–вакансія.
ORDER BY ES.creation_date

;