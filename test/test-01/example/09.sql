drop database if exists rk2;
create database rk2;

\c rk2;

drop table if exists medicine_employee;
drop table if exists department cascade;
drop table if exists employee cascade;
drop table if exists medicine;

create table medicine(
    id serial primary key,
    name varchar(255) not null,
    price decimal(10,2) not null check(price >= 0.0),
    description text
);
insert into medicine(name, price, description) values
    ('medicine 1', 5.50, 'desc 1'),
    ('medicine 2', 7.39, 'desc 2'),
    ('medicine 3', 3.99, 'desc 3'),
    ('medicine 4', 9.45, 'desc 4'),
    ('medicine 5', 1.10, 'desc 5'),
    ('medicine 6', 6.23, 'desc 6'),
    ('medicine 7', 8.67, 'desc 7'),
    ('medicine 8', 4.83, 'desc 8'),
    ('medicine 9', 2.12, 'desc 9'),
    ('medicine 10', 0.20, 'desc 10');

create table department(
    id serial primary key,
    name varchar(255) not null,
    phone varchar(255) not null,
    lead_id int not null
);
insert into department(name, phone, lead_id) values
    ('dep 1', 'phone 1', 1),
    ('dep 2', 'phone 2', 2),
    ('dep 3', 'phone 3', 3),
    ('dep 4', 'phone 4', 4),
    ('dep 5', 'phone 5', 5),
    ('dep 6', 'phone 6', 6),
    ('dep 7', 'phone 7', 7),
    ('dep 8', 'phone 8', 8),
    ('dep 9', 'phone 9', 9),
    ('dep 10', 'phone 10', 10);

create table employee(
    id serial primary key,
    fullname varchar(255) not null,
    position varchar(255) not null,
    department_id int not null references department(id),
    salary decimal(10,2) not null check(salary >= 0.0)
);
insert into employee(fullname, position, department_id, salary) values
    ('emp 1', 'pos 1', 1, 5000.00),
    ('emp 2', 'pos 2', 2, 6000.00),
    ('emp 3', 'pos 3', 3, 7000.00),
    ('emp 4', 'pos 4', 4, 8000.00),
    ('emp 5', 'pos 5', 5, 9000.00),
    ('emp 6', 'pos 6', 6, 10000.00),
    ('emp 7', 'pos 7', 7, 11000.00),
    ('emp 8', 'pos 8', 8, 12000.00),
    ('emp 9', 'pos 9', 9, 13000.00),
    ('emp 10', 'pos 10', 10, 14000.00),
    ('emp 11', 'pos 11', 1, 15000.00),
    ('emp 12', 'pos 12', 2, 16000.00),
    ('emp 13', 'pos 13', 3, 17000.00),
    ('emp 14', 'pos 14', 4, 18000.00),
    ('emp 15', 'pos 15', 5, 19000.00);

alter table department
    add constraint fk_lead_id foreign key (lead_id) references employee(id);

create table medicine_employee(
    id serial primary key,
    medicine_id int not null references medicine(id),
    employee_id int not null references employee(id),
    unique(medicine_id, employee_id)
);
insert into medicine_employee(medicine_id, employee_id) values
    (1, 5), (4, 2), (6, 1), (3, 4), (2, 8),
    (5, 10), (6, 3), (7, 1), (7, 9), (10, 1);

-- получить статус работников
select 
    e.id, e.fullname,
    case
        when e.id = d.lead_id then 'заведующий'
        else 'сотрудник'
    end as "статус работника"
from employee e 
full join department d on e.id = d.lead_id
order by e.id;

-- получить количество сотрудников для отделов
select distinct 
    d.id, 
    count(*) over(partition by e.department_id) as count,
    d.name
from employee e
join department d on e.department_id = d.id
order by d.id;

-- получить сотрудников, у которых не менее 3х медикаментов
select 
    me.employee_id as eid, 
    e.fullname
from medicine_employee me
join employee e on me.employee_id = e.id
group by me.employee_id, e.fullname
having count(*) > 2;

-- храманимая процедура которая выводит сведения об идексах таблицы в бд
create extension if not exists dblink;
create or replace procedure get_table_indexes_from_db(
    db_name text, table_name text
)
as $$
declare
    query text;
    result record;
begin
    query := '
        select 
            indexname,
            indexdef
        from pg_indexes 
        where tablename = ''' || table_name || ''';';

    for result in
        select * from dblink(
            'dbname=' || db_name,
            query
        ) as t(indexname text, indexdef text)
    loop
        raise notice 'name: %, definition: %', result.indexname, result.indexdef;
    end loop;
end;
$$ language plpgsql;

call get_table_indexes_from_db('rk2', 'medicine');
