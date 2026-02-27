require "rails_helper"

RSpec.describe "Api::V1::Tweets", type: :request do
  describe "POST /api/v1/tweets" do
    context "when authenticated" do
      let(:user) { create(:user) }
      let(:headers) { { "Authorization" => "Bearer #{user.generate_jwt}" } }

      context "with valid content" do
        it "creates a tweet and returns 201" do
          post "/api/v1/tweets", params: { content: "Hello world" }, headers: headers

          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json["data"]["content"]).to eq("Hello world")
        end
      end

      context "with content over 280 characters" do
        it "returns 422" do
          post "/api/v1/tweets", params: { content: "a" * 281 }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        post "/api/v1/tweets", params: { content: "Hello world" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/tweets/:id" do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:tweet) { create(:tweet, user: owner) }

    context "when authenticated as owner" do
      it "deletes the tweet and returns 204" do
        headers = { "Authorization" => "Bearer #{owner.generate_jwt}" }

        delete "/api/v1/tweets/#{tweet.id}", headers: headers

        expect(response).to have_http_status(:no_content)
        expect(Tweet.find_by(id: tweet.id)).to be_nil
      end
    end

    context "when authenticated as non-owner" do
      it "returns 403" do
        headers = { "Authorization" => "Bearer #{other_user.generate_jwt}" }

        delete "/api/v1/tweets/#{tweet.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        delete "/api/v1/tweets/#{tweet.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/tweets/timeline" do
    context "when authenticated" do
      let(:user) { create(:user) }
      let(:headers) { { "Authorization" => "Bearer #{user.generate_jwt}" } }

      it "returns paginated timeline with own tweets and followed users tweets" do
        followed_user = create(:user)
        create(:follow, follower: user, followed: followed_user)

        own_tweet      = create(:tweet, user: user)
        followed_tweet = create(:tweet, user: followed_user)
        outsider_tweet = create(:tweet, user: create(:user))

        get "/api/v1/tweets/timeline", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        tweet_ids = json["data"].map { |t| t["id"] }

        expect(tweet_ids).to include(own_tweet.id, followed_tweet.id)
        expect(tweet_ids).not_to include(outsider_tweet.id)
        expect(json["meta"]).to include("total", "page")
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        get "/api/v1/tweets/timeline"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
