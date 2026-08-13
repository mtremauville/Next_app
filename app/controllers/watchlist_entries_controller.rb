class WatchlistEntriesController < ApplicationController
  before_action :set_watchlist_entry, only: [ :update, :destroy ]

  PER_PAGE = 12

  def index
    @watchlist_entries = filter_by_status(current_user.watchlist_entries.includes(:title).order(created_at: :desc))
                            .page(params[:page]).per(PER_PAGE)
  end

  def movies
    @watchlist_entries = filter_by_status(current_user.watchlist_entries.joins(:title).merge(Title.movie).includes(:title).order(created_at: :desc))
                            .page(params[:page]).per(PER_PAGE)
  end

  def series
    @watchlist_entries = filter_by_status(current_user.watchlist_entries.joins(:title).merge(Title.tv_series).includes(:title).order(created_at: :desc))
                            .page(params[:page]).per(PER_PAGE)
  end

  def create
    current_user.watchlist_entries.create(title_id: params[:title_id])
    redirect_to title_path(params[:title_id], back: params[:back])
  end

  def update
    @watchlist_entry.update(status: params[:status])
    redirect_back fallback_location: watchlist_entries_path
  end

  def destroy
    title_id = @watchlist_entry.title_id
    @watchlist_entry.destroy

    if params[:back].present?
      redirect_to title_path(title_id, back: params[:back])
    else
      redirect_back fallback_location: watchlist_entries_path
    end
  end

  private

  def set_watchlist_entry
    @watchlist_entry = current_user.watchlist_entries.find(params[:id])
  end

  def filter_by_status(scope)
    WatchlistEntry.statuses.key?(params[:status]) ? scope.where(status: params[:status]) : scope
  end
end
