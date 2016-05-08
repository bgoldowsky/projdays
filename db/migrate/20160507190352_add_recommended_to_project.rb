class AddRecommendedToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :recommended, :boolean
  end

  def self.down
    remove_column :projects, :recommended
  end
end
