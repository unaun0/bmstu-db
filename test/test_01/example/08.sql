drop database if exists rk2;
create database rk2;

\c rk2;

-- санаторий
drop table if exists sanatorium_client;
drop table if exists sanatorium;
drop table if exists region;
drop table if exists client;

create table client(
    id serial primary key,
    fullname varchar(255) not null,
    birth_year int check(birth_year > 1900),
    email varchar(255),
    address varchar(255)
);
insert into client(fullname, birth_year, email, address) values
    ('отдыхающий 1', 2010, 'e1@gmail.com', 'адрес 1'),
    ('отдыхающий 2', 1995, 'e2@gmail.com', 'адрес 2'),
    ('отдыхающий 3', 2015, 'e3@gmail.com', 'адрес 1'),
    ('отдыхающий 4', 1992, 'e4@gmail.com', 'адрес 1'),
    ('отдыхающий 5', 1998, 'e5@gmail.com', 'адрес 3'),
    ('отдыхающий 6', 1991, 'e6@gmail.com', 'адрес 4'),
    ('отдыхающий 7', 1996, 'e7@gmail.com', 'адрес 4'),
    ('отдыхающий 8', 1997, 'e8@gmail.com', 'адрес 5'),
    ('отдыхающий 9', 1941, 'e9@gmail.com', 'адрес 6'),
    ('отдыхающий 10', 1955, 'e10@gmail.com', 'адрес 7');

create table region(
    id serial primary key,
    name varchar(255) not null,
    description text
);
insert into region(name, description) values
    ('регион 1', 'описание 1'),
    ('регион 2', null),
    ('регион 3', 'описание 3'),
    ('регион 4', 'описание 4'),
    ('регион 5', 'описание 5'),
    ('регион 6', null),
    ('регион 7', 'описание 7'),
    ('регион 8', 'описание 8'),
    ('регион 9', 'описание 9'),
    ('регион 10', 'описание 10');

create table sanatorium(
    id serial primary key,
    name varchar(255) not null,
    description text,
    region_id int not null references region(id) on delete cascade,
    year int check(year > 0)
);
insert into sanatorium(name, description, region_id, year) values
    ('санаторий 1', 'описание 1', 1, 2000),
    ('санаторий 2', 'описание 2', 2, 2001),
    ('санаторий 3', 'описание 3', 3, 2002),
    ('санаторий 4', 'описание 4', 4, 2003),
    ('санаторий 5', 'описание 5', 5, null),
    ('санаторий 6', 'описание 6', 3, 1965),
    ('санаторий 7', 'описание 7', 3, 1960),
    ('санаторий 8', 'описание 8', 8, 2020),
    ('санаторий 9', 'описание 9', 9, null),
    ('санаторий 10', 'описание 10', 10, null);

create table sanatorium_client(
    id serial primary key,
    sanatorium_id int not null references sanatorium(id) on delete cascade,
    client_id int not null references client(id) on delete cascade,
    unique(sanatorium_id, client_id)
);
insert into sanatorium_client(sanatorium_id, client_id) values
    (1, 1), (1, 2), (1, 3), (2, 4), (2, 5), (3, 6),
    (3, 7), (3, 8), (4, 9), (4, 10), (5, 1), (5, 2),
    (5, 3), (6, 4), (6, 5), (7, 6), (7, 7), (8, 8), (8, 9),
    (9, 10), (10, 1);

-- получить информацию об отдыхающих и их возрастной статус
select 
    id, fullname, email,
    case
        when extract(year from CURRENT_DATE) - birth_year < 18 then 'ребенок'
        when extract(year from CURRENT_DATE) - birth_year >= 65 then 'пожилой'
        else 'взрослый'
    end as status
from client;

-- изменить год основания санатория на текущий, если год null
update sanatorium
set year = (
    select extract(year from CURRENT_DATE)
)
where year is null;

-- получить id санаториев, в которых хотя бы 3 отдыхающих
select sc.sanatorium_id
from sanatorium_client sc
group by sc.sanatorium_id
having count(*) >= 3;

-- хранимая процедура для уничтожения представлений
create or replace procedure drop_all_views(out deleted_views_count int)
as $$
declare
    vrecord record;
begin
    deleted_views_count := 0;
    for vrecord in
        select schemaname, viewname
        from pg_views
        where schemaname not in ('pg_catalog', 'information_schema')
    loop
        execute 'drop view if exists ' || vrecord.schemaname || '.' || vrecord.viewname;
        deleted_views_count := deleted_views_count + 1;
    end loop;
end;
$$ language plpgsql;

-- тест
drop view if exists test_view1;
create view test_view1 as
select generate_series(1, 5) as number;

drop view if exists test_view2;
create view test_view2 as
select generate_series(1, 3) as number;

do $$ 
declare
    result int;
begin
    call drop_all_views(result);
    raise notice '%', result;
end $$;