import { useState } from 'react'
import { useParams } from 'react-router-dom'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Avatar } from '../components/common/Avatar'
import { Button } from '../components/common/Button'
import { Input } from '../components/common/Input'
import { LoadingSpinner } from '../components/common/LoadingSpinner'
import { TweetCard } from '../components/common/TweetCard'
import { FollowButton } from '../components/users/FollowButton'
import { useAuth } from '../hooks/useAuth'
import { useUserProfile, useUpdateProfile } from '../hooks/useUser'
import { getUserTweets, deleteTweet, likeTweet, unlikeTweet } from '../services/tweets'

export function ProfilePage() {
  const { username } = useParams<{ username: string }>()
  const { user: currentUser } = useAuth()

  const { data: profile, isLoading, isError } = useUserProfile(username!)

  const tweetsQuery = useQuery({
    queryKey: ['tweets', 'user', username],
    queryFn: () => getUserTweets(username!),
    enabled: !!username,
  })

  const queryClient = useQueryClient()
  const updateProfileMutation = useUpdateProfile(username!)

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteTweet(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['tweets', 'user', username] }),
  })

  const likeMutation = useMutation({
    mutationFn: ({ id, liked }: { id: number; liked: boolean }) =>
      liked ? unlikeTweet(id) : likeTweet(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['tweets', 'user', username] }),
  })

  const [isEditing, setIsEditing] = useState(false)
  const [displayName, setDisplayName] = useState('')
  const [bio, setBio] = useState('')
  const [avatarUrl, setAvatarUrl] = useState('')

  const isOwnProfile = currentUser?.id === profile?.id

  function handleEditOpen() {
    setDisplayName(profile?.display_name ?? '')
    setBio(profile?.bio ?? '')
    setAvatarUrl(profile?.avatar_url ?? '')
    setIsEditing(true)
  }

  function handleEditCancel() {
    setIsEditing(false)
  }

  async function handleEditSubmit(event: React.FormEvent) {
    event.preventDefault()
    await updateProfileMutation.mutateAsync({
      display_name: displayName || null,
      bio: bio || null,
      avatar_url: avatarUrl || null,
    })
    setIsEditing(false)
  }

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    )
  }

  if (isError || !profile) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-zinc-500 dark:text-zinc-400">User not found.</p>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-xl">
      {/* Header */}
      <div className="border-b border-zinc-100 px-4 py-6 dark:border-zinc-800">
        <div className="flex items-start justify-between gap-4">
          <Avatar
            avatarUrl={profile.avatar_url}
            displayName={profile.display_name}
            username={profile.username}
            size="lg"
          />
          {isOwnProfile ? (
            <Button variant="secondary" onClick={handleEditOpen}>
              Edit profile
            </Button>
          ) : (
            <FollowButton user={profile} currentUserId={currentUser?.id} />
          )}
        </div>

        <div className="mt-3">
          <p className="text-base font-bold text-zinc-900 dark:text-zinc-100">
            {profile.display_name ?? profile.username}
          </p>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">@{profile.username}</p>
          {profile.bio ? (
            <p className="mt-2 text-sm text-zinc-800 dark:text-zinc-200">{profile.bio}</p>
          ) : null}
        </div>

        {/* Stats */}
        <div className="mt-4 flex gap-6">
          <button className="text-sm text-zinc-700 hover:underline dark:text-zinc-300">
            <span className="font-semibold text-zinc-900 dark:text-zinc-100">
              {profile.tweet_count}
            </span>{' '}
            Tweets
          </button>
          <button className="text-sm text-zinc-700 hover:underline dark:text-zinc-300">
            <span className="font-semibold text-zinc-900 dark:text-zinc-100">
              {profile.followers_count}
            </span>{' '}
            Followers
          </button>
          <button className="text-sm text-zinc-700 hover:underline dark:text-zinc-300">
            <span className="font-semibold text-zinc-900 dark:text-zinc-100">
              {profile.following_count}
            </span>{' '}
            Following
          </button>
        </div>
      </div>

      {/* Edit form */}
      {isEditing && isOwnProfile ? (
        <form
          onSubmit={handleEditSubmit}
          className="border-b border-zinc-100 px-4 py-4 dark:border-zinc-800"
        >
          <p className="mb-3 text-sm font-semibold text-zinc-900 dark:text-zinc-100">
            Edit profile
          </p>
          <div className="flex flex-col gap-3">
            <Input
              label="Display name"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              placeholder="Your name"
            />
            <Input
              label="Bio"
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              placeholder="Tell something about you"
            />
            <Input
              label="Avatar URL"
              value={avatarUrl}
              onChange={(e) => setAvatarUrl(e.target.value)}
              placeholder="https://example.com/avatar.jpg"
            />
          </div>
          <div className="mt-4 flex justify-end gap-2">
            <Button type="button" variant="ghost" onClick={handleEditCancel}>
              Cancel
            </Button>
            <Button
              type="submit"
              variant="primary"
              isLoading={updateProfileMutation.isPending}
            >
              Save
            </Button>
          </div>
        </form>
      ) : null}

      {/* Tweets */}
      <div>
        {tweetsQuery.isLoading ? (
          <div className="flex justify-center py-8">
            <LoadingSpinner size="md" />
          </div>
        ) : tweetsQuery.data?.data.length === 0 ? (
          <p className="py-8 text-center text-sm text-zinc-400 dark:text-zinc-500">
            No tweets yet.
          </p>
        ) : (
          tweetsQuery.data?.data.map((tweet) => (
            <TweetCard
              key={tweet.id}
              tweet={tweet}
              currentUserId={currentUser?.id}
              onLike={(id, liked) => likeMutation.mutate({ id, liked })}
              onDelete={(id) => deleteMutation.mutate(id)}
            />
          ))
        )}
      </div>
    </div>
  )
}
