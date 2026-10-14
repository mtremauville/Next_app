class MoviePositionsController < ApplicationController
  rescue_from Tmdb::Error do
    back alert: "TMDB est indisponible, réessaie dans un instant."
  end

  rescue_from ResumePosition::Invalid do |error|
    back alert: error.message
  end

  rescue_from ActiveRecord::RecordInvalid do |error|
    back alert: error.record.errors.full_messages.to_sentence
  end

  def update
    entry = find_or_build_entry
    authorize entry, :track?

    if entry.watched?
      return back(alert: "Ce film est déjà vu : change son statut depuis [ Modifier ] pour enregistrer une position.")
    end

    seconds = ResumePosition.parse(params[:hours], params[:minutes], params[:seconds])
    entry.update!(status: :watching, position_seconds: seconds)

    back notice: "Position enregistrée : #{helpers.format_position(seconds)}."
  end

  def destroy
    entry = current_user.entries.find_by!(tmdb_id: params[:tmdb_id], media_type: "movie")
    authorize entry, :track?

    entry.update!(position_seconds: nil)
    back notice: "Position effacée."
  end

  private

  def find_or_build_entry
    current_user.entries.find_by(tmdb_id: params[:tmdb_id], media_type: "movie") ||
      Tmdb::EntryBuilder.new.call(current_user, "movie", params[:tmdb_id])
  end

  def back(**flash)
    redirect_back_or_to movie_path(params[:tmdb_id]), status: :see_other, **flash
  end
end
