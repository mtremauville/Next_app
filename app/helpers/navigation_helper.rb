module NavigationHelper
  def side_link(key, path, active_when)
    active = request.path.match?(active_when)

    link_to "[ #{t("nav.#{key}")} ]", path,
            class: ("is-active" if active),
            aria: { current: ("page" if active) }
  end
end
