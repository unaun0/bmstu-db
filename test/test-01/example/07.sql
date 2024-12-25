drop database if exists rk2;
create database rk2;

\c rk2;

-- кафедра
drop table if exists teacher_subject;
drop table if exists teacher;
drop table if exists subject;
drop table if exists department;

create table department(
    id serial primary key,
    name varchar(255) not null,
    description text default null
);
insert into department(name, description) values
    ('iu1', 'iu1 department'),
    ('iu2', 'iu2 department'),
    ('iu3', 'iu3 department'),
    ('iu4', 'iu4 department'),
    ('iu5', 'iu5 department'),
    ('iu6', 'iu6 department'),
    ('iu7', 'iu7 department'),
    ('iu8', 'iu8 department'),
    ('iu9', 'iu9 department'),
    ('iu10', 'iu10 department');

create table subject(
    id serial primary key,
    name varchar(255) not null,
    hours int check(hours > 0),
    semester int check(semester > 0),
    rating int check(rating between 1 and 5)
);
insert into subject(name, hours, semester, rating) values
    ('s1', 70, 1, 4),
    ('s2', 30, 2, 5),
    ('s3', 45, 1, 2),
    ('s4', 30, 2, 1),
    ('s5', 144, 3, 1),
    ('s6', 25, 8, 4),
    ('s7', 90, 4, 4),
    ('s8', 78, 5, 5),
    ('s9', 120, 6, 5),
    ('s10', 20, 7, 3);

create table teacher(
    id serial primary key,
    full_name varchar(255),
    department_id int references department(id),
    degree varchar(255),
    position varchar(255)
);
insert into teacher(full_name, department_id, degree, position) values
    ('t1', 1, 'a', 'lecturer'),
    ('t2', 2, 'b', 'lecturer'),
    ('t3', 3, 'c', 'lecturer'),
    ('t4', 4, 'a', 'docent'),
    ('t5', 5, 'b', 'lecturer'),
    ('t6', 6, 'c', 'docent'),
    ('t7', 7, 'a', 'lecturer'),
    ('t8', 8, 'a', 'docent'),
    ('t9', 9, 'b', 'docent'),
    ('t10', 10, 'a', 'docent');

create table teacher_subject(
    id serial primary key,
    teacher_id int references teacher(id),
    subject_id int references subject(id),
    unique (teacher_id, subject_id)
);
insert into teacher_subject(teacher_id, subject_id) values
    (1, 1), (1, 2), (1, 3), (2, 4), (2, 5), (3, 6), (3, 7), (4, 8), (4, 9), (5, 10),
    (5, 1),(6, 2), (6, 3), (7, 4), (7, 5), (8, 6), (8, 7), (9, 8), (9, 9), (10, 10);

-- получить предметы, количество часов которых больше 100
select * from subject
where hours > 100;

-- получить информацию о предметах: 
-- максимальное, минимальное количество часов; 
-- среднее количество часов,сумма всех часов предметов
select 
    max(hours) as max_hours, 
    min(hours) as min_hours,
    avg(hours) as avg_hours,
    sum(hours) as sum_hours
from subject;

-- получить временную таблицу с преподавателями кафедры с названием iu7
drop table if exists iu7;
select * into iu7 
from teacher t
where t.department_id in (
    select id
    from department
    where name like 'iu7'
);
select * from iu7;

-- хранимая процедура для вывода сведений об индексах таблицы
create or replace procedure get_table_indexes(table_name text)
as $$
declare
    irecord record;
begin
    if not exists (
        select 1 from pg_class
        where relname = table_name and relkind = 'r'
    ) then
        raise exception '% not exists', table_name;
        return;
    end if;

    for irecord in
        select 
            indexname,
            indexdef 
        from pg_indexes
        where tablename = table_name
    loop
        raise notice 'name: %, definifion: %', irecord.indexname, irecord.indexdef;
    end loop;
end;
$$ language plpgsql;

-- тест
call get_table_indexes('teacher_subject');