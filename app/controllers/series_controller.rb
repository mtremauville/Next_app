class SeriesController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    @title = Tmdb::TitleDetails.new.call("tv", params[:id])
    @entry = current_user.entries.find_by(tmdb_id: @title.tmdb_id, media_type: "tv")
    @playlists = current_user.playlists.order(:name)
    @progress = SeriesProgress.new(@entry, @title.seasons)
    @season_number = pick_season(@title.seasons)
    load_season if @season_number
  rescue Tmdb::Error
    redirect_to catalog_path, alert: "Cette série est indisponible pour le moment."
  end

  private

  def pick_season(seasons)
    numbers = seasons.map(&:number)
    requested = params[:season].to_i
    numbers.include?(requested) ? requested : numbers.first
  end

  def load_season
    @season = Tmdb::SeasonDetails.new.call(@title.tmdb_id, @season_number)
  rescue Tmdb::Error
    @season_unavailable = true
  end
end
