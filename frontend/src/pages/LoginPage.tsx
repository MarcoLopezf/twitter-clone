import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'
import { Button } from '../components/common/Button'
import { Input } from '../components/common/Input'
import type { ApiError } from '../types'
import type { AxiosError } from 'axios'

export function LoginPage() {
  const { login } = useAuth()
  const navigate = useNavigate()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault()
    setError(null)
    setIsSubmitting(true)
    try {
      await login({ email, password })
      navigate('/timeline')
    } catch (err) {
      const axiosError = err as AxiosError<ApiError>
      setError(axiosError.response?.data?.error ?? 'Something went wrong. Please try again.')
    } finally {
      setIsSubmitting(false)
    }
  }

  function fillDemoCredentials() {
    setEmail('demo@theflock.com')
    setPassword('demo1234')
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-sky-50 to-white px-4 dark:from-zinc-950 dark:to-zinc-900">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="mb-8 text-center">
          <span className="text-5xl">🐦</span>
          <h1 className="mt-3 text-3xl font-bold tracking-tight text-zinc-900 dark:text-zinc-100">
            Welcome back
          </h1>
          <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">Sign in to your Flock account</p>
        </div>

        <div className="rounded-2xl border border-zinc-100 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900 md:p-8">
          {/* Demo banner */}
          <button
            type="button"
            onClick={fillDemoCredentials}
            className="mb-5 flex w-full items-center justify-between rounded-xl border border-sky-200 bg-sky-50 px-4 py-3 text-left transition-colors hover:bg-sky-100 dark:border-sky-800/60 dark:bg-sky-900/20 dark:hover:bg-sky-900/30"
          >
            <div>
              <p className="text-xs font-semibold text-sky-700 dark:text-sky-400">🎭 Try the demo</p>
              <p className="mt-0.5 font-mono text-xs text-sky-600 dark:text-sky-500">
                demo@theflock.com · demo1234
              </p>
            </div>
            <span className="text-xs font-medium text-sky-500 dark:text-sky-400">Fill →</span>
          </button>

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
              label="Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="current-password"
              required
            />

            {error && (
              <p className="rounded-xl bg-red-50 px-4 py-3 text-sm text-red-600 dark:bg-red-900/20 dark:text-red-400">
                {error}
              </p>
            )}

            <Button type="submit" variant="primary" isLoading={isSubmitting} className="mt-1 w-full">
              Sign in
            </Button>
          </form>

          <p className="mt-5 text-center text-sm text-zinc-500 dark:text-zinc-400">
            Don&apos;t have an account?{' '}
            <Link to="/register" className="font-semibold text-sky-500 hover:underline dark:text-sky-400">
              Create one
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}
