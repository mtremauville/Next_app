class LocalesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def update
    locale = params[:locale].to_s

    if I18n.available_locales.map(&:to_s).include?(locale)
      cookies[:locale] = { value: locale, expires: 1.year.from_now, same_site: :lax, secure: Rails.env.production? }
    end

    redirect_back_or_to root_path, status: :see_other
  end
end
