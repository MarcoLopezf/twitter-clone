module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[register login]

      def register
        result = Auth::RegisterUser.new(register_params).call

        if result[:success]
          render json: { data: auth_response(result) }, status: :created
        else
          render json: { error: "Registration failed", details: result[:errors] }, status: :unprocessable_entity
        end
      end

      def login
        result = Auth::AuthenticateUser.new(
          email: params[:email],
          password: params[:password]
        ).call

        if result[:success]
          render json: { data: auth_response(result) }, status: :ok
        else
          render json: { error: result[:error] }, status: :unauthorized
        end
      end

      def me
        render json: { data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] } }, status: :ok
      end

      private

      def register_params
        params.permit(:email, :username, :display_name, :password, :bio, :avatar_url)
      end

      def auth_response(result)
        {
          token: result[:token],
          user: UserSerializer.new(result[:user]).serializable_hash[:data][:attributes]
        }
      end
    end
  end
end
