require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/register" do
    let(:valid_params) do
      {
        email: "alice@example.com",
        username: "alice",
        display_name: "Alice",
        password: "Password1!"
      }
    end

    context "with valid params" do
      it "returns 201 and a token" do
        post "/api/v1/auth/register", params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["data"]["token"]).to be_present
        expect(json["data"]["user"]["username"]).to eq("alice")
      end
    end

    context "with a duplicate email" do
      before { create(:user, email: "alice@example.com", username: "other") }

      it "returns 422 with an error" do
        post "/api/v1/auth/register", params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end
    end

    context "with a duplicate username" do
      before { create(:user, email: "other@example.com", username: "alice") }

      it "returns 422 with an error" do
        post "/api/v1/auth/register", params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end
    end

    context "with missing fields" do
      it "returns 422 when email is absent" do
        post "/api/v1/auth/register", params: valid_params.except(:email)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end

      it "returns 422 when password is absent" do
        post "/api/v1/auth/register", params: valid_params.except(:password)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "bob@example.com", password: "Password1!") }

    context "with correct credentials" do
      it "returns 200 and a token" do
        post "/api/v1/auth/login", params: { email: "bob@example.com", password: "Password1!" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"]["token"]).to be_present
        expect(json["data"]["user"]["email"]).to eq("bob@example.com")
      end
    end

    context "with wrong password" do
      it "returns 401" do
        post "/api/v1/auth/login", params: { email: "bob@example.com", password: "WrongPass!" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end
    end

    context "when user does not exist" do
      it "returns 401" do
        post "/api/v1/auth/login", params: { email: "ghost@example.com", password: "Password1!" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end
    end
  end

  describe "GET /api/v1/auth/me" do
    let!(:user) { create(:user) }

    context "with a valid token" do
      it "returns 200 and the current user" do
        token = user.generate_jwt

        get "/api/v1/auth/me", headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"]["user"]["id"]).to eq(user.id)
      end
    end

    context "without a token" do
      it "returns 401" do
        get "/api/v1/auth/me"

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end
    end

    context "with an invalid token" do
      it "returns 401" do
        get "/api/v1/auth/me", headers: { "Authorization" => "Bearer invalid.token.here" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end
    end
  end
end
