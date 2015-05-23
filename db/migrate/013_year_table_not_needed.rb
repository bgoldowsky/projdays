class YearTableNotNeeded < ActiveRecord::Migration
  def self.up
    execute %{alter table histories add column year int;}
    execute %{update histories set year=2007;}
    execute %{alter table histories drop column year_id;}
    execute %{drop table years;}
  end

  def self.down
  end
end
