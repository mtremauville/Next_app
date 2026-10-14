class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern
  before_action :authenticate_user!

  after_action :verify_authorized, unless: :skip_authorization_check?
  after_action :verify_policy_scoped, if: :check_policy_scope?

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  def skip_authorization_check?
    devise_controller? || action_name == "index"
  end

  def check_policy_scope?
    !devise_controller? && action_name == "index"
  end

  def forbidden
    redirect_back_or_to root_path, alert: t("flash.forbidden"), status: :see_other
  end
end
