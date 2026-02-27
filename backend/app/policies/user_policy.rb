class UserPolicy < ApplicationPolicy
  def update?
    record.id == user.id
  end
end
