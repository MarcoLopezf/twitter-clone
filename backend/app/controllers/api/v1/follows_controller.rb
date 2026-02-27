module Api
  module V1
    class FollowsController < ApplicationController
      include Pagy::Method

      def follow
        target_user = User.find(params[:id])
        result = Follows::FollowUser.new(follower: current_user, followed: target_user).call

        if result[:success]
          render json: { data: serialize_follow(result[:follow]) }, status: :created
        else
          render json: { error: "Validation failed", details: result[:errors] }, status: :unprocessable_entity
        end
      end

      def unfollow
        target_user = User.find(params[:id])
        result = Follows::UnfollowUser.new(follower: current_user, followed: target_user).call

        if result[:success]
          head :no_content
        else
          render json: { error: result[:errors].first }, status: :unprocessable_entity
        end
      end

      def followers
        user  = User.find(params[:id])
        pagy, paginated_followers = pagy(user.followers)

        render json: {
          data: paginated_followers.map { |follower| serialize_user(follower) },
          meta: { total: pagy.count, page: pagy.page }
        }, status: :ok
      end

      def following
        user  = User.find(params[:id])
        pagy, paginated_following = pagy(user.following)

        render json: {
          data: paginated_following.map { |followed| serialize_user(followed) },
          meta: { total: pagy.count, page: pagy.page }
        }, status: :ok
      end

      private

      def serialize_follow(follow)
        {
          id:           follow.id,
          follower_id:  follow.follower_id,
          following_id: follow.followed_id,
          created_at:   follow.created_at
        }
      end

      def serialize_user(user)
        UserSerializer.new(user).serializable_hash[:data][:attributes].merge(id: user.id)
      end
    end
  end
end
