drop database if exists rk2;
create database rk2;

\c rk2;

-- прививки
drop table if exists clinic_vaccine;
drop table if exists child_vaccine;
drop table if exists clinic;
drop table if exists vaccine;
drop table if exists child cascade;

create table child(
    id serial primary key,
    fullname varchar(255),
    birth_year int check(birth_year > 1900),
    address varchar(255),
    parent_phone varchar(20)
);
insert into child(fullname, birth_year, address, parent_phone) values
    ('child 1', 2019, 'address 1', '1234'),
    ('child 2', 2018, 'address 2', '5678'),
    ('child 3', 2017, 'address 3', '9012'),
    ('child 4', 2016, 'address 4', '3456'),
    ('child 5', 2015, 'address 2', '5678'),
    ('child 6', 2014, 'address 5', '2345'),
    ('child 7', 2013, 'address 7', '6789'),
    ('child 8', 2012, 'address 5', '4567'),
    ('child 9', 2011, 'address 9', '3456'),
    ('child 10', 2010, 'address 10', '1234');

create table vaccine(
    id serial primary key,
    name varchar(255),
    description text
);
insert into vaccine(name, description) values
    ('vaccine 1', 'description 1'),
    ('vaccine 2', 'description 2'),
    ('vaccine 3', 'description 3'),
    ('vaccine 4', 'description 4'),
    ('vaccine 5', 'description 5'),
    ('vaccine 6', 'description 6'),
    ('vaccine 7', 'description 7'),
    ('vaccine 8', 'description 8'),
    ('vaccine 9', 'description 9'),
    ('vaccine 10', 'description 10');

create table clinic(
    id serial primary key,
    name varchar(255),
    description text,
    birth_year int check(birth_year > 0)
);
insert into clinic(name, description, birth_year) values
    ('clinic 1', 'description 1', 2019),
    ('clinic 2', 'description 2', 2017),
    ('clinic 3', 'description 3', 2017),
    ('clinic 4', 'description 4', 2020),
    ('clinic 5', 'description 5', 2005),
    ('clinic 6', 'description 6', 2014),
    ('clinic 7', 'description 7', 2024),
    ('clinic 8', 'description 8', 1995),
    ('clinic 9', 'description 9', 1960),
    ('clinic 10', 'description 10', 1974);

create table clinic_vaccine(
    id serial primary key,
    clinic_id int not null references clinic(id) on delete cascade,
    vaccine_id int not null references vaccine(id) on delete cascade,
    unique(clinic_id, vaccine_id)
);
insert into clinic_vaccine(clinic_id, vaccine_id) values
    (1, 1), (1, 2), (1, 3), (2, 4), (2, 5),
    (3, 6), (3, 7), (4, 8), (4, 9), (5, 10),
    (6, 1), (6, 2), (7, 3), (9, 4), (8, 5);

create table child_vaccine(
    id serial primary key,
    child_id int not null references child(id) on delete cascade,
    vaccine_id int not null references vaccine(id) on delete cascade,
    unique(child_id, vaccine_id)
);
insert into child_vaccine(child_id, vaccine_id) values
    (1, 1), (1, 2), (1, 3), (2, 4), (2, 5),
    (3, 6), (3, 7), (4, 8), (4, 9), (5, 10),
    (6, 1), (6, 2), (7, 3), (7, 4), (8, 5), 
    (8, 6), (9, 7), (9, 8), (10, 9), (10, 10);

-- получить детей, родившихся после 2017 года
select * 
from child 
where birth_year > 2017;

-- получить количество прививок для поликлиник (без прививок не учитываются)
select distinct
    c.id, c.name,
    count(cv.vaccine_id) over(partition by c.id) as count_vaccines
from clinic c
join clinic_vaccine cv on c.id = cv.clinic_id
order by c.id;

-- получить детей, которые делали прививку в поликлиниках, дата основания которых < 2000
select *
from child c 
where exists(
    select cv.child_id
    from child_vaccine cv
    join clinic_vaccine cv2 on cv.vaccine_id = cv2.vaccine_id
    join clinic cl on cv2.clinic_id = cl.id
    where cl.birth_year < 2000 and cv.child_id = c.id
);

-- хранимая прцоедура, check для бд
create extension if not exists dblink;
create or replace procedure get_check_db(
    db_name text
)
as $$
declare
    query text;
    result record;
begin
    query := '
        select 
            conname, 
            pg_get_constraintdef(oid) as constraint_definition
        from pg_constraint
        where contype = ''c'' 
        and pg_get_constraintdef(oid) like ''%~~%'';';
    for result in
        select * from dblink(
            'dbname=' || db_name,
            query
        ) as t(conname text, constraint_definition text)
    loop
        raise notice 'name: %, definition: %', result.conname, result.constraint_definition;
    end loop;
end;
$$ language plpgsql;


-- хранимая процедура, сheck для таблицы
create or replace procedure get_check(table_name text)
as $$
declare
    crecord record;
begin
    for crecord in
        select
            conname,
            conrelid::regclass AS tname,
            pg_get_constraintdef(pg_constraint.oid) AS expression
        from pg_constraint
        join pg_class on conrelid = pg_class.oid
        join pg_namespace on pg_class.relnamespace = pg_namespace.oid
        where contype = 'c'
        and pg_get_constraintdef(pg_constraint.oid) ilike '%~~%'
        and conrelid::regclass::text = table_name
    loop
        raise notice 'name: %, expression: %', crecord.conname, crecord.expression;
    end loop;
end;
$$ language plpgsql;

-- тест 1
drop table if exists t1;
create table t1(
    id serial primary key,
    name text not null check (name like '^[a-zA-Z0-9]+$')
);
drop table if exists t2;
create table t2(
    id serial primary key,
    sym text not null check (sym = 'like')
);

-- test 1
--call get_check('t1');
--call get_check('t2');

-- test 2
call get_check_db('rk2');