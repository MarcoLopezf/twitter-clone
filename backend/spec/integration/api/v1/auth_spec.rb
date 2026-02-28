require "swagger_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  path "/api/v1/auth/register" do
    post "Register a new user" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %w[email username password],
        properties: {
          email:        { type: :string, example: "newuser@example.com" },
          username:     { type: :string, example: "newuser" },
          display_name: { type: :string, example: "New User" },
          password:     { type: :string, example: "Password1!" },
          bio:          { type: :string, example: "Hello world" },
          avatar_url:   { type: :string, example: "https://example.com/avatar.png" }
        }
      }

      response "201", "user registered" do
        let(:body) { { email: "newuser@example.com", username: "newuser", display_name: "New User", password: "Password1!" } }

        run_test!
      end

      response "422", "validation failed" do
        let(:body) { { email: "", username: "x", password: "Password1!" } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/login" do
    post "Login with email and password" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %w[email password],
        properties: {
          email:    { type: :string, example: "docuser@example.com" },
          password: { type: :string, example: "Password1!" }
        }
      }

      response "200", "login successful" do
        let!(:user) { create(:user, email: "login@example.com", password: "Password1!") }
        let(:body)  { { email: "login@example.com", password: "Password1!" } }

        run_test!
      end

      response "401", "invalid credentials" do
        let(:body) { { email: "nobody@example.com", password: "wrongpass" } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/me" do
    get "Return the authenticated user" do
      tags "Auth"
      produces "application/json"
      security [ bearer_auth: [] ]

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
