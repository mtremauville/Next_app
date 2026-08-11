class EpisodesController < ApplicationController
  def toggle_watched
    episode = Episode.find(params[:id])
    episode_view = current_user.episode_views.find_by(episode: episode)

    if episode_view
      episode_view.destroy
    else
      current_user.episode_views.create!(episode: episode, watched_at: Time.current)
    end

    title = episode.season.title
    current_user.watchlist_entries.find_by(title: title)&.refresh_status_from_progress!

    redirect_to title_path(title)
  end
end
