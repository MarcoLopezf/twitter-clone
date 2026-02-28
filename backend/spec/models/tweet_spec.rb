require "rails_helper"

RSpec.describe Tweet, type: :model do
  describe "fields" do
    it { is_expected.to respond_to(:content) }
    it { is_expected.to respond_to(:user_id) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(280) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "scopes" do
    describe ".recent" do
      it "returns tweets ordered by created_at descending" do
        older_tweet = create(:tweet, created_at: 2.hours.ago)
        newer_tweet = create(:tweet, created_at: 1.hour.ago)

        expect(Tweet.recent).to eq([ newer_tweet, older_tweet ])
      end
    end

    describe ".by_users" do
      it "returns tweets from the given user ids ordered by created_at descending" do
        user_a = create(:user)
        user_b = create(:user)
        other_user = create(:user)

        older_tweet = create(:tweet, user: user_a, created_at: 2.hours.ago)
        newer_tweet = create(:tweet, user: user_b, created_at: 1.hour.ago)
        _excluded_tweet = create(:tweet, user: other_user)

        result = Tweet.by_users([ user_a.id, user_b.id ])

        expect(result).to eq([ newer_tweet, older_tweet ])
      end

      it "returns an ActiveRecord::Relation" do
        expect(Tweet.by_users([])).to be_a(ActiveRecord::Relation)
      end
    end
  end
end
