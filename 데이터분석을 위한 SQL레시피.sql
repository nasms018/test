-- Hive, SparkSQL의 경우
52 하나의 값 조작stamp

55 url에서 요소 추출하기
레퍼러 도메인을 추출하는 쿼리
SELECT stamp
, parse_url(referrer, 'HOST') AS referrer_host
FROM access_log;

url 경로와 get매개변수에 있는 특정 키 값을 추출하는 쿼리
SELECT stamp
, parse_url(url, 'PATH') as path
, parse_url(url, 'QUERY', 'id') as id
FROM access_log;

58문자열을 배열로 분해하기
url 경롤르 슬래시로 분할해서 계층을 추출하는 쿼리
SELECT stamp
, url
, split(parse_url(url, 'PATH'), '/')[1] as path1
, split(parse_url(url, 'PATH'), '/')[2] as path2
FROM access_log;

59 날짜와 스탬프 다루기
현재 날짜와 타임스탬프를 추출하는 쿼리
SELECT stamp
, CURRENT_DATE as dt	-- 2017-01-30
, CURRENT_TIMESTAMP as stamp	-- 2017-01-30 18:42:57.584993
FROM access_log;

지정한 값의 날짜/시각 데이터 추출하기
문자열을 날짜/타임스탬프로 변환하기
SELECT DATE('2016-01-30') as dt
, TIMESTAMP('2016-01-30 12:00:00') as stamp;

날짜/시각에서 특정 필드 추출하기
타임스탬프 자료형의 데이터에서 연,월,일 등을 추출하는 쿼리
SELECT stamp
, YEAR(stamp) as year
, MONTH() as month
, DAY() as day
, HOUR() as hour
FROM (SELECT CAST('2016-01-30 12:00:00' AS TIMESTAMP) as stamp) as t;

타임스탬프를 나타내는 문자열에서 연 월 일 등을 추출하는 쿼리
SELECT stamp
, SUBSTR(stamp, 1, 4) as year
, SUBSTR(stamp, 6, 2) as month
, SUBSTR(stamp, 9, 2) as day
, SUBSTR(stamp, 12, 2) as hour
, SUBSTR(stamp, 1, 7) as year_month
FROM (SELECT CAST('2016-01-30 12:00:00' AS string) as stamp) as t;

64결손값을 디폴트 값으로 대체하기
SELECT purchase_id
, amount
, coupon
, (amount - coupon) as discount_amount       -- 이건 값 빼는걸 의미
, (amount - COALESCE(coupon, 0)) AS discount_amount2
FROM purchase_log_with_coupon

66여러개의 값에 대한 조작
67 문자열 연결하기
문자열을 연결하는 쿼리
SELECT user_id
, CONCAT(pref_name, city_name) as pref_city
FROM mst_user_location;
68여러개값 비교하기
q1, q2 컬럼을 비교하는 쿼리
SELECT year, q1, q2
, CASE
	WHEN q1 < q2 THEN '+'
	WHEN q1 = q2 THEN ' '
	ELSE '-'
  END as judge_q1_q2
, SIGN(q2-q1) as sign_q2_q1	-- 양수면 1, 0이면 0, 음수면 -1을 리턴
FROM quarterly_sales;

연간 최대/최소 4분기 매출을 찾는 쿼리 / 단순연산으로 4분기 매출을 구하는 쿼리
SELECT year
, GREATEST(q1,q2,q3,q4) as greatest_sales
, LEAST(q1,q2,q3,q4) as least_sales
, (q1+q2+q3+q4) / 4 as average
FROM quarterly_sales;

COALESCE를 사용해 NULL을 0으로 변환하고 평균값을 구하는 쿼리
SELECT year
, (COALESCE(q, 0) + COALESCE(q, 0) + COALESCE(q, 0) + COALESCE(q, 0))/4 as average
FROM quarterly_sales;

2개의 값 비율 계산하기
SELECT dt, ad_id
, clicks / impressions as ctr
, 100.0 * clicks / impressions AS ctr_as_percent
FROM advertising_stats;

0으로 나누는 것 을 피해 CTR을 계산하는 쿼리
SELECT dt, ad_id
, CASE
	WHEN impressions > 0 THEN 100.0 * clicks / impressions
  END as ctr_as_percent_BY_case
, 100.0 * clicks / 
		CASE 
			WHEN impressions = 0 THEN NULL
			ELSE impressions 
		END AS ctr_as_percent_BY_null
FROM advertising_stats;

77 두 값의 거리 계산하기

일차원 데이터의 절댓값과 제곱 평균 제곱근을 계산하는 쿼리
5|10	5|5
10|5	5|5
-2|4	6|6
SELECT ABS(x1-x2) AS abs
, SQRT(power(x1-x2,2)) AS rms
FROM location_1d;

xy평면위에 있는 두점의 유클리드 거리계산
0|0|2|2		2.82842712474619
3|5|1|2		3.60555127546399
5|3|2|1		3.60555127546399
이차원테이블에 대해 제곱 평균 제곱근(유클리드 거리)을 구하는 쿼리
SELECT SQRT(power(x1-x2,2) + power(y1-y2,2)) AS DISTINCT
FROM location_2d;

79날짜/시간 계산하기
미래 또는 과거의 날짜/시간을 계산하는 쿼리
SELECT user_id
, CAST(register_stamp as timestamp) as register_stamp
, FROM_unixtime(unix_timestamp(register_stamp) + 60 * 60) as after_1_hour
, FROM_unixtime(unix_timestamp(register_stamp) - 30 * 60) as before_30_minutes
, TO_DATE(register_stamp) as register_date
, date_add(to_date(register_stamp), 1) as after_1_day
, ADD_MONTHS(to_date(register_stamp), -1) as before_1_month		--연을 구하는 함수는 구현안됨
FROM mst_user_with_dates;

날짜데이터들의 차이계산
두 날짜의 차이를 계산하는 쿼리
SELECT user_id
, CURRENT_DATE() as today
, to_date(register_stamp) AS register_date
, datediff(CURRENT_DATE(), TO_DATE(register_stamp)) as diff_days
FROM mst_user_with_dates;

날짜를 정수로 표현해서 나이를 계산하는 함수
SELECT floor((20160228-20000229)/10000) as age
SELECT user_id
, SUBSTR(register_stamp, 1, 10) as register_date
, birth_date
, floor(
	(CAST(replace(SUBSTR(register_stamp, 1, 10), '-', '') as int)
		- CAST(replace(birth_date, '-', '') as int)
	) / 10000 ) as register_age
, floor(
	(CAST(replace(CAST(current_date() as string) as int)
		- CAST(replace(birth_date, '-', '') as int)
	) / 10000 ))
FROM mst_user_with_dates;

87 아이피 주소 다루기
아이피주소를 정수 자료형으로 변환하기
SELECT ip
, CAST(SPLIT(ip, '\\.')[0] as int) as ip_part_1
, CAST(SPLIT(ip, '\\.')[1] as int) as ip_part_1
, CAST(SPLIT(ip, '\\.')[2] as int) as ip_part_1
, CAST(SPLIT(ip, '\\.')[3] as int) as ip_part_1
FROM (SELECT '192.168.0.1' as ip) as t;

아이피 주소를 정수 자료형 표기로 변환하는 쿼리
SELECT ip
, CAST(SPLIT(ip, '\\.')[0] as int) * pow(2,24)
+ CAST(SPLIT(ip, '\\.')[1] as int) * pow(2,16)
+ CAST(SPLIT(ip, '\\.')[2] as int) * pow(2, 8)
+ CAST(SPLIT(ip, '\\.')[3] as int) * pow(2, 0)
FROM (SELECT '192.168.0.1' as ip) as t;

아이피주소를 0으로 메운 문자열로 변환하는 쿼리
SELECT ip
, CONCAT(
	  LPAD(split(ip, '\\.')[0], 3, '0')
	, LPAD(split(ip, '\\.')[1], 3, '0')
	, LPAD(split(ip, '\\.')[2], 3, '0')
	, LPAD(split(ip, '\\.')[3], 3, '0')
	) as ip_padding
FROM (SELECT '192.168.0.1' as ip) as t;

92하나의 테이블에 대한 조작
93그룹의 특징잡기
집계 함수를 사용해서 테이블 전체의 특징량을 계산하는 쿼리(집약)
SELECT -- user_id
  COUNT(*) AS total_count
, COUNT(DISTINCT user_id) as user_count
, COUNT(DISTINCT product_id) as product_count
, sum(score) as sum
, avg(score) as avg
, max(score) as max
, min(score) as min
FROM review;
-- GROUP BY user_id 사용자기반으로 데이터를 분할하고 집계함수를 적용하는 쿼리

집계함수를 적용한 값과 집계전의 값을 동시에 다루기
윈도 함수를 사용해 집계함수의 겨로가와 원래 값을 동시에 다루는 쿼리
SELECT user_id
, product_id
, score
, avg(score) OVER() as avg_score
, avg(score) OVER(PARTITION BY user_id) as user_avg_score
, score - avg(score) OVER(PARTITION BY user_id) as user_avg_core_diff
FROM review;

97그룹내부의 순서
SELECT product_id
, score
, ROW_NUMBER() OVER(ORDER BY score DESC) as row			-- 점수 순서로 유일한 순위(같은점수라도 순위 다름)
, RANK() OVER(ORDER BY score DESC) as rank				-- 같은 순위를 허용해서 순위를 붙임 1224
, DENSE_RANK() OVER(ORDER BY score DESC) as dense_rank	-- 같은 순위가 있을 때 같은 순위 다음 순위를 건너뛰고 순위를 붙임 1223
, LAG(product_id) OVER(ORDER BY score DESC) as lag1		-- 현재 행보다 앞에 있는 행의 값 추출
, LAG(product_id, 2) OVER(ORDER BY score DESC) as lag2
, LEAD(product_id) OVER(ORDER BY score DESC) as lead1	-- 현재 행보다 뒤에 있는 행의 값 추출
, LEAD(product_id, 2) OVER(ORDER BY score DESC) as lead2
FROM popular_products ORDER BY row;

