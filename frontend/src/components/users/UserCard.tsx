import { Link } from 'react-router-dom'
import { Avatar } from '../common/Avatar'
import { FollowButton } from './FollowButton'
import type { User } from '../../types'

interface UserCardProps {
  user: User
  currentUserId: number | undefined
}

export function UserCard({ user, currentUserId }: UserCardProps) {
  return (
    <div className="flex items-center justify-between gap-3 rounded-xl p-3 transition-colors hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
      <Link
        to={`/profile/${user.username}`}
        className="flex min-w-0 flex-1 items-center gap-3"
      >
        <Avatar
          avatarUrl={user.avatar_url}
          displayName={user.display_name}
          username={user.username}
          size="md"
        />
        <div className="min-w-0">
          <p className="truncate text-sm font-semibold text-zinc-900 dark:text-zinc-100">
            {user.display_name ?? user.username}
          </p>
          <p className="truncate text-sm text-zinc-500 dark:text-zinc-400">@{user.username}</p>
        </div>
      </Link>
      <FollowButton user={user} currentUserId={currentUserId} />
    </div>
  )
}
