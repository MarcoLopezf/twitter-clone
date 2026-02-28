import { useInfiniteQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getTimeline, deleteTweet, likeTweet, unlikeTweet } from '../services/tweets'
import type { PaginatedResponse, Tweet } from '../types'

export function useTimeline() {
  const queryClient = useQueryClient()

  const query = useInfiniteQuery<PaginatedResponse<Tweet>>({
    queryKey: ['timeline'],
    queryFn: ({ pageParam }) => getTimeline(pageParam as number),
    initialPageParam: 1,
    getNextPageParam: (lastPage) => lastPage.meta.next_page ?? undefined,
  })

  const tweets = query.data?.pages.flatMap((page) => page.data) ?? []

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteTweet(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['timeline'] }),
  })

  const likeMutation = useMutation({
    mutationFn: ({ id, liked }: { id: number; liked: boolean }) =>
      liked ? unlikeTweet(id) : likeTweet(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['timeline'] }),
  })

  return {
    tweets,
    isLoading: query.isLoading,
    isError: query.isError,
    hasNextPage: query.hasNextPage,
    isFetchingNextPage: query.isFetchingNextPage,
    fetchNextPage: query.fetchNextPage,
    deleteTweet: (id: number) => deleteMutation.mutate(id),
    toggleLike: (id: number, liked: boolean) => likeMutation.mutate({ id, liked }),
  }
}