ORDER BY구문과 집계함수 조합
SELECT product_id
, score
, ROW_NUMBER() OVER(ORDER BY score DESC) as row
, SUM(score) 
	OVER(ORDER BY score DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cum_score -- 상위 순위부터 누계점수 계산하기
, AVG(score) 
	OVER(ORDER BY score DESC
		ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as local_avg -- 현재행과 앞뒤의 행이 가진 값을 기반으로 평균점수 구하기
, FIRST_VALUE(product_id)
	OVER(ORDER BY score DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as first_value
, LAST_VALUE(product_id)
	OVER(ORDER BY score DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_value
FROM popular_products ORDER BY row;

윈도 프레임 지정별 상품 ID를 집약하는 쿼리
SELECT product_id
, ROW_NUMBER() OVER(ORDER BY score DESC) as row
, array_agg(product_id) -- collect_list(product_id)
	OVER(ORDER BY score DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as whole_agg -- 가장 앞순위부터 가장 뒷순위까지의 범위를 대상으로
, array_agg(product_id) -- collect_list(product_id)
	OVER(ORDER BY score DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND current row) as whole_agg -- 가장 앞순위부터 현재 순위까지 범위를 대상으로
, array_agg(product_id) 
	OVER(ORDER BY score DESC
		ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as local_agg -- 현재행과 앞뒤의 행을 가진 배열
FROM popular_products WHERE category = 'action' ORDER BY row;

윈도함수를 사용해 카테고리들의 순위를 계산하는 쿼리
SELECT category, product_id, score
, ROW_NUMBER() OVER(PARTITION BY category ORDER BY score DESC) as row			-- 카테고리별 점수 순서로 정렬 유일 순위
, RANK() OVER(PARTITION BY category ORDER BY score DESC) as rank				-- 카테고리별 같은 순위를 허가하고 순위122
, DENSE_RANK() OVER(PARTITION BY category ORDER BY score DESC) as dense_rank	-- 카테고리별 같은순위가있을때 순위 건너뛰고 순위 붙임1223
FROM popular_products ORDER BY row;

카테고리들의 순위 상위 2개까지의 상품을 추출하는 쿼리
SELECT * FROM
( SELECT category, product_id, score
  , ROW_NUMBER() OVER(PARTITION BY category ORDER BY score DESC) as rank
  FROM popular_products) as popular_products_with_rank
WHERE rank <= 2
ORDER BY category, rank;FROM

카테고리별 순위 최상위 상품을 추출하는 쿼리
SELECT DISTINCT category
, FIRST_VALUE(product_id)
	OVER(PARTITION BY category ORDER BY score DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as product_id
FROM popular_products;

106 세로기반 데이터를 가로기반으로 변환하기
행으로 저장된 지표 값을 열로 변환하는 쿼리
SELECT dt
, max(CASE WHEN indicator = 'impressions' THEN val END) as impressions
, max(CASE WHEN indicator = 'sessions' THEN val END) as sessions
, max(CASE WHEN indicator = 'users' THEN val END) as users
FROM daily_kpi GROUP BY dt, ORDER BY dt;

행을 집계해서 쉼표로 구분된 문자열로 변환하기 // 데이터브릭스에서 안됨
SELECT purchase_id
, concat_ws(',', collect_list(product_id)) as product_ids
, sum(price) as amount
FROM purchase_detail_log
GROUP BY purchase_id ORDER BY purchase_id;

일련 번호를 가진 피벗 테이블을 사용해 행으로 변환하는 쿼리
SELECT q.year
, CASE		-- q1 에서 q4까지 레이블 이름 출력하기
	WHEN p.idx = 1 THEN 'q1'
	WHEN p.idx = 2 THEN 'q2'
	WHEN p.idx = 3 THEN 'q3'
	WHEN p.idx = 4 THEN 'q4'
  END as quarter
, CASE
	WHEN p.idx = 1 THEN q.q1
	WHEN p.idx = 2 THEN q.q2
	WHEN p.idx = 3 THEN q.q3
	WHEN p.idx = 4 THEN q.q4
  END as sales
FROM
 quarterly_sales as q
CROSS JOIN
( 		  SELECT 1 as idx
UNION ALL SELECT 2 as idx
UNION ALL SELECT 3 as idx
UNION ALL SELECT 4 as idx) as p;

테이블 함수를 사용해 배열을 행으로 전개하는 쿼리
SELECT explode(array('A001', 'A002', 'A003')) as product_id;

테이블 함수를 사용해 쉼표로 구분된 문자열 데이터를 행으로 전개하는 쿼리
SELECT purchase_id, product_id
FROM purchase_log as p
LATERAL VIEW explode(split(product_ids, ',')) e as product_id;

118 여러 개의 테이블 조작
UNION ALL 구문을 사용해 테이블을 세로로 결합(중복제거하려면 UNION or UNION DISTINCT)
SELECT 'app1' as app_name, user_id, name, email FROM app1_mst_users
UNION ALL
SELECT 'app2' as app_name, user_id, name, NULL as email FROM app2_mst_users;

여러 테이블을 결합해서 가로로 정렬하는 쿼리
SELECT m.category_id
, m.name
, s.sales
, r.product_id as sale_product
FROM mst_categories as m
JOIN category_sales as s
ON m.category_id = s.category_id
JOIN product_sale_ranking as r
ON m.category_id = r.category_id;

마스터 테이블의 행 수를 변경하지 않고 여러 개의 테이블을 가로로 정렬하는 쿼리
SELECT m.category_id
, m.name
, s.sales
, r.product_id as top_sale_product
FROM mst_categories as m
LEFT JOIN category_sales as s
ON m.category_id = s.category_id
LEFT JOIN product_sale_ranking as r
ON m.category_id = r.category_id AND r.rank = 1;

상관 서브쿼리로 여러 개의 테이블을 가로로 정렬하는 쿼리
SELECT m.category_id
, m.name
, (SELECT s.sales
	FROM category_sales as s
	WHERE m.category_id = s.category_id
	) as sales
, (SELECT r.product_id
	FROM category_sales_ranking as r
	WHERE m.category_id = r.category_id
	ORDER BY sales DESC
	LIMIT 1
	) as top_sale_product
FROM mst_categories as m;

125 조건 플래그를 0과 1로 표현하기
SELECT m.user_id
, m.card_number
, COUNT(p.user_id) as purchase_count
, CASE
	WHEN m.card_number IS NOT NULL THEN 1
	ELSE 0 
  END as has_card
, SIGN(COUNT(p.user_id)) as has_purchased	-- 양수면 1, 0이면 0, 음수면 -1을 리턴
FROM mst_user_with_card_number as m
LEFT JOIN purchase_log as p
ON m.user_id = p.user_id
GROUP BY m.user_id, m.card_number;

127 계산한 테이블에 이름 붙여 재사용하기
카테고리별 순위를 추가한 테이블에 이름 붙이기
WITH product_sale_ranking as (
	SELECT category_name
	, product_id
	, sales
	, ROW_NUMBER OVER(PARTITION BY category_name ORDER BY sales DESC) as rank
	FROM product_sales
)
SELECT * FROM product_sale_ranking

카테고리들의 순위에서 유니크한 순위목록을 계산하는 쿼리 **
WITH product_sale_ranking as (
	SELECT ROW_NUMBER OVER(PARTITION BY category_name ORDER BY sales DESC) as rank
	FROM product_sales
), mst_rank as(
	SELECT DISTINCT rank
	FROM product_sale_ranking
)
SELECT * FROM mst_rank;

카테고리들의 순위를 횡단적으로 출력하는 쿼리
WITH product_sale_ranking as (
	SELECT ROW_NUMBER OVER(PARTITION BY category_name ORDER BY sales DESC) as rank
	FROM product_sales
), mst_rank as(
	SELECT DISTINCT rank
	FROM product_sale_ranking
)
SELECT m.rank
, r1.product_id as dvd
, r1.sales as dvd_sales
, r2.product_id as cd
, r2.sales as cd_sales
, r3.product_id as book
, r3.sales as book_sales
FROM mst_rank as m
LEFT JOIN product_sale_ranking as r1
ON m.rank = r1.rank
AND r1.category_name = 'dvd'
LEFT JOIN product_sale_ranking as r2
ON m.rank = r2.rank
AND r1.category_name = 'cd'
LEFT JOIN product_sale_ranking as r3
ON m.rank = r3.rank
AND r1.category_name = 'book'
ORDER BY m.rank;

131유사테이블 만드릭
디바이스 ID와 이름의 마스터 테이블을 만드는 쿼리
WITH mst_devices as (
			SELECT 1 as device_id, 'PC' as devices_name
	UNION ALL SELECT 2 as device_id, 'SP' as devices_name
	UNION ALL SELECT 3 as device_id, '애플리케이션' as devices_name
) 
SELECT * FROM mst_devices;

의사 테이블을 사용해 코드를 레이블로 변환하는 쿼리
WITH mst_devices as (
			SELECT 1 as device_id, 'PC' as devices_name
	UNION ALL SELECT 2 as device_id, 'SP' as devices_name
	UNION ALL SELECT 3 as device_id, '애플리케이션' as devices_name
) 
SELECT u.user_id
, d.devices_name
FROM users as u
LEFT JOIN mst_devices as d
on u.register_device = d.device_id;

-- VALUES 구문을 사용해 동적으로 테이블을 만드는쿼리  // 포스트그레스
-- WITH mst_devices(device_id, devices_name) as (
-- 	VALUES
-- 	  (1, 'PC')
-- 	, (2, 'SP')
-- 	, (3, '애플리케이션')
-- )
-- SELECT *
-- FROM mst_devices;

배열과 explode 함수를 사용해 동적으로 테이블을 만드는 쿼리
WITH mst_devices as (
	SELECT 
	  d[0] as device_id
	, d[1] as devices_name
FROM (
	SELECT explode(
		array(
			  array('1', 'PC')
			, array('2', 'SP')
			, array('3', '애플리케이션')
		)) d
	) as t
)
SELECT *
FROM mst_devices;

map 자료형과 explode 함수를 사용해 통적으로 테이블을 작성하는 쿼리
WITH mst_devices as (
	SELECT
	  d['device_id'] as device_id
	, d['device_name'] as device_name
	FROM (
		SELECT explode(
			array(
				  map('device_id', '1', 'device_name', 'PC')
				, map('device_id', '2', 'device_name', 'SP')
				, map('device_id', '3', 'device_name', '애플리케이션')
			)
		) d
	) as t
)
SELECT *
FROM mst_devices;

repeat함수를 응용해서 순번을 작성하는 쿼리
SELECT
	ROW_NUMBER() OVER(ORDER by x) as idx
FROM (
	SELECT explode(split(repeat('x', 5-1)), 'x') as x
) as t

138 시계열 기반으로 데이터 집계하기
날짜별 매출과 평균 구매액을 집계하는 쿼리
SELECT dt
, COUNT(*) as purchase_count
, SUM(purchase_amount) as total_amount
, AVG(purchase_amount) as avg_amount
FROM purchase_log
GROUP BY dt
ORDER BY dt;

날짜별 매출과 7일 이동평균을 집계하는 쿼리
SELECT dt
, SUM(purchase_amount) as total_amount
, AVG(SUM(purchase_amount))
  OVER(ORDER BY dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as seven_day_avg  -- 6일전부터 오늘까지
, CASE
	WHEN 7 = COUNT(*) OVER(ORDER BY dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
	THEN AVG(SUM(purchase_amount)) OVER(ORDER BY dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
  END as seven_day_avg_strict
FROM purchase_log
GROUP BY dt
ORDER BY dt;

9-3날짜별 매출과 당월 누계 매출을 집계하는 쿼리
SELECT dt
, SUBSTR(dt, 1, 7) as year_month
, SUM(purchase_amount) as total_amount
, SUM(SUM(purchase_amount)) 
  OVER(PARTITION BY SUBSTR(dt, 1, 7) ORDER BY dt ROWS UNBOUNDED PRECEDING) as agg_amount
FROM purchase_log
GROUP BY dt
ORDER BY dt;

9-4 날짜별 매출을 일시 테이블로 만드는 쿼리
WITH daily_purchase as (
	SELECT dt
	, SUBSTR(dt, 1, 4) as year
	, SUBSTR(dt, 6, 2) as month
	, SUBSTR(dt, 9, 2) as date
	, SUM(purchase_amount) as purchase_amount
	FROM purchase_log
	GROUP BY dt
)
SELECT *
FROM daily_purchase
ORDER BY dt;

9-5 daily_purchase 테이블에 대해 당월 누계 매출을 집계하는 쿼리
WITH daily_purchase as (
	SELECT dt
	, SUBSTR(dt, 1, 4) as year
	, SUBSTR(dt, 6, 2) as month
	, SUBSTR(dt, 9, 2) as date
	, SUM(purchase_amount) as purchase_amount
	FROM purchase_log
	GROUP BY dt
)
SELECT dt
, concat(year, '-', month) as year_month
, purchase_amount
, SUM(purchase_amount) OVER(PARTITION BY year, month ORDER BY dt ROWS UNBOUNDED PRECEDING) as agg_amount
FROM daily_purchase
ORDER BY dt;

9-6 월별 매출과 작대비를 계산하는 쿼리
WITH daily_purchase as (
	SELECT dt
	, SUBSTR(dt, 1, 4) as year
	, SUBSTR(dt, 6, 2) as month
	, SUBSTR(dt, 9, 2) as date
	, SUM(purchase_amount) as purchase_amount
	FROM purchase_log
	GROUP BY dt
)
SELECT month
, SUM(CASE year WHEN '2014' THEN purchase_amount END) as amount_2014
, SUM(CASE year	WHEN '2015' THEN purchase_amount END) as amount_2015
, 100.0 * SUM(CASE year WHEN '2014' THEN purchase_amount END)
		/ SUM(CASE year WHEN '2015' THEN purchase_amount END)
FROM daily_purchase
GROUP BY month
ORDER BY month;

150p z차트로 업적의 추이 확인
9-7 2015년 매출에 대한 z차트로 작성하는 쿼리
WITH daily_purchase as (
	SELECT dt
	, SUBSTR(dt, 1, 4) as year
	, SUBSTR(dt, 6, 2) as month
	, SUBSTR(dt, 9, 2) as date
	, SUM(purchase_amount) as purchase_amount
	FROM purchase_log
	GROUP BY dt
), monthly_amount as (
	SELECT year
	, month
	, SUM(purchase_amount) as amount
	FROM daily_purchase
	GROUP BY year, month
), calc_index as (
	SELECT year
	, month
	, amount
	, SUM(CASE WHEN year='2015' THEN amount END)
		OVER(ORDER BY year, month ROWS UNBOUNDED PRECEDING) as agg_amount
	, SUM(amount)
		OVER(ORDER BY year, month ROWS BETWEEN 11 PRECEDING AND current ROW) as year_avg_amount
	FROM monthly_purchase
	ORDER BY year, month
)
SELECT
  concat(year, '-', month) as year_month
, amount
, agg_amount
, year_avg_amount
FROM calc_index
WHERE year = '2015'
ORDER BY year_month;

9-8 매출과 관련된 지표를 집계하는 쿼리
WITH daily_purchase as (
	SELECT dt
	, SUBSTR(dt, 1, 4) as year
	, SUBSTR(dt, 6, 2) as month
	, SUBSTR(dt, 9, 2) as date
	, SUM(purchase_amount) as purchase_amount
	FROM purchase_log
	GROUP BY dt
), monthly_purchase as (
	SELECT year
	, month
	, SUM(orders) as orders
	, AVG(purchase_amount) as avg_amount
	, SUM(purchase_amount) as monthly
	FROM daily_purchase
	GROUP BY year, month
)
SELECT
  concat(year, '-', month) as year_month
, orders
, avg_amount
, monthly
, SUM(monthly) OVER(PARTITION BY year ORDER BY month ROWS UNBOUNDED PRECEDING) as agg_amount
, LAG(monthly, 12) OVER(ORDER BY year, month) as last_year	-- 12개월 전 매출 구하기
, 100.0 * monthly / LAG(monthly, 12) OVER(ORDER BY year, month) as rate	-- 12개월 전 매출과 비교해서 비율 구하기
FROM monthly_purchase
ORDER BY year_month;

161 다면적은 축을 사용해 데이터 집계하기
10-1  카테고리별 매출과 소계를 동시에 구하는 쿼리
WITH sub_category_amount as (
	SELECT
	  category as category
	, sub_category as sub_category
	, SUM(price) as amount
	FROM purchase_detail_log
	GROUP BY category, sub_category
), category_amount as (
	SELECT
	  category
	, 'all' as sub_category
	, SUM(price) as amount
	FROM purchase_detail_log
	GROUP BY category
), total_amount as (
	SELECT
	  'all' as category
	, 'all' as sub_category
	, SUM(price) as amount
	FROM purchase_detail_log
)
		SELECT category, sub_category, amount FROM sub_category_amount
UNION ALL SELECT category, sub_category, amount FROM category_amount
UNION ALL SELECT category, sub_category, amount FROM total_amount

10-2 ROLLUP을 사용해서 카테고리별 매출과 소계를 동시에 구하는 쿼리
SELECT
  COALESCE(category, 'all') as category
, COALESCE(sub_category, 'all') as sub_category
, SUM(price) as amount
FROM purchase_detail_log
GROUP BY category, sub_category WITH ROLLUP; -- 다른sql ROLLUP(category, sub_category)

10-3 매출 구성비누계와 ABC 등급을 계산하는 쿼리
WITH monthly_sales as (
	SELECT 
	  category1
	, SUM(price) as amount
	FROM purchase_log
	WHERE dt BETWEEN '2015-12-01' AND '2015-12-31'
	GROUP BY category1
), sales_composition_ratio as(
	SELECT 
	  category1
	, amount
	, 100.0 * amount / SUM(amount) OVER () as composition_ratio -- 구성비 100.0 * <항목별 매출> / <전체 매출>
	, 100.0 * SUM(amount) OVER (ORDER BY amount DESC) / SUM(amount) OVER () as cumulative_ratio -- 구성비 누계 100.0 * <항목별 구계 매출> / <전체 매출>
	FROM monthly_sales
)
SELECT *
, CASE
	WHEN cumulative_ratio BETWEEN 0 AND 70 THEN 'A'
	WHEN cumulative_ratio BETWEEN 70 AND 90 THEN 'B'
	WHEN cumulative_ratio BETWEEN 90 AND 100 THEN 'C'
  END as abc_rank
FROM sales_composition_ratio
ORDER BY amount DESC;

10-4 팬차트 작성때 필요한 데이터를 구하는 쿼리
WITH daily_category_amount as (
	SELECT dt
	, category
	, SUBSTR(dt, 1, 4) as year
	, SUBSTR(dt, 6, 2) as month
	, SUBSTR(dt, 9, 2) as date
	, SUM(price) as amount
	FROM purchase_detail_log
	GROUP BY dt, category
), monthly_category_amount as (
	SELECT
	  concat(year, '-', month) as year_month
	, category
	, SUM(amount) as amount
	GROUP BY year, month, category
)
SELECT 
  year_month
, category
, amount
, FIRST_VALUE(amount) OVER(PARTITION BY category ORDER BY year_month, category ROWS UNBOUNDED PRECEDING) as base_amount
, 100.0 * amount / FIRST_VALUE(amount) OVER(PARTITION BY category ORDER BY year_month, category ROWS UNBOUNDED PRECEDING) as rate
FROM monthly_category_amount
ORDER BY year_month, category;

10-5 최대값 최솟값 범위를 구하는 쿼리
WITH stats as (
	SELECT
	  max(price) as max_price
	, min(price) as min_price
	, max(price) - min(price) as range_price --금액의 범위
	, 10 as bucket_num	-- 계층 수
	FROM purchase_detail_log
)
SELECT *
FROM stats;

10-6 데이터 계층을 구하는 쿼리
WITH stats as (
	SELECT
	  max(price) as max_price
	, min(price) as min_price
	, max(price) - min(price) as range_price --금액의 범위
	, 10 as bucket_num	-- 계층 수
	FROM purchase_detail_log
), purchase_log_with_bucket as (
	SELECT 
	  price
	, min_price
	, price - min_price as diff  -- 정규화 금액 : 대상금액에서 최소금액을 뺀 것
	, 1.0 * range_price / bucket_num as bucket_range -- 계층범위 : 금액범위를 계층수로 나눈 것
	--계층판정: floor(<정규화금액>/<계층범위>)
	, floor(
		1.0 * (price - min_price)
		/ (1.0 * range_price / bucket_num)
	) + 1 as bucket	-- index가 1부터 시작하므로 1만큼 더하기 ????
	FROM purchase_detail_log, stats
)
SELECT *
FROM purchase_log_with_bucket
ORDER BY amount;

10-7 계급 상한 값을 조정한 쿼리
WITH stats as (
	SELECT
	  max(price) + 1 as max_price	-- <금액의 최대값> + 1
	, min(price) as min_price		-- 금액의 최솟값
	, max(price) + 1 - min(price) as range_price -- <금액의 범위> +1(실수)
	, 10 as bucket_num 	--계층수
	FROM purchase_detail_log
), purchase_log_with_bucket as (
	SELECT 
	  price
	, min_price
	, price - min_price as diff  -- 정규화 금액 : 대상금액에서 최소금액을 뺀 것
	, 1.0 * range_price / bucket_num as bucket_range -- 계층범위 : 금액범위를 계층수로 나눈 것
	--계층판정: floor(<정규화금액>/<계층범위>)
	, floor(
		1.0 * (price - min_price)
		/ (1.0 * range_price / bucket_num)
	) + 1 as bucket	-- index가 1부터 시작하므로 1만큼 더하기 ????
	FROM purchase_detail_log, stats
)
SELECT *
FROM purchase_log_with_bucket
ORDER BY price;

10-8 히스토그램을 구하는 쿼리
WITH stats as (
	SELECT
	  max(price) + 1 as max_price	-- <금액의 최대값> + 1
	, min(price) as min_price		-- 금액의 최솟값
	, max(price) + 1 - min(price) as range_price -- <금액의 범위> +1(실수)
	, 10 as bucket_num 	--계층수
	FROM purchase_detail_log
), purchase_log_with_bucket as (
	SELECT 
	  price
	, min_price
	, price - min_price as diff  -- 정규화 금액 : 대상금액에서 최소금액을 뺀 것
	, 1.0 * range_price / bucket_num as bucket_range -- 계층범위 : 금액범위를 계층수로 나눈 것
	--계층판정: floor(<정규화금액>/<계층범위>)
	, floor(
		1.0 * (price - min_price)
		/ (1.0 * range_price / bucket_num)
	) + 1 as bucket	-- index가 1부터 시작하므로 1만큼 더하기 ????
	FROM purchase_detail_log, stats
)
SELECT
  bucket
, min_price + bucket_range * (bucket - 1) as lower_limit	--계층의 하한과 상한 계산하기
, min_price + bucket_range * bucket as upper_limit
, COUNT(price) as num_purchase -- 도수 세기
, SUM(price) as total_amount
FROM purchase_log_with_bucket
GROUP BY bucket, min_price, bucket_range
ORDER BY bucket;

10-9 히스토그램의 상한과 하한을 수동으로 조정한 쿼리
WITH stats as (
	SELECT
	  50000 as max_price
	, 0 as min_price
	, 50000 as range_price
	, 10 as bucket_num
	FROM purchase_detail_log
), purchase_log_with_bucket as (
	SELECT 
	  price
	, min_price
	, price - min_price as diff  -- 정규화 금액 : 대상금액에서 최소금액을 뺀 것
	, 1.0 * range_price / bucket_num as bucket_range -- 계층범위 : 금액범위를 계층수로 나눈 것
	--계층판정: floor(<정규화금액>/<계층범위>)
	, floor(
		1.0 * (price - min_price)
		/ (1.0 * range_price / bucket_num)
	) + 1 as bucket	-- index가 1부터 시작하므로 1만큼 더하기 ????
	FROM purchase_detail_log, stats
)
SELECT
  bucket
, min_price + bucket_range * (bucket - 1) as lower_limit	--계층의 하한과 상한 계산하기
, min_price + bucket_range * bucket as upper_limit
, COUNT(price) as num_purchase -- 도수 세기
, SUM(price) as total_amount  --합계금액 계산하기
FROM purchase_log_with_bucket
GROUP BY bucket, min_price, bucket_range
ORDER BY bucket;


186 사용자 전체의 특징과 경향 찾기
11-1 액션 수와 비율을 계산하는 쿼리
WITH stats as (
	SELECT COUNT(DISTINCT session) as total_uu
	FROM action_log
)
SELECT
  l.action
, COUNT(DISTINCT l.session) as action_uu
, COUNT(1) as action_count
, s.total_uu
, 100.0 * COUNT(DISTINCT l.session) / s.total_uu as usage_rate
, 1.0 * COUNT(1) / COUNT(DISTINCT l.session) as count_per_user
FROM action_log as l
CROSS JOIN stats as s
GROUP BY l.action, s.total_uu;

11-2 로그인 상태를 판별하는 쿼리
WITH action_log_with_status as (
	SELECT
	  session
	, user_id
	, action
	, CASE
		WHEN COALESCE(user_id, '') <> '' THEN 'login'
		ELSE 'guest'
	  END as login_status
	FROM action_log
)
SELECT *
FROM action_log_with_status;

11-3 로그인 상태에 따라 액션수 등을 따로 집계하는 쿼리
WITH action_log_with_status as (
	SELECT
	  session
	, user_id
	, action
	, CASE
		WHEN COALESCE(user_id, '') <> '' THEN 'login'
		ELSE 'guest'
	  END as login_status
	FROM action_log
)
SELECT
  COALESCE(action, 'all') as action
, COALESCE(login_status, 'all') as login_status
, COUNT(DISTINCT session) as action_uu
, COUNT(1) as action_count
FROM action_log_with_status
GROUP BY action, login_status WITH ROLLUP;

11-4 회원상태를 판별하는 쿼리
WITH action_log_with_status as (
	SELECT
	  session
	, user_id
	, action
	, CASE
		WHEN COALESCE(max(user_id) OVER(PARTITION BY session ORDER BY stamp 	-- 로그를 타임스탬프 순서로 나열하고, 한번이라도 로그인한 사용자일 경우,
			ROWS BETWEEN UNBOUNDED PRECEDING AND current row), '') <> '' THEN 'member'	-- 이후의 모든 로그 상태 멤버로 설정
		ELSE 'none'
	  END as member_status
	, stamp
	FROM action_log
)
SELECT *
FROM action_log_with_status;

194 연령별 구분 집계하기
11-5 사용자의 생일을 계산하는 쿼리
WITH mst_user_with_birth_date as (
	SELECT *
	, 20240101 as int_specific_date -- 특정날짜의 정수표현
	, CAST(regexp_replace(SUBSTR(birth_date,1,10), '-', '') as int) as int_birth_date
	FROM mst_users
), mst_users_with_age as (
	SELECT *
	, floor((int_specific_date - int_birth_date)/10000) as age
	FROM mst_user_with_birth_date
)
SELECT user_id, sex, birth_date, age
FROM mst_users_with_age

11-6 성별과 연령으로 연령별 구분을 계산하는 쿼리
WITH mst_user_with_birth_date as (
	SELECT *
	, 20240101 as int_specific_date -- 특정날짜의 정수표현
	, CAST(regexp_replace(SUBSTR(birth_date,1,10), '-', '') as int) as int_birth_date
	FROM mst_users
), mst_users_with_age as (
	SELECT *
	, floor((int_specific_date - int_birth_date)/10000) as age
	FROM mst_user_with_birth_date
), mst_users_with_category as (
	SELECT
	  user_id
	, sex
	, age
	, concat( CASE
				WHEN 20 < age THEN sex
				ELSE ''
			 END
			, CASE
				WHEN age BETWEEN 4 and 12 THEN 'C'
				WHEN age BETWEEN 13 and 19 THEN 'T'
				WHEN age BETWEEN 20 and 34 THEN '1'
				WHEN age BETWEEN 35 and 49 THEN '2'
				WHEN age >= 50 THEN '3'
			  END
	) as category
	FROM mst_users_with_age
)
SELECT *
FROM mst_users_with_category


11-7 연령별 구분의 사람수를 계산하는 쿼리
WITH mst_user_with_birth_date as (
	SELECT *
	, 20240101 as int_specific_date -- 특정날짜의 정수표현
	, CAST(regexp_replace(SUBSTR(birth_date,1,10), '-', '') as int) as int_birth_date
	FROM mst_users
), mst_users_with_age as (
	SELECT *
	, floor((int_specific_date - int_birth_date)/10000) as age
	FROM mst_user_with_birth_date
), mst_users_with_category as (
	SELECT
	  user_id
	, sex
	, age
	, concat( CASE
				WHEN 20 < age THEN sex
				ELSE ''
			 END
			, CASE
				WHEN age BETWEEN 4 and 12 THEN 'C'
				WHEN age BETWEEN 13 and 19 THEN 'T'
				WHEN age BETWEEN 20 and 34 THEN '1'
				WHEN age BETWEEN 35 and 49 THEN '2'
				WHEN age >= 50 THEN '3'
			  END
	) as category
	FROM mst_users_with_age
)
SELECT
  category
, COUNT(1) as user_count
FROM mst_users_with_category
GROUP BY category;

11-8 연령별 구분과 카테고리를 집계하는 쿼리
WITH mst_user_with_birth_date as (
	SELECT *
	, 20240101 as int_specific_date -- 특정날짜의 정수표현
	, CAST(regexp_replace(SUBSTR(birth_date,1,10), '-', '') as int) as int_birth_date
	FROM mst_users
), mst_users_with_age as (
	SELECT *
	, floor((int_specific_date - int_birth_date)/10000) as age
	FROM mst_user_with_birth_date
), mst_users_with_category as (
	SELECT
	  user_id
	, sex
	, age
	, concat( CASE
				WHEN 20 < age THEN sex
				ELSE ''
			 END
			, CASE
				WHEN age BETWEEN 4 and 12 THEN 'C'
				WHEN age BETWEEN 13 and 19 THEN 'T'
				WHEN age BETWEEN 20 and 34 THEN '1'
				WHEN age BETWEEN 35 and 49 THEN '2'
				WHEN age >= 50 THEN '3'
			  END
	) as category
	FROM mst_users_with_age
)
SELECT
  p.category as product_category
, u.category as user_category
, COUNT(*) as purchase_count
FROM action_log as p
JOIN mst_users_with_category as u
ON p.user_id = u.user_id
WHERE action = 'purchase'
GROUP BY p.category, u.category
ORDER BY p.category, u.category;

202 사용자의 방문 빈도 집계하기
11-9 한 주에 며칠 사용되었는지를 집계하는 쿼리
WITH action_log_with_dt as (
	SELECT *
	, SUBSTR(stamp, 1, 10) as dt
	FROM action_log
), action_day_count_per_user as (
	SELECT
	  user_id
	, COUNT(DISTINCT dt) as action_day_count
	FROM action_log_with_dt
	WHERE dt BETWEEN '2016-11-01' AND '2016-11-07' -- 한주동안을 대상으로 지정
	GROUP BY user_id
)
SELECT
  action_day_count
, COUNT(DISTINCT user_id) as user_count
FROM action_day_count_per_user
GROUP BY action_day_count
ORDER BY action_day_count;


11-10 구성비와 구성비 누계를 계산하는 쿼리
WITH action_log_with_dt as (
	SELECT *
	, SUBSTR(stamp, 1, 10) as dt
	FROM action_log
), action_day_count_per_user as (
	SELECT
	  user_id
	, COUNT(DISTINCT dt) as action_day_count
	FROM action_log_with_dt
	WHERE dt BETWEEN '2016-11-01' AND '2016-11-07' -- 한주동안을 대상으로 지정
	GROUP BY user_id
)
SELECT 
  action_day_count
, COUNT(DISTINCT user_id) as user_count
, 100.0 * COUNT(DISTINCT user_id) / SUM(COUNT(DISTINCT user_id)) OVER() as composition_ratio  --구성비
, 100.0 * SUM(COUNT(DISTINCT user_id)) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND current row) / SUM(COUNT(DISTINCT user_id)) OVER() as cumulative_ratio  --구성비
FROM action_day_count_per_user
GROUP BY action_day_count
ORDER BY action_day_count;


206 벤 다이어그램으로 사용자 액션 집계하기
11-11 사용자들의 액션 플래그를 집계하는 쿼리
WITH user_action_flag as (
	SELECT
	  user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) as has_purchase
	, SIGN(SUM(CASE WHEN action = 'review' THEN 1 ELSE 0 END)) as has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' THEN 1 ELSE 0 END)) as has_favorite
	FROM action_log
	GROUP BY user_id
)
SELECT *
FROM user_action_flag;

11-12 모든 액션 조합에 대한 사용자수 계산하기 // 포스트그레스 라고 되있는데 Hive에서 됨
WITH user_action_flag as (
	SELECT
	  user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) as has_purchase
	, SIGN(SUM(CASE WHEN action = 'review' THEN 1 ELSE 0 END)) as has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' THEN 1 ELSE 0 END)) as has_favorite
	FROM action_log
	GROUP BY user_id
), action_venn_diagram as (
	SELECT
	  has_purchase
	, has_review
	, has_favorite
	, COUNT(1) users
	FROM user_action_flag
	GROUP BY CUBE(has_purchase, has_review, has_favorite) -- ROLLUP과 달리 GROUP BY절에 명시한 모든 컬럼에 대해 소그룹 합계를 계산해줌
)
SELECT *
FROM action_venn_diagram
ORDER BY has_purchase, has_review, has_favorite;

11-13 CUBE 구문을 사용하지 않고 표준 SQL 구문만으로 작성한 쿼리
WITH user_action_flag as (
	SELECT
	  user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) as has_purchase
	, SIGN(SUM(CASE WHEN action = 'review' THEN 1 ELSE 0 END)) as has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' THEN 1 ELSE 0 END)) as has_favorite
	FROM action_log
	GROUP BY user_id
), action_venn_diagram as (
	--모든 액션 조합을 개별적으로 구하고 UNION ALL로 결합
	-- 3개의 액션을 모두 한 경우 집계
  	  SELECT has_purchase, has_review, has_favorite, COUNT(1) users
	  FROM user_action_flag
	  GROUP BY has_purchase, has_review, has_favorite
	-- 3개의 액션 중 2개의 액션을 한 경우 집계
	UNION ALL
	  SELECT NULL as has_purchase, has_review, has_favorite, COUNT(1) users
	  FROM user_action_flag
	  GROUP BY has_review, has_favorite
	UNION ALL
	  SELECT has_purchase, NULL as has_review, has_favorite, COUNT(1) users
	  FROM user_action_flag
	  GROUP BY has_purchase, has_favorite
	UNION ALL
	  SELECT has_purchase, has_review, NULL as has_favorite, COUNT(1) users
	  FROM user_action_flag
	  GROUP BY has_purchase, has_review
	-- 3개의 액션 중 1개의 액션을 한 경우 집계
	UNION ALL
	  SELECT NULL as has_purchase, NULL as has_review, has_favorite, COUNT(1) users
	  FROM user_action_flag
	  GROUP BY  has_favorite
	UNION ALL
	  SELECT NULL as has_purchase, has_review, NULL as has_favorite, COUNT(1) users
	  FROM user_action_flag
	  GROUP BY has_review
	UNION ALL
	  SELECT has_purchase, NULL as has_review, NULL as has_favorite, COUNT(1) users
	  FROM user_action_flag
	  GROUP BY has_purchase
	--액션과 상관없이 모든 사용자 집계
	UNION ALL
	  SELECT NULL as has_purchase, NULL as has_review, NULL as has_favorite, COUNT(1) users
	  FROM user_action_flag
)
SELECT *
FROM action_venn_diagram
ORDER BY has_purchase, has_review, has_favorite


11-14 유사적으로 NULL을 퐇마한 레코드를 추가해서 CUBE 구문과 같은 결과를 얻는 쿼리
WITH user_action_flag as (
	SELECT
	  user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) as has_purchase
	, SIGN(SUM(CASE WHEN action = 'review' THEN 1 ELSE 0 END)) as has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' THEN 1 ELSE 0 END)) as has_favorite
	FROM action_log
	GROUP BY user_id
), action_venn_diagram as (
	SELECT
	  mod_has_purchase as has_purchase
	, mod_has_review as has_review
	, mod_has_favorite as has_favorite
	, COUNT(1) as users
	FROM user_action_flag
	LATERAL VIEW explode(array(has_purchase, NULL)) e1 as mod_has_purchase
	LATERAL VIEW explode(array(has_review, NULL)) e2 as mod_has_review
	LATERAL VIEW explode(array(has_favorite, NULL)) e3 as mod_has_favorite
	GROUP BY mod_has_purchase, mod_has_review, mod_has_favorite
)
SELECT *
FROM action_venn_diagram
ORDER BY has_purchase, has_review, has_favorite

%sql
WITH user_action_flag as (
    SELECT
      user_id
    , SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) as has_purchase
    , SIGN(SUM(CASE WHEN action = 'review' THEN 1 ELSE 0 END)) as has_review
    , SIGN(SUM(CASE WHEN action = 'favorite' THEN 1 ELSE 0 END)) as has_favorite
    FROM action_log
    GROUP BY user_id
), action_venn_diagram as (
    SELECT
      has_purchase as mod_has_purchase
    , has_review as mod_has_review
    , has_favorite as mod_has_favorite
    , COUNT(1) as users
    FROM user_action_flag
    LATERAL VIEW explode(array(has_purchase, NULL)) e1 as mod_has_purchase
    LATERAL VIEW explode(array(has_review, NULL)) e2 as mod_has_review
    LATERAL VIEW explode(array(has_favorite, NULL)) e3 as mod_has_favorite
    GROUP BY has_purchase, has_review, has_favorite -- Include the non-aggregating expressions in the GROUP BY clause
)
SELECT *
FROM action_venn_diagram
ORDER BY mod_has_purchase, mod_has_review, mod_has_favorite






11-15 벤 다이어그램을 만들기 위해 데이터를 가공하는 쿼리
WITH user_action_flag as (
	SELECT
	  user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) as has_purchase
	, SIGN(SUM(CASE WHEN action = 'review' THEN 1 ELSE 0 END)) as has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' THEN 1 ELSE 0 END)) as has_favorite
	FROM action_log
	GROUP BY user_id
), action_venn_diagram as (
	SELECT
	  mode_has_purchase as has_purchase
	, mode_has_review as has_review
	, has_favorite as has_favorite
	, COUNT(1) as users
	FROM user_action_flag
	LATERAL VIEW explode(array(has_purchase, NULL)) e1 as mode_has_purchase
	LATERAL VIEW explode(array(has_review, NULL)) e2 as mode_has_review
	LATERAL VIEW explode(array(has_favorite, NULL)) e3 as mode_has_favorite
	GROUP BY mode_has_purchase, mode_has_review, mode_has_favorite
)
SELECT
	  CASE has_purchase
		WHEN 1 THEN 'purchase' WHEN 0 THEN 'not purchase'
		ELSE 'any'
	  END as has_purchase
	, CASE has_review
		WHEN 1 THEN 'review' WHEN 0 THEN 'not review'
		ELSE 'any'
	  END as has_review
	, CASE has_favorite
		WHEN 1 THEN 'favorite' WHEN 0 THEN 'not favorite'
		ELSE 'any'
	  END as has_favorite
	, users
	, 100.0 * users / NULLIF(
		SUM(CASE WHEN has_purchase IS NULL AND has_review IS NULL AND has_favorite IS NULL THEN users
				 ELSE 0
				END) OVER()
	, 0) as ratio
FROM action_venn_diagram
ORDER BY has_purchase, has_review, has_favorite

11-16 구매액이 많은 순서로 사용자 그룹을 10등분하는 쿼리
WITH user_purchase_amount as (
	SELECT
	  user_id
	, SUM(amount) as purchase_amount
	FROM action_log
	WHERE action = 'purchase'
	GROUP BY user_id
), users_with_decile as (
	SELECT
	  user_id
	, purchase_amount
	, ntile(10) OVER (ORDER BY purchase_amount DESC) as decile	--ntil()그룹등분 나머지 위에서 순차적으로 부여
	FROM user_purchase_amount
)
SELECT *
FROM users_with_decile;

11-17 10분할한 Decile들을 집계하는 쿼리
WITH user_purchase_amount as (
	SELECT
	  user_id
	, SUM(amount) as purchase_amount
	FROM action_log
	WHERE action = 'purchase'
	GROUP BY user_id
), users_with_decile as (
	SELECT
	  user_id
	, purchase_amount
	, ntile(10) OVER (ORDER BY purchase_amount DESC) as decile	--ntil()그룹등분 나머지 위에서 순차적으로 부여
	FROM user_purchase_amount
), decile_with_purchase_amount as (
	SELECT
	  decile
	, SUM(purchase_amount) as amount
	, AVG(purchase_amount) as avg_amount
	, SUM(SUM(purchase_amount)) OVER (ORDER BY decile) as cumulative_amount
	, SUM(SUM(purchase_amount)) OVER () as total_amount
	FROM users_with_decile
	GROUP BY decile
)
SELECT *
FROM decile_with_purchase_amount;


11-18 구매액이 많은 Decile순서로 구성비와 구성비 누계를 계산하는 쿼리
WITH user_purchase_amount as (
	SELECT
	  user_id
	, SUM(amount) as purchase_amount
	FROM action_log
	WHERE action = 'purchase'
	GROUP BY user_id
), users_with_decile as (
	SELECT
	  user_id
	, purchase_amount
	, ntile(10) OVER (ORDER BY purchase_amount DESC) as decile	--ntil()그룹등분 나머지 위에서 순차적으로 부여
	FROM user_purchase_amount
), decile_with_purchase_amount as (
	SELECT
	  decile
	, SUM(purchase_amount) as amount
	, AVG(purchase_amount) as avg_amount
	, SUM(SUM(purchase_amount)) OVER (ORDER BY decile) as cumulative_amount
	, SUM(SUM(purchase_amount)) OVER () as total_amount
	FROM users_with_decile
	GROUP BY decile
)
SELECT
	  decile
	, amount
	, avg_amount
	, 100.0 * amount / total_amount as total_ratio
	, 100.0 * cumulative_amount / total_amount as cumulative_ratio
FROM decile_with_purchase_amount;

11-19 사용자별로 RFM을 집계하는 쿼리
WITH purchase_log as (
	SELECT
	  user_id
	, amount
	, SUBSTR(stamp, 1, 10) as dt
	FROM access_log
	WHERE action = 'purchase'
), user_rfm as (
	SELECT
	  user_id
	, max(dt) as recent_date
	, datediff(CURRENT_DATE(), TO_DATE(max(dt))) as recency
	, COUNT(dt) as frequency
	, SUM(amount) as monetary
	FROM purchase_log
	GROUP BY user_id
)
SELECT *
FROM user_rfm;

11-20 사용자들의 RFM랭크를 계산하는 쿼리
WITH purchase_log as (
	SELECT
	  user_id
	, amount
	, SUBSTR(stamp, 1, 10) as dt
	FROM access_log
	WHERE action = 'purchase'
), user_rfm_rank as (
	SELECT
	  user_id
	, recent_date
	, recency
	, frequency
	, monetary
	, CASE
		WHEN recency < 14 THEN 5
		WHEN recency < 28 THEN 4
		WHEN recency < 60 THEN 3
		WHEN recency < 90 THEN 2
		ELSE 1
	  END as r
	, CASE
		WHEN 20 <= frequency THEN 5
		WHEN 10 <= frequency THEN 4
		WHEN  5 <= frequency THEN 3
		WHEN  2 <= frequency THEN 2
		WHEN  1  = frequency THEN 1
	  END as f
	, CASE
		WHEN 300000 <= monetary THEN 5
		WHEN 100000 <= monetary THEN 4
		WHEN  30000 <= monetary THEN 3
		WHEN   5000 <= monetary THEN 2
		ELSE 1
	  END as m
	FROM user_rfm
)
SELECT *
FROM user_rfm_rank

11-21 각 그룹의 사람 수를 확인하는 쿼리
WITH purchase_log as (
	SELECT
	  user_id
	, amount
	, SUBSTR(stamp, 1, 10) as dt
	FROM access_log
	WHERE action = 'purchase'
), user_rfm_rank as (
	SELECT
	  user_id
	, recent_date
	, recency
	, frequency
	, monetary
	, CASE
		WHEN recency < 14 THEN 5
		WHEN recency < 28 THEN 4
		WHEN recency < 60 THEN 3
		WHEN recency < 90 THEN 2
		ELSE 1
	  END as r
	, CASE
		WHEN 20 <= frequency THEN 5
		WHEN 10 <= frequency THEN 4
		WHEN  5 <= frequency THEN 3
		WHEN  2 <= frequency THEN 2
		WHEN  1  = frequency THEN 1
	  END as f
	, CASE
		WHEN 300000 <= monetary THEN 5
		WHEN 100000 <= monetary THEN 4
		WHEN  30000 <= monetary THEN 3
		WHEN   5000 <= monetary THEN 2
		ELSE 1
	  END as m
	FROM user_rfm
), mst_frm_index as (
			SELECT 1 as rfm_index
	UNION ALL SELECT 2 as rfm_index
	UNION ALL SELECT 3 as rfm_index
	UNION ALL SELECT 4 as rfm_index
	UNION ALL SELECT 5 as rfm_index
), rfm_flag as (
	SELECT
	  m.rfm_index
	, CASE WHEN m.rfm_index = r.r THEN 1 ELSE 0 END as r_flag
	, CASE WHEN m.rfm_index = r.f THEN 1 ELSE 0 END as f_flag
	, CASE WHEN m.rfm_index = r.m THEN 1 ELSE 0 END as m_flag
	FROM mst_frm_index as m
	CROSS JOIN user_rfm_rank as r
)
SELECT
  rfm_index
, SUM(r_flag) as r
, SUM(f_flag) as f
, SUM(m_flag) as m
FROM rfm_flag
GROUP BY rfm_index
ORDER BY rfm_index DESC;


11-22 통합랭크를 계산하는 쿼리
WITH purchase_log as (
	SELECT
	  user_id
	, amount
	, SUBSTR(stamp, 1, 10) as dt
	FROM access_log
	WHERE action = 'purchase'
), user_rfm_rank as (
	SELECT
	  user_id
	, recent_date
	, recency
	, frequency
	, monetary
	, CASE
		WHEN recency < 14 THEN 5
		WHEN recency < 28 THEN 4
		WHEN recency < 60 THEN 3
		WHEN recency < 90 THEN 2
		ELSE 1
	  END as r
	, CASE
		WHEN 20 <= frequency THEN 5
		WHEN 10 <= frequency THEN 4
		WHEN  5 <= frequency THEN 3
		WHEN  2 <= frequency THEN 2
		WHEN  1  = frequency THEN 1
	  END as f
	, CASE
		WHEN 300000 <= monetary THEN 5
		WHEN 100000 <= monetary THEN 4
		WHEN  30000 <= monetary THEN 3
		WHEN   5000 <= monetary THEN 2
		ELSE 1
	  END as m
	FROM user_rfm
)
SELECT
  r + f + m as total_rank
, COUNT(user_id)
FROM user_rfm_rank
GROUP BY r + f+ m
ORDER BY total_rank DESC;

11-24 R 과 F를 사용해 2차원 사용자 층의 사용자 수를 집계하는 쿼리
WITH purchase_log as (
	SELECT
	  user_id
	, amount
	, SUBSTR(stamp, 1, 10) as dt
	FROM access_log
	WHERE action = 'purchase'
), user_rfm_rank as (
	SELECT
	  user_id
	, recent_date
	, recency
	, frequency
	, monetary
	, CASE
		WHEN recency < 14 THEN 5
		WHEN recency < 28 THEN 4
		WHEN recency < 60 THEN 3
		WHEN recency < 90 THEN 2
		ELSE 1
	  END as r
	, CASE
		WHEN 20 <= frequency THEN 5
		WHEN 10 <= frequency THEN 4
		WHEN  5 <= frequency THEN 3
		WHEN  2 <= frequency THEN 2
		WHEN  1  = frequency THEN 1
	  END as f
	, CASE
		WHEN 300000 <= monetary THEN 5
		WHEN 100000 <= monetary THEN 4
		WHEN  30000 <= monetary THEN 3
		WHEN   5000 <= monetary THEN 2
		ELSE 1
	  END as m
	FROM user_rfm
)
SELECT
	  CONCAT('r_', r) as r_rank
	, COUNT(CASE WHEN f = 5 THEN 1 END) as f_5
	, COUNT(CASE WHEN f = 4 THEN 1 END) as f_4
	, COUNT(CASE WHEN f = 3 THEN 1 END) as f_3
	, COUNT(CASE WHEN f = 2 THEN 1 END) as f_2
	, COUNT(CASE WHEN f = 1 THEN 1 END) as f_1
FROM user_rfm_rank
GROUP BY r
ORDER BY r_rank DESC;

12-2 매달 등록 수와 전월비를 계산하는 쿼리
WITH mst_user_with_year_month as (
	SELECT *
	, SUBSTR(register_date, 1, 7) as year_month
	FROM mst_users
)
SELECT
  year_month
, COUNT(DISTINCT user_id) as register_count
, LAG(COUNT(DISTINCT user_id)) OVER(ORDER BY year_month ROWS BETWEEN 1 PRECEDING and 1 PRECEDING) as last_month_count
, 1.0 * COUNT(DISTINCT user_id) / LAG(COUNT(DISTINCT user_id)) OVER(ORDER BY year_month ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) as month_over_month_ratio
FROM mst_users_with_year_month
GROUP BY year_month;

12-3 디바이스들의 등록 수를 집계하는 쿼리
WITH mst_users_with_year_month as (
	SELECT *
	, SUBSTR(register_date, 1, 7) as year_month
	FROM mst_users
)
SELECT
	  year_month
	, COUNT(DISTINCT user_id) as register_count
	, COUNT(DISTINCT CASE WHEN register_device = 'pc' THEN user_id END) as register_pc
	, COUNT(DISTINCT CASE WHEN register_device = 'sp' THEN user_id END) as register_sp
	, COUNT(DISTINCT CASE WHEN register_device = 'app' THEN user_id END) as register_app
FROM mst_users_with_year_month
GROUP BY year_month;


12-4 '로그 최근 일자'와 '사용자별 등록일의 다음날'을 계산하는 쿼리
WITH action_log_with_mst_users as (
	SELECT
	  u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, date_add(CAST(u.register_date as date), 1) as next_day_1
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
)
SELECT *
FROM action_log_with_mst_users
ORDER BY register_date;

12-5 사용자의 액션플래그를 계산하는 쿼리
WITH action_log_with_mst_users as (
	SELECT
	  u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, date_add(CAST(u.register_date as date), 1) as next_day_1	-- 등록일 다음날의 날짜 계산하기
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, SIGN(
		SUM(
			CASE WHEN next_day_1 <= latest_date THEN
			  CASE WHEN next_day_1 = action_date THEN 1 ELSE 0 END
			END
		)
	) as next_1_day_action
	FROM action_log_with_mst_users
	GROUP BY user_id, register_date
)
SELECT *
FROM user_action_flag
ORDER BY register_date, user_id;

12-6 다음날 지속률을 계산하는 쿼리
WITH action_log_with_mst_users as (
	SELECT
	  u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, date_add(CAST(u.register_date as date), 1) as next_day_1
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, SIGN(
		SUM(
			CASE WHEN next_day_1 <= latest_date THEN
			  CASE WHEN next_day_1 = action_date THEN 1 ELSE 0 END
			END
		)
	) as next_1_day_action
	FROM action_log_with_mst_users
	GROUP BY user_id, register_date
)
SELECT 
  register_date
, AVG(100.0 * next_1_day_action) as repeat_rate_1_day
FROM user_action_flag
GROUP BY register_date
ORDER BY register_date;

12-7 지속률 지표를 관리하는 마스터 테이블을 작성하는 쿼리
WITH repeat_interval(index_name, interval_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_date
)
SELECT *
FROM repeat_interval
ORDER BY index_name;

12-8 지속률을 세로 기반으로 집계하는 쿼리
WITH repeat_interval(index_name, interval_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_date
), action_log_with_index_date as (
	SELECT
	  u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_date) as index_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_date <= latest_date THEN
			  CASE WHEN index_date = action_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_date
)
SELECT
  register_date
, index_name
, AVG(100.0 * index_date_action) as repeat_rate
FROM user_action_flag
GROUP BY register_date, index_name
ORDER BY register_date, index_name;

12-9 정착률 지표를 관리하는 마스터 테이블을 작성하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
		  	  SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
)
SELECT *
FROM repeat_interval
ORDER BY index_name;

12-10 정착률을 계산하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
		  	  SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
)
SELECT
  register_date
