-- 날짜 포맷 변경 (YYYY-MM-DD)
SELECT
  TO_CHAR (SYSDATE, 'YYYYMMDD') --20200723
,
  TO_CHAR (SYSDATE, 'YYYY/MM/DD') --2020/07/23
,
  TO_CHAR (SYSDATE, 'YYYY-MM-DD') --2020-07-23
,
  TO_CHAR (SYSDATE, 'YYYY-MM-DD HH24:MI:SS') --2020-07-23 11:10:52
FROM
  dual
  -- YYYY: 년, MM: 월, DD: 일, HH24: 24시간, HH: 12시간, MI: 분, SS:초
  --소수점 변경
SELECT
  TO_CHAR (123.456, 'FM990.999') --123.456
,
  TO_CHAR (1234.56, 'FM9990.99') --1234.56
,
  TO_CHAR (0.12345, 'FM9990.99') --0.12
FROM
  dual
  -- FM: 문자열의 공백제거
  -- 숫자의 최대 길이만큰 9999... 형식을 지정한다. (9 : 값이 없으면 표시안함, 0: 값이 없으면 "0"으로 처리)
  -- 정수은 지정한 형식보다 값의 길이가 길면 오류, 소수 지정한 길이보다 길면 반올림
  -- 숫자의 천 단위 콤마 찍기
SELECT
  TO_CHAR (123467, 'FM999,999') --123,467
,
  TO_CHAR (123467890, 'FM999,999,999') --123,467,890
,
  TO_CHAR (123467, 'FML999,999') --￦123,467
FROM
  dual
  -- 숫자의 최대 길이만큰 9999... 형식을 지정한다.
  -- 지정한 길이 만큼 "0"으로 채우기
SELECT
  TO_CHAR (123) --123
,
  TO_CHAR (123, 'FM00000') --00123
FROM
  dual
  -- 날짜의 "0" 없애기
SELECT
  TO_CHAR (SYSDATE, 'MM/DD') --07/03
,
  TO_CHAR (SYSDATE, 'FMMM/DD') --7/3
FROM
  dual
  -- 임의의 구분자로 날짜 형식 만들기
SELECT
  TO_CHAR (SYSDATE, '""YYYY"년 "MM"월 "DD"일"') --2020년 07월 23일
,
  TO_CHAR (SYSDATE, '""HH24"시 "MI"분 "SS"초"') --11시 12분 20초
FROM
  dual
  -- 시간의 오전, 오후 값 반환
SELECT
  TO_CHAR (SYSDATE, 'AM') --오전
,
  TO_CHAR (SYSDATE, 'AM HH:MI:SS') --오전 11:44:31
,
  TO_CHAR (SYSDATE, 'YYYY-MM-DD AMHH:MI:SS') --2020-07-23 오전11:44:31
FROM
  dual
  -- 오라클 언어 설정에 따라서 오전, 오후 또는 AM, PM으로 반환됨
  -- 날짜의 요일 반환
SELECT
  TO_CHAR (SYSDATE, 'D') --5 : 1(일)~7(토)
,
  TO_CHAR (SYSDATE, 'DY') --목
,
  TO_CHAR (SYSDATE, 'DAY') --목요일
FROM
  dual
  -- 오라클 언어 설정에 따라서 한글 또는 영문으로 반환됨
  -- 1년기준 몇일, 몇주, 분기 반환
SELECT
  TO_CHAR (SYSDATE, 'DDD') --365일 기준 205일
,
  TO_CHAR (SYSDATE, 'WW') --1년 기준 30주
,
  TO_CHAR (SYSDATE, 'Q') --3분기
FROM
  dual
  -- 간편한 날짜 변환
SELECT
  TO_CHAR (SYSDATE, 'MON') --7월
,
  TO_CHAR (SYSDATE, 'DL') --2020년 7월 23일 목요일
FROM
  dual
  -- 오라클 언어 설정에 따라서 한글 또는 영문으로 반환됨
  DATE_FORMAT (날짜, 'FORMAT') -- 날짜를 해당 포멧으로 변환
  DATE (날짜) -- 날짜를 '연도-월-일'로 변환
  YEAR (날짜) -- 날짜의 연도 반환
  MONTH (날짜) -- 날짜의 월 반환
  --날짜→ 문자
  CONVERT(포맷 (길이), 날짜, 변환 형식)
SELECT
  CONVERT(VARCHAR, GETDATE (), 120)
  --  결과 : 2019-09-15 15:30:11
  --120은 YYYY-MM-DD HH24:MI:SS 형식이다
  --문자 → 날짜
  CONVERT(날짜 형식, 문자)
SELECT
  CONVERT(DATE, '2008-01-01')
  --  2008-01-01 문자가 날짜로 변경된다
SELECT
  CONVERT(DATETIME, '2008-01-01 15:14:13')
  --  2008-01-01 15:14:13 문자가 날짜/시간으로 변경된다
  case
    when 7 = count(*) over (
      order by
        dt rows between 6 preceding
        and current row
    ) then avg(sum(purchase_amount)) over (
      order by
        dt rows between 6 preceding
        and current row
    )
  end