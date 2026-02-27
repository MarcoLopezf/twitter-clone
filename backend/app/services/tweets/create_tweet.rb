module Tweets
  class CreateTweet
    def initialize(user:, content:)
      @user    = user
      @content = content
    end

    def call
      tweet = @user.tweets.build(content: @content)

      if tweet.save
        { success: true, tweet: tweet }
      else
        { success: false, errors: tweet.errors }
      end
    end
  end
end
