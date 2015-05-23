class ConfirmedSessions < ActiveRecord::Migration
  def self.up
    add_column :sesses, :confirmed, :boolean
  end

  def self.down
    remove_column :sesses, :confirmed
  end
end
