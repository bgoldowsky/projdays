class Assignment < ActiveRecord::Base
  belongs_to :person
  belongs_to :sess

  validates_presence_of :person_id, :sess_id, :role

  ## Read existing or create new Assignment for person and session
  def self.get(person, sess, role='P')
    a = Assignment.find_or_initialize_by_person_id_and_sess_id(person.id, sess.id)
    a.role = role
    return a
  end

  def self.role_compare (a, b)
    if (a==b)
      return 0
    else
      role_to_int(a) <=> role_to_int(b)
    end
  end

  def self.role_to_int (role)
    if (role == 'L')
      return 1
    elsif (role == 'H')
      return 2
    else
      return 3
    end
  end

end
