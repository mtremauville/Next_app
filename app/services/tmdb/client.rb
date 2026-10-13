require "net/http"
require "json"

module Tmdb
  class Client
    BASE_URL = "https://api.themoviedb.org/3".freeze
    CACHE_TTL = 6.hours

    def initialize(token: self.class.default_token)
      @token = token
    end

    def self.default_token
      ENV["TMDB_API_KEY"].presence || Rails.application.credentials.dig(:tmdb, :token)
    end

    def get(path, params = {})
      key = [ "tmdb", path, params.sort_by { |name, _| name.to_s } ]
      Rails.cache.fetch(key, expires_in: CACHE_TTL) { request(path, params) }
    end

    private

    def request(path, params)
      raise Error, "TMDB token missing" if @token.blank?

      uri = URI("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(params)

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{@token}"
      request["Accept"] = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 5) do |http|
        http.request(request)
      end

      raise Error, "TMDB responded #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, JSON::ParserError => e
      raise Error, e.message
    end
  end
end
