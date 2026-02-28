import api from './api'
import type { User } from '../types'

interface RegisterPayload {
  email: string
  username: string
  password: string
  display_name?: string
  bio?: string
  avatar_url?: string
}

interface LoginPayload {
  email: string
  password: string
}

interface AuthResponse {
  data: {
    token: string
    user: User
  }
}

export async function register(payload: RegisterPayload): Promise<AuthResponse> {
  const response = await api.post<AuthResponse>('/api/v1/auth/register', payload)
  return response.data
}

export async function login(payload: LoginPayload): Promise<AuthResponse> {
  const response = await api.post<AuthResponse>('/api/v1/auth/login', payload)
  return response.data
}

export async function getMe(): Promise<User> {
  const response = await api.get<{ data: User }>('/api/v1/auth/me')
  return response.data.data
}