, index_name
, AVG(100.0 *  index_date_action) as index_rate
FROM user_action_flag
GROUP BY register_date, index_name
ORDER BY register_date, index_name;


12-11 지속률 지표를 관리하는 마스터 테이블을 정착률 형식으로 수정한 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
)
SELECT *
FROM repeat_interval
ORDER BY index_name;

12-12 n일 지속률들을 집계하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
)
SELECT
  index_name
, AVG(100.0 * index_date_action) as repeat_rate
FROM user_action_flag
GROUP BY index_name
ORDER BY index_name;

12-13 모든 사용자와 액션의 조합을 도출하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
), mst_actions as (
			  SELECT 'view'	  as action
	UNION ALL SELECT 'commit' as action
	UNION ALL SELECT 'follow' as action
), mst_user_actions as (
	SELECT
	  u.user_id
	, u.register_date
	, a.action
	FROM mst_users as u
	CROSS JOIN mst_actions as a
)
SELECT *
FROM mst_user_actions
ORDER BY user_id, action;


12-14 사용자의 액션 로그를 0, 1 의 플래그로 표현하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
), mst_actions as (
			  SELECT 'view'	  as action
	UNION ALL SELECT 'commit' as action
	UNION ALL SELECT 'follow' as action
), mst_user_actions as (
	SELECT
	  u.user_id
	, u.register_date
	, a.action
	FROM mst_users as u
	CROSS JOIN mst_actions as a
), register_action_flag as (
	SELECT DISTINCT
	  m.user_id
	, m.register_date
	, m.action
	, CASE
		WHEN a.actions IS NOT NULL THEN 1
		ELSE 0
	  END as do_action
	, index_name
	, index_date_action
	FROM mst_user_actions as m
	LEFT JOIN action_log as a
	ON m.user_id = a.user_id
	AND CAST(m.register_date as date) = CAST(a.stamp as date)
	AND m.action = a.action
	LEFT JOIN user_action_flag as f
	ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
)
SELECT *
FROM register_action_flag
ORDER BY user_id, index_name, action;



