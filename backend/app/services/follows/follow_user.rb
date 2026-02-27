module Follows
  class FollowUser
    def initialize(follower:, followed:)
      @follower = follower
      @followed = followed
    end

    def call
      follow = @follower.active_follows.build(followed: @followed)

      if follow.save
        { success: true, follow: follow }
      else
        { success: false, errors: follow.errors.full_messages }
      end
    end
  end
end
