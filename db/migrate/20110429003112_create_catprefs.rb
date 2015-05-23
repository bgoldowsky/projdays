class CreateCatprefs < ActiveRecord::Migration
  def self.up
    create_table :catprefs do |t|
      t.references :category, :null => false
      t.references :person, :null => false
      t.integer :value, :null => false
    end
    add_index :catprefs, :category_id
    add_index :catprefs, :person_id
  end

  def self.down
    drop_table :catprefs
  end
end
