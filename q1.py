# Database Systems 19T3 Assignment 3
# For each course offered in 19T3, produce a list of all courses with a quota
# more than 50 and that are over-enrolled.
# I.e. when the number of enrollments exceeds the quota for the course.
# Results should be ordered by course name (ascending)

import cs3311
conn = cs3311.connect()

cur = conn.cursor()

cur.execute("select * from nEnroll")

studentsEnroled = cur.fetchall()
list = {}

for list in studentsEnroled:
    subject_id, exceed = list
    print("{} {}%".format(subject_id, exceed))

cur.close()
conn.close()
