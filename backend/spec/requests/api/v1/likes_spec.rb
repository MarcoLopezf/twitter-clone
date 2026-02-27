require "rails_helper"

RSpec.describe "Api::V1::Likes", type: :request do
  describe "POST /api/v1/tweets/:id/like" do
    let(:current_user) { create(:user) }
    let(:tweet)        { create(:tweet) }
    let(:headers)      { { "Authorization" => "Bearer #{current_user.generate_jwt}" } }

    context "when authenticated" do
      context "with a tweet not yet liked" do
        it "creates the like and returns 201" do
          post "/api/v1/tweets/#{tweet.id}/like", headers: headers

          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json["data"]["tweet_id"]).to eq(tweet.id)
          expect(json["data"]["user_id"]).to eq(current_user.id)
        end
      end

      context "when already liked" do
        before { create(:like, user: current_user, tweet: tweet) }

        it "returns 422" do
          post "/api/v1/tweets/#{tweet.id}/like", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["error"]).to be_present
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        post "/api/v1/tweets/#{tweet.id}/like"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/tweets/:id/unlike" do
    let(:current_user) { create(:user) }
    let(:tweet)        { create(:tweet) }
    let(:headers)      { { "Authorization" => "Bearer #{current_user.generate_jwt}" } }

    context "when authenticated" do
      context "when the tweet is liked" do
        before { create(:like, user: current_user, tweet: tweet) }

        it "destroys the like and returns 204" do
          delete "/api/v1/tweets/#{tweet.id}/unlike", headers: headers

          expect(response).to have_http_status(:no_content)
          expect(current_user.liked_tweets).not_to include(tweet)
        end
      end

      context "when the tweet is not liked" do
        it "returns 422" do
          delete "/api/v1/tweets/#{tweet.id}/unlike", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["error"]).to be_present
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        delete "/api/v1/tweets/#{tweet.id}/unlike"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
