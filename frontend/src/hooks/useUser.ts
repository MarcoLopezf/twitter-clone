import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { followUser, getUserProfile, unfollowUser, updateProfile } from '../services/users'
import type { User } from '../types'

export function useUserProfile(username: string) {
  return useQuery({
    queryKey: ['users', username],
    queryFn: () => getUserProfile(username),
  })
}

export function useFollowUser(username: string) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (userId: number) => followUser(userId),
    onMutate: async () => {
      await queryClient.cancelQueries({ queryKey: ['users', username] })
      const previous = queryClient.getQueryData<User>(['users', username])

      queryClient.setQueryData<User>(['users', username], (old) => {
        if (!old) return old
        return { ...old, is_following: true, followers_count: old.followers_count + 1 }
      })

      return { previous }
    },
    onError: (_error, _variables, context) => {
      if (context?.previous) {
        queryClient.setQueryData(['users', username], context.previous)
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['users', username] })
    },
  })
}

export function useUnfollowUser(username: string) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (userId: number) => unfollowUser(userId),
    onMutate: async () => {
      await queryClient.cancelQueries({ queryKey: ['users', username] })
      const previous = queryClient.getQueryData<User>(['users', username])

      queryClient.setQueryData<User>(['users', username], (old) => {
        if (!old) return old
        return { ...old, is_following: false, followers_count: old.followers_count - 1 }
      })

      return { previous }
    },
    onError: (_error, _variables, context) => {
      if (context?.previous) {
        queryClient.setQueryData(['users', username], context.previous)
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['users', username] })
    },
  })
}

export function useUpdateProfile(username: string) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: updateProfile,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users', username] })
    },
  })
}
