class RequestRole < ActiveRecord::Migration
  def self.up
    add_column :requests, :role, :string, :limit=>1, :null=>false, :default=>'P'
    for p in Person.find_adults
      p.requests.map {|r| r.role='L'; r.save!}
    end
  end

  def self.down
    remove_column :requests, :role
  end
end
