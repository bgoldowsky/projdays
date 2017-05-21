class Sess < ActiveRecord::Base
  belongs_to :project
  belongs_to :location
  has_many :assignments
  has_and_belongs_to_many :timeslots, :order=>'id'

  validates_presence_of :project
  validates_presence_of :timeslots

  def location_name
    if location != nil
      location.name
    else
      "NO LOC"
    end
  end
  
  def to_s
    if timeslots.empty?
      "[session #{id}]"
    else 
      "[s#{timeslots.map {|x| x.id}.join("")}]"
    end
  end

  def sorted_assignments
    assignments.sort {|a,b|
      if a.role != b.role
        Assignment.role_compare(a.role, b.role)
      elsif a.person.classroom.mingrade != b.person.classroom.mingrade
        b.person.classroom.mingrade <=> a.person.classroom.mingrade # DESC
      elsif (a.person.classroom != b.person.classroom)
        a.person.classroom.name <=> b.person.classroom.name
      elsif (a.person.grade != b.person.grade)
        b.person.grade <=> a.person.grade # DESC
      else
        a.person.name <=> b.person.name
      end
    }
  end

  def assignment_for_person (person)
    assignments.detect {|a| a.person==person}
  end

  # Will return 1 if person is already assigned to this 
  def conflict_for_person (person)
    person.assignments.reject {|a| (a.sess.timeslots & timeslots).size==0}
  end

  def leader_names
    assignments.map {
      |a| if a.role == 'L'
            a.person.name.gsub(' ', '&nbsp;')
          end
    }.compact.sort
  end

  def helper_names
    assignments.map {
      |a| if a.role == 'H'
            a.person.name.gsub(' ', '&nbsp;')
          end
    }.compact.sort
  end

  def adult_helper_names
    assignments.map {
      |a| if (a.role == 'H' && a.person.adult?)
            a.person.name.gsub(' ', '&nbsp;')
          end
    }.compact.sort
  end

  def student_helper_names
    assignments.map {
      |a| if (a.role == 'H' && a.person.student?)
            a.person.name.gsub(' ', '&nbsp;')
          end
    }.compact.sort
  end

  def participant_names
    assignments.map {
      |a| if a.role != 'L' && a.role != 'H'
            a.person.name.gsub(' ', '&nbsp;')
          end
    }.compact.sort
  end

  def names_with_class (role)
    assignments.map {|a|
      if (a.role == role)
        "#{a.person.name.gsub(' ', '&nbsp;')}&nbsp;(#{a.person.classroom.shortname})"
      end
    }.compact.sort
  end

  def participant_names_with_class
    alist = assignments.reject {|a| a.role == 'L' or a.role == 'H'}
    alist.sort {|a,b|
      if (a.person.classroom.mingrade != b.person.classroom.mingrade)
        b.person.classroom.mingrade <=> a.person.classroom.mingrade
      elsif a.person.classroom != b.person.classroom
        a.person.classroom.name <=> b.person.classroom.name
      else
        a.person.name <=> b.person.name
      end
      }.map {|a|
        "#{a.person.name} (#{a.person.classroom.shortname})"
      }
  end

  def leader_count
    assignments.reject {|a| a.role != 'L'}.size
  end

  def student_count
    assignments.reject {|a| a.person.adult?}.size
  end

end
