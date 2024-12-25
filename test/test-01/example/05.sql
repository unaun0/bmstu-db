drop database if exists rk2;
create database rk2;

\c rk2;

-- кружки
drop table if exists client_hobby;
drop table if exists client;
drop table if exists hobby_group;
drop table if exists leader;

create table leader(
    id serial primary key,
    fullname varchar(255) not null,
    birth_year int check(birth_year > 1900),
    experience int check(experience >= 0),
    phone varchar(255)
);
insert into leader(fullname, birth_year, experience, phone) values 
    ('lead 1', 2003, 0, '1234'),
    ('lead 2', 2002, 0, '5678'),
    ('lead 3', 2001, 0, '9012'),
    ('lead 4', 2000, 4, '3456'),
    ('lead 5', 1999, 5, '7890'),
    ('lead 6', 1998, 7, '2345'),
    ('lead 7', 1997, 2, '6789'),
    ('lead 8', 1996, 10, '4567'),
    ('lead 9', 1995, 5, '3456'),
    ('lead 10', 1994, 12, '2345');

create table client(
    id serial primary key,
    fullname varchar(255) not null,
    birth_year int check(birth_year > 1900),
    email varchar(255) not null,
    address varchar(255)
);
insert into client(fullname, birth_year, email, address) values
    ('client 1', 2003, 'client1@gmail.com', 'address1'),
    ('client 2', 2002, 'client2@gmail.com', 'address2'),
    ('client 3', 2001, 'client3@gmail.com', 'address3'),
    ('client 4', 2000, 'client4@gmail.com', 'address4'),
    ('client 5', 1999, 'client5@gmail.com', 'address5'),
    ('client 6', 1998, 'client6@gmail.com', 'address6'),
    ('client 7', 1997, 'client7@gmail.com', 'address7'),
    ('client 8', 1996, 'client8@gmail.com', 'address8'),
    ('client 9', 1995, 'client9@gmail.com', 'address9'),
    ('client 10', 1994, 'client10@gmail.com', 'address10');

create table hobby_group(
    id serial primary key,
    name varchar(255) not null,
    description text,
    leader_id int references leader(id) on delete cascade,
    birth_year int check(birth_year > 0)
);
insert into hobby_group(name, description, leader_id, birth_year) values
    ('group 1', 'description 1', 1, 2003),
    ('group 2', 'description 2', 2, 2002),
    ('group 3', 'description 3', null, 2001),
    ('group 4', 'description 4', 4, 2000),
    ('group 5', 'description 5', null, 1999),
    ('group 6', 'description 6', 4, 1998),
    ('group 7', 'description 7', null, 1997),
    ('group 8', 'description 8', 10, 1996),
    ('group 9', 'description 9', 6, 1995),
    ('group 10', 'description 10', 10, 1994);

create table client_hobby(
    id serial primary key,
    client_id int not null references client(id) on delete cascade,
    hobby_id int not null references hobby_group(id) on delete cascade,
    unique (client_id, hobby_id)
);
insert into client_hobby(client_id, hobby_id) values
    (1, 1), (1, 2), (1, 3), (2, 4), (2, 5),
    (3, 7), (6, 1), (6, 2), (7, 3), (8, 4), 
    (8, 5), (8, 6), (9, 7), (9, 8), (10, 10);

-- получить статус для каждого кружка: есть руковожитель либо нет
select
    id,
    name,
    case
        when leader_id is null then 'not leader'
        else 'leader'
    end as status
from hobby_group;

-- получить средний год рождения поситетей в группах
select distinct
    h.id as hid, h.name,
    round(avg(c.birth_year) over(partition by h.id)) as date_of_birth
from hobby_group h
join client_hobby ch on h.id = ch.hobby_id
join client c on ch.client_id = c.id
order by h.id;

-- получить поситетей, которые состоят хотя бы в 3 кружках
select 
    c.id, 
    c.fullname
from client c
join client_hobby ch on c.id = ch.client_id
group by c.id
having count(*) > 2
order by c.id;

-- хранимая процедура для вывода скалярных функций и параметров
create or replace procedure get_scalar_functions_with_params(
    out total_functions int
)
language plpgsql
as $$
declare
    func_record record;
    count int := 0;
begin
    total_functions := 0;

    for func_record in
        select
            r.routine_name as function_name, 
            r.routine_type,
            p.oid as foid,
            pg_catalog.pg_get_function_arguments(p.oid) AS fparams
        from information_schema.routines r
        join pg_proc p on p.proname = r.routine_name
        join pg_namespace n on p.pronamespace = n.oid
        where
            r.specific_schema = 'public'
            and r.routine_type = 'FUNCTION'
            and r.data_type not like 'record'
            and r.data_type not like 'trigger'
            and r.data_type not like 'void'
            and n.nspname like 'public'
            and pg_catalog.pg_get_function_arguments(p.oid) not like ''
    loop
        raise notice 'function: %, parameters: %', func_record.function_name, func_record.fparams;
        count := count + 1;
    end loop;
    total_functions := count;
end;
$$;

do $$ 
declare
    result int;
begin
    call get_scalar_functions_with_params(result);
    raise notice '%', result;
end $$;

create or replace function test_func(
    p1 int, 
    p2 text
)
returns text as $$
begin
   return 'p1: ' || p1 || ', p2: ' || p2;
end;
$$ language plpgsql;
