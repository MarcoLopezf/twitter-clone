import { useState, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { searchUsers } from '../services/users'

const DEBOUNCE_DELAY_MS = 300
const MIN_QUERY_LENGTH = 2

export function useSearch() {
  const [inputValue, setInputValue] = useState('')
  const [debouncedQuery, setDebouncedQuery] = useState('')

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedQuery(inputValue)
    }, DEBOUNCE_DELAY_MS)

    return () => clearTimeout(timer)
  }, [inputValue])

  const isQueryValid = debouncedQuery.length >= MIN_QUERY_LENGTH

  const query = useQuery({
    queryKey: ['users', 'search', debouncedQuery],
    queryFn: () => searchUsers(debouncedQuery),
    enabled: isQueryValid,
  })

  return {
    inputValue,
    setInputValue,
    results: query.data?.data ?? [],
    isLoading: query.isFetching && isQueryValid,
    isQueryValid,
  }
}
