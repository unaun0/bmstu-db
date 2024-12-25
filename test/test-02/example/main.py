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

# страны, в которых создано более 10 спутников
Q1 = '''
select country
from satellite
group by country
having count(*) > 10;
'''

# спутники, которые не возвращались в течение этого календарного года
Q2 = '''
select s.*
from satellite s
where not exists (
    select 1
    from flight f
    where f.sid = s.id
        and extract(year from f.lnch_date) = extract(year from CURRENT_DATE)
        and type = 0
);
'''

# спутники, вернувшиеся на землю не позднее 10 дней с 2024-01-01
Q3 = '''
select distinct s.*
from satellite s
join flight f ON s.id = f.sid
where f.lnch_date between '2024-01-01' and '2024-01-11'
    and type = 0;
'''

# страны, в которых спутники не производились в декабре
Q4 = '''
select distinct country
from satellite
where country not in (
    select country
    from satellite
    where extract(month from prod_date) = 12
);
'''

# спутники, которые запускались в этом году более 3х раз
Q5 = '''
select s.id, s.name, s.prod_date, s.country
from flight f
join satellite s on s.id = f.sid
where 
    extract(year from f.lnch_date) = extract(year from current_date)
    and type = 1
group by s.id
having count(*) > 3;
'''

# страны, в которых есть хоть один космический аппарат, первый запуск которого был после 2024-10-01
Q6 = '''
select distinct s.country
from satellite s
join (
    select f.sid, min(f.lnch_date) AS first_launch_date
    from flight f
    where f.type = 1
    group by f.sid
) subquery ON s.id = subquery.sid
where subquery.first_launch_date > '2024-10-01';
'''

# страны, в которых спутники производятся только в мае
Q7 = '''
select distinct country
from satellite
where country not in (
    select distinct country
    from satellite
    where extract(month from prod_date) != 5
);
'''

# спутник, который вернулся первым на землю в этом году
Q8 = '''
select s.*
from satellite s
join flight f on s.id = f.sid
where f.type = 0 
    and extract(year from f.lnch_date) = extract(year from current_date)
order by f.lnch_date asc
limit 1;
'''

