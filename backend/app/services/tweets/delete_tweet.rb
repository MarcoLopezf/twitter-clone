module Tweets
  class DeleteTweet
    def initialize(tweet:)
      @tweet = tweet
    end

    def call
      @tweet.destroy
      { success: true }
    end
  end
end
