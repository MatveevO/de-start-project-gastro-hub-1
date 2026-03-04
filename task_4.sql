/*добавьте сюда запрос для решения задания 4*/

----------Task 4-------------
--Найдите пиццерию с самым большим количеством пицц в меню. Если таких пиццерий несколько, выведите все.

with count_pizza_by_cafe as (
select
	t.cafe_name,
	count(t.pizza_name) as count_pizza
from
(select distinct r.cafe_name, 
                jsonb_object_keys(r.menu->'Пицца') as pizza_name
from cafe.restaurants r
where r.type in ('pizzeria')) t	
group by t.cafe_name
order by count_pizza desc
)
select 
    c.cafe_name,
	c.count_pizza
from count_pizza_by_cafe c
where c.count_pizza in (
						select 
							MAX(c.count_pizza)
						from count_pizza_by_cafe c
);
