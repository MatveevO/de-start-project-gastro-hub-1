/*Добавьте в этот файл все запросы, для создания схемы сafe и
 таблиц в ней в нужном порядке*/
-----------create-----------

DROP SCHEMA IF EXISTS cafe CASCADE;
CREATE SCHEMA cafe;

CREATE TYPE cafe.restaurant_type AS ENUM 
    ('coffee_shop', 'restaurant', 'bar', 'pizzeria');

CREATE TABLE cafe.restaurants(
	restaurant_uuid  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	cafe_name varchar(30) NOT NULL unique,
	type cafe.restaurant_type,
	menu jsonb);

CREATE TABLE cafe.managers(
	manager_uuid  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	name varchar(50) NOT NULL unique,
	phone varchar(20) NULL);

CREATE TABLE cafe.restaurant_manager_work_dates(
	restaurant_uuid uuid,
	manager_uuid uuid,
	start_date date NOT NULL,
	end_date date NULL);

ALTER TABLE cafe.restaurant_manager_work_dates ADD CONSTRAINT restaurant_manager_pk PRIMARY KEY (restaurant_uuid, manager_uuid);
ALTER TABLE cafe.restaurant_manager_work_dates ADD CONSTRAINT fk_restaurant_manager_work_dates_restaurant FOREIGN KEY (restaurant_uuid) REFERENCES cafe.restaurants(restaurant_uuid);
ALTER TABLE cafe.restaurant_manager_work_dates ADD CONSTRAINT fk_restaurant_manager_work_dates_manager FOREIGN KEY (manager_uuid) REFERENCES cafe.managers(manager_uuid);

CREATE TABLE cafe.sales(
restaurant_uuid uuid,
date date NOT NULL,
avg_check numeric(6,2) DEFAULT 0);

ALTER TABLE cafe.sales ADD CONSTRAINT restaurant_date_pk PRIMARY key (restaurant_uuid, date);
ALTER TABLE cafe.sales ADD CONSTRAINT fk_sales_restaurant FOREIGN KEY (restaurant_uuid) REFERENCES cafe.restaurants(restaurant_uuid);

