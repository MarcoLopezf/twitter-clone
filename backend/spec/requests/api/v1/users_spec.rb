require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  describe "GET /api/v1/users/:username" do
    let(:target_user)  { create(:user) }
    let(:current_user) { create(:user) }
    let(:headers)      { { "Authorization" => "Bearer #{current_user.generate_jwt}" } }

    context "when authenticated" do
      context "with a valid username" do
        it "returns the public profile with counts and is_following false" do
          get "/api/v1/users/#{target_user.username}", headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          data = json["data"]["attributes"]
          expect(data["username"]).to eq(target_user.username)
          expect(data["display_name"]).to eq(target_user.display_name)
          expect(data["bio"]).to eq(target_user.bio)
          expect(data["avatar_url"]).to eq(target_user.avatar_url)
          expect(data["tweet_count"]).to eq(0)
          expect(data["followers_count"]).to eq(0)
          expect(data["following_count"]).to eq(0)
          expect(data["is_following"]).to eq(false)
        end

        it "reflects tweet_count correctly" do
          create_list(:tweet, 3, user: target_user)

          get "/api/v1/users/#{target_user.username}", headers: headers

          json = JSON.parse(response.body)
          expect(json["data"]["attributes"]["tweet_count"]).to eq(3)
        end

        it "reflects is_following true when current user follows target" do
          create(:follow, follower: current_user, followed: target_user)

          get "/api/v1/users/#{target_user.username}", headers: headers

          json = JSON.parse(response.body)
          expect(json["data"]["attributes"]["is_following"]).to eq(true)
        end
      end

      context "with an unknown username" do
        it "returns 404" do
          get "/api/v1/users/nonexistent_user_xyz", headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        get "/api/v1/users/#{target_user.username}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/v1/users/me" do
    let(:current_user) { create(:user) }
    let(:headers)      { { "Authorization" => "Bearer #{current_user.generate_jwt}" } }

    context "when authenticated" do
      context "with valid params" do
        it "updates display_name and returns 200" do
          patch "/api/v1/users/me",
                params: { display_name: "New Name" },
                headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["data"]["attributes"]["display_name"]).to eq("New Name")
        end

        it "updates bio and returns 200" do
          patch "/api/v1/users/me",
                params: { bio: "My new bio" },
                headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["data"]["attributes"]["bio"]).to eq("My new bio")
        end

        it "updates avatar_url and returns 200" do
          patch "/api/v1/users/me",
                params: { avatar_url: "https://example.com/avatar.png" },
                headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["data"]["attributes"]["avatar_url"]).to eq("https://example.com/avatar.png")
        end

        it "persists the changes to the database" do
          patch "/api/v1/users/me",
                params: { display_name: "Persisted Name", bio: "Persisted bio" },
                headers: headers

          current_user.reload
          expect(current_user.display_name).to eq("Persisted Name")
          expect(current_user.bio).to eq("Persisted bio")
        end
      end

      context "with invalid params" do
        it "returns 422 when bio exceeds 160 characters" do
          patch "/api/v1/users/me",
                params: { bio: "a" * 161 },
                headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["error"]).to be_present
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        patch "/api/v1/users/me", params: { display_name: "Hacker" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/users/search" do
    let(:current_user) { create(:user) }
    let(:headers)      { { "Authorization" => "Bearer #{current_user.generate_jwt}" } }

    context "when authenticated" do
      context "with a matching query on username" do
        it "returns matching users and 200" do
          matched = create(:user, username: "rustacean42")
          create(:user, username: "unrelated_xyz")

          get "/api/v1/users/search", params: { q: "rustacean" }, headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          usernames = json["data"].map { |u| u["attributes"]["username"] }
          expect(usernames).to include(matched.username)
          expect(usernames).not_to include("unrelated_xyz")
        end
      end

      context "with a matching query on display_name" do
        it "returns matching users and 200" do
          matched = create(:user, display_name: "Gopher King")
          create(:user, display_name: "Nobody")

          get "/api/v1/users/search", params: { q: "Gopher" }, headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          display_names = json["data"].map { |u| u["attributes"]["display_name"] }
          expect(display_names).to include(matched.display_name)
        end
      end

      context "with an empty query" do
        it "returns an empty array and 200" do
          get "/api/v1/users/search", params: { q: "" }, headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["data"]).to eq([])
        end
      end

      context "with no query param" do
        it "returns an empty array and 200" do
          get "/api/v1/users/search", headers: headers

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["data"]).to eq([])
        end
      end

      context "with pagination" do
        it "returns meta with total and page" do
          3.times { |i| create(:user, username: "searchable#{i}#{SecureRandom.hex(3)}") }

          get "/api/v1/users/search", params: { q: "searchable" }, headers: headers

          json = JSON.parse(response.body)
          expect(json["meta"]).to include("total", "page")
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        get "/api/v1/users/search", params: { q: "test" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
