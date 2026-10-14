class SeriesProgressesController < ApplicationController
  rescue_from Tmdb::Error do
    back alert: t("flash.catalog.tmdb_down")
  end

  rescue_from SeriesTracker::UnknownEpisode do
    back alert: t("flash.progress.unknown_episode")
  end

  rescue_from SeriesTracker::AlreadyWatched do
    back alert: t("flash.progress.episode_already_watched")
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

    back notice: t("flash.progress.position_saved", position: helpers.format_position(seconds))
  end

  def clear_position
    tracker = SeriesTracker.new(current_user, params[:tmdb_id])
    authorize tracker.entry, :track?

    tracker.clear_position(params[:season], params[:episode])
    back notice: t("flash.progress.position_cleared")
  end

  private

  def track
    tracker = SeriesTracker.new(current_user, params[:tmdb_id])
    authorize tracker.entry, :track?

    status = params[:status].to_s
    return back(alert: t("flash.progress.unknown_status")) unless EpisodeProgress.statuses.key?(status)

    yield tracker, status
    back
  end

  def back(**flash)
    redirect_back_or_to series_path(params[:tmdb_id]), status: :see_other, **flash
  end
end