12-15 액션에 따른 지속률과 정착률을 집계하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
), mst_actions as (
			  SELECT 'view'	  as action
	UNION ALL SELECT 'commit' as action
	UNION ALL SELECT 'follow' as action
), mst_user_actions as (
	SELECT
	  u.user_id
	, u.register_date
	, a.action
	FROM mst_users as u
	CROSS JOIN mst_actions as a
), register_action_flag as (
	SELECT DISTINCT
	  m.user_id
	, m.register_date
	, m.action
	, CASE
		WHEN a.actions IS NOT NULL THEN 1
		ELSE 0
	  END as do_action
	, index_name
	, index_date_action
	FROM mst_user_actions as m
	LEFT JOIN action_log as a
	ON m.user_id = a.user_id
	AND CAST(m.register_date as date) = CAST(a.stamp as date)
	AND m.action = a.action
	LEFT JOIN user_action_flag as f
	ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
)
SELECT
  action
, COUNT(1) users
, AVG(100.0 * do_action) as usage_rate
, index_name
, AVG(CASE do_action WHEN 1 THEN 100.0 * index_date_action END) as idx_rate
, AVG(CASE do_action WHEN 0 THEN 100.0 * index_date_action END) as no_action_idx_rate
FROM register_action_flag
GROUP BY index_name, action
ORDER BY index_name, action;

