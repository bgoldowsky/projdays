class Catpref < ActiveRecord::Base
  belongs_to :person
  belongs_to :category
  validates_presence_of :value

  def stringval
    if value == 1
      'YES'
    elsif value == 2
      'okay'
    else
      'no'
    end
  end

end
