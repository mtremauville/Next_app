class PagesController < ApplicationController
  def home
    @watchlist_entries = current_user.watchlist_entries.includes(:title).order(created_at: :desc)
  end
end
