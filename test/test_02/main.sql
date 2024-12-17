drop database if exists rk3;
create database rk3;
\c rk3;

drop table if exists satellite;
drop table if exists flight;

create table satellite (
    id serial primary key,
    name varchar(255) not null,
    prod_date date not null, 
    country varchar(255) not null
);

create table  flight (
    sid int not null,
    lnch_date date not null,
    lnch_time time not null,
    lnch_day varchar(255) not null check (
        lnch_day in (
            'Понедельник', 
            'Вторник', 
            'Среда', 
            'Четверг', 
            'Пятница', 
            'Суббота', 
            'Воскресенье'
        )
    ),
    type int check (type in (0, 1)),
    primary key (sid, lnch_date, lnch_time),
    foreign key (sid) references satellite(id)
);

insert into satellite (
    name, 
    prod_date, 
    country
) values
    ('SJT-2086', '2050-01-01', 'Россия'),
    ('Шинцзян 16-02', '2049-12-01', 'Китай');

insert into flight (
    sid, 
    lnch_date, 
    lnch_time, 
    lnch_day, 
    type
) values 
    (1, '2050-05-11', '09:00:00', 'Среда', 1),
    (1, '2051-06-11', '23:05:00', 'Среда', 0),
    (1, '2051-10-10', '23:50:00', 'Вторник', 1),
    (2, '2024-05-11', '15:15:00', 'Среда', 1),
    (1, '2052-01-01', '12:15:00', 'Понедельник', 0);
