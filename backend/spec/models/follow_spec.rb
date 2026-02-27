require "rails_helper"

RSpec.describe Follow, type: :model do
  describe "associations" do
    it { should belong_to(:follower).class_name("User") }
    it { should belong_to(:followed).class_name("User") }
  end

  describe "validations" do
    subject { build(:follow) }

    it { should validate_uniqueness_of(:follower_id).scoped_to(:followed_id) }

    context "cannot follow yourself" do
      it "is invalid when follower and followed are the same user" do
        user   = create(:user)
        follow = build(:follow, follower: user, followed: user)

        expect(follow).not_to be_valid
        expect(follow.errors[:follower_id]).to include("cannot follow yourself")
      end

      it "is valid when follower and followed are different users" do
        follow = build(:follow)
        expect(follow).to be_valid
      end
    end
  end

  describe "User associations through follows" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:user_c) { create(:user) }

    before do
      create(:follow, follower: user_a, followed: user_b)
      create(:follow, follower: user_c, followed: user_a)
    end

    it "user has_many following through active_follows" do
      expect(user_a.following).to include(user_b)
    end

    it "user has_many followers through passive_follows" do
      expect(user_a.followers).to include(user_c)
    end
  end

  describe "User#following?" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }

    it "returns true when user_a follows user_b" do
      create(:follow, follower: user_a, followed: user_b)
      expect(user_a.following?(user_b)).to be true
    end

    it "returns false when user_a does not follow user_b" do
      expect(user_a.following?(user_b)).to be false
    end
  end

  describe "User#followers_count" do
    let(:user) { create(:user) }

    it "returns the number of followers" do
      create(:follow, followed: user)
      create(:follow, followed: user)

      expect(user.followers_count).to eq(2)
    end

    it "returns 0 when there are no followers" do
      expect(user.followers_count).to eq(0)
    end
  end

  describe "User#following_count" do
    let(:user) { create(:user) }

    it "returns the number of users being followed" do
      create(:follow, follower: user)
      create(:follow, follower: user)

      expect(user.following_count).to eq(2)
    end

    it "returns 0 when not following anyone" do
      expect(user.following_count).to eq(0)
    end
  end
end
