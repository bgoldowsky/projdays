class Timeslot < ActiveRecord::Base

  has_and_belongs_to_many :sesses

  def Timeslot.list
    find :all, :order=>'id'
  end

  def to_s
    "s" + id.to_s
  end

  def shortdesc
    "#{day}#{start}"
  end

  def meddesc
    "#{day} #{start}-#{stop}"
  end

  def longdesc
    "[#{to_s}]: #{day} #{start}-#{stop}"
  end

  def sesses_by_name
    sesses.sort {|a,b| a.project.name.downcase <=> b.project.name.downcase}
  end

end
