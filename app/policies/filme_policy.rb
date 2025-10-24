class FilmePolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    return false unless user.present?
    return true if user.admin? || user.moderador?
    record.usuario == user
  end

  def destroy?
    return false unless user.present?
    return true if user.admin?
    record.usuario == user
  end
end
