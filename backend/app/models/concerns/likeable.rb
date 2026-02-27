module Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likes, dependent: :destroy
  end

  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end

  def likes_count
    likes.count
  end
end
