/*добавьте сюда запрос для решения задания 1*/
----------Task 1-------------
--Чтобы выдать премию менеджерам, нужно понять, у каких заведений самый высокий средний чек. 
--Создайте представление, которое покажет топ-3 заведения внутри каждого типа заведений 
--по среднему чеку за все даты. Столбец со средним чеком округлите до второго знака после запятой.

create view cafe.v_top3_sales as

with avg_sales as (
	select
  	      s.restaurant_uuid,
	      round(avg(s.avg_check),2) as avg_sales
	from cafe.sales as s
	group by s.restaurant_uuid
),
rn_sales as (
	select r.cafe_name, 
	       r.type, 
	       avg_s.avg_sales,
	       ROW_NUMBER() over (partition by r.type order by avg_s.avg_sales DESC) as rn
	from cafe.restaurants as r
	left join avg_sales as avg_s using(restaurant_uuid)
)

select cafe_name, type, avg_sales
from rn_sales
where rn < 4
;

select * from cafe.v_top3_sales vts;
