class Classrooms < ActiveRecord::Migration
  def self.up
    execute "delete from classrooms where mingrade < 9"
    execute "update classrooms set mingrade=98 where id=9"
    execute "update classrooms set mingrade=99 where id=10"
    execute %{
insert into classrooms (id, shortname, name, mingrade) values (1, 'K', 'Kindergarten', 0);
insert into classrooms (id, shortname, name, mingrade) values (2, 'JJ', 'Jim/Joanie', 1);
insert into classrooms (id, shortname, name, mingrade) values (3, 'MD', 'Mark/Dena', 1);
insert into classrooms (id, shortname, name, mingrade) values (4, 'ADO', 'Ani/Diana/Orit', 3);
insert into classrooms (id, shortname, name, mingrade) values (5, 'GE', 'Gale/Eric', 3);
insert into classrooms (id, shortname, name, mingrade) values (6, 'AC', 'Ann/Cindy', 5);
insert into classrooms (id, shortname, name, mingrade) values (7, 'CC', 'Chrissi/Cathie', 5);
insert into classrooms (id, shortname, name, mingrade) values (8, 'J', 'Unit: Jenn', 7);
insert into classrooms (id, shortname, name, mingrade) values (11, 'G', 'Unit: Grace', 7);
}
  end

  def self.down
  end
end