12-16 액션의 계급 마스터와 사용자 액션 플래그의 조합을 산출하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
), mst_action_bucket(action, min_count, max_count) as (
			  SELECT 'comment' as action, 0 as min_count, 0 as max_count
	UNION ALL SELECT 'comment' as action, 1 as min_count, 5 as max_count
	UNION ALL SELECT 'comment' as action, 6 as min_count, 10 as max_count
	UNION ALL SELECT 'comment' as action, 11 as min_count, 9999 as max_count
	UNION ALL SELECT 'follow' as action, 0 as min_count, 0 as max_count
	UNION ALL SELECT 'follow' as action, 1 as min_count, 5 as max_count
	UNION ALL SELECT 'follow' as action, 6 as min_count, 10 as max_count
	UNION ALL SELECT 'follow' as action, 11 as min_count, 9999 as max_count
), mst_user_action_bucket as (
	SELECT
	  u.user_id
	, u.register_date
	, a.action
	, a.min_count
	, a.max_count
	FROM mst_users as u
	CROSS JOIN mst_action_bucket as a		
)
SELECT *
FROM mst_user_action_bucket
ORDER BY user_id, action, min_count;

12-17 등록 후 7일 동안의 액션 수를 집계하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
), mst_action_bucket(action, min_count, max_count) as (
			  SELECT 'comment' as action, 0 as min_count, 0 as max_count
	UNION ALL SELECT 'comment' as action, 1 as min_count, 5 as max_count
	UNION ALL SELECT 'comment' as action, 6 as min_count, 10 as max_count
	UNION ALL SELECT 'comment' as action, 11 as min_count, 9999 as max_count
	UNION ALL SELECT 'follow' as action, 0 as min_count, 0 as max_count
	UNION ALL SELECT 'follow' as action, 1 as min_count, 5 as max_count
	UNION ALL SELECT 'follow' as action, 6 as min_count, 10 as max_count
	UNION ALL SELECT 'follow' as action, 11 as min_count, 9999 as max_count
), mst_user_action_bucket as (
	SELECT
	  u.user_id
	, u.register_date
	, a.action
	, a.min_count
	, a.max_count
	FROM mst_users as u
	CROSS JOIN mst_action_bucket as a		
), register_action_flag as (
	SELECT
	  m.user_id
	, m.action
	, m.min_count
	, m.max_count
	, COUNT(a.action) as action_count
	, CASE
		WHEN COUNT(a.action) BETWEEN m.min_count and m.max_count THEN 1
		ELSE 0
	  END as achieve
	, index_name
	, index_date_action
	FROM mst_user_action_bucket as m
	LEFT JOIN action_log as a
	on m.user_id = a.user_id
	AND CAST(a.stamp as date)		--스파크SQL의 경우
		BETWEEN CAST(m.register_date as date) AND date_add(CAST(m.register_date as date), 7)
		-- 하이브의 경우 JOIN 구문에 BETWEEN 구문을 사용할 수 없으므로 WHERE 구문을 사용해야함
	AND m.action = a.action
	LEFT JOIN user_action_flag as f
	ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
	GROUP BY
	  m.user_id
	, m.action
	, m.min_count
	, m.max_count
	, f.index_name
	, f.index_date_action
)
SELECT *
FROM register_action_flag
ORDER BY user_id, action, min_count;

