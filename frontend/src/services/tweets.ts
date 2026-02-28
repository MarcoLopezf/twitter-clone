import api from './api'
import type { Tweet, PaginatedResponse } from '../types'

export async function getTimeline(page = 1): Promise<PaginatedResponse<Tweet>> {
  const response = await api.get<PaginatedResponse<Tweet>>('/api/v1/tweets/timeline', {
    params: { page },
  })
  return response.data
}

export async function createTweet(content: string): Promise<Tweet> {
  const response = await api.post<{ data: Tweet }>('/api/v1/tweets', { content })
  return response.data.data
}

export async function deleteTweet(id: number): Promise<void> {
  await api.delete(`/api/v1/tweets/${id}`)
}

export async function likeTweet(id: number): Promise<void> {
  await api.post(`/api/v1/tweets/${id}/like`)
}

export async function unlikeTweet(id: number): Promise<void> {
  await api.delete(`/api/v1/tweets/${id}/unlike`)
}
