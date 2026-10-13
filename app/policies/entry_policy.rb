class EntryPolicy < ApplicationPolicy
  def update? = owner?
  def destroy? = owner?
  def watch? = owner?
  def assign_playlist? = owner?
  def track? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end

  private

  def owner?
    user.present? && record.user_id == user.id
  end
end