12-18 등록 후 7일 동안의 액션 횟수별로 14일 정착률을 집계하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
), mst_action_bucket(action, min_count, max_count) as (
			  SELECT 'comment' as action, 0 as min_count, 0 as max_count
	UNION ALL SELECT 'comment' as action, 1 as min_count, 5 as max_count
	UNION ALL SELECT 'comment' as action, 6 as min_count, 10 as max_count
	UNION ALL SELECT 'comment' as action, 11 as min_count, 9999 as max_count
	UNION ALL SELECT 'follow' as action, 0 as min_count, 0 as max_count
	UNION ALL SELECT 'follow' as action, 1 as min_count, 5 as max_count
	UNION ALL SELECT 'follow' as action, 6 as min_count, 10 as max_count
	UNION ALL SELECT 'follow' as action, 11 as min_count, 9999 as max_count
), mst_user_action_bucket as (
	SELECT
	  u.user_id
	, u.register_date
	, a.action
	, a.min_count
	, a.max_count
	FROM mst_users as u
	CROSS JOIN mst_action_bucket as a		
), register_action_flag as (
	SELECT
	  m.user_id
	, m.action
	, m.min_count
	, m.max_count
	, COUNT(a.action) as action_count
	, CASE
		WHEN COUNT(a.action) BETWEEN m.min_count and m.max_count THEN 1
		ELSE 0
	  END as achieve
	, index_name
	, index_date_action
	FROM mst_user_action_bucket as m
	LEFT JOIN action_log as a
	on m.user_id = a.user_id
	AND CAST(a.stamp as date)		--스파크SQL의 경우
		BETWEEN CAST(m.register_date as date) AND date_add(CAST(m.register_date as date), 7)
		-- 하이브의 경우 JOIN 구문에 BETWEEN 구문을 사용할 수 없으므로 WHERE 구문을 사용해야함
	AND m.action = a.action
	LEFT JOIN user_action_flag as f
	ON m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
	GROUP BY
	  m.user_id
	, m.action
	, m.min_count
	, m.max_count
	, f.index_name
	, f.index_date_action
)
SELECT
  action
, CONCAT(CAST(min_count as string), '~', CAST(max_count as string)) as count_range
, SUM(CASE achieve WHEN 1 THEN 1 ELSE 0 END) as achieve
, index_name
, AVG(CASE achieve THEN 1 THEN 100.0 * index_date_action END) as achieve_index_rate
FROM register_action_flag
GROUP BY index_name, action, min_count, max_count
ORDER BY index_name, action, min_count;

12-19 등록일 다음날부터 7일 동안의 사용 일수와 28일 정착 플래그를 생성하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
), register_action_flag as (
	SELECT
	  m.user_id
	, COUNT(DISTINCT CAST(a.stamp as date)) as dt_count
	, f.index_name			--f넣는게 맞나?
	, f.index_date_action   --
	FROM mst_users as m
	LEFT JOIN action_log a
	on m.user_id = a.user_id
	and CAST(a.stamp as date)
		BETWEEN date_add(CAST(m.register_date as date), 1) AND date_add(CAST(m.register_date as date), 8)
	LEFT JOIN user_action_flag f
	on m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
	GROUP BY
	  m.user_id
	, f.index_name
	, f.index_date_action
)
SELECT *
FROM register_action_flag;

12-20 사용 일수에 따른 정착율을 집계하는 쿼리
WITH repeat_interval(index_name, interval_begin_date, interval_end_date) as (
			  SELECT '01 day repeat' as index_name, 1 as interval_begin_date, 1 as interval_end_date
	UNION ALL SELECT '02 day repeat' as index_name, 2 as interval_begin_date, 2 as interval_end_date
	UNION ALL SELECT '03 day repeat' as index_name, 3 as interval_begin_date, 3 as interval_end_date
	UNION ALL SELECT '04 day repeat' as index_name, 4 as interval_begin_date, 4 as interval_end_date
	UNION ALL SELECT '05 day repeat' as index_name, 5 as interval_begin_date, 5 as interval_end_date
	UNION ALL SELECT '06 day repeat' as index_name, 6 as interval_begin_date, 6 as interval_end_date
	UNION ALL SELECT '07 day repeat' as index_name, 7 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
	UNION ALL SELECT '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
	UNION ALL SELECT '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
	UNION ALL SELECT '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
), action_log_with_index_date as (
	SELECT
      u.user_id
	, u.register_date
	, CAST(a.stamp as date) as action_date
	, max(CAST(a.stamp as date)) OVER() as latest_date
	, r.index_name
	, date_add(CAST(u.register_date as date), r.interval_begin_date) as index_begin_date
	, date_add(CAST(u.register_date as date), r.interval_end_date) as index_end_date
	FROM mst_users as u
	LEFT OUTER JOIN action_log as a
	ON u.user_id = a.user_id
	CROSS JOIN repeat_interval as r
), user_action_flag as (
	SELECT
	  user_id
	, register_date
	, index_name
	, SIGN(
		SUM(
			CASE WHEN index_end_date <= latest_date THEN
			  CASE WHEN action_date BETWEEN index_begin_date and index_end_date THEN 1 ELSE 0 END
			END
		)
	) as index_date_action
	FROM action_log_with_index_date
	GROUP BY user_id, register_date, index_name, index_begin_date, index_end_date
), register_action_flag as (
	SELECT
	  m.user_id
	, COUNT(DISTINCT CAST(a.stamp as date)) as dt_count
	, index_name			-- f.??
	, index_date_action   	--
	FROM mst_users as m
	LEFT JOIN action_log a
	on m.user_id = a.user_id
	and CAST(a.stamp as date)
		BETWEEN date_add(CAST(m.register_date as date), 1) AND date_add(CAST(m.register_date as date), 8)
	LEFT JOIN user_action_flag f
	on m.user_id = f.user_id
	WHERE f.index_date_action IS NOT NULL
	GROUP BY
	  m.user_id
	, f.index_name
	, f.index_date_action
)
SELECT
  dt_count as dates
