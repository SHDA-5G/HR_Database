/*
   Task 2. Місячна статистика по вакансіях
       Сформувати зведення за один календарний місяць (наприклад, березень 2025; інтервал [2025-03-01 00:00:00, 2025-04-01 00:00:00)):
        ●	total_candidates — кількість унікальних кандидатів з типами подій у (1, 3, 4, 10, 11, 12, 14, 19).

        ●	resumes_sent — кількість резюме з sent_at IS NOT NULL.

        ●	contracts — кількість статусів із type_id = 10.

        ●	rejections — кількість статусів із type_id = 11.

        ●	calls — кількість статусів із type_id = 2.

        ●	interviews — кількість статусів із type_id IN (12, 14).

	   Вивести: vacancy_id, vacancy_title, month, total_candidates, resumes_sent, contracts, rejections, calls, interviews.
       Сортувати за vacancy_id.
*/
  
 WITH filtered_statuses AS (
    SELECT *
    FROM early_statuses
    WHERE creation_date >= '2025-03-01'
      AND creation_date <  '2025-04-01'
),
candidate_counts AS (
    SELECT vacancy_id, COUNT(DISTINCT user_uid) AS total_candidates
    FROM filtered_statuses
    WHERE type_id IN (1, 3, 4, 10, 11, 12, 14, 19)
    GROUP BY vacancy_id
),
resumes_sent AS (
    SELECT R.vacancy_id, COUNT(*) AS resumes_sent
    FROM resumes R
    WHERE R.sent_at IS NOT NULL
    GROUP BY R.vacancy_id
),
contracts AS (
    SELECT vacancy_id, COUNT(*) AS contracts
    FROM filtered_statuses
    WHERE type_id = 10
    GROUP BY vacancy_id
),
rejections AS (
    SELECT vacancy_id, COUNT(*) AS rejections
    FROM filtered_statuses
    WHERE type_id = 11
    GROUP BY vacancy_id
),
calls AS (
    SELECT vacancy_id, COUNT(*) AS calls
    FROM filtered_statuses
    WHERE type_id = 2
    GROUP BY vacancy_id
),
interviews AS (
    SELECT vacancy_id, COUNT(*) AS interviews
    FROM filtered_statuses
    WHERE type_id IN (12, 14)
    GROUP BY vacancy_id
)

SELECT
    fs.vacancy_id,
    V.title AS vacancy_title,
    MONTH(fs.creation_date) AS month,
    COALESCE(cc.total_candidates, 0) AS total_candidates,
    COALESCE(rs.resumes_sent, 0) AS resumes_sent,
    COALESCE(c.contracts, 0) AS contracts,
    COALESCE(r.rejections, 0) AS rejections,
    COALESCE(cl.calls, 0) AS calls,
    COALESCE(i.interviews, 0) AS interviews
FROM filtered_statuses fs
  JOIN vacancies V 
     ON fs.vacancy_id = V.id
  LEFT JOIN candidate_counts cc
     ON fs.vacancy_id = cc.vacancy_id
  LEFT JOIN resumes_sent rs 
     ON fs.vacancy_id = rs.vacancy_id
  LEFT JOIN contracts c
	ON fs.vacancy_id = c.vacancy_id
  LEFT JOIN rejections r
    ON fs.vacancy_id = r.vacancy_id
  LEFT JOIN calls cl 
    ON fs.vacancy_id = cl.vacancy_id
  LEFT JOIN interviews i 
    ON fs.vacancy_id = i.vacancy_id
GROUP BY fs.vacancy_id, MONTH(fs.creation_date), V.title
ORDER BY fs.vacancy_id;