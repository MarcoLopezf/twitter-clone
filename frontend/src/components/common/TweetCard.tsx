import { Link } from 'react-router-dom'
import { Avatar } from './Avatar'
import type { Tweet } from '../../types'

interface TweetCardProps {
  tweet: Tweet
}

function formatRelativeTime(dateString: string): string {
  const diff = Date.now() - new Date(dateString).getTime()
  const minutes = Math.floor(diff / 60_000)
  if (minutes < 1) return 'just now'
  if (minutes < 60) return `${minutes}m`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h`
  const days = Math.floor(hours / 24)
  return `${days}d`
}

export function TweetCard({ tweet }: TweetCardProps) {
  return (
    <article className="flex gap-3 border-b border-zinc-100 px-4 py-3 dark:border-zinc-800">
      <Link to={`/profile/${tweet.user.username}`} className="shrink-0">
        <Avatar
          avatarUrl={tweet.user.avatar_url}
          displayName={tweet.user.display_name}
          username={tweet.user.username}
          size="md"
        />
      </Link>
      <div className="min-w-0 flex-1">
        <div className="flex items-baseline gap-1">
          <Link
            to={`/profile/${tweet.user.username}`}
            className="truncate text-sm font-semibold text-zinc-900 hover:underline dark:text-zinc-100"
          >
            {tweet.user.display_name ?? tweet.user.username}
          </Link>
          <span className="shrink-0 text-sm text-zinc-500 dark:text-zinc-400">
            @{tweet.user.username}
          </span>
          <span className="shrink-0 text-sm text-zinc-400 dark:text-zinc-500">·</span>
          <time className="shrink-0 text-sm text-zinc-400 dark:text-zinc-500">
            {formatRelativeTime(tweet.created_at)}
          </time>
        </div>
        <p className="mt-1 whitespace-pre-wrap break-words text-sm text-zinc-800 dark:text-zinc-200">
          {tweet.content}
        </p>
        <p className="mt-2 text-xs text-zinc-400 dark:text-zinc-500">
          {tweet.likes_count} {tweet.likes_count === 1 ? 'like' : 'likes'}
        </p>
      </div>
    </article>
  )
}