, COUNT(user_id) as users
, 100.0 * COUNT(user_id) / SUM(COUNT(user_id)) OVER() as user_ratio
, 100.0 * SUM(COUNT(user_id)) OVER(ORDER BY index_name, dt_count
								ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
  / SUM(COUNT(user_id)) OVER as cum_ratio
, SUM(index_date_action) as achieve_users
, AVG(100.0 * index_date_action) as achieve_ratio
FROM register_action_flag
GROUP BY index_name, dt_count
ORDER BY index_name, dt_count;

12-21 12개월 후 까지의 월을 도출하기 위한 보조테이블을 만드는 쿼리
WITH mst_intervals(interval_month) as (
			  SELECT  1 as interval_month
	UNION ALL SELECT  2 as interval_month
	UNION ALL SELECT  3 as interval_month
	UNION ALL SELECT  4 as interval_month
	UNION ALL SELECT  5 as interval_month
	UNION ALL SELECT  6 as interval_month
	UNION ALL SELECT  7 as interval_month
	UNION ALL SELECT  8 as interval_month
	UNION ALL SELECT  9 as interval_month
	UNION ALL SELECT 10 as interval_month
	UNION ALL SELECT 11 as interval_month
	UNION ALL SELECT 12 as interval_month
)
SELECT *
FROM mst_intervals;

12-22 등록 월에서 12개월 후 까지의 잔존율을 집계하는 쿼리
WITH mst_intervals(interval_month) as (
			  SELECT  1 as interval_month
	UNION ALL SELECT  2 as interval_month
	UNION ALL SELECT  3 as interval_month
	UNION ALL SELECT  4 as interval_month
	UNION ALL SELECT  5 as interval_month
	UNION ALL SELECT  6 as interval_month
	UNION ALL SELECT  7 as interval_month
	UNION ALL SELECT  8 as interval_month
	UNION ALL SELECT  9 as interval_month
	UNION ALL SELECT 10 as interval_month
	UNION ALL SELECT 11 as interval_month
	UNION ALL SELECT 12 as interval_month
), mst_users_with_index_month as (
	SELECT 
	  u.user_id
	, u.register_date
	, ADD_MONTHS(u.register_date, i.interval_month) as index_date
	, SUBSTR(u.register_date, 1, 7) as register_month
	, SUBSTR(CAST(ADD_MONTHS(u.register_date, i.interval_month) as string), 1,7)
	FROM mst_users as u
	CROSS JOIN mst_intervals as i
), action_log_in_month as (
	SELECT DISTINCT
	  user_id
	, SUBSTR(stamp, 1 ,7) as action_month
	FROM action_log
)
SELECT
  u.register_month
, u.index_month
, SUM(CASE WHEN a.action_month IS NOT NULL THEN 1 ELSE 0 END) as users
, AVG(CASE WHEN a.action_month IS NOT NULL THEN 100.0 ELSE 0.0 END) as retention_rate
FROM mst_users_with_index_month as u
LEFT JOIN action_log_in_month as a
on u.user_id = a.user_id
and u.index_month = a.action_month
GROUP BY u.register_month, u.index_month
ORDER BY u.register_month, u.index_month;

12-23 신규 사용자 수, 리피트 사용자 수, 컴백 사용자 수를 집계하는 쿼리
WITH monthly_user_action as (
	SELECT DISTINCT
	  u.user_id
	, SUBSTR(u.register_date, 1, 7) as register_month
	, SUBSTR(l.stamp, 1, 7) as action_month
	, SUBSTR(CAST(ADD_MONTHS(to_date(l.stamp), -1) as string), 1, 7) as action_month_priv
	FROM mst_users as u
	JOIN action_log as l
	on u.user_id = l.user_id
), monthly_user_with_type as (
	SELECT
	  action_month
	, user_id
	, CASE
		WHEN register_month = action_month THEN 'new_user'
		WHEN action_month_priv = LAG(action_month) OVER(PARTITION BY user_id ORDER BY action_month ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) THEN 'repeat_user'
	  ELSE 'come_back_user'
	END as c
	, action_month_priv
	FROM monthly_user_action
)
SELECT
  action_month
, COUNT(user_id) as mau
, COUNT(CASE WHEN c = 'new_user'		THEN 1 END) as new_user
, COUNT(CASE WHEN c = 'repeat_user'		THEN 1 END) as repeat_user
, COUNT(CASE WHEN c = 'come_back_user'	THEN 1 END) as come_back_user
FROM monthly_user_with_type
GROUP BY action_month
ORDER BY action_month;

12-24 리피트 사용자를 세분화해서 집계하는 쿼리
WITH monthly_user_action as (
	SELECT DISTINCT
	  u.user_id
	, SUBSTR(u.register_date, 1, 7) as register_month
	, SUBSTR(l.stamp, 1, 7) as action_month
	, SUBSTR(CAST(ADD_MONTHS(to_date(l.stamp), -1) as string), 1, 7) as action_month_priv
	FROM mst_users as u
	JOIN action_log as l
	on u.user_id = l.user_id
), monthly_user_with_type as (
	SELECT
	  action_month
	, user_id
	, CASE
		WHEN register_month = action_month THEN 'new_user'
		WHEN action_month_priv = LAG(action_month) OVER(PARTITION BY user_id ORDER BY action_month ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) THEN 'repeat_user'
	  ELSE 'come_back_user'
	END as c
	, action_month_priv
	FROM monthly_user_action
), monthly_users as (
	SELECT
	  m1.action_month
	, COUNT(m1.user_id) as mau
	, COUNT(CASE WHEN c = 'new_user'		THEN 1 END) as new_users
	, COUNT(CASE WHEN c = 'repeat_user'		THEN 1 END) as repeat_users
	, COUNT(CASE WHEN c = 'come_back_user'	THEN 1 END) as come_back_users
	, COUNT(CASE WHEN m1.c = 'repeat_user' AND m0.c = 'new_user'	THEN 1 END) as new_repeat_users
	, COUNT(CASE WHEN m1.c = 'repeat_user' AND m0.c = 'repeat_user'	THEN 1 END) as continuous_repeat_users
	, COUNT(CASE WHEN m1.c = 'repeat_user' AND m0.c = 'come_back_user'	THEN 1 END) as come_back_repeat_users
	FROM monthly_user_with_type as m0
	LEFT OUTER JOIN monthly_user_with_type as m1
	on m1.user_id = m0.user_id
	and m1.action_month_priv = m0.action_month
	GROUP BY m1.action_month
)
SELECT *
FROM monthly_users
ORDER BY action_month;


12-25 MAU 내역과 MAU 속성들의반복률을 계산하는 쿼리
WITH monthly_user_action as (
	SELECT DISTINCT
	  u.user_id
	, SUBSTR(u.register_date, 1, 7) as register_month
	, SUBSTR(l.stamp, 1, 7) as action_month
	, SUBSTR(CAST(ADD_MONTHS(to_date(l.stamp), -1) as string), 1, 7) as action_month_priv
	FROM mst_users as u
	JOIN action_log as l
	on u.user_id = l.user_id
), monthly_user_with_type as (
	SELECT
	  action_month
	, user_id
	, CASE
		WHEN register_month = action_month THEN 'new_user'
		WHEN action_month_priv = LAG(action_month) OVER(PARTITION BY user_id ORDER BY action_month ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) THEN 'repeat_user'
	  ELSE 'come_back_user'
	END as c
	, action_month_priv
	FROM monthly_user_action
), monthly_users as (
	SELECT
	  m1.action_month
	, COUNT(m1.user_id) as mau
	, COUNT(CASE WHEN c = 'new_user'		THEN 1 END) as new_users
	, COUNT(CASE WHEN c = 'repeat_user'		THEN 1 END) as repeat_users
	, COUNT(CASE WHEN c = 'come_back_user'	THEN 1 END) as come_back_users
	, COUNT(CASE WHEN m1.c = 'repeat_user' AND m0.c = 'new_user'	THEN 1 END) as new_repeat_users
	, COUNT(CASE WHEN m1.c = 'repeat_user' AND m0.c = 'repeat_user'	THEN 1 END) as continuous_repeat_users
	, COUNT(CASE WHEN m1.c = 'repeat_user' AND m0.c = 'come_back_user'	THEN 1 END) as come_back_repeat_users
	FROM monthly_user_with_type as m0
	LEFT OUTER JOIN monthly_user_with_type as m1
	on m1.user_id = m0.user_id
	and m1.action_month_priv = m0.action_month
	GROUP BY m1.action_month
)
SELECT
  action_month
, mau
, new_users
, repeat_users
, come_back_users
, new_repeat_users
, continuous_repeat_users
, come_back_repeat_users
, 100.0 * new_repeat_users / NULLIF(LAG(new_users) OVER(ORDER BY action_month), 0) as priv_new_repeat_ratio
, 100.0 * new_repeat_users / NULLIF(LAG(repeat_users) OVER(ORDER BY action_month), 0) as priv_continuous_repeat_ratio
, 100.0 * new_repeat_users / NULLIF(LAG(come_back_users) OVER(ORDER BY action_month), 0) as priv_come_back_repeat_ratio
FROM monthly_users
ORDER BY actions_month;

12-26 성장지수 산출을 위해 사용자 상태를 집계하는 쿼리
WITH unique_action_log as (
	SELECT DISTINCT
	  user_id
	, SUBSTR(stamp, 1, 10) as action_date
	FROM action_log
), mst_calendar as (
			  SELECT '2016-10-01' as dt
	UNION ALL SELECT '2016-10-02' as dt
	UNION ALL SELECT '2016-10-03' as dt
	UNION ALL SELECT '2016-10-04' as dt
	UNION ALL SELECT '2016-10-05' as dt
	UNION ALL SELECT '2016-10-06' as dt
	UNION ALL SELECT '2016-10-07' as dt
	UNION ALL SELECT '2016-10-08' as dt
	UNION ALL SELECT '2016-10-09' as dt
	UNION ALL SELECT '2016-10-10' as dt
	UNION ALL SELECT '2016-10-11' as dt
	UNION ALL SELECT '2016-10-12' as dt
	UNION ALL SELECT '2016-10-13' as dt
	UNION ALL SELECT '2016-10-14' as dt
	UNION ALL SELECT '2016-10-15' as dt
	UNION ALL SELECT '2016-10-16' as dt
	UNION ALL SELECT '2016-10-17' as dt
	UNION ALL SELECT '2016-10-18' as dt
	UNION ALL SELECT '2016-10-19' as dt
	UNION ALL SELECT '2016-10-20' as dt
	UNION ALL SELECT '2016-10-21' as dt
	UNION ALL SELECT '2016-10-22' as dt
	UNION ALL SELECT '2016-10-23' as dt
	UNION ALL SELECT '2016-10-24' as dt
	UNION ALL SELECT '2016-10-25' as dt
	UNION ALL SELECT '2016-10-26' as dt
	UNION ALL SELECT '2016-10-27' as dt
	UNION ALL SELECT '2016-10-28' as dt
	UNION ALL SELECT '2016-10-29' as dt
	UNION ALL SELECT '2016-10-30' as dt
	UNION ALL SELECT '2016-10-31' as dt
	UNION ALL SELECT '2016-10-01' as dt
	UNION ALL SELECT '2016-10-02' as dt
	UNION ALL SELECT '2016-10-03' as dt
	UNION ALL SELECT '2016-10-04' as dt
), target_date_with_user as (
	SELECT
	  c.dt_as target_date
	u.ser_id
	u.register_date
	u.withdraw_date
	FROM mst_users as u
	CROSS JOIN mst_calendar as c
), user_status_log as (
	SELECT
	  u.target_date
	, u.user_id
	, u.register_date
	, u.withdraw_date
	, a.action_date
	, CASE WHEN u.register_date = a.action_date THEN 1 ELSE 0 END as is_new
	, CASE WHEN u.withdraw_date = a.action_date THEN 1 ELSE 0 END as is_exit
	, CASE WHEN u.target_date = a.action_date THEN 1 ELSE 0 END as is_access
	, LAG(CASE WHEN u.target_date = a.action_date THEN 1 ELSE 0 END) OVER(PARTITION BY u.user_id ORDER BY u.target_date
																		ROWS 1 PRECEDING AND 1 PRECEDING) as was_access
	FROM target_date_with_user as u
	LEFT JOIN unique_action_log as a
	on u.user_id = a.user_id
	and u.target_date = a.action_date
	WHERE u.register_date <= u.target_date
	and ( u.withdraw_date IS NULL or u.target_date <= u.withdraw_date)
)
SELECT
  target_date
, user_id
, is_new
, is_exit
, is_access
, was_access
FROM user_status_log;


12-27 매일의 성장지수를 계산하는 쿼리
WITH unique_action_log as (
	SELECT DISTINCT
	  user_id
	, SUBSTR(stamp, 1, 10) as action_date
	FROM action_log
), mst_calendar as (
			  SELECT '2016-10-01' as dt
	UNION ALL SELECT '2016-10-02' as dt
	UNION ALL SELECT '2016-10-03' as dt
	UNION ALL SELECT '2016-10-04' as dt
	UNION ALL SELECT '2016-10-05' as dt
	UNION ALL SELECT '2016-10-06' as dt
	UNION ALL SELECT '2016-10-07' as dt
	UNION ALL SELECT '2016-10-08' as dt
	UNION ALL SELECT '2016-10-09' as dt
	UNION ALL SELECT '2016-10-10' as dt
	UNION ALL SELECT '2016-10-11' as dt
	UNION ALL SELECT '2016-10-12' as dt
	UNION ALL SELECT '2016-10-13' as dt
	UNION ALL SELECT '2016-10-14' as dt
	UNION ALL SELECT '2016-10-15' as dt
	UNION ALL SELECT '2016-10-16' as dt
	UNION ALL SELECT '2016-10-17' as dt
	UNION ALL SELECT '2016-10-18' as dt
	UNION ALL SELECT '2016-10-19' as dt
	UNION ALL SELECT '2016-10-20' as dt
	UNION ALL SELECT '2016-10-21' as dt
	UNION ALL SELECT '2016-10-22' as dt
	UNION ALL SELECT '2016-10-23' as dt
	UNION ALL SELECT '2016-10-24' as dt
	UNION ALL SELECT '2016-10-25' as dt
	UNION ALL SELECT '2016-10-26' as dt
	UNION ALL SELECT '2016-10-27' as dt
	UNION ALL SELECT '2016-10-28' as dt
	UNION ALL SELECT '2016-10-29' as dt
	UNION ALL SELECT '2016-10-30' as dt
	UNION ALL SELECT '2016-10-31' as dt
	UNION ALL SELECT '2016-10-01' as dt
	UNION ALL SELECT '2016-10-02' as dt
	UNION ALL SELECT '2016-10-03' as dt
	UNION ALL SELECT '2016-10-04' as dt
), target_date_with_user as (
	SELECT
	  c.dt_as target_date
	u.ser_id
	u.register_date
	u.withdraw_date
	FROM mst_users as u
	CROSS JOIN mst_calendar as c
), user_status_log as (
	SELECT
	  u.target_date
	, u.user_id
	, u.register_date
	, u.withdraw_date
	, a.action_date
	, CASE WHEN u.register_date = a.action_date THEN 1 ELSE 0 END as is_new
	, CASE WHEN u.withdraw_date = a.action_date THEN 1 ELSE 0 END as is_exit
	, CASE WHEN u.target_date = a.action_date THEN 1 ELSE 0 END as is_access
	, LAG(CASE WHEN u.target_date = a.action_date THEN 1 ELSE 0 END) OVER(PARTITION BY u.user_id ORDER BY u.target_date
																		ROWS 1 PRECEDING AND 1 PRECEDING) as was_access
	FROM target_date_with_user as u
	LEFT JOIN unique_action_log as a
	on u.user_id = a.user_id
	and u.target_date = a.action_date
	WHERE u.register_date <= u.target_date
	and ( u.withdraw_date IS NULL or u.target_date <= u.withdraw_date)
), user_growth_index as (
	SELECT *
	, CASE
		WHEN is_new + is_exit = 1 THEN
		  CASE
			WHEN is_new = 1 THEN 'signup'
			WHEN is_exit = 1 THEN 'exit'
		  END
		WHEN is_new + is_exit = 0 THEN
		  CASE
		    WHEN was_access = 0 and is_access = 1 THEN 'reactivation'
			WHEN was_access = 1 and is_access = 0 THEN 'deactivation'
		  END
		END as user_growth_index
	FROM user_status_log
)
SELECT
  target_date
, sum(CASE growth_index WHEN 'signup'		THEN 1 ELSE 0 END) as signup
, sum(CASE growth_index WHEN 'reactivation'		THEN 1 ELSE 0 END) as reactivation
, sum(CASE growth_index WHEN 'deactivation'		THEN 1 ELSE 0 END) as deactivation
, sum(CASE growth_index WHEN 'exit'		THEN 1 ELSE 0 END) as exit
, sum(CASE growth_index
		WHEN 'signup'	THEN 1
		WHEN '' THEN 1
		WHEN '' THEN -1
		WHEN '' THEN -1
		ELSE 0
	  END) as growth_index
FROM user_growth_index
GROUP BY target_date
ORDER BY target_date;

같은 레코드에 있는 두개의 날짜로 계산할 경우
13-1 신청일과 숙박일의 리드타임을 계산하는 쿼리
WITH reservations(reservation_id, register_date, visit_date, days) as (
			  SELECT 1 as reservation_id, date '2016-09-01' as register_date, date '2016-10-01' as visit_date, 3 as days
	UNION ALL SELECT 2 as reservation_id, date '2016-09-20' as register_date, date '2016-10-01' as visit_date, 2 as days
	UNION ALL SELECT 3 as reservation_id, date '2016-09-30' as register_date, date '2016-11-20' as visit_date, 2 as days
	UNION ALL SELECT 4 as reservation_id, date '2016-10-01' as register_date, date '2017-01-03' as visit_date, 2 as days
	UNION ALL SELECT 5 as reservation_id, date '2016-11-01' as register_date, date '2016-12-28' as visit_date, 3 as days
)
SELECT
  reservation_id
, register_date
, visit_date
, datediff(to_date(visit_date), to_date(register_date)) as lead_time
FROM reservations;

여러 테이블에 있는 여러 개의 날짜로 계산할 경우
13-2 각 단계에서의 리드 타임과 토탈 리드 타임을 계산하는 쿼리
WITH requests(user_id, product_id, request_date) as (
			  SELECT 'U001' as user_id, '1' as product_id, date '2016-09-01' as request_date
	UNION ALL SELECT 'U002' as user_id, '2' as product_id, date '2016-09-20' as request_date
	UNION ALL SELECT 'U003' as user_id, '3' as product_id, date '2016-09-30' as request_date
	UNION ALL SELECT 'U004' as user_id, '4' as product_id, date '2016-10-01' as request_date
	UNION ALL SELECT 'U005' as user_id, '5' as product_id, date '2016-11-01' as request_date
), estimates(user_id, product_id, estimate_date) as (
			  SELECT 'U002' as user_id, '2' as product_id, date '2016-09-21' as estimate_date
	UNION ALL SELECT 'U003' as user_id, '3' as product_id, date '2016-10-15' as estimate_date
	UNION ALL SELECT 'U004' as user_id, '4' as product_id, date '2016-10-15' as estimate_date
	UNION ALL SELECT 'U005' as user_id, '5' as product_id, date '2016-12-01' as estimate_date
), orders(user_id, product_id, order_date) as (
			  SELECT 'U002' as user_id, '2' as product_id, date '2016-10-01' as order_date
	UNION ALL SELECT 'U005' as user_id, '5' as product_id, date '2016-12-05' as order_date
)
SELECT
  r.user_id
, r.product_id
, datediff(to_date(e.estimate_date), to_date(r.request_date)) as estimate_lead_time
, datediff(to_date(e.order_date), to_date(r.estimate_date)) as order_lead_time
, datediff(to_date(e.order_date), to_date(r.request_date)) as total_lead_time
FROM requests as r
LEFT OUTER JOIN estimates as e
ON r.user_id = e.user_id
AND r.product_id = e.product_id
LEFT OUTER JOIN orders as o
ON r.user_id = o.user_id
AND r.product_id = o.product_id;

같은 테이블의 다른 레코드에 있는 날짜로 계산할 경우
13-3 이전 구매일로부터의 일수를 계산하는 쿼리
WITH purchase_log(user_id, product_id, order_date) as (
			  SELECT 'U001' as user_id, '1' as product_id, date '2016-09-01' as request_date
	UNION ALL SELECT 'U001' as user_id, '2' as product_id, date '2016-09-20' as request_date
	UNION ALL SELECT 'U002' as user_id, '3' as product_id, date '2016-09-30' as request_date
	UNION ALL SELECT 'U001' as user_id, '4' as product_id, date '2016-10-01' as request_date
	UNION ALL SELECT 'U002' as user_id, '5' as product_id, date '2016-11-01' as request_date
)
SELECT
  user_id
, purchase_date
, datediff(to_date(purchase_date), LAG(to_date(purchase_date))
		over(PARTITION BY user_id ORDER BY purchase_date
		ROWS BETWEEN 1 PRECEDING and 1 PRECEDING)) as lead_time
FROM purchase_log;

카트 추가후에 구매했는지 파악하기
13-4 상품들이 카트에 추가된 시각과 구매되니 시각을 산출하는 쿼리
WITH row_action_log as (
	SELECT
	  dt
	, user_id
	, action
	, product_id
	, stamp
	FROM action_log
	LATERAL VIEW explode(split(products, ',')) e as product_id  --CROSS JOIN unnest(split(products,',')) as asdf <빅쿼리
), action_time_stats as (
	SELECT
	  user_id
	, product_id
	, min(CASE action when 'add_cart' THEN dt END) as dt
	, min(CASE action when 'add_cart' THEN stamp END) as add_cart_time
	, min(CASE action when 'purchase' THEN stamp END) as purchase_time
	, (min(CASE action when 'purchase' THEN unix_timestamp(stamp) END) - min(CASE action when 'add_cart' THEN unix_timestamp(stamp) END)) as lead_time
	FROM row_action_log
	GROUP BY user_id, product_id
)
SELECT
  user_id
, product_id
, add_cart_time
, purchase_time
, lead_time
FROM action_time_stats
ORDER BY user_id, product_id;

13-5 카트 추가 후 n 시간 이내 구매된 상품 수와 구매율을 집계하는 쿼리
WITH row_action_log as (
	SELECT
	  dt
	, user_id
	, action
	, product_id
	, stamp
	FROM action_log
	LATERAL VIEW explode(split(products, ',')) e as product_id
), action_time_stats as (
	SELECT
	  user_id
	, product_id
	, min(CASE action when 'add_cart' THEN dt END) as dt
	, min(CASE action when 'add_cart' THEN stamp END) as add_cart_time
	, min(CASE action when 'purchase' THEN stamp END) as purchase_time
	, (min(CASE action when 'purchase' THEN unix_timestamp(stamp) END) - min(CASE action when 'add_cart' THEN unix_timestamp(stamp) END)) as lead_time
	FROM row_action_log
	GROUP BY user_id, product_id
), purchase_lead_time_flag as (
	  user_id
	, product_id
	, dt
	, CASE WHEN lead_time <=  1 * 60 * 60 THEN 1 ELSE 0 END as purchase_1_hour
	, CASE WHEN lead_time <=  6 * 60 * 60 THEN 1 ELSE 0 END as purchase_6_hour
	, CASE WHEN lead_time <= 24 * 60 * 60 THEN 1 ELSE 0 END as purchase_24_hour
	, CASE WHEN lead_time <= 48 * 60 * 60 THEN 1 ELSE 0 END as purchase_48_hour
	, CASE WHEN lead_time IS NULL OR NOT (lead_time <= 48 * 60 * 60) THEN 1 ELSE 0 END as not_purchase
	FROM action_time_stats
)
SELECT
  dt
, COUNT(*) as add_cart
, SUM(purchase_1_hour) as purchase_1_hour
, AVG(purchase_1_hour) as purchase_1_hour_rate
, SUM(purchase_6_hour) as purchase_6_hour
, AVG(purchase_6_hour) as purchase_6_hour_rate
, SUM(purchase_24_hour) as purchase_24_hour
, AVG(purchase_24_hour) as purchase_24_hour_rate
, SUM(purchase_48_hour) as purchase_48_hour
, AVG(purchase_48_hour) as purchase_48_hour_rate
, SUM(not_purchase) as not_purchase
, AVG(not_purchase) as not_purchase_rate
FROM purchase_lead_time_flag
GROUP BY dt;

등록으로부터의 매출을 날짜별로 집계하기
13-6 사용자들의 등록일부터 경과한 일수별 매출을 계산하는 쿼리
WITH index_intervals(index_name, interval_begin_date, interval_end_date) as (
		  	  SELECT '30 day sales amount' as index_name, 0 as interval_begin_date, 30 as interval_end_date
	UNION ALL SELECT '45 day sales amount' as index_name, 0 as interval_begin_date, 45 as interval_end_date
	UNION ALL SELECT '60 day sales amount' as index_name, 0 as interval_begin_date, 60 as interval_end_date
), mst_users_with_base_date as (
	SELECT
	  user_id
	, register_date as base_date      --< 기준일을 등록일 사용하기 first_purchase_date as base_date 처음 구매한날을 기준으로 하고 싶다면 다음과 같이 사용
	FROM mst_users
), purchase_log_with_index_date as (
	SELECT
	  u.user_id
	, u.base_date
	, CAST(p.stamp as date) as action_date
	, MAX(CAST(p.stamp as date)) OVER() as latest_date
	, SUBSTR(p.stamp, 1, 7) as month
	, i.index_name
	, date_add(CAST(u.base_date as date), r.interval_begin_date) as  index_begin_date
	, date_add(CAST(u.base_date as date), r.interval_end_date) as  interval_end_date
	, p.amount
	FROM mst_users_with_base_date as u
	LEFT OUTER JOIN action_log as p
	ON u.user_id = p.user_id
	AND p.action = 'purchase'
	CROSS JOIN index_intervals as i
)
SELECT *
FROM purchase_log_with_index_date;


13-7 월별 등록자수와 경과일수별 매출을 집계하는 쿼리
WITH index_intervals(index_name, interval_begin_date, interval_end_date) as (
		  	  SELECT '30 day sales amount' as index_name, 0 as interval_begin_date, 30 as interval_end_date
	UNION ALL SELECT '45 day sales amount' as index_name, 0 as interval_begin_date, 45 as interval_end_date
	UNION ALL SELECT '60 day sales amount' as index_name, 0 as interval_begin_date, 60 as interval_end_date
), mst_users_with_base_date as (
	SELECT
	  user_id
	, register_date as base_date      --< 기준일을 등록일 사용하기 first_purchase_date as base_date 처음 구매한날을 기준으로 하고 싶다면 다음과 같이 사용
	FROM mst_users
), purchase_log_with_index_date as (
	SELECT
	  u.user_id
	, u.base_date
	, CAST(p.stamp as date) as action_date
	, MAX(CAST(p.stamp as date)) OVER() as latest_date
	, SUBSTR(p.stamp, 1, 7) as month
	, i.index_name
	, date_add(CAST(u.base_date as date), r.interval_begin_date) as  index_begin_date
	, date_add(CAST(u.base_date as date), r.interval_end_date) as  interval_end_date
	, p.amount
	FROM mst_users_with_base_date as u
	LEFT OUTER JOIN action_log as p
	ON u.user_id = p.user_id
	AND p.action = 'purchase'
	CROSS JOIN index_intervals as i
), user_purchase_amount as (
	SELECT
	  user_id
	, month
	, index_name
	, SUM(
		CASE WHEN index_end_date <= latest_date THEN
		  CASE
		    WHEN action_date BETWEEN index_begin_date AND index_end_date THEN amount
			ELSE 0
		  END
		END) as index_date_amount
	FROM purchase_log_with_index_date
	GROUP BY user_id, month, index_name, index_begin_date, index_end_date
)
SELECT
  month
, COUNT(index_date_amount) as users
, index_name
, COUNT(CASE WHEN index_date_amount > 0 THEN user_id END) as purchase_uu
, SUM(index_date_amount) as total_amount
, AVG(index_date_amount) as avg_amount
FROM user_purchase_amount
GROUP BY month, index_name
ORDER BY month, index_name;


14-1 날짜별 접근데이터를 집계하는 쿼리
SELECT
  SUBSTR(stamp, 1, 10) as dt
, COUNT(DISTINCT long_session) as access_users
, COUNT(DISTINCT short_session) as access_count
, COUNT(*) as page_view
, 1.0 * COUNT(*) / CASE WHEN COUNT(DISTINCT long_session) <> 0 THEN COUNT(DISTINCT long_session) END as pv_per_user
FROM access_log
GROUP BY SUBSTR(stamp, 1, 10)
ORDER BY dt;

14-2 URL별로 집계하는 쿼리
SELECT
  url
, COUNT(DISTINCT long_session) as access_users
, COUNT(DISTINCT short_session) as access_count
, COUNT(*) as page_view
FROM access_log
GROUP BY url;

14-3 경로별로 집계하는 쿼리
WITH access_log_with_path as (
	SELECT *
	, parse_url(url, 'PATH') as url_path
	FROM access_log
)
SELECT
  url_path
, COUNT(DISTINCT long_session) as access_users
, COUNT(DISTINCT short_session) as access_count
, COUNT(*) as page_view
FROM access_log_with_path
GROUP BY url_path;

14-4 URL 에 의미를 부여햇 집계하는 쿼리
WITH access_log_with_path as (
	SELECT *
	, parse_url(url, 'PATH') as url_path
	FROM access_log
), access_log_with_split_path as (
	SELECT *
	, split(url_path, '/')[1] as path1
	, split(url_path, '/')[2] as path2
	FROM access_log_with_path
), access_log_with_page_name as (
	SELECT *
	, CASE
		WHEN path1 = 'list' THEN
		  CASE
		    WHEN path2 = 'newly' THEN 'newly_list'
			ELSE 'category_list'
		  END
		ELSE url_path
	  END as page_name
	FROM access_log_with_split_path
)
SELECT
  page_name
, COUNT(DISTINCT long_session) as access_users
, COUNT(DISTINCT short_session) as access_count
, COUNT(*) as page_view
FROM access_log_with_page_name
GROUP BY page_name
ORDER BY page_name;

14-5 유입원별로 방문 횟수를 집계하는 쿼리
WITH access_log_with_parse_info as (
	SELECT *
	, parse_url(url, 'HOST') as url_domain
	, parse_url(url, 'QUERY', 'utm_source') as url_utm_source
	, parse_url(url, 'QUERY', 'utm_medium') as url_utm_medium
	, parse_url(referrer, 'HOST') as referrer_domain
	FROM access_log
), access_log_with_via_info as (
	SELECT *
	, ROW_NUMBER() OVER(ORDER BY stamp) as log_id
	, CASE
		WHEN url_utm_source <> '' AND url_utm_medium <> ''
		  THEN concat(url_utm_source, '-', url_utm_medium)
		WHEN referrer_domain IN ('search.yahoo.co.jp', 'www.google.co.jp') THEN 'search'
		WHEN referrer_domain IN ('twitter.com', 'www.facebook.com') THEN 'social'
		ELSE 'other'
	  END as via
	FROM access_log_with_parse_info
	WHERE COALESCE(referrer_domain, '') NOT IN ('', url_domain)
)
SELECT via, COUNT(1) as access_count
FROM access_log_with_via_info
GROUP BY via
ORDER BY access_count DESC;



















