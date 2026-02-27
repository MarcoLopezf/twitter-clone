class TweetPolicy < ApplicationPolicy
  def destroy?
    record.user_id == user.id
  end
end
