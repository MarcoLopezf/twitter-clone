require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:password) }

    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:username).case_insensitive }

    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("not-an-email").for(:email) }
    it { should_not allow_value("missing@").for(:email) }

    it { should validate_length_of(:username).is_at_least(3).is_at_most(30) }
    it { should validate_length_of(:bio).is_at_most(160) }
  end

  describe "has_secure_password" do
    it "authenticates with the correct password" do
      user = create(:user, password: "secret123")
      expect(user.authenticate("secret123")).to eq(user)
    end

    it "rejects an incorrect password" do
      user = create(:user, password: "secret123")
      expect(user.authenticate("wrongpassword")).to be_falsey
    end
  end

  describe "#generate_jwt" do
    it "returns a JWT token string" do
      user = create(:user)
      token = user.generate_jwt
      expect(token).to be_a(String)
      expect(token.split(".").length).to eq(3)
    end

    it "encodes the user id in the token payload" do
      user = create(:user)
      token = user.generate_jwt
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      expect(decoded.first["user_id"]).to eq(user.id)
    end
  end

  describe ".from_token" do
    it "returns the user corresponding to a valid token" do
      user = create(:user)
      token = user.generate_jwt
      expect(User.from_token(token)).to eq(user)
    end

    it "returns nil for an invalid token" do
      expect(User.from_token("invalid.token.string")).to be_nil
    end

    it "returns nil for a nil token" do
      expect(User.from_token(nil)).to be_nil
    end
  end
end
