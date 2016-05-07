class Project < ActiveRecord::Base
  has_many :sesses, :include => :timeslots
  has_many :histories
  has_many :requests, :order => "rank"
  has_many :requesters, :through => :requests, :source => :person
  has_many :assignments, :through => :sesses, :source => :assignments

  validates_presence_of :name, :shortname, :description
  validates_numericality_of :capacity
  validates_uniqueness_of :name, :shortname

  def real
    isreal
  end

  ## Names

   def shortest_name
     shortname
   end

   def display_name
     shortname
   end

   def sort_name
     shortname.downcase
   end

  ## Listing methods

   def Project.list
     find :all, :order=>'name'
   end

   def Project.list_real
     find :all, :order=>'shortname, name', :conditions=>'isreal=true AND thisyear=true'
   end

   def Project.list_real_by_name
     find :all, :order=>'name', :conditions=>'isreal=true AND thisyear=true'
   end

   def Project.list_fake
     find :all, :order=>'shortname, name', :conditions=>'isreal=false'
   end

   def Project.list_old (only_real = true)
     cond = 'thisyear=false'
     if only_real
       cond = 'isreal=true AND ' + cond
     end
     find :all, :order=>'name', :conditions=>cond
   end

   def Project.list_old_by_year
     projs = find :all, :order=>'name', :conditions=>'isreal=true AND thisyear=false', :include=>:histories
     projs.sort!{ |a,b|
       ay = a.most_recent_year
       by = b.most_recent_year
       if ay==by
         a.name <=> b.name
       else
         b.most_recent_year <=> a.most_recent_year
       end
     }
   end

   def most_recent_year
     if histories.empty?
       0
     else
       histories.map{|h|h.year}.max
     end
   end

   def ok_for_grade? (g)
     return mingrade<=g && g<=maxgrade
   end

   def Project.list_for_grade (g)
     find :all, :order=>'name', :conditions=>['isreal=true AND thisyear=true AND mingrade<=? AND ?<=maxgrade', g, g]
   end

   def Project.list_by_shortname(only_real=false, only_thisyear=false, include=[])
     find :all, :order=>'shortname, name', :conditions=>conditions_for(only_real, only_thisyear), :include=>include
   end

   def Project.list_by_grade(only_real=false, only_thisyear=false)
     find :all, :order=>'mingrade, maxgrade, name', :conditions=>conditions_for(only_real, only_thisyear)
   end

   ## Various ways of looking at Requests

   def rank_for (p)
     req = requests.find(:first, :conditions=>['person_id=?', p])
     req && req.rank
   end

   def request_for_person (person)
     requests.detect {|r| r.person==person}
   end

   def student_requesters
     requesters.reject {|p| p.adult?}
   end

   def owner_requests
     requests.reject{|r| !r.owner?}
   end

   def leader_requests (omit_owner=false)
     requests.reject{|r| r.role!='L' || (omit_owner&&r.owner?)}.sort{|a,b|a.rank<=>b.rank}
   end

   def helper_requests
     requests.reject { |r| r.role!='H' }.sort{|a,b|a.rank<=>b.rank}
   end

   def participant_requests
     requests.reject {|r| r.role!='P' }.sort{|a,b|a.rank<=>b.rank}
   end

   def owner_requests_str
     owner_requests.map {|r| r.person.name }.join(', ')
   end

   def leader_requests_str (omit_owner=false)
     leader_requests(omit_owner).map {|r| r.person.name}.join(', ')
   end

   def participant_requests_str
     participant_requests.map {|r| r.person.name }.join(', ')
   end

   def historical_leaders
     histories.reject {|r| r.role!='L' }.sort{|a,b| a.year!=b.year ? b.year<=>a.year : a.who<=>b.who }
   end
   
   def historical_leaders_str
     historical_leaders.map {|r| "#{r.who} (#{r.year})"}.join(', ')
   end

   def historical_participant_average
     ## Average number of participants per year
     h = histories.reject{|h| h.role != 'P'}
     years = Hash.new(0)
     h.each {|x| years[x.year]=1 }
     if (years.length > 0)
       "#{h.size}/#{years.length} = #{h.size / years.length}"
     else
       "-"
     end
   end

   ## Looking at assignments

   def has_assignments?
     sesses.any? {|s| s.assignments.size>0 }
   end

   def assignment_for_person (person)
     sesses.detect {|s| s.assignments.find(:first, :conditions=>['person_id=?', person])}
     # Was:
     # sesses.detect {|s| s.assignments.detect {|a| a.person==person}}
   end

   ## Looking at Sesses

   def sess_in_timeslot (t)
     # Return ONE session for this project that includes the given timeslot
     # Is this implementation slow when repeatedly called?
     return sesses.detect {|s| s.timeslots.include? t}
     # Alternative, used in 2013:
#     for s in Sess.all(:conditions => ["project_id = ?", id], :include=>:timeslots)
#       if s.timeslots.include? t
#         return s
#       end
#     end
#     return nil
   end

   def sesses_sorted
     sesses.sort {|a,b| a.to_s <=> b.to_s}
   end

   ## Setup methods

   def self.default_note
     ''
   end

   def self.default_unit_note
     'Who are you planning this with?

Any preferred location for project?

Do you want to do more than one session?

Do you need any special equipment?

Other comments?

'
   end

   private

   def self.conditions_for (only_real, only_thisyear)
     conditions = ""
     if only_real
       conditions = "isreal=true"
     end
     if only_thisyear
       if !conditions.empty?
         conditions += " and "
       end
       conditions += "thisyear=true"
     end
   end

end
