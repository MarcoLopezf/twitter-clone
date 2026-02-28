require "swagger_helper"

USER_PROFILE_SCHEMA = {
  type: :object,
  properties: {
    data: {
      type: :object,
      properties: {
        id:   { type: :string, example: "2" },
        type: { type: :string, example: "user" },
        attributes: {
          type: :object,
          properties: {
            id:              { type: :integer, example: 2 },
            email:           { type: :string, example: "docuser@example.com" },
            username:        { type: :string, example: "docuser" },
            display_name:    { type: :string, example: "Doc User" },
            bio:             { type: :string, nullable: true, example: "A short bio." },
            avatar_url:      { type: :string, nullable: true, example: "https://example.com/avatar.png" },
            created_at:      { type: :string, example: "2026-02-26T19:41:16.797Z" },
            tweet_count:     { type: :integer, example: 0 },
            followers_count: { type: :integer, example: 0 },
            following_count: { type: :integer, example: 0 },
            is_following:    { type: :boolean, example: false }
          }
        }
      }
    }
  }
}.freeze

RSpec.describe "Api::V1::Users", type: :request do
  path "/api/v1/users/{username}" do
    get "Get a user's public profile" do
      tags "Users"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :username, in: :path, type: :string, required: true,
                description: "Username of the user"

      response "200", "profile returned" do
        schema USER_PROFILE_SCHEMA

        let!(:target_user)  { create(:user) }
        let!(:current_user) { create(:user) }
        let(:username)      { target_user.username }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "404", "user not found" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Not found" }
               }

        let!(:current_user) { create(:user) }
        let(:username)      { "nonexistent_user_xyz" }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let!(:target_user) { create(:user) }
        let(:username)     { target_user.username }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path "/api/v1/users/me" do
    patch "Update current user's profile" do
      tags "Users"
      consumes "application/x-www-form-urlencoded"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :display_name, in: :formData, type: :string, required: false,
                description: "New display name"
      parameter name: :bio, in: :formData, type: :string, required: false,
                description: "New bio (max 160 characters)"
      parameter name: :avatar_url, in: :formData, type: :string, required: false,
                description: "New avatar URL"

      response "200", "profile updated" do
        schema USER_PROFILE_SCHEMA

        let!(:current_user) { create(:user) }
        let(:display_name)  { "Updated Name" }
        let(:bio)           { "A short bio." }
        let(:avatar_url)    { "https://example.com/avatar.png" }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "422", "validation error" do
        schema type: :object,
               properties: {
                 error:   { type: :string, example: "Validation failed" },
                 details: { type: :array, items: { type: :string } }
               }

        let!(:current_user) { create(:user) }
        let(:bio)           { "a" * 161 }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let(:display_name)  { "Hacker" }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path "/api/v1/users/search" do
    get "Search users by username or display name" do
      tags "Users"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :q, in: :query, type: :string, required: false,
                description: "Search term (username or display name)"
      parameter name: :page, in: :query, type: :integer, required: false,
                description: "Page number (default: 1)"

      response "200", "search results returned" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id:   { type: :string },
                       type: { type: :string },
                       attributes: {
                         type: :object,
                         properties: {
                           username:        { type: :string },
                           display_name:    { type: :string, nullable: true },
                           bio:             { type: :string, nullable: true },
                           avatar_url:      { type: :string, nullable: true },
                           tweet_count:     { type: :integer },
                           followers_count: { type: :integer },
                           following_count: { type: :integer },
                           is_following:    { type: :boolean }
                         }
                       }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     total: { type: :integer, example: 2 },
                     page:  { type: :integer, example: 1 }
                   }
                 }
               }

        let!(:current_user) { create(:user) }
        let!(:_matched)     { create(:user, username: "searchable_user") }
        let(:q)             { "searchable" }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "200", "empty query returns empty array" do
        schema type: :object,
               properties: {
                 data: { type: :array, items: {}, example: [] },
                 meta: {
                   type: :object,
                   properties: {
                     total: { type: :integer, example: 0 },
                     page:  { type: :integer, example: 1 }
                   }
                 }
               }

        let!(:current_user) { create(:user) }
        let(:q)             { "" }
        let(:Authorization) { "Bearer #{current_user.generate_jwt}" }

        run_test!
      end

      response "401", "unauthenticated" do
        schema type: :object,
               properties: {
                 error: { type: :string, example: "Unauthorized" }
               }

        let(:q)             { "test" }
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
