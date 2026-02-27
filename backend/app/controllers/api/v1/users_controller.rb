module Api
  module V1
    class UsersController < ApplicationController
      include Pagy::Method
      def show
        user = User.find_by!(username: params[:username])
        render json: UserSerializer.new(user, params: { current_user: current_user }).serializable_hash
      end

      def update
        authorize current_user, policy_class: UserPolicy
        user = Users::UpdateProfile.new(current_user, profile_params).call

        if user.valid?
          render json: UserSerializer.new(user, params: { current_user: current_user }).serializable_hash
        else
          render json: { error: "Validation failed", details: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def search
        return render json: { data: [], meta: { total: 0, page: 1 } } if params[:q].blank?

        pagy, users = pagy(Users::SearchUsers.new(params[:q]).call)
        render json: UserSerializer.new(users, params: { current_user: current_user })
                       .serializable_hash
                       .merge(meta: { total: pagy.count, page: pagy.page })
      end

      private

      def profile_params
        params.permit(:display_name, :bio, :avatar_url)
      end
    end
  end
end
