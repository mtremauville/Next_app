module ProgressHelper
  STATE_LABELS = { "watched" => "Vu", "watching" => "En cours", "to_watch" => "À voir" }.freeze
  SERIES_LABELS = { "watched" => "Série terminée", "watching" => "En cours", "to_watch" => "À voir" }.freeze

  def state_label(state) = STATE_LABELS.fetch(state.to_s)
  def series_state_label(state) = SERIES_LABELS.fetch(state.to_s)
end
