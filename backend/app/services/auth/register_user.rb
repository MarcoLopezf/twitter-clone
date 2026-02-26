module Auth
  class RegisterUser
    def initialize(params)
      @params = params
    end

    def call
      user = User.new(@params)

      if user.save
        { success: true, user: user, token: user.generate_jwt }
      else
        { success: false, errors: user.errors }
      end
    end
  end
end
