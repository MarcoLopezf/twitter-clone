export interface User {
  id: number
  email: string
  username: string
  display_name: string | null
  bio: string | null
  avatar_url: string | null
  created_at: string
  followers_count: number
  following_count: number
  tweet_count: number
  is_following: boolean
}

export interface Tweet {
  id: number
  content: string
  created_at: string
  likes_count: number
  liked_by_current_user: boolean
  user: Pick<User, 'id' | 'username' | 'display_name' | 'avatar_url'>
}

export interface PaginatedResponse<T> {
  data: T[]
  meta: {
    total: number
    page: number
    next_page: number | null
  }
}

export interface ApiError {
  error: string
  details?: string[]
}
