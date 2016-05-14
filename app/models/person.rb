class Person < ActiveRecord::Base
  belongs_to :classroom
  has_many :requests, :order=>'rank', :dependent=>:delete_all
  has_many :assignments, :order=>'id'
  has_many :catprefs, :order=>'category_id', :dependent=>:delete_all

  validates_presence_of :name, :classroom_id
  validates_uniqueness_of :name, :scope => :classroom_id, :message=>'already exists'
  validates_numericality_of :grade
  validate :parent_must_have_email
  validate :adult_must_have_password
  validates_confirmation_of :password

  def parent_must_have_email
    if (grade==Person.parent_grade)
      errors.add_on_empty("email")
    end
  end

  def adult_must_have_password
    if grade!=nil and adult?
      errors.add_on_empty("password")
    end
  end
  
  def self.teacher_grade
    99
  end

  def self.parent_grade
    98
  end

  def self.adultgrades
    [ 98, 99 ]
  end

  def self.studentgrades
    [ 0, 1, 2, 3, 4, 5, 6, 7, 8 ]
  end

  def self.allgrades
    [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 98, 99 ]
  end

  def self.list
    find(:all, :order=>'name')
  end

  # Return list of all students
  def self.find_students
    find(:all, :conditions => [ 'grade < 10' ], :order => 'name')
  end

  # Return list of all in the unit
  def self.find_unit
    find(:all, :conditions => [ 'grade=7 OR grade=8' ], :order => 'name')
  end

  # Return list of all adults (parents and teachers)
  def self.find_adults
    find(:all, :conditions => [ 'grade >= 10' ], :order => 'name')
  end

  # Return list of parents
  def self.find_parents
    find(:all, :conditions => [ 'grade = 98' ], :order => 'name')
  end

  # Return list of teachers
  def self.find_teachers
    find(:all, :conditions => [ 'grade = 99' ], :order => 'name')
  end

  def self.authenticate(user, pw)
    if user
      if (user.password == pw)
        return user
      end
    end
    return false
  end

  # instance methods

  def teacher?
    grade == 99
  end

  def parent?
    grade == 98
  end

  def unit?
    grade==7 or grade==8
  end

  def student?
    grade < 10
  end

  def adult?
    grade >= 10
  end

  def self.default_max_choices
    8
  end

  def self.adult_max_choices
    4
  end

  def self.unit_max_choices
    10
  end

  def max_choices
    if adult?
      Person.adult_max_choices
    elsif unit?
      Person.unit_max_choices
    else
      Person.default_max_choices
    end
  end

  # Is this user scheduled for the given session?
  def is_assigned? (s)
    assignments.detect { |a| a.sess == s }
  end

  # Does this person have anything assigned in timeslot t?
  def has_assignment_for (t)
    assignments.detect {|a| a.sess.timeslots.include? t}
  end

  # What is this person assigned to do in timeslot t?
  def assignments_for (t)
    assignments.reject {|a| !(a.sess.timeslots.include? t)}
  end
    
  # Formatted version of the above
  def schedule_for (t)
    result = assignments_for(t)
    if not result.empty?
      result.map {|a| a.sess.project.display_name}.join('<br/> ')
    else
      nil
    end
  end

  # Is this person assigned to do this project? (boolean)
  def schedule_to (proj)
    assignments.detect{|a| a.sess.project == proj}
  end

  def request_for_project (proj)
    requests.detect{|r| r.project == proj}
  end

  def request_rank_for_project (proj)
    req = request_for_project(proj)
    if (req)
      req.rank
    else
      nil
    end
  end

  def requests_with_role (role)
    requests.reject{|r| r.role != role}
  end

  def requests_with_rank (rank)
    requests.reject{|r| r.rank != rank}
  end

  def requests_with_rank_and_role (rank, role)
    requests.reject{|r| r.rank != rank || r.role != role}
  end

  def catprefs_with_value (value)
    catprefs.reject{|cp| cp.value != value}
  end

  def catprefs_with_value_string (value)
    catprefs_with_value(value).map{|cp| cp.category.name}.join(', ')
  end

end
