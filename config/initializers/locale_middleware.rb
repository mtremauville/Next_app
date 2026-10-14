class LocaleMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    I18n.with_locale(locale_for(env)) { @app.call(env) }
  end

  private

  def locale_for(env)
    cookie = Rack::Request.new(env).cookies["locale"]
    header = env["HTTP_ACCEPT_LANGUAGE"].to_s[/\A\s*([a-z]{2})/i, 1]

    [ cookie, header ].filter_map { |value| allowed(value) }.first || I18n.default_locale
  end

  def allowed(value)
    locale = value.to_s.downcase
    locale.to_sym if I18n.available_locales.map(&:to_s).include?(locale)
  end
end

Rails.application.config.middleware.insert_before Warden::Manager, LocaleMiddleware
