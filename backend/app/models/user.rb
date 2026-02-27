class User < ApplicationRecord
  has_secure_password

  has_many :tweets, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_tweets, through: :likes, source: :tweet

  has_many :active_follows,  class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :passive_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: EMAIL_REGEX }
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 }
  validates :bio, length: { maximum: 160 }, allow_blank: true

  def following?(user)
    following.exists?(user.id)
  end

  def followers_count
    followers.count
  end

  def following_count
    following.count
  end

  def generate_jwt
    payload = { user_id: id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end

  def self.from_token(token)
    return nil if token.nil?

    decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
    find_by(id: decoded.first["user_id"])
  rescue JWT::DecodeError
    nil
  end
end
