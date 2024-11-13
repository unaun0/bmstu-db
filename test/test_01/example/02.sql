drop database if exists rk2;
create database rk2;

\c rk2;

-- конфеты
drop table if exists store_proc_candy;
drop table if exists prod_candy;
drop table if exists producer;
drop table if exists store;
drop table if exists candy;

create table candy(
    id serial primary key,
    name varchar(255) not null,
    composition text default null,
    description text default null
);
insert into candy (name, composition, description) values
    ('конфета A', 'сахар', 'вкусная'),
    ('конфета B', null, null),
    ('конфета C', 'сахар, вода', 'сладкая'),
    ('конфета D',  null, 'горькая'),
    ('конфета E', 'кислота', null),
    ('конфета F', 'вода, сахар, какао', null),
    ('конфета G', null, 'белый шоколад'),
    ('конфета H', 'вода, сахар, какао, орешки', 'шоколад c орешками'),
    ('конфета I', 'вода, сахар, какао, молоко', 'молочный шоколад'),
    ('конфета J', 'сахар', null);

create table producer(
    id serial primary key,
    name varchar(255) not null,
    inn varchar(255) not null,
    address varchar(255) not null
);
insert into producer(name, inn, address) values
    ('поставщик A', '1234', 'Москва'),
    ('поставщик B', '4321', 'Москва'),
    ('поставщик C', '5678', 'Санкт-Петербург'),
    ('поставщик D', '9012', 'Москва'),
    ('поставщик E', '1111', 'Санкт-Петербург'),
    ('поставщик F', '2222', 'Москва'),
    ('поставщик G', '3333', 'Пермь'),
    ('поставщик H', '4444', 'Казань'),
    ('поставщик I', '5555', 'Санкт-Петербург'),
    ('поставщик J', '6666', 'Москва');

create table prod_candy(
    id serial primary key,
    candy_id int not null references candy(id) on delete cascade,
    producer_id int not null references producer(id) on delete cascade,
    unique(candy_id, producer_id)
);
insert into prod_candy(candy_id, producer_id) values
    (1, 1), (2, 1), (1, 5), (7, 2), (5, 2), 
    (5, 1), (10, 2), (10, 5), (2, 5), (3, 7);

create table store(
    id serial primary key,
    name varchar(255) not null,
    address varchar(255) not null,
    registration_date date not null,
    rating int check (rating between 1 and 5)
);
insert into store(name, address, registration_date, rating) values
    ('магазин A', 'Москва', '2020-01-05', 3),
    ('магазин B', 'Санкт-Петербург', '2023-06-04', 4),
    ('магазин C', 'Москва', '2024-03-15', 5),
    ('магазин D', 'Санкт-Петербург', '2022-09-12', 1),
    ('магазин E', 'Пермь', '2024-02-20', 2),
    ('магазин F', 'Казань', '2024-01-11', 5),
    ('магазин G', 'Казань', '2024-11-13', 4),
    ('магазин H', 'Москва', '2024-06-11', 3),
    ('магазин I', 'Казань', '2024-12-04', 4),
    ('магазин J', 'Санкт-Петербург', '2008-11-14', 1);

create table store_proc_candy(
    id serial primary key,
    store_id int not null references store(id) on delete cascade,
    prod_candy_id int not null references prod_candy(id) on delete cascade,
    unique(store_id, prod_candy_id)
);
insert into store_proc_candy(store_id, prod_candy_id) values
    (5, 7), (6, 8), (7, 8), (7, 10), (5, 1), 
    (3, 2), (2, 10), (1, 1), (5, 5), (9, 5);

-- получить магазины, дата регистрации которых с 2020 по 2022 год включительно
select * from store
where extract(year from registration_date) >= 2020 
and extract(year from registration_date) <= 2022;

-- получить информацию о поставщиках и количестве поставляемых типов конфет ими
select distinct
    p.id, p.name, p.inn,
    count(pc.id) over(partition by pc.producer_id) as candy_count
from producer p 
full join prod_candy pc on p.id = pc.producer_id;

-- получить информацию о магазинах, у которых нет поставщиков
select * from store s
where s.id NOT IN (
	select spc.store_id
	from store_proc_candy spc
    where s.id = spc.store_id
);

-- хранимая процедура для поиска подстроки
create or replace function func_test()
returns int as $$
	select 5
$$ language sql;

create or replace procedure info_routine(str text)
as $$
declare
    elem record;
begin
    for elem in
        select routine_name, routine_type
		from information_schema.routines
		where specific_schema = 'public'
		and (routine_type = 'PROCEDURE' 
			or (routine_type = 'FUNCTION' 
				and data_type not like 'record' 
				and data_type not like 'trigger'))
    loop
        if exists (
            select 1
            from pg_proc p
            join pg_language l on p.prolang = l.oid
            where p.proname = elem.routine_name 
            and p.prosrc ILIKE '%' || str || '%'
            and  l.lanname = 'sql'
        ) then
            raise notice 'elem: %', elem;
        end if;
    end loop;
end;
$$ language plpgsql;

call info_routine('SELECT');