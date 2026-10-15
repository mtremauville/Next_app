module CatalogHelper
  def tmdb_image_url(path, size = "w342")
    "https://image.tmdb.org/t/p/#{size}#{path}"
  end

  def catalog_item_path(item)
    item.media_type == "tv" ? series_path(item.tmdb_id) : movie_path(item.tmdb_id)
  end

  def format_air_date(value)
    l(Date.iso8601(value), format: :air_date)
  rescue ArgumentError, TypeError
    nil
  end

  def crew_label(key)
    t("crew.#{key}")
  end
end
