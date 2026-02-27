module Likes
  class LikeTweet
    def initialize(user:, tweet:)
      @user  = user
      @tweet = tweet
    end

    def call
      like = @user.likes.build(tweet: @tweet)

      if like.save
        { success: true, like: like }
      else
        { success: false, errors: like.errors.full_messages }
      end
    end
  end
end
