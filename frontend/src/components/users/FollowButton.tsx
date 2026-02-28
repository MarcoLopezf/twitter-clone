import { Button } from '../common/Button'
import { useFollowUser, useUnfollowUser } from '../../hooks/useUser'
import type { User } from '../../types'

interface FollowButtonProps {
  user: User
  currentUserId: number | undefined
}

export function FollowButton({ user, currentUserId }: FollowButtonProps) {
  const followMutation = useFollowUser(user.username)
  const unfollowMutation = useUnfollowUser(user.username)

  if (currentUserId === user.id) return null

  const isLoading = followMutation.isPending || unfollowMutation.isPending

  if (user.is_following) {
    return (
      <Button
        variant="secondary"
        isLoading={isLoading}
        onClick={() => unfollowMutation.mutate(user.id)}
      >
        Unfollow
      </Button>
    )
  }

  return (
    <Button
      variant="primary"
      isLoading={isLoading}
      onClick={() => followMutation.mutate(user.id)}
    >
      Follow
    </Button>
  )
}
