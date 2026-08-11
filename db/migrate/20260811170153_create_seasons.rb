class CreateSeasons < ActiveRecord::Migration[8.1]
  def change
    create_table :seasons do |t|
      t.references :title, null: false, foreign_key: true
      t.integer :number, null: false

      t.timestamps
    end

    add_index :seasons, [ :title_id, :number ], unique: true
  end
end
