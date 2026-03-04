/*добавьте сюда запрос для решения задания 2*/
----------Task 2-------------
--Создайте материализованное представление, которое покажет, как изменяется средний чек
-- для каждого заведения от года к году за все года за исключением 2023 года. 
--Все столбцы со средним чеком округлите до второго знака после запятой.

create materialized view cafe.v_lag_sales as

with years_avg_sales as (
select extract(year from s.date) as year_sale,
       round(avg(s.avg_check),2) as avg_sales,
       s.restaurant_uuid
from cafe.sales s
where extract(year from s.date) <> 2023
group by extract(year from s.date), s.restaurant_uuid
),

years_avg_sales_by_types as (
select ys.*, r.type, r.cafe_name
from years_avg_sales as ys
left join cafe.restaurants as r using(restaurant_uuid)
),

lag_avg_sales as(
select yst.*, 
       LAG(yst.avg_sales) OVER (PARTITION BY yst.restaurant_uuid ORDER BY yst.year_sale) AS previous_sales
from years_avg_sales_by_types as yst
)

select l.year_sale,
       l.cafe_name,
       l.type,
       l.avg_sales,
       l.previous_sales,
       case when l.previous_sales is null then NULL else round(l.avg_sales/l.previous_sales - 1,2) end as percent_change
from lag_avg_sales as l
;

select * from cafe.v_lag_sales vls;