# спутник, который в прошлом году вернулся последним
Q9 = '''
select s.*
from satellite s
join flight f on s.id = f.sid
where f.type = 0 
    and extract(year from f.lnch_date) = extract(year from current_date) - 1
order by f.lnch_date desc
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
    print('\n')

def q2_sql():
    result = db.execute_sql(Q2)
    for row in result:
        print(row)
    print('\n')

def q3_sql():
    result = db.execute_sql(Q3)
    for row in result:
        print(row)
    print('\n')
   
def q4_sql():
    result = db.execute_sql(Q4)
    for row in result:
        print(row)
    print('\n')

def q5_sql():
    result = db.execute_sql(Q5)
    for row in result:
        print(row)
    print('\n')

def q6_sql():
    result = db.execute_sql(Q6)
    for row in result:
        print(row)
    print('\n')

def q7_sql():
    result = db.execute_sql(Q7)
    for row in result:
        print(row)
    print('\n')

def q8_sql():
    result = db.execute_sql(Q8)
    for row in result:
        print(row)
    print('\n')

def q9_sql():
    result = db.execute_sql(Q9)
    for row in result:
        print(row)
    print('\n')

def q1_orm():
    query = (
        Satellite
        .select(Satellite.country) #,fn.COUNT(Satellite.id).alias('count'))
        .group_by(Satellite.country)
        .having(fn.COUNT(Satellite.id) > 10)
    )
    for country in query:
        print(f'{country.country}')
    print('\n')

def q2_orm():
    subquery = (
        Flight.select(Flight.sid)
        .where(
            (SQL(f'extract(year from lnch_date) = {datetime.datetime.now().year}')) &
            (Flight.type == 0)
        )
    )
    query = (
        Satellite
        .select()
        .where(~Satellite.id.in_(subquery))
    )
    for satellite in query:
        print(f'{satellite.id}, {satellite.name}, {satellite.prod_date}, {satellite.country}')
    print('\n')

def q3_orm():
    query = (
        Satellite
        .select()
        .distinct()
        .join(Flight, on=(Flight.sid == Satellite.id))
        .where(
            (Flight.lnch_date >= datetime.date(2024, 1, 1)) &
            (Flight.lnch_date <= datetime.date(2024, 1, 11)) &
            (Flight.type == 0)
        )
    )
    for satellite in query:
        print(f'{satellite.id}, {satellite.name}, {satellite.prod_date}, {satellite.country}')
    print('\n')

def q4_orm():
    subquery = (
        Satellite
        .select(Satellite.country)
        .where(
            (SQL(f'extract(month from prod_date) = 12'))
        )
        .distinct()
    )
    query = (
        Satellite
        .select(Satellite.country)
        .where(~Satellite.country.in_(subquery))
        .distinct()
    )
    for satellite in query:
        print(f'{satellite.country}')
    print('\n')

def q5_orm():
    query = (
        Satellite
        .select(
            Satellite.id,
            Satellite.name,
            Satellite.prod_date,
            Satellite.country
        )
        .join(Flight, on=(Satellite.id == Flight.sid))
        .where(
            SQL(f'extract(year from lnch_date) = {datetime.datetime.now().year}'),
            Flight.type == 1
        )
        .group_by(Satellite.id)
        .having(fn.COUNT('*') > 3)
    )
    for result in query:
        print(f'{result.id}, {result.name}, {result.prod_date}, {result.country}')
    print('\n')

def q6_orm():
    recent_date = datetime.date(2024, 10, 1)
    subquery = (
        Flight
        .select(
            Flight.sid,
            fn.MIN(Flight.lnch_date).alias('first_launch_date')
        )
        .where(Flight.type == 1)
        .group_by(Flight.sid)
    )
    query = (
        Satellite
        .select(Satellite.country)
        .distinct()
        .join(subquery, on=(Satellite.id == subquery.c.sid))
        .where(subquery.c.first_launch_date > recent_date)
    )
    for result in query:
        print(f'{result.country}')
    print('\n')

def q7_orm():
    subquery = (
        Satellite
        .select(Satellite.country)
        .where(
            (SQL(f'extract(month from prod_date) != 5'))
        )
        .distinct()
    )
    query = (
        Satellite
        .select(Satellite.country)
        .where(~Satellite.country.in_(subquery))
        .distinct()
    )
    for satellite in query:
        print(f'{satellite.country}')
    print('\n')

def q8_orm():
    query = (
        Satellite
        .select(Satellite, Flight.lnch_date)
        .join(Flight, on=(Satellite.id == Flight.sid))
        .where(
            (Flight.type == 0),
            (SQL(f'extract (year from lnch_date) = {datetime.datetime.now().year}'))
        )
        .order_by(Flight.lnch_date.asc())
        .limit(1)
    )
    result = query.first()
    if result:
        print(f'{result.id}, {result.name}, {result.prod_date}, {result.country}')
    print('\n')

def q9_orm():
    query = (
        Satellite
        .select(Satellite, Flight.lnch_date)
        .join(Flight, on=(Satellite.id == Flight.sid))
        .where(
            (Flight.type == 0),
            (SQL(f'extract (year from lnch_date) = {datetime.datetime.now().year - 1}'))
        )
        .order_by(Flight.lnch_date.desc())
        .limit(1)
    )
    result = query.first()
    if result:
        print(f'{result.id}, {result.name}, {result.prod_date}, {result.country}')
    print('\n')

if __name__ == '__main__':
    db.connect()

    q1_sql()
    q1_orm()

    q2_sql()
    q2_orm()

    q3_sql()
    q3_orm()

    q4_sql()
    q4_orm()

    q5_sql()
    q5_orm()

    q6_sql()
    q6_orm()

    q7_sql()
    q7_orm()

    q8_sql()
    q8_orm()

    q9_sql()
    q9_orm()

    db.close()