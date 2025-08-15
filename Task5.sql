
/*
Task 5. Нагадування на сьогодні
Повернути всі нагадування з reminders на сьогоднішню дату (інтервал [сьогодні 00:00:00, завтра 00:00:00)) для поточного HR (Alice, hr_id = 1), причому сама подія нагадування також повинна бути доступна Alice у access (entity_type='reminder', right_code='Read').
*/

SELECT 
  R.id as reminder_id,
  remdate as remdate,
  candidate_id as candadate_id,
  full_name as full_name,
  COALESCE(note,'') as note
FROM reminders R 
  JOIN candidates C  -- Для виводу повного імені кандидата
    ON C.id = R.candidate_id
  JOIN access A
    ON A.entity_id = R.id AND
       A.entity_type = 'reminder' AND
       A.right_code = 'Read'
WHERE remdate >= CURDATE() AND 
      remdate < DATE_ADD(CURDATE(), INTERVAL 1 DAY) AND 
	  R.hr_id = 1
ORDER BY R.remdate