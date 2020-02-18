# COMP3311 19T3 Assignment 3
# Given a 4 letter course code prefix (e.g. COMP) as a command line argument,
# produce a list of terms (ordered ascending),
# where for each term a sub-list is produced showing which courses run in that
# term and how many students are currently enrolled in those courses.
import sys
import cs3311

if len(sys.argv) != 2:
    code = 'ENGG'
else:
    code = sys.argv[1]

def addCourseToList(termList, term_code):
    if term_code not in termList:
        termList[term_code] = {
            'courses' : [],

        }

conn = cs3311.connect()

cur = conn.cursor()

cur.execute("select * from Q4(%s) order by q4;", [code])
tupList = cur.fetchall()

finalList = {}
i = 0
while i< len(tupList):
    list = tupList[i][0].split(":")
    #print(list[0])
    addCourseToList(finalList, list[0])
    finalList[list[0]]['courses'].append(list[1]+ '(' + list[2] + ')')

    i += 1

for key, value in sorted(finalList.items()):

    print("{}\n {}".format(key, "\n ".join(value['courses']) ))


cur.close()
conn.close()
