import { NavLink } from 'react-router-dom'
import type { ReactNode } from 'react'
import { useAuth } from '../../hooks/useAuth'
import { useDarkMode } from '../../hooks/useDarkMode'
import { Avatar } from './Avatar'

interface NavItemProps {
  to: string
  label: string
  icon: string
}

function NavItem({ to, label, icon }: NavItemProps) {
  return (
    <NavLink
      to={to}
      className={({ isActive }) =>
        [
          'group flex w-full items-center justify-center gap-3 rounded-full py-3 text-[15px] font-medium transition-all md:justify-start md:px-4',
          isActive
            ? 'text-sky-500 dark:text-sky-400'
            : 'text-zinc-700 hover:bg-zinc-100 hover:text-zinc-900 dark:text-zinc-300 dark:hover:bg-zinc-800/70 dark:hover:text-zinc-100',
        ].join(' ')
      }
    >
      <span className="text-[22px] leading-none">{icon}</span>
      <span className="hidden text-sm md:inline">{label}</span>
    </NavLink>
  )
}

interface LayoutProps {
  children: ReactNode
}

export function Layout({ children }: LayoutProps) {
  const { user, logout } = useAuth()
  const { isDark, toggle } = useDarkMode()

  return (
    <div className="flex min-h-screen bg-white dark:bg-zinc-950">
      {/* Sidebar — desktop only */}
      <aside className="sticky top-0 hidden h-screen w-[72px] shrink-0 flex-col justify-between border-r border-zinc-100 py-3 dark:border-zinc-800/70 md:flex md:w-[220px] md:px-3">
        <div className="flex flex-col">
          {/* Logo */}
          <div className="mb-2 flex items-center justify-center py-2 md:justify-start md:px-2">
            <span className="text-2xl">🐦</span>
            <span className="ml-2 hidden text-lg font-bold text-zinc-900 dark:text-zinc-100 md:inline">
              Flock
            </span>
          </div>

          <nav className="flex flex-col gap-0.5">
            <NavItem to="/timeline" label="Home" icon="🏠" />
            <NavItem to="/search" label="Search" icon="🔍" />
            {user && <NavItem to={`/profile/${user.username}`} label="Profile" icon="👤" />}
          </nav>
        </div>

        <div className="flex flex-col gap-1">
          {/* Dark mode toggle */}
          <button
            onClick={toggle}
            title={isDark ? 'Switch to light mode' : 'Switch to dark mode'}
            className="flex w-full items-center justify-center gap-3 rounded-full py-3 text-zinc-500 transition-all hover:bg-zinc-100 hover:text-zinc-800 dark:text-zinc-400 dark:hover:bg-zinc-800/70 dark:hover:text-zinc-200 md:justify-start md:px-4"
          >
            <span className="text-[22px] leading-none">{isDark ? '☀️' : '🌙'}</span>
            <span className="hidden text-sm md:inline">{isDark ? 'Light mode' : 'Dark mode'}</span>
          </button>

          {/* User + logout */}
          {user && (
            <button
              onClick={logout}
              title="Log out"
              className="flex w-full items-center justify-center gap-2 rounded-full py-2 transition-all hover:bg-zinc-100 dark:hover:bg-zinc-800/70 md:justify-start md:px-3 md:py-3"
            >
              <span className="shrink-0">
                <Avatar
                  avatarUrl={user.avatar_url}
                  displayName={user.display_name}
                  username={user.username}
                  size="sm"
                />
              </span>
              <div className="hidden min-w-0 flex-1 text-left md:block">
                <p className="truncate text-xs font-semibold text-zinc-900 dark:text-zinc-100">
                  {user.display_name ?? user.username}
                </p>
                <p className="truncate text-xs text-zinc-500 dark:text-zinc-400">
                  @{user.username}
                </p>
              </div>
              <span className="hidden shrink-0 text-zinc-400 dark:text-zinc-500 md:inline">🚪</span>
            </button>
          )}
        </div>
      </aside>

      {/* Main content */}
      <main className="min-w-0 flex-1 border-r border-zinc-100 pb-16 dark:border-zinc-800/70 md:pb-0">
        {children}
      </main>

      {/* Right spacer */}
      <div className="hidden w-72 xl:block" />

      {/* Bottom nav — mobile only */}
      <nav className="fixed bottom-0 left-0 right-0 z-20 flex justify-around border-t border-zinc-100 bg-white/95 py-2 backdrop-blur dark:border-zinc-800 dark:bg-zinc-950/95 md:hidden">
        <NavLink
          to="/timeline"
          className={({ isActive }) =>
            isActive
              ? 'flex flex-col items-center text-sky-500'
              : 'flex flex-col items-center text-zinc-500 dark:text-zinc-400'
          }
        >
          <span className="text-xl">🏠</span>
        </NavLink>
        <NavLink
          to="/search"
          className={({ isActive }) =>
            isActive
              ? 'flex flex-col items-center text-sky-500'
              : 'flex flex-col items-center text-zinc-500 dark:text-zinc-400'
          }
        >
          <span className="text-xl">🔍</span>
        </NavLink>
        {user && (
          <NavLink
            to={`/profile/${user.username}`}
            className={({ isActive }) =>
              isActive
                ? 'flex flex-col items-center text-sky-500'
                : 'flex flex-col items-center text-zinc-500 dark:text-zinc-400'
            }
          >
            <span className="text-xl">👤</span>
          </NavLink>
        )}
        <button
          onClick={toggle}
          className="flex flex-col items-center text-zinc-500 dark:text-zinc-400"
        >
          <span className="text-xl">{isDark ? '☀️' : '🌙'}</span>
        </button>
      </nav>
    </div>
  )
}
