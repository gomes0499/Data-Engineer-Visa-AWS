
from datetime import timedelta, datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'gomes',
    'depends_on_past': False,
    "start_date": datetime(2022, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    "visa-pipeline",
    default_args=default_args,
    description="A simple pipeline DAG",
    schedule_interval=timedelta(days=1),
    catchup=False,
)   

t1  = BashOperator(
    task_id="visa-api",
    bash_command="source /Users/gomes/.pyenv/versions/project8/bin/activate && python /Users/gomes/Desktop/Projects/Data\ Engineer/8-Project/scripts/visaapi.py",
    dag=dag,
)

t2  = BashOperator(
    task_id="data-process",
    bash_command="source /Users/gomes/.pyenv/versions/project8/bin/activate && python /Users/gomes/Desktop/Projects/Data\ Engineer/8-Project/scripts/gluejob.py",
    dag=dag,
)

t3  = BashOperator(
    task_id="redshift",
    bash_command="source /Users/gomes/.pyenv/versions/project8/bin/activate && python /Users/gomes/Desktop/Projects/Data\ Engineer/8-Project/scripts/redshift.py",
    dag=dag,
)

t4 = BashOperator(
    task_id="dbt_run",
    bash_command="source /Users/gomes/.pyenv/versions/project8/bin/activate && cd /Users/gomes/Desktop/Projects/Data\ Engineer/8-Project/wu8project && dbt run",
    dag=dag,
)

t1 >> t2 >> t3 >> t4

