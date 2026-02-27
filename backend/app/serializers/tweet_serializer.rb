class TweetSerializer
  include JSONAPI::Serializer

  attributes :id, :content, :created_at

  attribute :user do |tweet|
    {
      id:           tweet.user.id,
      username:     tweet.user.username,
      display_name: tweet.user.display_name,
      avatar_url:   tweet.user.avatar_url
    }
  end

  attribute :likes_count do |tweet|
    tweet.likes_count
  end

  attribute :liked_by_current_user do |tweet, params|
    next false unless params[:current_user]

    tweet.liked_by?(params[:current_user])
  end
end
