require "rails_helper"

RSpec.describe "Api::V1::Follows", type: :request do
  describe "POST /api/v1/users/:id/follow" do
    let(:current_user) { create(:user) }
    let(:target_user)  { create(:user) }
    let(:headers)      { { "Authorization" => "Bearer #{current_user.generate_jwt}" } }

    context "when authenticated" do
      context "with a valid target user not yet followed" do
        it "creates the follow and returns 201" do
          post "/api/v1/users/#{target_user.id}/follow", headers: headers

          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json["data"]["following_id"]).to eq(target_user.id)
        end
      end

      context "when already following the target user" do
        before { create(:follow, follower: current_user, followed: target_user) }

        it "returns 422" do
          post "/api/v1/users/#{target_user.id}/follow", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["error"]).to be_present
        end
      end

      context "when trying to follow yourself" do
        it "returns 422" do
          post "/api/v1/users/#{current_user.id}/follow", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["error"]).to be_present
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        post "/api/v1/users/#{target_user.id}/follow"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/users/:id/unfollow" do
    let(:current_user) { create(:user) }
    let(:target_user)  { create(:user) }
    let(:headers)      { { "Authorization" => "Bearer #{current_user.generate_jwt}" } }

    context "when authenticated" do
      context "when following the target user" do
        before { create(:follow, follower: current_user, followed: target_user) }

        it "destroys the follow and returns 204" do
          delete "/api/v1/users/#{target_user.id}/unfollow", headers: headers

          expect(response).to have_http_status(:no_content)
          expect(current_user.following).not_to include(target_user)
        end
      end

      context "when not following the target user" do
        it "returns 422" do
          delete "/api/v1/users/#{target_user.id}/unfollow", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["error"]).to be_present
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        delete "/api/v1/users/#{target_user.id}/unfollow"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/users/:id/followers" do
    let(:user)    { create(:user) }
    let(:headers) { { "Authorization" => "Bearer #{user.generate_jwt}" } }

    context "when authenticated" do
      it "returns paginated list of followers with 200" do
        follower_one = create(:user)
        follower_two = create(:user)
        create(:follow, follower: follower_one, followed: user)
        create(:follow, follower: follower_two, followed: user)

        get "/api/v1/users/#{user.id}/followers", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(2)
        expect(json["meta"]).to include("total", "page")
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        get "/api/v1/users/#{user.id}/followers"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/users/:id/following" do
    let(:user)    { create(:user) }
    let(:headers) { { "Authorization" => "Bearer #{user.generate_jwt}" } }

    context "when authenticated" do
      it "returns paginated list of followed users with 200" do
        followed_one = create(:user)
        followed_two = create(:user)
        create(:follow, follower: user, followed: followed_one)
        create(:follow, follower: user, followed: followed_two)

        get "/api/v1/users/#{user.id}/following", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(2)
        expect(json["meta"]).to include("total", "page")
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        get "/api/v1/users/#{user.id}/following"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
