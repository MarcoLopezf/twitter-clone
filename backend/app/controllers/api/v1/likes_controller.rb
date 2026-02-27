module Api
  module V1
    class LikesController < ApplicationController
      def like
        tweet  = Tweet.find(params[:id])
        result = Likes::LikeTweet.new(user: current_user, tweet: tweet).call

        if result[:success]
          render json: { data: serialize_like(result[:like]) }, status: :created
        else
          render json: { error: "Validation failed", details: result[:errors] }, status: :unprocessable_entity
        end
      end

      def unlike
        tweet  = Tweet.find(params[:id])
        result = Likes::UnlikeTweet.new(user: current_user, tweet: tweet).call

        if result[:success]
          head :no_content
        else
          render json: { error: result[:errors].first }, status: :unprocessable_entity
        end
      end

      private

      def serialize_like(like)
        {
          id:         like.id,
          user_id:    like.user_id,
          tweet_id:   like.tweet_id,
          created_at: like.created_at
        }
      end
    end
  end
end
