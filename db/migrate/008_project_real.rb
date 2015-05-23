class ProjectReal < ActiveRecord::Migration
  def self.up
    add_column :projects, :real, :boolean, :null=>false, :default=>true
  end

  def self.down
    remove_column :projects, :real
  end
end
