drop database if exists rk2;
create database rk2;

\c rk2;

-- группы детей
drop table if exists relations;
drop table if exists child;
drop table if exists child_group;
drop table if exists parent;

create table child_group(
    id serial primary key,
    name varchar(255) not null,
    teacher_fullname varchar(255) not null,
    max_hours int check(max_hours >= 0)
);
insert into child_group(name, teacher_fullname, max_hours) values
    ('group 1', 'teacher 1', 5),
    ('group 2', 'teacher 2', 15),
    ('group 3', 'teacher 3', 20),
    ('group 4', 'teacher 3', 20),
    ('group 5', 'teacher 2', 25),
    ('group 6', 'teacher 1', 30),
    ('group 7', 'teacher 1', 35),
    ('group 8', 'teacher 2', 40),
    ('group 9', 'teacher 2', 45),
    ('group 10', 'teacher 3', 50);

create table child(
    id serial primary key,
    fullname varchar(255),
    group_id int not null references child_group(id) on delete cascade,
    birthdate date not null,
    sex varchar(255) not null,
    address varchar(255)
);
insert into child(fullname, group_id, birthdate, sex, address) values
    ('child 1', 1, '2022-01-01', 'male', 'address 1'),
    ('child 2', 2, '2023-01-01', 'female', 'address 1'),
    ('child 3', 2, '2021-12-31', 'male', 'address 2'),
    ('child 4', 5, '2020-08-24', 'female', 'address 3'),
    ('child 5', 6, '2021-05-05', 'male', 'address 2'),
    ('child 6', 6, '2022-08-08', 'female', 'address 4'),
    ('child 7', 10, '2020-09-17', 'male', 'address 5'),
    ('child 8', 8, '2021-03-15', 'female', 'address 6'),
    ('child 9', 9, '2022-12-09', 'male', 'address 7'),
    ('child 10', 2, '2020-02-10', 'female', 'address 4');

create table parent(
    id serial primary key,
    fullname varchar(255) not null,
    type varchar(255),
    age int check(age > 0)
);
insert into parent(fullname, type, age) values
    ('parent 1', 'mother', 30),
    ('parent 2', 'father', 35),
    ('parent 3', 'mother', 40),
    ('parent 4', 'father', 45),
    ('parent 5', 'mother', 50),
    ('parent 6', 'father', 25),
    ('parent 7', 'mother', 23),
    ('parent 8', 'father', 45),
    ('parent 9', 'mother', 50),
    ('parent 10', 'father', 19);

create table relations(
    id serial primary key,
    child_id int not null references child(id) on delete cascade,
    parent_id int not null references parent(id) on delete cascade,
    unique (child_id, parent_id)
);
insert into relations(child_id, parent_id) values
    (1, 1), (1, 2), (2, 3), (2, 4), (3, 3), 
    (3, 4), (4, 7), (4, 8), (5, 9), (10, 10);

-- получить информацию об активности групп
select
    id, name,
    case
        when max_hours > 30 then 'высокая'
        when max_hours between 20 and 30 then 'средняя'
        else 'низкая'
    end as "активность группы"
from child_group;

-- изменить максимальное количество часов для групп, 
-- где оно меньше 10, на avg max кол-во часов всех групп
update child_group
set max_hours = (
    select avg(max_hours)
    from child_group
)
where max_hours < 10;

-- получить id и имена родителей, у которых больше одного ребенка
select p.id as pid, p.fullname
from relations r
join parent p on p.id = r.parent_id
group by p.id
having count(*) > 1;

-- хранимая процедура для поиска EXECUTE в pgsql
create or replace procedure search_for_exec_keyword()
as $$
declare
    proc record;
    exec_instruction text;
begin
    for proc in
        select
            proname as procedure_name,
            prosrc as procedure_code
        from pg_proc
        where prosrc ILIKE '%EXECUTE%'
        and pronamespace = (select oid from pg_namespace where nspname = 'public')
    loop
        for exec_instruction in
            select regexp_matches(proc.procedure_code, 'EXECUTE\s+[^;]*;', 'g')::text
        loop
            raise notice 'процедура: %, инструкция: %', proc.procedure_name, exec_instruction;
        end loop;
    end loop;
end;
$$ language plpgsql;

-- тест
create or replace function target_function()
returns text as $$
begin
    return 'hello world!';
end;
$$ language plpgsql;

create or replace procedure execute_target_function()
as $$
declare
    result text;
begin
    EXECUTE 'select target_function()' into result;
    raise notice '%', result;
end;
$$ language plpgsql;


call search_for_exec_keyword();