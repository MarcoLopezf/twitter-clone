class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :username, :display_name, :bio, :avatar_url, :created_at,
             :tweet_count, :followers_count, :following_count

  attribute :is_following do |user, params|
    next false unless params[:current_user]

    params[:current_user].following?(user)
  end
end
