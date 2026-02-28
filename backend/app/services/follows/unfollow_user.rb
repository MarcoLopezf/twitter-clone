module Follows
  class UnfollowUser
    def initialize(follower:, followed:)
      @follower = follower
      @followed = followed
    end

    def call
      follow = @follower.active_follows.find_by(followed: @followed)

      return { success: false, errors: [ "Not following this user" ] } unless follow

      follow.destroy
      { success: true }
    end
  end
end
