require "rails_helper"

RSpec.describe Like, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:tweet) }
  end

  describe "validations" do
    subject { build(:like) }

    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:tweet_id) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:tweet_id) }
  end

  describe "User associations through likes" do
    let(:user)    { create(:user) }
    let(:tweet_a) { create(:tweet) }
    let(:tweet_b) { create(:tweet) }

    before do
      create(:like, user: user, tweet: tweet_a)
      create(:like, user: user, tweet: tweet_b)
    end

    it "user has_many liked_tweets through likes" do
      expect(user.liked_tweets).to include(tweet_a, tweet_b)
    end
  end

  describe "Tweet associations" do
    let(:tweet)   { create(:tweet) }
    let(:user_a)  { create(:user) }
    let(:user_b)  { create(:user) }

    before do
      create(:like, user: user_a, tweet: tweet)
      create(:like, user: user_b, tweet: tweet)
    end

    it "tweet has_many likes" do
      expect(tweet.likes.count).to eq(2)
    end
  end
end
