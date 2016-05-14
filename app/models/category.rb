class Category < ActiveRecord::Base

  # No longer used

   def Category.list
     find :all, :order=>'id'
   end

end
