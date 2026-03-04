/*добавьте сюда запросы для решения задания 6*/
----------Task 7-------------
--Руководство GastroHub приняло решение сделать единый номер телефонов для всех менеджеров. 
--Новый номер — 8-800-2500-***, где порядковый номер менеджера выставляется по алфавиту, 
--начиная с номера 100. Старый и новый номер нужно будет хранить в массиве, где первый элемент массива — новый номер, а второй — старый.
--Во время проведения этих изменений таблица managers должна быть недоступна для изменений со стороны других пользователей, но доступна для чтения.

---------тестовая тбл для проверки блокировок--

/*
DROP TABLE IF EXISTS cafe.managers_tmp CASCADE;

CREATE TABLE cafe.managers_tmp(
	manager_uuid  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	name varchar(50) NOT NULL unique,
	phone varchar(20) NULL);

insert into cafe.managers_tmp(name, phone) (
select distinct manager, manager_phone from raw_data.sales
);

select * from cafe.managers_tmp;
*/
-----------------------------------------

BEGIN;

LOCK TABLE cafe.managers IN EXCLUSIVE mode NOWAIT;

--добавили колонку с типом массив
alter table cafe.managers add column phone_set text array[2];

--непосредственно обновление массива телефонов
update cafe.managers as m1
set phone_set = array[m2.new_phone, m1.phone]
from (select m.manager_uuid,
             concat('8-800-2500-',100+(ROW_NUMBER() OVER (ORDER BY m.name ASC))) as new_phone
	  from cafe.managers m) as m2
where m1.manager_uuid = m2.manager_uuid;

alter table cafe.managers drop column phone;

--падает с ошибкой драйвера Array type varchar doesn't have a component type
--alter table cafe.managers rename column phone_set to phone;

COMMIT;
	
select * from cafe.managers;


