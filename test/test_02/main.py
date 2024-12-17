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

Q1 = '''
select 1;
'''

Q2 = '''
select 1;
'''

Q3 = '''
select 1;
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

def q1_orm():
    pass

def q2_orm():
    pass

def q3_orm():
    pass

if __name__ == '__main__':
    db.connect()

    print('--- Q1 ---')
    q1_sql()
    q1_orm()

    print('--- Q2 ---')
    q2_sql()
    q2_orm()

    print('--- Q3 ---')
    q3_sql()
    q3_orm()

    db.close()