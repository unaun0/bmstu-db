drop database if exists rk2;
create database rk2;
\c rk2;

drop table if exists ctransaction;
drop table if exists employee;
drop table if exists currency_rate;
drop table if exists currency;

create table currency(
    id serial primary key,
    currency_name varchar(32) not null
);

create table currency_rate(
    id serial primary key,
    currency_id int not null unique references currency(id) on delete cascade,
    srate decimal(10, 2) not null check(srate >= 0.0),
    brate decimal(10, 2) not null check(brate >= 0.0)
);

create table employee(
    id serial primary key,
    fullname varchar(255) not null,
    birth_year int check(
        birth_year 
        between extract(year from CURRENT_DATE) - 75 and extract(year from CURRENT_DATE)
    ),
    position varchar(255) not null
);

create table ctransaction(
    id serial primary key,
    rate_id int not null references currency_rate(id) on delete cascade,
    employee_id int not null references employee(id) on delete cascade,
    amount decimal(10, 2) not null check(amount >= 0.0)
);

insert into currency(currency_name) values
    ('usd'), ('eur'), ('rub'), ('byn'), ('gel'), 
    ('egp'), ('jpy'), ('kzt'), ('cad'), ('dkk');

-- select * from currency;

insert into employee(fullname, birth_year, position) values
    ('Петров Петр Петрович', 2003, 'директор'),
    ('Петров Петр Иванович', 1985, 'менеджер'),
    ('Петров Иван Иванович', 1984, 'программист'),
    ('Петров Иван Петрович', 1989, 'стажер'),
    ('Иванов Иван Иванович', 1991, 'бухгалтер'),
    ('Иванов Петр Иванович', 1995, 'программист'),
    ('Иванов Петр Петрович', 2001, 'стажер'),
    ('Иванов Иван Петрович', 2004, 'бухгалтер'),
    ('Носков Иван Петрович', 2002, 'бухгалтер'),
    ('Носков Петр Иванович', 2001, 'бухгалтер');

-- select * from employee;

insert into currency_rate(currency_id, srate, brate) values
    (1, 45.00, 55.00),
    (2, 100.00, 45.00),
    (3, 1.00, 2.00),
    (4, 15.50, 10.00),
    (5, 67.44, 56.45),
    (6, 12.34, 13.22),
    (7, 56.43, 54.32),
    (8, 0.44, 0.01),
    (9, 6.78, 5.10),
    (10, 0.01, 0.10);

-- select * from currency_rate;

insert into  ctransaction(rate_id, employee_id, amount) values
    (1, 4, 100.00), (1, 10, 200.00),
    (1, 5, 990.90), (1, 4, 50.00),
    (9, 4, 1000.00), (9, 7, 257.11),
    (4, 6, 250.21), (7, 2, 304.51),
    (5, 1, 400.40), (7, 8, 764.23);

-- select * from ctransaction;

-- 1. получить информацию о сотрудниках, которые проводили операции обмена
select
    e.id,
    e.fullname, 
    e.position
from employee e
where exists (
    select t.employee_id
    from ctransaction t
    where t.employee_id = e.id
);

-- 2. получить информацию о сотрудниках и о их количестве операций обмена 
select 
    e.id,
    e.fullname, 
    e.position,
    count(*) as count_op
from employee e
join ctransaction t on e.id = t.employee_id
group by e.id;

-- 3. вставляем операции обмена для бухгалтеров и валют, продажа которых > 90.00 на сумму 500.00
insert into ctransaction (rate_id, employee_id, amount)
select cr.id, e.id, 500.00
from currency_rate cr
join currency c on cr.currency_id = c.id
join employee e on e.position = 'бухгалтер'
where cr.srate > 90.00;

select * from ctransaction;

-- хранимая процедура или функция с выходным параметром, которая уничтожает все dml триггеры в текущей бд
create or replace procedure drop_all_dml_triggers(out dcount int)
as $$
declare
    trecord record;
begin
    dcount := 0;
    for trecord in
        select tgname, tgrelid::regclass
        from pg_trigger
        where tgisinternal = false
        and tgtype & (1 << 0) != 0 -- before
        or tgtype & (1 << 1) != 0 -- after
        or tgtype & (1 << 2) != 0 -- instead of
    loop
        begin
            execute 'drop trigger ' || trecord.tgname || ' on ' || trecord.tgrelid;
            raise notice 'trigger % on % dropped', trecord.tgname, trecord.tgrelid;
            dcount := dcount + 1;
        exception
            when others then
                continue;
        end;
    end loop;
end;
$$ language plpgsql;

-- тестирование
create or replace function before_insert_currency()
returns trigger as $$
begin
    if new.currency_name is null OR new.currency_name = '' THEN
        new.currency_name := 'unnamed';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger before_insert_trigger
before insert on currency
for each row execute function before_insert_currency();

insert into currency (currency_name) values (null);

do $$ 
declare
    result int;
begin
    call drop_all_dml_triggers(result);
    raise notice '%', result; -- 1
end $$;