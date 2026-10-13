class PlaylistPolicy < ApplicationPolicy
  def new? = user.present?
  def create? = user.present?
  def edit? = owner?
  def update? = owner?
  def destroy? = owner?
  def show? = owner?

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  private

  def owner?
    user.present? && record.user_id == user.id
  end
end
