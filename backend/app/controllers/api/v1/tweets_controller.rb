module Api
  module V1
    class TweetsController < ApplicationController
      include Pagy::Method

      def create
        result = Tweets::CreateTweet.new(
          user:    current_user,
          content: tweet_params[:content]
        ).call

        if result[:success]
          render json: { data: serialize_tweet(result[:tweet]) }, status: :created
        else
          render json: { error: "Validation failed", details: result[:errors] }, status: :unprocessable_entity
        end
      end

      def destroy
        tweet = Tweet.find(params[:id])
        authorize tweet

        Tweets::DeleteTweet.new(tweet: tweet).call

        head :no_content
      end

      def timeline
        tweets = Tweets::BuildTimeline.new(user: current_user).call
        pagy, paginated_tweets = pagy(tweets)

        render json: {
          data: serialize_tweets(paginated_tweets),
          meta: { total: pagy.count, page: pagy.page }
        }, status: :ok
      end

      private

      def tweet_params
        params.permit(:content)
      end

      def serialize_tweet(tweet)
        TweetSerializer.new(tweet, params: { current_user: current_user })
                       .serializable_hash[:data][:attributes]
                       .merge(id: tweet.id)
      end

      def serialize_tweets(tweets)
        tweets.map { |tweet| serialize_tweet(tweet) }
      end
    end
  end
end
