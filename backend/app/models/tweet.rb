class Tweet < ApplicationRecord
  include Likeable

  belongs_to :user

  validates :content, presence: true, length: { maximum: 280 }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_users, ->(user_ids) { where(user_id: user_ids).order(created_at: :desc) }
end
