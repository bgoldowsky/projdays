class Category < ActiveRecord::Base

   def Category.list
     find :all, :order=>'id'
   end

end
