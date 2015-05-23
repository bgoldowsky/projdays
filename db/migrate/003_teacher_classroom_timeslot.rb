class TeacherClassroomTimeslot < ActiveRecord::Migration
  def self.up


    execute %{
insert into timeslots (day, start, stop) values ('Mon', '9:00', '12:00');
insert into timeslots (day, start, stop) values ('Mon', '1:00', '2:00');
insert into timeslots (day, start, stop) values ('Mon', '2:00', '3:00');
insert into timeslots (day, start, stop) values ('Tues', '9:00', '12:00');
insert into timeslots (day, start, stop) values ('Tues', '1:00', '2:00');
insert into timeslots (day, start, stop) values ('Tues', '2:00', '3:00');

insert into classrooms (shortname, name, mingrade) values ('A/C', 'Ann & Cindy', 5);
insert into classrooms (shortname, name, mingrade) values ('J/J', 'Jim/Joanie', 1);
insert into classrooms (shortname, name, mingrade) values ('M/C', 'Meg/Cindy', 0);
insert into classrooms (shortname, name, mingrade) values ('M/D', 'Mark/Dena', 1);
insert into classrooms (shortname, name, mingrade) values ('G/E', 'Gale/Eric', 3);
insert into classrooms (shortname, name, mingrade) values ('R/A', 'Rebecca/Ani', 3);
insert into classrooms (shortname, name, mingrade) values ('E/C', 'Emily/Cathie', 5);
insert into classrooms (shortname, name, mingrade) values ('Unit', 'Unit', 7);
insert into classrooms (shortname, name, mingrade) values ('P', 'Parent', 9);
insert into classrooms (shortname, name, mingrade) values ('T', 'Teacher', 10);

insert into people (name, grade, classroom_id) values ('Aaron', 99, 10); 
insert into people (name, grade, classroom_id) values ('Ana', 99, 10); 
insert into people (name, grade, classroom_id) values ('Angela', 99, 10); 
insert into people (name, grade, classroom_id) values ('Ani', 99, 10); 
insert into people (name, grade, classroom_id) values ('Ann', 99, 10); 
insert into people (name, grade, classroom_id) values ('Berit', 99, 10); 
insert into people (name, grade, classroom_id) values ('Brian C.', 99, 10); 
insert into people (name, grade, classroom_id) values ('Brian Gomes', 99, 10); 
insert into people (name, grade, classroom_id) values ('Carole', 99, 10); 
insert into people (name, grade, classroom_id) values ('Cathie', 99, 10); 
insert into people (name, grade, classroom_id) values ('Chris', 99, 10); 
insert into people (name, grade, classroom_id) values ('Chrissi', 99, 10); 
insert into people (name, grade, classroom_id) values ('Cindy Dill', 99, 10); 
insert into people (name, grade, classroom_id) values ('Cindy Tse', 99, 10); 
insert into people (name, grade, classroom_id) values ('Connie', 99, 10); 
insert into people (name, grade, classroom_id) values ('David', 99, 10); 
insert into people (name, grade, classroom_id) values ('Dena', 99, 10); 
insert into people (name, grade, classroom_id) values ('Diana Glass', 99, 10); 
insert into people (name, grade, classroom_id) values ('Diana B.', 99, 10); 
insert into people (name, grade, classroom_id) values ('Dorla', 99, 10); 
insert into people (name, grade, classroom_id) values ('Ed', 99, 10); 
insert into people (name, grade, classroom_id) values ('Eric', 99, 10); 
insert into people (name, grade, classroom_id) values ('Gale', 99, 10); 
insert into people (name, grade, classroom_id) values ('Grace', 99, 10); 
insert into people (name, grade, classroom_id) values ('Hannah', 99, 10); 
insert into people (name, grade, classroom_id) values ('Hilary', 99, 10); 
insert into people (name, grade, classroom_id) values ('Iku', 99, 10); 
insert into people (name, grade, classroom_id) values ('Ingleed', 99, 10); 
insert into people (name, grade, classroom_id) values ('Jennifer', 99, 10); 
insert into people (name, grade, classroom_id) values ('Jim', 99, 10); 
insert into people (name, grade, classroom_id) values ('Joanie', 99, 10); 
insert into people (name, grade, classroom_id) values ('Kate Laffy', 99, 10); 
insert into people (name, grade, classroom_id) values ('Kate Lee', 99, 10); 
insert into people (name, grade, classroom_id) values ('Lisette', 99, 10); 
insert into people (name, grade, classroom_id) values ('Mark', 99, 10); 
insert into people (name, grade, classroom_id) values ('Mary', 99, 10); 
insert into people (name, grade, classroom_id) values ('Maxie', 99, 10); 
insert into people (name, grade, classroom_id) values ('Meg', 99, 10); 
insert into people (name, grade, classroom_id) values ('Melanie', 99, 10); 
insert into people (name, grade, classroom_id) values ('Nina Grimwald', 99, 10); 
insert into people (name, grade, classroom_id) values ('Nina Araújo', 99, 10); 
insert into people (name, grade, classroom_id) values ('Orit', 99, 10); 
insert into people (name, grade, classroom_id) values ('Paul', 99, 10); 
insert into people (name, grade, classroom_id) values ('Ray', 99, 10); 
insert into people (name, grade, classroom_id) values ('Rob', 99, 10); 
insert into people (name, grade, classroom_id) values ('Rowena', 99, 10); 
insert into people (name, grade, classroom_id) values ('Scot', 99, 10); 
insert into people (name, grade, classroom_id) values ('Sharon', 99, 10); 
insert into people (name, grade, classroom_id) values ('Stacey', 99, 10); 
insert into people (name, grade, classroom_id) values ('Sue', 99, 10); 
insert into people (name, grade, classroom_id) values ('Susan', 99, 10); 
}
  end

  def self.down
    Timeslot.delete_all
    Person.delete_all
    Classroom.delete_all
  end
end
