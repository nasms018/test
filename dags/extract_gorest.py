from airflow.providers.http.operators.http import SimpleHttpOperator

# 기본적으로 Http호출하는 Operator
extract_gorest = SimpleHttpOperator(
		task_id='extract_gorest', 
		http_conn_id='GoRest',  # connection에 type을 http로 정의한 conntion id
		endpoint='v2/users', # connection에 정의하고 나머지 주소
		method='GET', # rest api method
		response_filter=lambda res: json.loads(res.text), # response를 어떻게 가져올지 정의 python 함수로 정의
		log_response=True # true로 정의하면 web ui에 log에서 logging을 남김
)