require "net/http"

class TmdbClient
  BASE_URL = "https://api.themoviedb.org/3"

  def search(query)
    results = get("/search/multi", query: query)["results"] || []
    results.select { |result| %w[movie tv].include?(result["media_type"]) }
  end

  def details(tmdb_id, kind)
    get("/#{media_type_for(kind)}/#{tmdb_id}")
  end

  def season_episodes(tmdb_id, season_number)
    get("/tv/#{tmdb_id}/season/#{season_number}")["episodes"] || []
  end

  private

  def media_type_for(kind)
    kind == "tv_series" ? "tv" : "movie"
  end

  def get(path, params = {})
    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params.merge(language: "fr-FR"))

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"
    request["Accept"] = "application/json"

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    body = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[TmdbClient] #{response.code} for #{uri.path}: #{body["status_message"]}")
    end

    body
  end

  def access_token
    Rails.application.credentials.dig(:tmdb, :api_key)
  end
end
