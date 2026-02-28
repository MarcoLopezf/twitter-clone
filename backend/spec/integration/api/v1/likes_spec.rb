require "swagger_helper"

RSpec.describe "Api::V1::Likes", type: :request do
  path "/api/v1/tweets/{id}/like" do
    post "Like a tweet" do
      tags "Likes"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "ID of the tweet to like"

      response "201", "like created" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id:         { type: :integer, example: 1 },
                     user_id:    { type: :integer, example: 7 },
                     tweet_id:   { type: :integer, example: 3 },
                     created_at: { type: :string, example: "2026-02-27T21:07:21.891Z" }
                   }
                 }
               }

        let!(:current_user) { create(:user) }
        let!(:tweet)        { create(:tweet) }
        let(:id)            { tweet.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "422", "already liked" do
        schema type: :object,
               properties: {
                 error:   { type: :string, example: "Validation failed" },
                 details: { type: :array, items: { type: :string } }
               }

        let!(:current_user) { create(:user) }
        let!(:tweet)        { create(:tweet) }
        let!(:_like)        { create(:like, user: current_user, tweet: tweet) }
        let(:id)            { tweet.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let!(:tweet) { create(:tweet) }
        let(:id)     { tweet.id }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path "/api/v1/tweets/{id}/unlike" do
    delete "Unlike a tweet" do
      tags "Likes"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "ID of the tweet to unlike"

      response "204", "unliked successfully" do
        let!(:current_user) { create(:user) }
        let!(:tweet)        { create(:tweet) }
        let!(:_like)        { create(:like, user: current_user, tweet: tweet) }
        let(:id)            { tweet.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "422", "not liked" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Not liked" }
               }

        let!(:current_user) { create(:user) }
        let!(:tweet)        { create(:tweet) }
        let(:id)            { tweet.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let!(:tweet) { create(:tweet) }
        let(:id)     { tweet.id }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
