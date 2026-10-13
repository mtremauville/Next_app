class SeriesProgressesController < ApplicationController
  rescue_from Tmdb::Error do
    back alert: "TMDB est indisponible, réessaie dans un instant."
  end

  rescue_from SeriesTracker::UnknownEpisode, ActiveRecord::RecordInvalid do
    back alert: "Épisode introuvable."
  end

  def episode
    track { |tracker, status| tracker.mark_episode(params[:season], params[:episode], status) }
  end

  def season
    track { |tracker, status| tracker.mark_season(params[:season], status) }
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
