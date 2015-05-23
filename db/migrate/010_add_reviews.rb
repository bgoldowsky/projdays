class AddReviews < ActiveRecord::Migration
  def self.up
#    add_column :projects, :review, :text
#    add_column :people, :review, :text
    execute %{alter table projects add column review text; }
    execute %{create table notes (id serial primary key, year int, updated_at timestamp, text text);}
  end

  def self.down
#    remove_column :projects, :review
#    remove_column :people, :review
  end

end
