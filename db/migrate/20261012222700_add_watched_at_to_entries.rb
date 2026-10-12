class AddWatchedAtToEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :watched_at, :datetime
  end
end
