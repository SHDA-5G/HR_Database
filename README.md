Тестове завдання: SQL (MySQL 8+)
Використовуйте надану тестову базу даних (структура й сид у файлі recruiting_crm_schema.sql https://drive.google.com/file/d/1CeUrJhRBICVt-zNWLkPpOPaDVVbL9Dbm/view?usp=sharing  ).
 Мета — перевірити вміння працювати з реалістичною схемою рекрутинг-системи: відбори з умовами, анти-джойни, агрегати, оновлення через підзапити.
Фіксація поточного користувача: у всіх місцях, де згадується «поточний HR», вважати, що це Alice Recruiter з hr_id = 1 (див. aspnetusers).
Формат здачі: кожне завдання — окремий .sql-файл (task1.sql … task5.sql). Угорі кожного файлу короткий коментар, що робить запит.
________________________________________
Task 1. Ліди без подальших дій
Повернути список  кандидатів з early_statuses, для яких одночасно виконується:
1.	Є хоча б один статус із type_id = 1 (“Lead”) у вказаному діапазоні дат (creation_date).

2.	Немає жодного пізнішого статусу по тому ж кандидату і тій самій вакансії.

3.	Немає жодного резюме з відправкою (sent_at IS NOT NULL) по тій самій парі кандидат–вакансія.

4.	І кандидат, і вакансія доступні поточному HR (Alice, hr_id = 1) згідно з таблицею access (entity_type IN ('candidate','vacancy'), right_code='Read').

Вивести колонки:
 candidate_id, full_name, linkedin_url, vacancy_id, vacancy_title, creation_date, comment_text, is_friend, is_pro.
 Сортувати за creation_date ↑.
________________________________________
 
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
________________________________________
 
Task 3. Щоденний KPI по HR
Створити у себе тимчасову таблицю kpi_table зі схемою:
day_date DATE, hr_id INT,
leads_created INT, statuses_added INT, resumes_prepared INT,
resumes_sent INT, calls_made INT, contracts_signed INT

Вставити один рядок на кожного HR із aspnetusers, підрахувавши метрики за вчорашній день (інтервал [учора 00:00:00, сьогодні 00:00:00), UTC):
●	leads_created — кількість подій із type_id = 1.

●	statuses_added — кількість подій з усіма типами, крім type_id = 1.

●	resumes_prepared — кількість подій із type_id = 3.

●	resumes_sent — кількість записів у resumes з sent_at IS NOT NULL.

●	calls_made — type_id = 2.

●	contracts_signed — type_id = 10.

________________________________________
Task 4. Оновлення лічильників навичок
Оновити skill_variants.cnt, щоб значення дорівнювало кількості унікальних кандидатів із цією навичкою (зв’язки — у candidate_skills).
 Форма рішення — через UPDATE ... JOIN (SELECT ... GROUP BY).
________________________________________
 
Task 5. Нагадування на сьогодні
Повернути всі нагадування з reminders на сьогоднішню дату (інтервал [сьогодні 00:00:00, завтра 00:00:00)) для поточного HR (Alice, hr_id = 1), причому сама подія нагадування також повинна бути доступна Alice у access (entity_type='reminder', right_code='Read').
Вивести: reminder_id, remdate, candidate_id, full_name, note.
 Сортувати за remdate.
________________________________________
Вимоги до оформлення
1.	Усі фільтри по датах задавайте як інтервал [start, end) — верхня межа виключається.

2.	Обробляйте NULL через COALESCE/IFNULL, щоб уникнути пропусків у підрахунках.

3.	Не дублюйте однакову логіку у кількох підзапитах — за можливості використовуйте JOIN або CTE.

4.	Використовуйте точні назви таблиць і колонок із наданої recruiting_crm_schema-схеми.

________________________________________

