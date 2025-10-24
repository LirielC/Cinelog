class ComentarioPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    return false unless user.present?
    return true if user.admin? || user.moderador?
    record.usuario == user
  end

  def update?
    false # Comentários não são editáveis
  end
end
