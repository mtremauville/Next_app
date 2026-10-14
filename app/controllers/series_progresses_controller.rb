class SeriesProgressesController < ApplicationController
  rescue_from Tmdb::Error do
    back alert: "TMDB est indisponible, réessaie dans un instant."
  end

  rescue_from SeriesTracker::UnknownEpisode do
    back alert: "Épisode introuvable."
  end

  rescue_from SeriesTracker::AlreadyWatched do
    back alert: "Cet épisode est déjà vu : remets-le à voir pour enregistrer une position."
  end

  rescue_from ResumePosition::Invalid do |error|
    back alert: error.message
  end

  rescue_from ActiveRecord::RecordInvalid do |error|
    back alert: error.record.errors.full_messages.to_sentence
  end

  def episode
    track { |tracker, status| tracker.mark_episode(params[:season], params[:episode], status) }
  end

  def season
    track { |tracker, status| tracker.mark_season(params[:season], status) }
  end

  def position
    tracker = SeriesTracker.new(current_user, params[:tmdb_id])
    authorize tracker.entry, :track?

    seconds = ResumePosition.parse(params[:hours], params[:minutes], params[:seconds])
    tracker.save_position(params[:season], params[:episode], seconds)

    back notice: "Position enregistrée : #{helpers.format_position(seconds)}."
  end

  def clear_position
    tracker = SeriesTracker.new(current_user, params[:tmdb_id])
    authorize tracker.entry, :track?

    tracker.clear_position(params[:season], params[:episode])
    back notice: "Position effacée."
  end

  private

  def track
    tracker = SeriesTracker.new(current_user, params[:tmdb_id])
    authorize tracker.entry, :track?

    status = params[:status].to_s
    return back(alert: "Statut inconnu.") unless EpisodeProgress.statuses.key?(status)

    yield tracker, status
    back
  end

  def back(**flash)
    redirect_back_or_to series_path(params[:tmdb_id]), status: :see_other, **flash
  end
end
