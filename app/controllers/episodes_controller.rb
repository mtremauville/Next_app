class EpisodesController < ApplicationController
  def toggle_watched
    episode = Episode.find(params[:id])
    episode_view = current_user.episode_views.find_by(episode: episode)

    if episode_view
      episode_view.destroy
    else
      current_user.episode_views.create!(episode: episode, watched_at: Time.current)
    end

    redirect_to title_path(episode.season.title)
  end
end
