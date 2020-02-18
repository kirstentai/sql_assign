# COMP3311 19T3 Assignment 3

import sys

import cs3311


if len(sys.argv) != 2:
    code = 'COMP1521'
else:
    code = sys.argv[1]


conn = cs3311.connect()

cur = conn.cursor()

cur.execute("SELECT * FROM quotaCounter WHERE code = '{}'".format(code) )

for tupList in cur.fetchall():
    subjCode, classType, classTag, enrolmentRate = tupList
    print("{} {} is {}% full".format(classType, classTag, enrolmentRate))


cur.close()
conn.close()
