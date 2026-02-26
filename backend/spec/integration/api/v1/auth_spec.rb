require "swagger_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  path "/api/v1/auth/register" do
    post "Register a new user" do
      tags "Auth"
      consumes "application/x-www-form-urlencoded"
      produces "application/json"

      parameter name: :email,        in: :formData, type: :string, required: true
      parameter name: :username,     in: :formData, type: :string, required: true
      parameter name: :display_name, in: :formData, type: :string
      parameter name: :password,     in: :formData, type: :string, required: true

      response "201", "user registered" do
        let(:email)        { "newuser@example.com" }
        let(:username)     { "newuser" }
        let(:display_name) { "New User" }
        let(:password)     { "Password1!" }

        run_test!
      end

      response "422", "validation failed" do
        let(:email)        { "" }
        let(:username)     { "x" }
        let(:display_name) { nil }
        let(:password)     { "Password1!" }

        run_test!
      end
    end
  end

  path "/api/v1/auth/login" do
    post "Login with email and password" do
      tags "Auth"
      consumes "application/x-www-form-urlencoded"
      produces "application/json"

      parameter name: :email,    in: :formData, type: :string, required: true
      parameter name: :password, in: :formData, type: :string, required: true

      response "200", "login successful" do
        let!(:user) { create(:user, email: "login@example.com", password: "Password1!") }
        let(:email)    { "login@example.com" }
        let(:password) { "Password1!" }

        run_test!
      end

      response "401", "invalid credentials" do
        let(:email)    { "nobody@example.com" }
        let(:password) { "wrongpass" }

        run_test!
      end
    end
  end

  path "/api/v1/auth/me" do
    get "Return the authenticated user" do
      tags "Auth"
      produces "application/json"
      security [bearer_auth: []]

      response "200", "authenticated" do
        let!(:user)         { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
