"""
TriggerDagRunOperator 공식 문서
<https://airflow.apache.org/docs/apache-airflow/stable/_api/airflow/operators/trigger_dagrun/index.html#airflow.operators.trigger_dagrun.TriggerDagRunOperator>
"""
from time import sleep
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from datetime import datetime, timedelta
from pendulum.tz.timezone import Timezone

kst=Timezone('Asia/Seoul')

with DAG(
    dag_id='ex_trigger_sample',
    description='trigger를 실행하게 해주는 DAG입니다.',
    schedule_interval='@once',
    start_date=datetime(2022,6,22, tzinfo=kst),
    tags=['test', 'call_trigger_sample']
) as dag:

    def dump() -> None:
        sleep(3)

    start = PythonOperator(
        task_id='start',
        python_callable=dump
    )

    call_trigger = TriggerDagRunOperator(
        task_id='call_trigger',
        trigger_dag_id='standby_trigger', # 호출할 DAG_ID 입력
        trigger_run_id=None, # 실행중인 run_id를 입력하면 해당 run_id를 실행한다. None이나 default값은 자동 할당이다.
        execution_date=None, # 실행 날짜를 지정한다.
        reset_dag_run=False, # 해당 dag에 dag_run이 있을 경우 초기화 하고 다시 시작함
        wait_for_completion=False, # DAG_run이 완료 될때 까지 기다린다.
        poke_interval=60, # wait_for_completion을 true로 했다면, Trigger가 작동했는지 확인하는 간격을 지정 할 수 있다. 값을 정해주지 않는다면 기본값은 60이다.
        allowed_states=["success"], # Trigger를 실행할 state를 작성한다.list로 작성해야하며 default는 success이다.
        failed_states=None, # Trigger를 실행하지 않을 상태를 기입한다. list로 작성한다.
    )

    # trigger rule을 사용하지 않으면 바로 end task가 실행된다
    # 바로 실행 되지 않고 trigger를 기다리고 싶다면 trigger rule을 사용
    # email보내는 것과 같이 그냥 보내고 다른 task를 진행하고 싶다면 trigger rule을 사용하지 않고 진행
    end = PythonOperator(
        task_id='end',
        python_callable=dump
    )

    start >> call_trigger >> end