import { useAuth } from '../hooks/useAuth'
import { useSearch } from '../hooks/useSearch'
import { UserCard } from '../components/users/UserCard'
import { LoadingSpinner } from '../components/common/LoadingSpinner'

export function SearchPage() {
  const { user: currentUser } = useAuth()
  const { inputValue, setInputValue, results, isLoading, isQueryValid } = useSearch()

  return (
    <div className="mx-auto max-w-xl px-4 py-6">
      <h1 className="mb-4 text-xl font-bold text-zinc-900 dark:text-zinc-100">Search</h1>

      <input
        type="search"
        value={inputValue}
        onChange={(event) => setInputValue(event.target.value)}
        placeholder="Search people..."
        className="w-full rounded-full border border-zinc-200 bg-zinc-100 px-4 py-2 text-sm text-zinc-900 outline-none transition focus:border-sky-500 focus:ring-2 focus:ring-sky-500/20 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:placeholder-zinc-500 dark:focus:border-sky-400"
      />

      <div className="mt-4">
        {isLoading && <LoadingSpinner size="md" />}

        {!isLoading && isQueryValid && results.length === 0 && (
          <p className="text-center text-sm text-zinc-500 dark:text-zinc-400">
            No results for &ldquo;{inputValue}&rdquo;
          </p>
        )}

        {!isLoading && results.length > 0 && (
          <ul>
            {results.map((user) => (
              <li key={user.id}>
                <UserCard user={user} currentUserId={currentUser?.id} />
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  )
}
