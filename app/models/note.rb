class Note < ActiveRecord::Base

  validates_presence_of :year

  def self.for_this_year
    return find_or_initialize_by_year(Date.today.year)
  end

  def self.list
    return find(:all)
  end

  def self.previous_years
    return find(:all, :conditions=>['year < ?', Date.today.year])
  end

end
