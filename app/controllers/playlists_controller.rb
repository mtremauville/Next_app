class PlaylistsController < ApplicationController
  before_action :set_playlist, only: %i[show edit update destroy]
  def index
    @playlists = policy_scope(Playlist).includes(:entries).order(:name)
  end

  def show
    entries = @playlist.entries.order(:title).to_a

    @count = entries.size
    @groups = {
      "Films" => entries.select { |entry| entry.media_type == "movie" },
      "Séries" => entries.select { |entry| entry.media_type == "tv" },
      "Autres" => entries.reject { |entry| %w[movie tv].include?(entry.media_type) }
    }.reject { |_, list| list.empty? }
  end
  def new
    @playlist = current_user.playlists.build
    authorize @playlist
  end

  def create
    @playlist = current_user.playlists.build(playlist_params)
    authorize @playlist

    if @playlist.save
      redirect_to playlists_path, notice: "Playlist créée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @playlist.update(playlist_params)
      redirect_to playlists_path, notice: "Playlist renommée."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @playlist.destroy
    redirect_to playlists_path, notice: "Playlist supprimée.", status: :see_other
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:id])
    authorize @playlist
  end

  def playlist_params
    params.expect(playlist: %i[name])
  end
end
