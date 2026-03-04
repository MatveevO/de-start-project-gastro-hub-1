/*добавьте сюда запрос для решения задания 5*/
----------Task 5-------------
--Найдите самую дорогую пиццу для каждой пиццерии.

with cost_pizza_by_cafe as (
select
	t.cafe_name,
	t.pizza_name,
	t.pizza_cost,
	ROW_NUMBER() over (partition by t.cafe_name order by t.pizza_cost DESC) as rn
from
(select distinct r.cafe_name,
                jsonb_object_keys(r.menu->'Пицца') as pizza_name,
                r.menu-> 'Пицца' -> jsonb_object_keys(r.menu->'Пицца') as pizza_cost
from cafe.restaurants r
where r.type in ('pizzeria')) t	
order by t.cafe_name, t.pizza_cost desc
)
select 
    c.cafe_name,
    'Пицца' type,
	c.pizza_name,
	c.pizza_cost
from cost_pizza_by_cafe c
where c.rn = 1
;
