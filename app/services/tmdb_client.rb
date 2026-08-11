class TmdbClient
  BASE_URL = "https://api.themoviedb.org/3"

  def search(query)
    results = get("/search/multi", query: query)["results"] || []
    results.select { |result| %w[movie tv].include?(result["media_type"]) }
  end

  def details(tmdb_id, kind)
    get("/#{media_type_for(kind)}/#{tmdb_id}")
  end

  private

  def media_type_for(kind)
    kind == "tv_series" ? "tv" : "movie"
  end

  def get(path, params = {})
    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params.merge(api_key: api_key, language: "fr-FR"))
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end

  def api_key
    Rails.application.credentials.dig(:tmdb, :api_key)
  end
end
