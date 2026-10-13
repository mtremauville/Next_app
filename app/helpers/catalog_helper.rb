module CatalogHelper
  def tmdb_image_url(path, size = "w342")
    "https://image.tmdb.org/t/p/#{size}#{path}"
  end

  def catalog_item_path(item)
    item.media_type == "tv" ? series_path(item.tmdb_id) : movie_path(item.tmdb_id)
  end
end
