module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :refuse_guest, only: %i[edit update destroy]

    private

    def refuse_guest
      return unless current_user&.guest?

      redirect_to root_path, alert: "Le compte de démonstration ne peut pas être modifié.", status: :see_other
    end
  end
end
