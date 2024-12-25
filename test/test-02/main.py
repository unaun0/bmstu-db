# ЗАДАНИЕ 2

from peewee import *
import datetime

DB_NAME = 'rk3'
DB_USER = 'postgres'
DB_PASS = ''
DB_HOST = 'localhost'
DB_PORT = '5432'

db = PostgresqlDatabase(
    DB_NAME,
    user=DB_USER,
    password=DB_PASS,
    host=DB_HOST,
    port=DB_PORT
)

# найти все страны, в которых меньше 55 космических аппаратов
Q1 = '''
select country
from satellite
group by country
having count(*) < 55;
'''

# найти КА, которые в общей сложности пробыли в космосе более 40 дней
Q2 = '''
select
    s.name,
    s.country,
    sum(f2.lnch_date - f1.lnch_date) as days_in_space
from flight f1
left join flight f2
on  f1.sid = f2.sid 
    and f1.type = 1 
    and f2.type = 0
    and f2.lnch_date > f1.lnch_date
    and not exists (
        select 1
        from flight f3
        where f3.sid = f1.sid
            and f3.type = 1
            and f3.lnch_date > f1.lnch_date
            and f3.lnch_date < f2.lnch_date
    )
join satellite s
on f1.sid = s.id
group by s.id, s.name, s.country
having sum(f2.lnch_date - f1.lnch_date) > 40;
'''

# найти КА, который в прошлом году вернулся последним
Q3 = '''
select s.*
from satellite s
join flight f on s.id = f.sid
where f.type = 0 
    and extract(year from f.lnch_date) = extract(year from current_date) - 1
order by f.lnch_date, f.lnch_time desc
limit 1;
'''

class BaseModel(Model):
    class Meta:
        database = db

class Satellite(BaseModel):
    id = AutoField()
    name = CharField()
    prod_date = DateField()
    country = CharField()

class Flight(BaseModel):
    sid = ForeignKeyField(Satellite, backref='flights', column_name='sid')
    lnch_date = DateField()
    lnch_time = TimeField()
    lnch_day = CharField()
    type = IntegerField()

def q1_sql():
    result = db.execute_sql(Q1)
    for row in result:
        print(row)

def q2_sql():
    result = db.execute_sql(Q2)
    for row in result:
        print(row)

def q3_sql():
    result = db.execute_sql(Q3)
    for row in result:
        print(row)

def q1_orm():
    query = (
        Satellite
        .select(Satellite.country)
        .group_by(Satellite.country)
        .having(fn.COUNT(Satellite.id) < 55)
    )
    for q in query:
        print(f'{q.country}')

def q2_orm():
    f1 = Flight.alias('f1')
    f2 = Flight.alias('f2')
    query = (
        Satellite
        .select(
            Satellite.name,
            Satellite.country,
            fn.SUM(f2.lnch_date - f1.lnch_date).alias('days_in_space')
        )
        .join(f1, on=(Satellite.id == f1.sid))
        .join(
            f2,
            on=(
                (f1.sid == f2.sid) &
                (f1.type == 1) &
                (f2.type == 0) &
                (f2.lnch_date > f1.lnch_date) &
                ~fn.EXISTS(
                    Flight
                    .select(1)
                    .where(
                        (f1.sid == Flight.sid) &
                        (Flight.type == 1) &
                        (Flight.lnch_date > f1.lnch_date) &
                        (Flight.lnch_date < f2.lnch_date)
                    )
                )
            )
        )
        .group_by(Satellite.id, Satellite.name, Satellite.country)
        .having(fn.SUM(f2.lnch_date - f1.lnch_date) > 40)
    )
    for satellite in query:
        print(f"{satellite.name}, {satellite.country}, {satellite.days_in_space}")

def q3_orm():
    query = (
        Satellite
        .select(Satellite, Flight.lnch_date)
        .join(Flight, on=(Satellite.id == Flight.sid))
        .where(
            (Flight.type == 0),
            (SQL(f'extract (year from lnch_date) = {datetime.datetime.now().year - 1}'))
        )
        .order_by(Flight.lnch_date.desc())
        .order_by(Flight.lnch_time.desc())
        .limit(1)
    )
    result = query.first()
    if result:
        print(f'{result.id}, {result.name}, {result.prod_date}, {result.country}')

if __name__ == '__main__':
    db.connect()

    print('-------- Q1 --------')
    print('-- SQL --')
    q1_sql()
    print('-- ORM --')
    q1_orm()

    print('-------- Q2 --------')
    print('-- SQL --')
    q2_sql()
    print('-- ORM --')
    q2_orm()

    print('-------- Q3 --------')
    print('-- SQL --')
    q3_sql()
    print('-- ORM --')
    q3_orm()

    db.close()
