class WatchlistEntriesController < ApplicationController
  before_action :set_watchlist_entry, only: [ :update, :destroy ]

  def index
    @watchlist_entries = filter_by_status(current_user.watchlist_entries.includes(:title).order(created_at: :desc))
  end

  def movies
    @watchlist_entries = filter_by_status(current_user.watchlist_entries.joins(:title).merge(Title.movie).includes(:title).order(created_at: :desc))
  end

  def series
    @watchlist_entries = filter_by_status(current_user.watchlist_entries.joins(:title).merge(Title.tv_series).includes(:title).order(created_at: :desc))
  end

  def create
    current_user.watchlist_entries.create(title_id: params[:title_id])
    redirect_back fallback_location: titles_path
  end

  def update
    @watchlist_entry.update(status: params[:status])
    redirect_back fallback_location: watchlist_entries_path
  end

  def destroy
    @watchlist_entry.destroy
    redirect_back fallback_location: watchlist_entries_path
  end

  private

  def set_watchlist_entry
    @watchlist_entry = current_user.watchlist_entries.find(params[:id])
  end

  def filter_by_status(scope)
    WatchlistEntry.statuses.key?(params[:status]) ? scope.where(status: params[:status]) : scope
  end
end
