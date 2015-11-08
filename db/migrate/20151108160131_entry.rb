class Entry < ActiveRecord::Migration
  def up
    create_table :entries do |t|
      t.string  :url
      t.timestamps null: false
    end
  end

  def down
    drop_table :entries
  end
end
