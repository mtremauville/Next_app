class MoviesController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    @title = Tmdb::TitleDetails.new.call("movie", params[:id])
    @entry = current_user.entries.find_by(tmdb_id: @title.tmdb_id, media_type: "movie")
    @playlists = current_user.playlists.order(:name)
  rescue Tmdb::Error
    redirect_to catalog_path, alert: t("flash.catalog.movie_unavailable")
  end
end
