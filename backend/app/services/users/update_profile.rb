module Users
  class UpdateProfile
    def initialize(user, profile_params)
      @user          = user
      @profile_params = profile_params
    end

    def call
      @user.update(@profile_params)
      @user
    end
  end
end
