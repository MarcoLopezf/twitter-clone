import { Link } from 'react-router-dom'
import { Avatar } from './Avatar'
import type { Tweet } from '../../types'

interface TweetCardProps {
  tweet: Tweet
  onLike?: (id: number, liked: boolean) => void
  onDelete?: (id: number) => void
  currentUserId?: number
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

export function TweetCard({ tweet, onLike, onDelete, currentUserId }: TweetCardProps) {
  const isOwn = currentUserId === tweet.user.id

  return (
    <article className="group flex gap-3 border-b border-zinc-100 px-4 py-4 transition-colors hover:bg-zinc-50/60 dark:border-zinc-800/70 dark:hover:bg-zinc-900/40">
      <Link to={`/profile/${tweet.user.username}`} className="shrink-0">
        <Avatar
          avatarUrl={tweet.user.avatar_url}
          displayName={tweet.user.display_name}
          username={tweet.user.username}
          size="md"
        />
      </Link>

      <div className="min-w-0 flex-1">
        {/* Header */}
        <div className="flex flex-wrap items-baseline gap-x-1.5 gap-y-0">
          <Link
            to={`/profile/${tweet.user.username}`}
            className="text-[15px] font-bold text-zinc-900 hover:underline dark:text-zinc-100"
          >
            {tweet.user.display_name ?? tweet.user.username}
          </Link>
          <span className="text-sm text-zinc-500 dark:text-zinc-400">
            @{tweet.user.username}
          </span>
          <span className="text-sm text-zinc-300 dark:text-zinc-600">·</span>
          <time className="text-sm text-zinc-400 dark:text-zinc-500">
            {formatRelativeTime(tweet.created_at)}
          </time>
        </div>

        {/* Content */}
        <p className="mt-1.5 whitespace-pre-wrap break-words text-[15px] leading-relaxed text-zinc-800 dark:text-zinc-200">
          {tweet.content}
        </p>

        {/* Actions */}
        <div className="mt-3 flex items-center gap-5">
          {onLike ? (
            <button
              onClick={() => onLike(tweet.id, tweet.liked_by_current_user)}
              className={[
                'group/like flex items-center gap-1.5 text-sm transition-colors',
                tweet.liked_by_current_user
                  ? 'text-rose-500 dark:text-rose-400'
                  : 'text-zinc-400 hover:text-rose-500 dark:text-zinc-500 dark:hover:text-rose-400',
              ].join(' ')}
            >
              <span className="text-base transition-transform group-hover/like:scale-125">
                {tweet.liked_by_current_user ? '❤️' : '🤍'}
              </span>
              <span className="tabular-nums">{tweet.likes_count}</span>
            </button>
          ) : (
            <span className="flex items-center gap-1.5 text-sm text-zinc-400 dark:text-zinc-500">
              <span className="text-base">❤️</span>
              <span className="tabular-nums">{tweet.likes_count}</span>
            </span>
          )}

          {isOwn && onDelete && (
            <button
              onClick={() => onDelete(tweet.id)}
              className="text-sm text-zinc-300 opacity-0 transition-all group-hover:opacity-100 hover:text-red-500 dark:text-zinc-600 dark:hover:text-red-400"
            >
              Delete
            </button>
          )}
        </div>
      </div>
    </article>
  )
}
