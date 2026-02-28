import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createTweet } from '../../services/tweets'
import { Button } from '../common/Button'

const MAX_TWEET_LENGTH = 280

export function TweetComposer() {
  const [content, setContent] = useState('')
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: () => createTweet(content),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['timeline'] })
      setContent('')
    },
  })

  const isDisabled = content.trim().length === 0 || content.length > MAX_TWEET_LENGTH

  function handleSubmit(event: React.FormEvent) {
    event.preventDefault()
    mutation.mutate()
  }

  return (
    <form onSubmit={handleSubmit} className="border-b border-zinc-100 px-4 py-4 dark:border-zinc-800">
      <textarea
        aria-label="Tweet content"
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder="What's happening?"
        rows={3}
        className="w-full resize-none bg-transparent text-zinc-900 placeholder-zinc-400 focus:outline-none dark:text-zinc-100 dark:placeholder-zinc-500"
      />
      <div className="mt-2 flex items-center justify-between">
        <span
          className={
            content.length > MAX_TWEET_LENGTH
              ? 'text-sm text-red-500'
              : 'text-sm text-zinc-400 dark:text-zinc-500'
          }
        >
          {content.length} / {MAX_TWEET_LENGTH}
        </span>
        <Button
          type="submit"
          variant="primary"
          disabled={isDisabled}
          isLoading={mutation.isPending}
        >
          Tweet
        </Button>
      </div>
    </form>
  )
}
