class Location < ActiveRecord::Base
  
  has_many :sesses

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.list
    find(:all, :order => 'name')
  end

 # What's scheduled to happen here during the given timeslot?
 def sesses_in (t)
   list = sesses.collect {|s| (s.timeslots.include?(t)) ? s : nil}
   list.compact!
   list
 end

 # Return list of projects for this location in given timeslot
#  def projects_in (t)
#    s = sesses_in(t)
#    if s
#      s.map {|s| s.project}
#    else
#      []
#    end
#  end

end
