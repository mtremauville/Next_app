class TitlesController < ApplicationController
  def index
    @query = params[:query]
    @results = @query.present? ? TmdbClient.new.search(@query) : []
  end

  def show
    @title = Title.find_or_create_by(tmdb_id: params[:id]) do |title|
      details = TmdbClient.new.details(params[:id], params[:kind])

      title.assign_attributes(
        name: details["title"] || details["name"],
        kind: params[:kind],
        poster_path: details["poster_path"],
        overview: details["overview"],
        release_date: details["release_date"].presence || details["first_air_date"].presence
      )
    end

    @watchlist_entry = current_user.watchlist_entries.find_by(title: @title)
  end
end
