module Tweets
  class BuildTimeline
    def initialize(user:)
      @user = user
    end

    def call
      followed_ids = @user.following.pluck(:id)
      visible_ids  = followed_ids + [@user.id]

      Tweet.by_users(visible_ids)
    end
  end
end
