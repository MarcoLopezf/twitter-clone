import api from './api'
import type { User, PaginatedResponse } from '../types'

interface JsonApiUser {
  id: string
  type: string
  attributes: Omit<User, 'id'>
}

function normalizeUser(resource: JsonApiUser): User {
  return { id: Number(resource.id), ...resource.attributes }
}

export async function getUserProfile(username: string): Promise<User> {
  const response = await api.get<{ data: JsonApiUser }>(`/api/v1/users/${username}`)
  return normalizeUser(response.data.data)
}

export async function updateProfile(payload: Partial<Pick<User, 'display_name' | 'bio' | 'avatar_url'>>): Promise<User> {
  const response = await api.patch<{ data: JsonApiUser }>('/api/v1/users/me', payload)
  return normalizeUser(response.data.data)
}

export async function searchUsers(query: string, page = 1): Promise<PaginatedResponse<User>> {
  const response = await api.get<{ data: JsonApiUser[]; meta: PaginatedResponse<User>['meta'] }>('/api/v1/users/search', {
    params: { q: query, page },
  })
  return {
    data: response.data.data.map(normalizeUser),
    meta: response.data.meta,
  }
}

export async function followUser(id: number): Promise<void> {
  await api.post(`/api/v1/users/${id}/follow`)
}

export async function unfollowUser(id: number): Promise<void> {
  await api.delete(`/api/v1/users/${id}/unfollow`)
}

export async function getFollowers(id: number, page = 1): Promise<PaginatedResponse<User>> {
  const response = await api.get<PaginatedResponse<User>>(`/api/v1/users/${id}/followers`, {
    params: { page },
  })
  return response.data
}

export async function getFollowing(id: number, page = 1): Promise<PaginatedResponse<User>> {
  const response = await api.get<PaginatedResponse<User>>(`/api/v1/users/${id}/following`, {
    params: { page },
  })
  return response.data
}
