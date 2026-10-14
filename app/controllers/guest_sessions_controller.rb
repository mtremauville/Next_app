class GuestSessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def create
    sign_in(:user, User.guest)
    redirect_to root_path, notice: t("flash.guest_welcome")
  end
end
