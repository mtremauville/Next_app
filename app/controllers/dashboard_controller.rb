class DashboardController < ApplicationController
  skip_after_action :verify_authorized

  def show
    @stats = Stats::Dashboard.new(current_user)
  end
end
