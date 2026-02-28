import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { vi, describe, it, expect, beforeEach } from 'vitest'
import { useQuery } from '@tanstack/react-query'
import { FollowButton } from '../components/users/FollowButton'
import { getUserProfile } from '../services/users'
import * as usersService from '../services/users'
import type { User } from '../types'

vi.mock('../services/users', () => ({
  getUserProfile: vi.fn(),
  followUser: vi.fn(),
  unfollowUser: vi.fn(),
  updateProfile: vi.fn(),
  searchUsers: vi.fn(),
  getFollowers: vi.fn(),
  getFollowing: vi.fn(),
}))

const baseUser: User = {
  id: 2,
  email: 'other@example.com',
  username: 'otheruser',
  display_name: 'Other User',
  bio: null,
  avatar_url: null,
  created_at: '2024-01-01T00:00:00Z',
  followers_count: 10,
  following_count: 5,
  tweet_count: 3,
  is_following: false,
}

const currentUserId = 1

/**
 * Renders FollowButton inside a wrapper that subscribes to the React Query cache
 * for the user profile. This mirrors how ProfilePage works in production and
 * allows optimistic cache updates from useFollowUser / useUnfollowUser to
 * propagate to the button automatically.
 */
function ProfileWrapper({ username, currentId }: { username: string; currentId?: number }) {
  const { data: user } = useQuery({
    queryKey: ['users', username],
    queryFn: () => getUserProfile(username),
  })

  if (!user) return null

  return <FollowButton user={user} currentUserId={currentId} />
}

function buildQueryClient() {
  return new QueryClient({ defaultOptions: { queries: { retry: false } } })
}

function renderProfileWrapper(currentId?: number) {
  return render(
    <QueryClientProvider client={buildQueryClient()}>
      <ProfileWrapper username={baseUser.username} currentId={currentId} />
    </QueryClientProvider>,
  )
}

describe('FollowButton', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders follow button on profile page', async () => {
    vi.mocked(usersService.getUserProfile).mockResolvedValue({
      ...baseUser,
      is_following: false,
    })

    renderProfileWrapper(currentUserId)

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /^follow$/i })).toBeInTheDocument()
    })
  })

  it('toggles to unfollow after clicking follow', async () => {
    const user = userEvent.setup()
    vi.mocked(usersService.followUser).mockResolvedValue(undefined)

    // First call: initial load → not following. Subsequent calls (after invalidation): following.
    vi.mocked(usersService.getUserProfile)
      .mockResolvedValueOnce({ ...baseUser, is_following: false })
      .mockResolvedValue({ ...baseUser, is_following: true, followers_count: 11 })

    renderProfileWrapper(currentUserId)

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /^follow$/i })).toBeInTheDocument()
    })

    await user.click(screen.getByRole('button', { name: /^follow$/i }))

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /unfollow/i })).toBeInTheDocument()
    })
  })

  it('toggles back to follow after clicking unfollow', async () => {
    const user = userEvent.setup()
    vi.mocked(usersService.unfollowUser).mockResolvedValue(undefined)

    // First call: initial load → following. Subsequent calls (after invalidation): not following.
    vi.mocked(usersService.getUserProfile)
      .mockResolvedValueOnce({ ...baseUser, is_following: true })
      .mockResolvedValue({ ...baseUser, is_following: false, followers_count: 9 })

    renderProfileWrapper(currentUserId)

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /unfollow/i })).toBeInTheDocument()
    })

    await user.click(screen.getByRole('button', { name: /unfollow/i }))

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /^follow$/i })).toBeInTheDocument()
    })
  })

  it('hides follow button on own profile', async () => {
    vi.mocked(usersService.getUserProfile).mockResolvedValue({
      ...baseUser,
      id: currentUserId,
    })

    renderProfileWrapper(currentUserId)

    // Wait for the query to resolve, then confirm the follow button is never shown
    await waitFor(() => {
      expect(vi.mocked(usersService.getUserProfile)).toHaveBeenCalled()
    })

    expect(screen.queryByRole('button', { name: /follow/i })).not.toBeInTheDocument()
  })
})
