class CatalogEntriesController < ApplicationController
  skip_after_action :verify_policy_scoped

  def create
    playlist = target_playlist
    return choose_a_playlist unless playlist

    authorize playlist, playlist.new_record? ? :create? : :update?
    entry = find_or_build_entry
    authorize entry, :assign_playlist?

    if save_in_playlist(entry, playlist)
      redirect_back_or_to title_path, status: :see_other,
                          notice: t("flash.catalog.added", title: entry.title, playlist: playlist.name)
    else
      messages = (playlist.errors.full_messages + entry.errors.full_messages).uniq
      redirect_back_or_to title_path, alert: messages.to_sentence, status: :see_other
    end
  rescue Tmdb::Error
    redirect_back_or_to title_path, alert: t("flash.catalog.tmdb_down"), status: :see_other
  end

  def destroy
    entry = current_user.entries.find_by!(tmdb_id: params[:tmdb_id], media_type: params[:media_type])
    authorize entry, :assign_playlist?
    entry.update!(playlist: nil)

    redirect_back_or_to title_path, notice: t("flash.catalog.removed"), status: :see_other
  end

  private

  def target_playlist
    new_name = params[:new_playlist_name].to_s.strip
    return current_user.playlists.build(name: new_name) if new_name.present?

    Playlist.find_by(id: params[:playlist_id])
  end

  def save_in_playlist(entry, playlist)
    Entry.transaction do
      playlist.save! if playlist.new_record?
      entry.playlist = playlist
      entry.save!
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def choose_a_playlist
    skip_authorization
    redirect_back_or_to title_path, alert: t("flash.catalog.choose_playlist"), status: :see_other
  end

  def find_or_build_entry
    current_user.entries.find_by(tmdb_id: params[:tmdb_id], media_type: params[:media_type]) || build_entry
  end

  def build_entry
    Tmdb::EntryBuilder.new.call(current_user, params[:media_type], params[:tmdb_id])
  end

  def title_path
    params[:media_type] == "tv" ? series_path(params[:tmdb_id]) : movie_path(params[:tmdb_id])
  end
end
