import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { vi, describe, it, expect, beforeEach } from 'vitest'
import { TweetComposer } from '../components/tweets/TweetComposer'
import * as tweetsService from '../services/tweets'
import type { Tweet } from '../types'

vi.mock('../services/tweets', () => ({
  createTweet: vi.fn(),
  getTimeline: vi.fn(),
  deleteTweet: vi.fn(),
  likeTweet: vi.fn(),
  unlikeTweet: vi.fn(),
  getUserTweets: vi.fn(),
}))

const mockTweet: Tweet = {
  id: 1,
  content: 'Hello world!',
  created_at: '2024-01-01T00:00:00Z',
  likes_count: 0,
  liked_by_current_user: false,
  user: {
    id: 1,
    username: 'testuser',
    display_name: 'Test User',
    avatar_url: null,
  },
}

function renderTweetComposer() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  })
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>
        <TweetComposer />
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('TweetComposer', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders tweet form on timeline', () => {
    renderTweetComposer()

    expect(screen.getByRole('textbox', { name: /tweet content/i })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /tweet/i })).toBeInTheDocument()
  })

  it('disables submit when content is empty', () => {
    renderTweetComposer()

    const submitButton = screen.getByRole('button', { name: /tweet/i })
    expect(submitButton).toBeDisabled()
  })

  it('disables submit when content exceeds 280 chars', async () => {
    const user = userEvent.setup()
    renderTweetComposer()

    const textarea = screen.getByRole('textbox', { name: /tweet content/i })
    await user.type(textarea, 'a'.repeat(281))

    expect(screen.getByRole('button', { name: /tweet/i })).toBeDisabled()
  })

  it('creates tweet and updates timeline on submit', async () => {
    const user = userEvent.setup()
    vi.mocked(tweetsService.createTweet).mockResolvedValue(mockTweet)

    renderTweetComposer()

    const textarea = screen.getByRole('textbox', { name: /tweet content/i })
    await user.type(textarea, 'Hello world!')

    expect(screen.getByRole('button', { name: /tweet/i })).not.toBeDisabled()
    await user.click(screen.getByRole('button', { name: /tweet/i }))

    await waitFor(() => {
      expect(tweetsService.createTweet).toHaveBeenCalledWith('Hello world!')
    })

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: /tweet content/i })).toHaveValue('')
    })
  })
})
