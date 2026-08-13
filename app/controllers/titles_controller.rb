class TitlesController < ApplicationController
  def index
    @query = params[:query]
    @results = @query.present? ? TmdbClient.new.search(@query) : []
  end

  def show
    @title = Title.find(params[:id])
    sync_seasons if @title.tv_series? && (@title.seasons.empty? || @title.episodes.where(overview: nil).exists?)

    @back_url = safe_back_path(params[:back]) || safe_back_path(request.referer)
    @watchlist_entry = current_user.watchlist_entries.find_by(title: @title)

    if @title.tv_series?
      @watched_episode_ids = current_user.episode_views
                                          .joins(episode: :season)
                                          .where(seasons: { title_id: @title.id })
                                          .pluck(:episode_id)
    end
  end

  def import
    title = Title.find_or_create_by(tmdb_id: params[:tmdb_id]) do |t|
      details = TmdbClient.new.details(params[:tmdb_id], params[:kind])

      t.assign_attributes(
        name: details["title"] || details["name"],
        kind: params[:kind],
        poster_path: details["poster_path"],
        overview: details["overview"],
        release_date: details["release_date"].presence || details["first_air_date"].presence
      )
    end

    redirect_to title_path(title)
  end

  private

  def safe_back_path(url)
    return nil if url.blank?

    uri = URI.parse(url)
    return nil if uri.host.present? && uri.host != request.host

    [ uri.path, uri.query ].compact.join("?").presence
  rescue URI::InvalidURIError
    nil
  end

  def sync_seasons
    client = TmdbClient.new
    seasons_data = client.details(@title.tmdb_id, "tv_series")["seasons"] || []

    seasons_data.each do |season_data|
      season = @title.seasons.find_or_create_by!(number: season_data["season_number"])

      client.season_episodes(@title.tmdb_id, season.number).each do |episode_data|
        episode = season.episodes.find_or_initialize_by(number: episode_data["episode_number"])
        episode.update!(name: episode_data["name"], overview: episode_data["overview"])
      end
    end
  end
end
