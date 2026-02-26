module Auth
  class AuthenticateUser
    INVALID_CREDENTIALS_MESSAGE = "Invalid email or password"

    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.find_by("LOWER(email) = ?", @email.to_s.downcase)

      if user&.authenticate(@password)
        { success: true, user: user, token: user.generate_jwt }
      else
        { success: false, error: INVALID_CREDENTIALS_MESSAGE }
      end
    end
  end
end
