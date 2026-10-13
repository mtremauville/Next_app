class AddEpisodesTotalToEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :episodes_total, :integer
  end
end
