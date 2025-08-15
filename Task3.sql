
/*
Task 3. Щоденний KPI по HR
Створити у себе тимчасову таблицю kpi_table з відповідною схемою:

Вставити один рядок на кожного HR із aspnetusers, підрахувавши метрики за вчорашній день (інтервал [учора 00:00:00, сьогодні 00:00:00), UTC):
●	leads_created — кількість подій із type_id = 1.

●	statuses_added — кількість подій з усіма типами, крім type_id = 1.

●	resumes_prepared — кількість подій із type_id = 3.

●	resumes_sent — кількість записів у resumes з sent_at IS NOT NULL.

●	calls_made — type_id = 2.

●	contracts_signed — type_id = 10.

*/

CREATE TEMPORARY TABLE kpi_table (
    day_date DATE,
    hr_id INT,
    leads_created INT,
    statuses_added INT,
    resumes_prepared INT,
    resumes_sent INT,
    calls_made INT,
    contracts_signed INT
);

 INSERT kpi_table (
    day_date ,
    hr_id ,
    leads_created ,
    statuses_added ,
    resumes_prepared ,
    resumes_sent ,
    calls_made ,
    contracts_signed)

WITH filtered_statuses AS (
    SELECT *
    FROM early_statuses
    WHERE creation_date >= DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND 
          creation_date < CURDATE()
),
leads_created AS (
    SELECT created_by AS hr_id, COUNT(*) AS leads_created
    FROM filtered_statuses
    WHERE type_id = 1
    GROUP BY created_by
),
statuses_added AS (
    SELECT created_by AS hr_id, COUNT(*) AS statuses_added
    FROM filtered_statuses
    WHERE type_id != 1
    GROUP BY created_by
),
resumes_prepared AS (
    SELECT created_by AS hr_id, COUNT(*) AS resumes_prepared
    FROM filtered_statuses
    WHERE type_id = 3
    GROUP BY created_by
),
resumes_sent AS (
    SELECT ES.created_by AS hr_id, COUNT(*) AS resumes_sent
    FROM filtered_statuses ES
    JOIN resumes R ON R.vacancy_id = ES.vacancy_id
    WHERE R.sent_at IS NOT NULL
    GROUP BY ES.created_by
),
calls_made AS (
    SELECT created_by AS hr_id, COUNT(*) AS calls_made
    FROM filtered_statuses
    WHERE type_id = 2
    GROUP BY created_by
),
contracts_signed AS (
    SELECT created_by AS hr_id, COUNT(*) AS contracts_signed
    FROM filtered_statuses
    WHERE type_id = 10
    GROUP BY created_by
)

SELECT DISTINCT
    CURDATE() AS day_date,
    ASP.id AS hr_id,
    COALESCE(lc.leads_created, 0) AS leads_created,
    COALESCE(sa.statuses_added, 0) AS statuses_added,
    COALESCE(rp.resumes_prepared, 0) AS resumes_prepared,
    COALESCE(rs.resumes_sent, 0) AS resumes_sent,
    COALESCE(cm.calls_made, 0) AS calls_made,
    COALESCE(cs.contracts_signed, 0) AS contracts_signed
FROM aspnetusers ASP
  JOIN filtered_statuses ES 
    ON ASP.id = ES.created_by
  LEFT JOIN leads_created lc
    ON ASP.id = lc.hr_id
  LEFT JOIN statuses_added sa 
    ON ASP.id = sa.hr_id
  LEFT JOIN resumes_prepared rp 
    ON ASP.id = rp.hr_id
  LEFT JOIN resumes_sent rs 
    ON ASP.id = rs.hr_id
  LEFT JOIN calls_made cm 
    ON ASP.id = cm.hr_id
  LEFT JOIN contracts_signed cs
    ON ASP.id = cs.hr_id;

 
SELECT *   -- Отримуємо дані з тимчасової таблиці
FROM kpi_table
