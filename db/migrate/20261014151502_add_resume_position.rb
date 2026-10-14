class AddResumePosition < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :position_seconds, :integer
    add_column :episode_progresses, :position_seconds, :integer
  end
end
