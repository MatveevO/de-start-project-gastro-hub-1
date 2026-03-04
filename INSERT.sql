/*Добавьте в этот файл запросы, которые наполняют данными таблицы в схеме cafe данными*/
-----------insert-----------

--80 cafe--
insert into cafe.restaurants(cafe_name,type,menu) (
	select distinct cafe_name, type::cafe.restaurant_type, menu from raw_data.sales s 
	left join raw_data.menu m using(cafe_name)
);


--20 managers--
insert into cafe.managers(name, phone) (
select distinct manager, manager_phone from raw_data.sales
);

--200 periods--
insert into cafe.restaurant_manager_work_dates(restaurant_uuid, manager_uuid, start_date, end_date) (
select r.restaurant_uuid, m.manager_uuid, Min(s.report_date) as start_date, Max(s.report_date) as end_date from raw_data.sales s 
left join cafe.managers m on m.name = s.manager   
left join cafe.restaurants r on r.cafe_name = s.cafe_name
group by m.manager_uuid, r.restaurant_uuid
order by m.manager_uuid, start_date, end_date 
);

--204480 sales--
insert into cafe.sales(restaurant_uuid, date, avg_check) (
select r.restaurant_uuid, s.report_date, s.avg_check from raw_data.sales s 
left join cafe.restaurants r on r.cafe_name = s.cafe_name
order by s.report_date
);
