-- 19T3 Database Systems Assignment 3
-- Helper views and functions (if needed)

-- Q1 function
create or replace view nEnroll
as
    select distinct y.subj_code, cast((cast(y.nE as float) / cast(y.quota as float)) *100 as integer)
    from (
        select s.code as subj_code, s.id as subj_id, c.quota as quota, count(ce.course_id) as nE
        from course_enrolments ce, subjects s, courses c, terms t
        where
        c.term_id = t.id
        and t.name = '19T3'
        and c.quota > 50
        and c.id = ce.course_id
        and c.subject_id = s.id

        group by subj_code, subj_id, quota
        having count(ce.course_id) > c.quota

    ) as y
    join courses c on (y.subj_id = c.subject_id)

    group by y.subj_code , y.nE, y.quota
    order by y.subj_code

;

-- Q2
create or replace view courseCounts
as

    select substring(code, 5, 8) as course_num, count(*) as total
    from Subjects
    group by course_num
    order by course_num asc

;
-- returns list of course_depts with the course_num passed in
create or replace function Q2(course_no text) returns setof text
as $$
declare
	match integer := 0;
	results record;
	course_dept text;

begin
select count(*) into match from Subjects
	where code ilike '%'|| course_no;
if (match = 0)
then
	return next 'No matching courses';
else
	for results in
		select * from Subjects
		where substring(code, 5,8) ilike '%' || course_no
        order by substring(code, 1, 4)
	loop
		course_dept := substring(results.code, 1, 4);
	return next course_dept;
	end loop;
end if;
return;
end;
$$ language plpgsql;

-- Q3

create or replace view bldgCourses
as
    select distinct b.name as bldg, s.code as subj_name
    from terms t, buildings b, rooms r, subjects s, courses co, classes cl, meetings m
    where
    t.name = '19T2'
    and t.id = co.term_id
    and co.subject_id = s.id
    and co.id = cl.course_id
    and cl.id = m.class_id
    and m.room_id = r.id
    and r.within = b.id
    group by b.name, s.code
    order by b.name, s.code
;


create or replace function Q3(_course_dept text) returns setof text
as $$
declare
    match integer := 0;
    results record;
    courseList text;
begin
select count(*) into match from bldgCourses
	where subj_name ilike _course_dept || '%';

if (match = 0)
then
	return next 'No matching courses';
else
	for results in
		select * from bldgCourses
        where subj_name ilike _course_dept || '%'
        order by bldg, subj_name

	loop
		courseList := results.subj_name;
	return next results.bldg||':'|| courseList;
	end loop;
end if;
return;
end;
$$ language plpgsql;


-- Q4
create or replace view termCourses
as
    select y.termName, y.subjName, y.nEnrolled
    from
    (select t.name as termName, s.code as subjName, count(ce.course_id) as nEnrolled
    from terms t, subjects s, courses c, course_enrolments ce
    where
        c.term_id = t.id
        and c.subject_id = s.id
        and c.id = ce.course_id
    group by subjName, termName
    having count(ce.course_id) > 0
    order by subjName, termName
    ) as y

    group by y.termName, y.subjName, y.nEnrolled
    order by y.termName asc
;


create or replace function Q4(_course_dept text) returns setof text
as $$
declare
    match integer := 0;
    results record;
    courseList text;
    enrolledCourse text;
begin
select count(*) into match from termCourses
	where subjName ilike _course_dept || '%';
    --group by termName
    --order by termName asc;

if (match = 0)
then
	return next 'No matching courses';
else
	for results in
		select termName, subjName, nEnrolled from termCourses
        where subjName ilike _course_dept || '%'
        group by termName, subjName, nEnrolled
        order by termName asc
	loop
		courseList := results.subjName;
        enrolledCourse := results.nenrolled;

	return next results.termName||':'|| courseList||':'|| enrolledCourse;
	end loop;
end if;
return;
end;
$$ language plpgsql;

-- Q5

create or replace view classMeetings
as

    select s.code, y.classtype, y.classtag, cast((cast(y.nE as float) / cast(y.quota as float)) *100 as integer) as pE
    from (select c.subject_id as subjName, ct.name as classType, cl.tag as classTag, cl.quota as quota, count(ce.class_id) as nE
        from classtypes ct, classes cl, class_enrolments ce, courses c
        where
        cl.type_id = ct.id
        and cl.course_id = c.id
        and cl.id = ce.class_id
        and cl.quota > 0
        group by subjName, classType, classTag, cl.quota
        having count(ce.class_id) < cl.quota
    ) as y
    join subjects s on (s.id = y.subjName)
    group by s.code, y.classtype, y.classtag, y.nE, y.quota

    order by s.code, y.classtype, y.classtag
;

create or replace view quotaCounter
as
    select code, classtype, classtag, pE from classMeetings
    where pE < 50
;
