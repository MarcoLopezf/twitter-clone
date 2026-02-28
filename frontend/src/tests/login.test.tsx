import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { vi, describe, it, expect, beforeEach } from 'vitest'
import { LoginPage } from '../pages/LoginPage'
import { AuthProvider } from '../context/AuthContext'
import * as authService from '../services/auth'
import type { User } from '../types'

const mockNavigate = vi.fn()

vi.mock('react-router-dom', async (importOriginal) => {
  const actual = await importOriginal<typeof import('react-router-dom')>()
  return { ...actual, useNavigate: () => mockNavigate }
})

vi.mock('../services/auth', () => ({
  login: vi.fn(),
  getMe: vi.fn(),
}))

const mockUser: User = {
  id: 1,
  email: 'test@example.com',
  username: 'testuser',
  display_name: 'Test User',
  bio: null,
  avatar_url: null,
  created_at: '2024-01-01T00:00:00Z',
  followers_count: 0,
  following_count: 0,
  tweet_count: 0,
  is_following: false,
}

function renderLoginPage() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  })
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>
        <AuthProvider>
          <LoginPage />
        </AuthProvider>
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('LoginPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorage.clear()
  })

  it('renders login form', () => {
    renderLoginPage()

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument()
  })

  it('shows error on invalid credentials', async () => {
    const user = userEvent.setup()
    vi.mocked(authService.login).mockRejectedValue({
      response: { data: { error: 'Invalid credentials' } },
    })

    renderLoginPage()

    await user.type(screen.getByLabelText(/email/i), 'wrong@example.com')
    await user.type(screen.getByLabelText(/password/i), 'wrongpassword')
    await user.click(screen.getByRole('button', { name: /sign in/i }))

    await waitFor(() => {
      expect(screen.getByText(/invalid credentials/i)).toBeInTheDocument()
    })
  })

  it('redirects to /timeline on successful login', async () => {
    const user = userEvent.setup()
    vi.mocked(authService.login).mockResolvedValue({
      data: { token: 'fake-token', user: mockUser },
    })

    renderLoginPage()

    await user.type(screen.getByLabelText(/email/i), 'test@example.com')
    await user.type(screen.getByLabelText(/password/i), 'password123')
    await user.click(screen.getByRole('button', { name: /sign in/i }))

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('/timeline')
    })
  })
})
