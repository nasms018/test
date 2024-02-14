from airflow.operators.python import PythonOperator
from datetime import datetime
from airflow import DAG

dag = DAG(
    dag_id ="helloWorld",
    start_date = datetime(2021,8,26),
    catchup=False,
    tags = ['example'],
    schedule = '0 2 * * *'
)

def print_hello():
    print("hello!")
    return "hello!"

def print_world():
    print("world!")
    return "world!"

def my_python_function():
    print("Hello, Airflow!")
    print("Current date:", datetime.now())

print_hello = PythonOperator(
    task_id = 'print_hello',
    python_callable= print_hello,
    dag = dag
)

print_world = PythonOperator(
    task_id = 'print_world',
    python_callable= print_world,
    dag = dag
)

print_func = PythonOperator(
    task_id = 'print_hello_airflow',
    python_callable= my_python_function,
    dag = dag
)

# 이렇게 순서를 정하지 않으면, 동시에 독립적으로 실행
print_hello >> print_func >> print_world