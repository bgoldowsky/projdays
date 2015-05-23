class Request < ActiveRecord::Base
  belongs_to :person
  belongs_to :project

  validates_presence_of :person, :project, :rank

  def owner?
    role=='L' and rank==1
  end

end
