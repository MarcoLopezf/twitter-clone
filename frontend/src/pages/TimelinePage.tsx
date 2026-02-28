import { useTimeline } from '../hooks/useTimeline'
import { useAuth } from '../hooks/useAuth'
import { TweetComposer } from '../components/tweets/TweetComposer'
import { TweetCard } from '../components/common/TweetCard'
import { LoadingSpinner } from '../components/common/LoadingSpinner'
import { Button } from '../components/common/Button'

export function TimelinePage() {
  const { user } = useAuth()
  const { tweets, isLoading, isError, hasNextPage, isFetchingNextPage, fetchNextPage, toggleLike, deleteTweet } =
    useTimeline()

  return (
    <div className="mx-auto max-w-xl">
      <header className="sticky top-0 z-10 border-b border-zinc-100 bg-white/80 px-4 py-3 backdrop-blur dark:border-zinc-800 dark:bg-zinc-950/80">
        <h1 className="text-lg font-bold text-zinc-900 dark:text-zinc-100">Home</h1>
      </header>

      {user && <TweetComposer />}

      {isLoading && (
        <div className="flex justify-center py-10">
          <LoadingSpinner size="lg" />
        </div>
      )}

      {isError && (
        <p className="px-4 py-6 text-center text-sm text-red-500">
          Failed to load timeline. Please refresh.
        </p>
      )}

      {!isLoading && !isError && tweets.length === 0 && (
        <div className="px-4 py-16 text-center">
          <p className="text-4xl">🐦</p>
          <p className="mt-2 text-sm font-medium text-zinc-700 dark:text-zinc-300">Nothing here yet</p>
          <p className="mt-1 text-xs text-zinc-400 dark:text-zinc-500">
            Follow some people to see their tweets!
          </p>
        </div>
      )}

      {tweets.map((tweet) => (
        <TweetCard
          key={tweet.id}
          tweet={tweet}
          currentUserId={user?.id}
          onLike={toggleLike}
          onDelete={deleteTweet}
        />
      ))}

      {hasNextPage && (
        <div className="flex justify-center py-6">
          <Button variant="secondary" isLoading={isFetchingNextPage} onClick={() => fetchNextPage()}>
            Load more
          </Button>
        </div>
      )}

      <div className="h-20 md:h-4" />
    </div>
  )
}
