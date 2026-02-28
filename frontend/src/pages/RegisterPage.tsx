import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { register } from '../services/auth'
import { TOKEN_KEY } from '../services/api'
import { useAuth } from '../hooks/useAuth'
import { Button } from '../components/common/Button'
import { Input } from '../components/common/Input'
import type { ApiError } from '../types'
import type { AxiosError } from 'axios'

export function RegisterPage() {
  const { login } = useAuth()
  const navigate = useNavigate()

  const [email, setEmail] = useState('')
  const [username, setUsername] = useState('')
  const [displayName, setDisplayName] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault()
    setError(null)
    setIsSubmitting(true)
    try {
      const response = await register({ email, username, password, display_name: displayName })
      localStorage.setItem(TOKEN_KEY, response.data.token)
      await login({ email, password })
      navigate('/timeline')
    } catch (err) {
      const axiosError = err as AxiosError<ApiError>
      const details = axiosError.response?.data?.details
      setError(
        details?.join(', ') ??
          axiosError.response?.data?.error ??
          'Something went wrong. Please try again.',
      )
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-sky-50 to-white px-4 dark:from-zinc-950 dark:to-zinc-900">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="mb-8 text-center">
          <span className="text-5xl">🐦</span>
          <h1 className="mt-3 text-3xl font-bold tracking-tight text-zinc-900 dark:text-zinc-100">
            Join Flock
          </h1>
          <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">Create your account</p>
        </div>

        <div className="rounded-2xl border border-zinc-100 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900 md:p-8">
          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <Input
              label="Email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="email"
              required
            />
            <Input
              label="Username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              autoComplete="username"
              required
            />
            <Input
              label="Display name"
              type="text"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              autoComplete="name"
            />
            <Input
              label="Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="new-password"
              required
            />

            {error && (
              <p className="rounded-xl bg-red-50 px-4 py-3 text-sm text-red-600 dark:bg-red-900/20 dark:text-red-400">
                {error}
              </p>
            )}

            <Button type="submit" variant="primary" isLoading={isSubmitting} className="mt-1 w-full">
              Create account
            </Button>
          </form>

          <p className="mt-5 text-center text-sm text-zinc-500 dark:text-zinc-400">
            Already have an account?{' '}
            <Link to="/login" className="font-semibold text-sky-500 hover:underline dark:text-sky-400">
              Sign in
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}
