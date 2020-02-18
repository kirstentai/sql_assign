# COMP3311 19T3 Assignment 3

# Someone has asked you "I wonder how many cases there are were 5 UNSW courses
# share the same 4 numbers in their course code?". Write a solution that
# produces a list of all different cases where there are X UNSW courses
# that share the same course code numbers, where X is passed in as the command line argument.
import sys

import cs3311


assert int(sys.argv[1]) >= 2 and int(sys.argv[1]) <= 10;

if len(sys.argv) != 2:
    number == 2
else:
    number = sys.argv[1]

course_nums_list = {}
# appends course number to d if not existent, appends course depts to number
def addNumToList(d, code):
    if code not in d:
        d[code] = {
            'course_depts' : [],
        }

conn = cs3311.connect()
cur = conn.cursor()

cur.execute("select course_num, total from courseCounts where total = %s order by course_num asc", [number])
tupList = cur.fetchall()


i = 0
while i < len(tupList):
    cur.execute("select * from Q2(%s);", [tupList[i][0]] )
    subject_list = cur.fetchall()
    addNumToList(course_nums_list, tupList[i][0])

    j = 0
    while j < len(subject_list):
        course_nums_list[tupList[i][0]]['course_depts'].append(subject_list[j][0])
        j += 1
    i+= 1

for key, value in sorted(course_nums_list.items()):

    print("{}: {} ".format(key, " ".join(value['course_depts'])))

cur.close()

conn.close()
