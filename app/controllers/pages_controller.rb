class PagesController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def home
    entries = current_user.entries
    @stats = Stats::Dashboard.new(current_user)
    @in_progress = entries.watching.includes(:episode_progresses).order(updated_at: :desc).limit(4)
    @up_next = entries.to_watch.order(created_at: :asc).limit(4)
  end
end
