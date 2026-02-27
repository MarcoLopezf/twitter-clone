module Likes
  class UnlikeTweet
    def initialize(user:, tweet:)
      @user  = user
      @tweet = tweet
    end

    def call
      like = @user.likes.find_by(tweet: @tweet)

      if like
        like.destroy
        { success: true }
      else
        { success: false, errors: ["Not liked"] }
      end
    end
  end
end
