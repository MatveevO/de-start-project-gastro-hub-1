/*добавьте сюда запрос для решения задания 3*/
----------Task 3-------------
--Найдите топ-3 заведения, где чаще всего менялся менеджер за весь период.

select distinct 
	r.cafe_name, 
	count(w.manager_uuid) over (partition by w.restaurant_uuid) as count_change
from cafe.restaurant_manager_work_dates w
left join cafe.restaurants r using(restaurant_uuid)
order by count_change desc
limit 3
;
