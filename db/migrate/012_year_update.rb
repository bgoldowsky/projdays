class YearUpdate < ActiveRecord::Migration
  def self.up
    ## The following is the beginning-of-year update.
    ## It should really be done by a page on the admin site
    Project.transaction do

      say_with_time "Saving history..." do
        y = Year.new(:name => '2007')
        y.save!
      
        Assignment.find(:all).each do |a|
          h = History.create_from(a, y)
        end
      end

      say_with_time "Cleaning out database for new year..." do

        Project.find(:all).each do |p|
          p.update_attribute :thisyear, false
        end
        
        execute %{delete from assignments}
        execute %{delete from sesses}
        execute %{delete from requests}
        execute %{delete from people}
      end

    end
  end

  def self.down
    Project.transaction do

      Project.find(:all).each do |p|
        p.update_attribute :thisyear, true
      end
      
      execute %{delete from histories }
      execute %{delete from years }

    end
  end

end
