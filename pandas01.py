import pandas as pd
df_exam = pd.read_excel("./data/excel_exam.xlsx")

df_exam

df1 = pd.DataFrame({'a' : [1, 2, 3],
 'b' : [4, 5, 6]})
df1


x =[1,2,3]
print(sum(x))



import seaborn as sns
var = ['a','b','c','d']
var
#sns.countplot(x=var)



df = sns.load_dataset('titanic')
df

# 막대그래프
#sns.countplot(data=df, x='sex')
#sns.countplot(data=df, x='class')
# hue='alive' 별 색 표현
#sns.countplot(data=df, x='class', hue='alive')

# 함수사용법이 궁금할때
# sns.countplot?

# import sklearn.metrics
# sklearn.metrics.accuracy_score()
# sklearn -> scikit-learn  로 바뀜

# 샘플 데이터셋 불러오기
import pydataset
pydataset.data()
df = pydataset.data('mtcars')
df


df = pd.DataFrame({'name':['김지훈','이유진','박동현','김민지'],
                   'english':[90,80,60,70],
                   'math':[50,60,100,20]})
#전체보기
df
# 열출력
df['english']
# 열 계산하기
sum(df['english'])
sum(df['math'])/4 #수학점수 평균

#84p
df = pd.DataFrame({"제품":["사과","딸기","수박"],
                   "가격":[1800,1500,3000],
                   "판매량":[24,38,13]})
df
sum(df['가격']/3)
sum(df["판매량"]/len(df['판매량']))

# 엑셀파일 불러오기
df_exam = pd.read_excel('./data/excel_exam.xlsx')
df_exam

sum(df_exam['english']) / len(df_exam)
# 엑셀파일에 헤더가 없으면 header = None으로
#df_exam_novar = pd.read_excel('excel_exam_novar.xlsx', header = None)

# Sheet2 시트의 데이터 불러오기
#df_exam = pd.read_excel('excel_exam.xlsx', sheet_name = 'Sheet2')
# 세 번째 시트의 데이터 불러오기
#df_exam = pd.read_excel('excel_exam.xlsx', sheet_name = 2)

# csv파일 불러오기
df_csv_exam = pd.read_csv("./data/exam.csv")
df_csv_exam

df_midterm = pd.DataFrame({"english":[90,80,60,70],
                           "math":[50,60,100,20],
                           "nclass":[1,1,2,2]})
df_midterm


df_midterm.to_csv("./data/output_newdata.csv")
# 인덱스번호 제외하고 저장하기
df_midterm.to_csv("./data/output_newdata2.csv", index=False)



df_exam.head()
df_exam.head(10)
df_exam.tail(4)
# 행,열 개수 구하기 학생20명 5개 변수
df_exam.shape
# 컬럼명/Dtype 스키마 타입/non-null count 확인가능
df_exam.info()
# df.describe().show()와 동일 산술적 통계 구하기 민,맥스,평균
df_exam.describe()

mpg = pd.read_csv("./data/mpg.csv")

mpg.head()
# 산술적통계 / 문자변수 용약 통계량 함께 출력
mpg.describe(include='all')

# sum() # 내장함수
# pd.read_csv # 패키지함수
# df.head() #메서드

var = [1,2,3]
type(mpg)
type(var)



df_raw = pd.DataFrame({"var1":[1,2,1],
                       "var2":[2,3,2]})
df_raw

#컬럼명 바꾸기
df_new = df_raw.copy()
df_new = df_new.rename(columns={"var1":"v1"})

mpg2 = mpg.copy()
mpg2 = mpg2.rename(columns={'hwy':'highway','cty':'city'})


df = pd.DataFrame({'var1' : [4, 3, 8],
 'var2' : [2, 6, 1]})

# withColumn 새로운 변수 만들기
df['var_sum'] = df['var1']+df['var2']
df['var_mean'] = (df['var1']+df['var2'])/2

mpg2['total'] = (mpg2['city']+mpg2['highway'])/2
mpg2['total'].mean()

mpg2['total'].describe()
#히스토그램
mpg2['total'].plot.hist()



import numpy as np
#where 는 삼항연산자??  mpg2['total']>=20?'pass':'fail'
mpg2['test'] = np.where(mpg2['total']>=20, 'pass','fail')

# where이용한 연비 합격 빈도표 만들기
mpg2['test'].value_counts()


count_test = mpg2['test'].value_counts()
type(count_test) # pandas.core.series.Series
count_test.plot.bar()
# 그래프에서 축 이름 수평으로 만들기
count_test.plot.bar(rot=0)


mpg2['grade'] = np.where(mpg2['total']>=30, 'A', np.where(mpg2['total']>=20,'B','C'))
# 연비 등급 빈도 만들기
count_grade = mpg2['grade'].value_counts()
count_grade
# 오름차순 정렬
count_grade = mpg2['grade'].value_counts().sort_index()
count_grade


count_grade.plot.bar(rot = 0)

mpg2['grade'] = np.where(mpg2['total']>=30, 'A',
                np.where(mpg2['total']>=25, 'B',
                np.where(mpg2['total']>=20, 'C', 'D'
                )))


mpg2['size'] = np.where































































