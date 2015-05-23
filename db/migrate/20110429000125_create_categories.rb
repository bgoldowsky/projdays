class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name, :null => false
    end
    c = Category.new
    c.name = "Can lead a project"
    c.save!
    c = Category.new
    c.name = "Only want to assist"
    c.save!
    c = Category.new
    c.name = "Younger Kids"
    c.save!
    c = Category.new
    c.name = "Older Kids"
    c.save!
    c = Category.new
    c.name = "Sports"
    c.save!
    c = Category.new
    c.name = "Science"
    c.save!
    c = Category.new
    c.name = "Sewing crafts"
    c.save!
    c = Category.new
    c.name = "Messy Crafts"
    c.save!
    c = Category.new
    c.name = "Cooking"
    c.save!
    c = Category.new
    c.name = "Field trips"
    c.save!
    c = Category.new
    c.name = "Board games etc"
    c.save!
    c = Category.new
    c.name = "Surprise me!"
    c.save!

  end

  def self.down
    drop_table :categories
  end
end
