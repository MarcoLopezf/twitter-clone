require "swagger_helper"

RSpec.describe "Api::V1::Follows", type: :request do
  path "/api/v1/users/{id}/follow" do
    post "Follow a user" do
      tags "Follows"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "ID of the user to follow"

      response "201", "follow created" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id:           { type: :integer, example: 1 },
                     follower_id:  { type: :integer, example: 6 },
                     following_id: { type: :integer, example: 5 },
                     created_at:   { type: :string, example: "2026-02-27T20:53:54.595Z" }
                   }
                 }
               }

        let!(:current_user) { create(:user) }
        let!(:target_user)  { create(:user) }
        let(:id)            { target_user.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "422", "already following" do
        schema type: :object,
               properties: {
                 error:   { type: :string, example: "Validation failed" },
                 details: { type: :array, items: { type: :string } }
               }

        let!(:current_user) { create(:user) }
        let!(:target_user)  { create(:user) }
        let!(:_follow)      { create(:follow, follower: current_user, followed: target_user) }
        let(:id)            { target_user.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "422", "cannot follow yourself" do
        schema type: :object,
               properties: {
                 error:   { type: :string, example: "Validation failed" },
                 details: { type: :array, items: { type: :string } }
               }

        let!(:current_user) { create(:user) }
        let(:id)            { current_user.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let!(:target_user) { create(:user) }
        let(:id)           { target_user.id }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path "/api/v1/users/{id}/unfollow" do
    delete "Unfollow a user" do
      tags "Follows"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "ID of the user to unfollow"

      response "204", "unfollowed successfully" do
        let!(:current_user) { create(:user) }
        let!(:target_user)  { create(:user) }
        let!(:_follow)      { create(:follow, follower: current_user, followed: target_user) }
        let(:id)            { target_user.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "422", "not following this user" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Not following this user" }
               }

        let!(:current_user) { create(:user) }
        let!(:target_user)  { create(:user) }
        let(:id)            { target_user.id }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let!(:target_user) { create(:user) }
        let(:id)           { target_user.id }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path "/api/v1/users/{id}/followers" do
    get "List followers of a user" do
      tags "Follows"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "ID of the user whose followers to list"
      parameter name: :page, in: :query, type: :integer, required: false,
                description: "Page number (default: 1)"

      response "200", "paginated followers list" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id:           { type: :integer },
                       email:        { type: :string },
                       username:     { type: :string },
                       display_name: { type: :string },
                       bio:          { type: :string, nullable: true },
                       avatar_url:   { type: :string, nullable: true },
                       created_at:   { type: :string }
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

        let!(:user)     { create(:user) }
        let!(:follower) { create(:user) }
        let!(:_follow)  { create(:follow, follower: follower, followed: user) }
        let(:id)        { user.id }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let!(:user) { create(:user) }
        let(:id)    { user.id }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path "/api/v1/users/{id}/following" do
    get "List users followed by a user" do
      tags "Follows"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "ID of the user whose following list to retrieve"
      parameter name: :page, in: :query, type: :integer, required: false,
                description: "Page number (default: 1)"

      response "200", "paginated following list" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id:           { type: :integer },
                       email:        { type: :string },
                       username:     { type: :string },
                       display_name: { type: :string },
                       bio:          { type: :string, nullable: true },
                       avatar_url:   { type: :string, nullable: true },
                       created_at:   { type: :string }
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

        let!(:user)    { create(:user) }
        let!(:followed) { create(:user) }
        let!(:_follow) { create(:follow, follower: user, followed: followed) }
        let(:id)       { user.id }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let!(:user) { create(:user) }
        let(:id)    { user.id }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
