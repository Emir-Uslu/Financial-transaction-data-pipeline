from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

def get_engine():
    url = URL.create(
        drivername="postgresql+psycopg",
        username=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=int(DB_PORT),
        database=DB_NAME,
    )
    return create_engine(url, future=True)

def execute_sql_file(engine, path):
    sql = path.read_text(encoding="utf-8")
    with engine.begin() as conn:
        conn.exec_driver_sql(sql)

def scalar(engine, sql):
    with engine.connect() as conn:
        return conn.execute(text(sql)).scalar_one()
