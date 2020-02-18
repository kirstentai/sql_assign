# COMP3311 19T3 Assignment 3

import sys
import cs3311


if len(sys.argv) != 2:
    code = 'ENGG'
else:
    code = sys.argv[1]

# adds building to list, appends courses to each building
def addBldgToList(list, bldgName):
    if bldgName not in list:
        list[bldgName] = {
            'courses' : [],
        }

conn = cs3311.connect()

cur = conn.cursor()

cur.execute("select * from Q3(%s);", [code])
tupList = cur.fetchall()

finalList = {}
i = 0
while i< len(tupList):
    list = tupList[i][0].split(":")
    #print(list[0])
    addBldgToList(finalList, list[0])
    finalList[list[0]]['courses'].append(list[1])
    i += 1

for key, value in sorted(finalList.items()):
    print("{}\n {}".format(key, "\n ".join(value['courses'])))


cur.close()
conn.close()
