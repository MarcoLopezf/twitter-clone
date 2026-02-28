interface AvatarProps {
  avatarUrl?: string | null
  displayName?: string | null
  username?: string
  size?: 'sm' | 'md' | 'lg'
}

const SIZE_CLASSES = {
  sm: 'h-8 w-8 text-xs',
  md: 'h-10 w-10 text-sm',
  lg: 'h-14 w-14 text-base',
}

function getInitials(displayName: string | null | undefined, username: string | undefined): string {
  const name = displayName ?? username ?? '?'
  return name.slice(0, 2).toUpperCase()
}

export function Avatar({ avatarUrl, displayName, username, size = 'md' }: AvatarProps) {
  const sizeClass = SIZE_CLASSES[size]

  if (avatarUrl) {
    return (
      <img
        src={avatarUrl}
        alt={displayName ?? username ?? ''}
        className={`${sizeClass} rounded-full object-cover ring-1 ring-zinc-200 dark:ring-zinc-700`}
      />
    )
  }

  return (
    <div
      aria-label={displayName ?? username}
      className={`${sizeClass} inline-flex items-center justify-center rounded-full bg-sky-500 font-semibold text-white dark:bg-sky-600`}
    >
      {getInitials(displayName, username)}
    </div>
  )
}
