import { useEffect, useState } from 'react'

const DARK_MODE_KEY = 'flock_dark_mode'

function getInitialDark(): boolean {
  const stored = localStorage.getItem(DARK_MODE_KEY)
  if (stored !== null) return stored === 'true'
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}

export function useDarkMode() {
  const [isDark, setIsDark] = useState(getInitialDark)

  useEffect(() => {
    const root = document.documentElement
    if (isDark) {
      root.classList.add('dark')
    } else {
      root.classList.remove('dark')
    }
    localStorage.setItem(DARK_MODE_KEY, String(isDark))
  }, [isDark])

  function toggle() {
    setIsDark((prev) => !prev)
  }

  return { isDark, toggle }
}
