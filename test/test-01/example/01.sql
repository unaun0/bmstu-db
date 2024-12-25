drop database if exists rk2;
create database rk2;

\c rk2;

-- валюта
drop table if exists exchange_transaction;
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
    rate decimal(10, 2) not null check(rate >= 0.0),
    date date not null
);

create table employee(
    id serial primary key,
    full_name varchar(255) not null,
    year_of_birth int check(
        year_of_birth 
        between extract(year from CURRENT_DATE) - 75 and extract(year from CURRENT_DATE)
    ),
    position varchar(255) not null
);

create table exchange_transaction(
    id serial primary key,
    rate_id int not null references currency_rate(id) on delete cascade,
    employee_id int not null references employee(id) on delete cascade,
    amount decimal(10, 2) not null check(amount >= 0.0)
);

insert into currency(currency_name) values
    ('usd'), ('eur'), ('rub'), ('byn'), ('gel'), 
    ('egp'), ('jpy'), ('kzt'), ('cad'), ('dkk');

select * from currency;

insert into employee(full_name, year_of_birth, position) values
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

select * from employee;

insert into currency_rate(currency_id, rate, date) values
    (1, 45.00, '2010-12-30'),
    (2, 100.00, '2022-03-15'),
    (3, 1.00, '2023-12-15'),
    (4, 15.50, '2024-01-30'),
    (5, 67.44, '2020-05-05'),
    (6, 12.34, '2005-06-07'),
    (7, 56.43, '2013-12-13'),
    (8, 0.44, '2015-12-15'),
    (9, 6.78, '2003-12-27'),
    (10, 0.01, '2006-06-25');

select * from currency_rate;

insert into  exchange_transaction(rate_id, employee_id, amount) values
    (1, 4, 100.00), (1, 10, 200.00),
    (1, 5, 990.90), (1, 4, 50.00),
    (9, 4, 1000.00), (9, 7, 257.11),
    (4, 6, 250.21), (7, 2, 304.51),
    (5, 1, 400.40), (7, 8, 764.23);

select * from exchange_transaction;

-- получить для каждого сотрудника статус в зависимости от года рождения
select 
    id, 
    full_name, 
    case
        when year_of_birth < 1965 then 'бумер'
        when year_of_birth < 1997 then 'миллениал'
        else 'зумер'
    end as status
from employee;

-- получить среднее значение суммы операций обмена по валютам
select distinct
    t.rate_id,
    c.currency_name,
    avg(t.amount) over(partition by t.rate_id) as avg_amount
from exchange_transaction t 
join currency_rate cr on t.rate_id = cr.id
join currency c on cr.id = c.id
order by t.rate_id;

-- получить информацию о сотруднике, который провел не менее трех операций обмена
select 
    e.id,
    e.full_name, 
    e.position
from employee e
join exchange_transaction t on e.id = t.employee_id
group by e.id
having count(*) > 2;

-- хранимая процедура для резервного копирования
create extension if not exists plpython3u;
create or replace procedure backup_all_databases()
language plpython3u
as $$
    import subprocess
    import datetime
    import os
    plpy.notice(f'директория для резервных копий: {os.getcwd()}')

    # костыль для меня 
    pg_dump_path = '/Applications/Postgres.app/Contents/Versions/16/bin/'
    host, user = 'localhost', 'postgres'

    query = plpy.execute(
        '''
        select datname 
        from pg_database 
        where datistemplate = false and datname not in ('postgres')
        '''
    )
    for record in query:
        db_name = record["datname"]
        date_str = datetime.datetime.now().strftime("%Y%d%m")
        backup_file = f'{db_name}_{date_str}.sql'
        cmd = f'pg_dump -h {host} -U {user} -d {db_name} -f {backup_file}'
        try:
            try:
                subprocess.run(cmd, shell=True, check=True)
            except:
                subprocess.run(pg_dump_path + cmd, shell=True, check=True)
            plpy.notice(f'резервная копия бд {db_name} в {backup_file}')
        except:
            plpy.error('ошибка')
$$;

call backup_all_databases();


