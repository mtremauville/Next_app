class AddDetailsToEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :runtime_minutes, :integer
    add_column :entries, :genres, :string
  end
end
