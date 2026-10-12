class EntriesController < ApplicationController
  before_action :set_entry, only: %i[edit update destroy watch]
  def index
    @entries = policy_scope(Entry).includes(:playlist).order(created_at: :desc)
  end

  def new
    playlist = current_user.playlists.find_by(id: params[:playlist_id])
    @entry = current_user.entries.build(playlist: playlist)
    authorize @entry
  end

  def create
    @entry = current_user.entries.build(entry_params)
    authorize @entry
    enrich_from_tmdb(@entry)
    if @entry.save
      redirect_to(@entry.playlist ? playlists_path : entries_path, notice: "Titre ajouté.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @entry.update(entry_params)
      redirect_to entries_path, notice: "Titre mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    redirect_to entries_path, notice: "Titre supprimé.", status: :see_other
  end

  def watch
    @entry.update!(status: :watched)
    redirect_back_or_to entries_path, status: :see_other
  end

  private

  def set_entry
    @entry = Entry.find(params[:id])
    authorize @entry
  end

  def entry_params
    params.expect(entry: %i[title status rating platform playlist_id
                            tmdb_id media_type poster_path year overview])
  end

  def enrich_from_tmdb(entry)
    return if entry.tmdb_id.blank?

    details = Tmdb::Details.new.call(entry.tmdb_id, entry.media_type)
    return unless details

    entry.runtime_minutes = details.runtime_minutes
    entry.genres = details.genres
  end
end
