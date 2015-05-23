class ConfigTable < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.column "name", :string
      t.column "value", :string
      t.timestamps
    end
  end

  def self.down
    drop_table :configurations
  end
end
