class Passwords < ActiveRecord::Migration
  def self.up
    add_column :people, :password, :string, :default=>'', :null=>false
    execute "update people set password='pd07' where grade='99'"
    execute "update people set password='fss07' where grade='98'"
  end

  def self.down
    remove_column :people, :password
  end
end
