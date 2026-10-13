module Tmdb
  class Catalog
    TYPES = %w[movie tv].freeze

    Item = Struct.new(:tmdb_id, :title, :media_type, :year, :poster_path, :overview, keyword_init: true)
    Page = Struct.new(:items, :page, :total_pages, keyword_init: true)

    def initialize(client: Client.new)
      @client = client
    end

    def popular(media_type, page: 1)
      fetch_page("/#{media_type}/popular", media_type, page: page)
    end

    def search(query, media_type, page: 1)
      fetch_page("/search/#{media_type}", media_type, page: page, query: query)
    end

    private

    def fetch_page(path, media_type, **params)
      raise ArgumentError, "unknown media type" unless TYPES.include?(media_type)

      data = @client.get(path, params.merge(language: "fr-FR", include_adult: false))

      Page.new(
        items: data.fetch("results", []).map { |item| build_item(item, media_type) },
        page: data["page"] || 1,
        total_pages: data["total_pages"].to_i.clamp(1, 500)
      )
    end

    def build_item(item, media_type)
      date = item["release_date"].presence || item["first_air_date"].presence

      Item.new(
        tmdb_id: item["id"],
        title: item["title"].presence || item["name"],
        media_type: media_type,
        year: date&.slice(0, 4),
        poster_path: item["poster_path"],
        overview: item["overview"]
      )
    end
  end
end
