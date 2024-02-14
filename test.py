
# import pandas as pd
# import sys
# from operator import add
# from pyspark.sql import SparkSession, Row

# spark = SparkSession\
#    .builder\
#    .appName("PythonWordCount")\
#    .getOrCreate()

# data = [Row(col1='pyspark and spark', col2=1), Row(col1='pyspark', col2=2), Row(col1='spark vs hadoop', col2=2), Row(col1='spark', col2=2), Row(col1='hadoop', col2=2)]
# df = spark.createDataFrame(data)
# lines = df.rdd.map(lambda r: r[0])

# counters = lines.flatMap(lambda x: x.split(' ')) \
#    .map(lambda x: (x, 1)) \
#    .reduceByKey(add)

# output = counters.collect()
# sortedCollection = sorted(output, key = lambda r: r[1], reverse = True)

# for (word, count) in sortedCollection:
#    print("%s: %i" % (word, count))


list(filter(lambda x:x>0, [1, -2, 3, -5, 8, -3]))


import os
def search(dirname):
   filenames = os.listdir(dirname)
   for filename in filenames:
      full_filename = os.path.join(dirname, filename)
      print(full_filename)

data = """
홍길동의 주민 등록 번호는 800905-1049118 입니다. 
그리고 고길동의 주민 등록 번호는 700905-1059119 입니다.
그렇다면 누가 형님일까요?
"""
result = []
for line in data.split("\n"):
   word_result = []
   for word in line.split(" "):
      if len(word) == 14 and word[:6].isdigit() and word[7:].isdigit():
         word = word[:6] + "-" + "*******"
      word_result.append(word)
   result.append(" ".join(word_result))
print("\n".join(result))

import re
pat = re.compile("(\d{6})[-]\d{7}")
print(pat.sub("\g<1>-*******", data))


import datetime

day1 = datetime.date(2019, 12, 14)
day2 = datetime.date(2021, 6, 5)
diff = day2-day1
diff
diff.days


day = datetime.date(2019, 12, 14)
time = datetime.time(10, 14, 50)
dt = datetime.datetime.combine(day, time)
dt


today = datetime.date.today()


import textwrap

textwrap.shorten("Life is too short, you need python", width=15)



diffday = datetime.timedelta(days=100)



import calendar
calendar.isleap(0)

from collections import deque

a = [1,2,3,4,5]
q = deque(a)

from collections import namedtuple


data = [
 ('홍길동', 23, '01099990001'), 
 ('김철수', 31, '01099991002'), 
 ('이영희', 29, '01099992003'),
]

Employee = namedtuple('Employee','name,age,cellphone')


# data = [Employee(emp[0],emp[1], emp[2]) for emp in data]
data = [Employee._make(emp) for emp in data]


from collections import Counter

import re
data = """
산에는 꽃 피네
꽃이 피네
갈 봄 여름 없이
꽃이 피네
산에
산에
피는 꽃은
저만치 혼자서 피어 있네
산에서 우는 작은 새여
꽃이 좋아
산에서
사노라네
산에는 꽃 지네
꽃이 지네
갈 봄 여름 없이
꽃이 지네
"""



words = re.findall(r'\w+', data)








