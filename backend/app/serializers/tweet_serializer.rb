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

  attribute :likes_count do |_tweet|
    0
  end

  attribute :liked_by_current_user do |_tweet, params|
    params[:current_user].present? ? false : false
  end
end
