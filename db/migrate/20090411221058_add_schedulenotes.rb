class AddSchedulenotes < ActiveRecord::Migration
  def self.up
    add_column :projects, :schedulenotes, :text
  end

  def self.down
    remove_column :projects, :schedulenotes
  end
end
