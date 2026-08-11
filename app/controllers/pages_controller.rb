class PagesController < ApplicationController
  PER_PAGE = 10

  def home
    @watchlist_entries = filter_by_status(current_user.watchlist_entries.includes(:title).order(created_at: :desc))
                            .page(params[:page]).per(PER_PAGE)
  end

  private

  def filter_by_status(scope)
    WatchlistEntry.statuses.key?(params[:status]) ? scope.where(status: params[:status]) : scope
  end
end
