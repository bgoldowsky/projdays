class AddHistory < ActiveRecord::Migration
  def self.up

    add_column :projects, :thisyear, :boolean, :null=>false, :default=>true

    create_table :years do |t|
      t.string  :name
    end
    
    create_table :histories do |t|
      t.references :year
      t.references :project
      t.column "who", :string
      t.column "role", :string, :limit=>1
    end

  end

  def self.down
    remove_column :projects, :thisyear
    drop_table :years
    drop_table :histories
  end
end
