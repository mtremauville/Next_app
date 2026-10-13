class CatalogController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @playlists = current_user.playlists.order(:name)
    @media_type = Tmdb::Catalog::TYPES.include?(params[:type]) ? params[:type] : "movie"
    @query = params[:q].to_s.strip
    page = params[:page].to_i.clamp(1, 500)

    catalog = Tmdb::Catalog.new
    @result = if @query.length >= 2
      catalog.search(@query, @media_type, page: page)
    else
      catalog.popular(@media_type, page: page)
    end
  rescue Tmdb::Error
    @unavailable = true
    @result = Tmdb::Catalog::Page.new(items: [], page: 1, total_pages: 1)
  end
end
