class Request < ActiveRecord::Base
  belongs_to :person
  belongs_to :project

  validates_presence_of :person, :project, :rank

  def owner?
    role=='L' and rank==1
  end

  def self.requesters_for (project, max)
    reqs = find(:all, :conditions=>['project_id=? and rank<=?', project.id, max], :include=>['person','project']).find_all {|r| r.person.student?}
    reqs.map{|r| r.person}.uniq
  end

  def self.requester_map (max)
    reqmap = find(:all, :conditions=>['rank<=?', max], :include=>['person','project']).find_all {|r| r.person.student?}.group_by{|r|r.project}
    reqmap.each do |proj, reqlist|
      reqmap[proj] = reqlist.map{|r| r.person}.uniq
    end
    reqmap
  end

end
