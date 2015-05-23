class Classroom < ActiveRecord::Base
  has_many :people, :order => 'name'

  def Classroom.list
    find :all, :order=>'mingrade'
  end

  def self.list_real
    find :all, :order=>'mingrade', :conditions=>'mingrade<10'
  end

  def self.parent_classroom
    find_by_mingrade(Person.parent_grade)
  end
  
  def self.teacher_classroom
    find_by_mingrade(Person.teacher_grade)
  end

  def adult?
    mingrade >= 10
  end

  def max_choices
    if adult?
      Person.adult_max_choices
    elsif mingrade>=7
      Person.unit_max_choices
    else
      Person.default_max_choices
    end
  end

  # Some Fayerweather-specific rules:
  #   Kindergarten is all "grade 0"
  #   Other classrooms contain two grade levels
  def grades
    if mingrade == 0
      [ 0 ]
    else
      [ mingrade, mingrade+1]
    end
  end

end
