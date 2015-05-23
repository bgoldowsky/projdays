class History < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :who, :year, :project_id, :role

  def self.of_project_id (pid)
    find(:all, :conditions=>["project_id=#{pid}"])
  end

  def self.create_from (assg, year)

    if (!self.exists?(['who=? AND project_id=? AND role=? AND year=?',
                        assg.person.name, assg.sess.project.id,
                        assg.role, year]))
      h = self.new
      h.who = assg.person.name
      h.project = assg.sess.project
      h.role = assg.role
      h.year = year
      return h.save!
    end
    return true
  end

end
