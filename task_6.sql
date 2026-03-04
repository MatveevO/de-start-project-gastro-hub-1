/*добавьте сюда запросы для решения задания 6*/
----------Task 6-------------
--В Gastro Hub решили проверить новую продуктовую гипотезу и поднять цены на капучино. 
--Маркетологи компании собрали совещание, чтобы обсудить, на сколько стоит поднять цены.
--В это время для отчётности использовать старые цены нельзя. После обсуждения решили увеличить цены на капучино на 20%.
--Обновите данные по ценам так, чтобы до завершения обновления никто не вносил других изменений в цены этих заведений.
--В заведениях, где цены не меняются, данные о меню должны остаться в полном доступе.


---------тестовая тбл для проверки блокировок--
/*
DROP TABLE IF EXISTS cafe.restaurants_tmp CASCADE;

CREATE TABLE cafe.restaurants_tmp(
	restaurant_uuid  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	cafe_name varchar(30) NOT NULL unique,
	type cafe.restaurant_type,
	menu jsonb);

insert into cafe.restaurants_tmp(cafe_name,type,menu) (
	select distinct cafe_name, type::cafe.restaurant_type, menu from raw_data.sales s 
	left join raw_data.menu m using(cafe_name)
);

select * from cafe.restaurants_tmp;
*/
-----------------------------------------

BEGIN;

with
--cte с двумя целевыми выборками: 
--new_cost_coffee_by_cafe список новых цен в привязке к заведению
--список uuid заведений для блокировки целевых строк в базовой таблице

cost_coffee_by_cafe as (
select
	t.restaurant_uuid,
	t.coffee_name,
	t.coffee_cost
from
(select r.restaurant_uuid,
        jsonb_object_keys(r.menu->'Кофе') as coffee_name,
        r.menu-> 'Кофе' -> jsonb_object_keys(r.menu->'Кофе') as coffee_cost
from cafe.restaurants r) t	
where coffee_name like 'Капучино'
),
new_cost_coffee_by_cafe as (
select 
    c.restaurant_uuid,
    c.coffee_name,
	c.coffee_cost,
	c.coffee_cost::numeric*1.2  as coffee_new_cost
from cost_coffee_by_cafe c
),
--накладываем блокировку на необходимые строки.
--FOR NO KEY update разрешает этой транзакции изменять только не ключевые поля в блокируемых строках
blocked_cafe as (
select 
    b.restaurant_uuid
from cafe.restaurants b
where  b.restaurant_uuid in (select t.restaurant_uuid from new_cost_coffee_by_cafe t)
FOR NO KEY update NOWAIT
)
--непосредственно обновление цен на Капучино
update cafe.restaurants r
set menu = jsonb_set(menu, '{Кофе,Капучино}', ncc.coffee_new_cost::text::jsonb)
from new_cost_coffee_by_cafe ncc
where r.restaurant_uuid = ncc.restaurant_uuid;

COMMIT;

select * from cafe.restaurants r;
