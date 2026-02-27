require "swagger_helper"

RSpec.describe "Api::V1::Tweets", type: :request do
  path "/api/v1/tweets" do
    post "Create a tweet" do
      tags "Tweets"
      consumes "application/json"
      produces "application/json"
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        required: ["content"],
        properties: {
          content: { type: :string, example: "Hello from the Flock API!" }
        }
      }

      response "201", "tweet created" do
        let!(:user)         { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:body)          { { content: "Hello from the Flock API!" } }

        run_test!
      end

      response "422", "content too long" do
        let!(:user)         { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:body)          { { content: "a" * 281 } }

        run_test!
      end

      response "401", "unauthenticated" do
        let(:Authorization) { nil }
        let(:body)          { { content: "Hello world" } }

        run_test!
      end
    end
  end

  path "/api/v1/tweets/{id}" do
    delete "Delete a tweet" do
      tags "Tweets"
      produces "application/json"
      security [bearer_auth: []]

      parameter name: :id, in: :path, type: :integer, required: true

      response "204", "tweet deleted" do
        let!(:user)         { create(:user) }
        let!(:tweet)        { create(:tweet, user: user) }
        let(:id)            { tweet.id }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }

        run_test!
      end

      response "403", "not the owner" do
        let!(:owner)        { create(:user) }
        let!(:other_user)   { create(:user) }
        let!(:tweet)        { create(:tweet, user: owner) }
        let(:id)            { tweet.id }
        let(:Authorization) { "Bearer #{other_user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        let!(:tweet)        { create(:tweet) }
        let(:id)            { tweet.id }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path "/api/v1/tweets/timeline" do
    get "Get paginated timeline" do
      tags "Tweets"
      produces "application/json"
      security [bearer_auth: []]

      parameter name: :page, in: :query, type: :integer, required: false,
                description: "Page number (default: 1)"

      response "200", "paginated timeline" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id:                    { type: :integer },
                       content:               { type: :string },
                       created_at:            { type: :string },
                       likes_count:           { type: :integer },
                       liked_by_current_user: { type: :boolean },
                       user: {
                         type: :object,
                         properties: {
                           id:           { type: :integer },
                           username:     { type: :string },
                           display_name: { type: :string },
                           avatar_url:   { type: :string, nullable: true }
                         }
                       }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     total: { type: :integer, example: 1 },
                     page:  { type: :integer, example: 1 }
                   }
                 }
               }

        let!(:user)         { create(:user) }
        let!(:tweet)        { create(:tweet, user: user) }
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
