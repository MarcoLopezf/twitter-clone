import type { InputHTMLAttributes } from 'react'

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string
  error?: string
}

export function Input({ label, error, id, className = '', ...props }: InputProps) {
  const inputId = id ?? label.toLowerCase().replace(/\s+/g, '-')

  return (
    <div className="flex flex-col gap-1">
      <label
        htmlFor={inputId}
        className="text-sm font-medium text-zinc-700 dark:text-zinc-300"
      >
        {label}
      </label>
      <input
        id={inputId}
        className={[
          'rounded-lg border px-3 py-2 text-sm text-zinc-900 placeholder-zinc-400 transition-colors focus:outline-none focus:ring-2 focus:ring-sky-500',
          'bg-white dark:bg-zinc-900 dark:text-zinc-100 dark:placeholder-zinc-500',
          error
            ? 'border-red-500 dark:border-red-400'
            : 'border-zinc-300 dark:border-zinc-700 hover:border-zinc-400 dark:hover:border-zinc-600',
          className,
        ].join(' ')}
        {...props}
      />
      {error ? (
        <p className="text-xs text-red-500 dark:text-red-400">{error}</p>
      ) : null}
    </div>
  )
}
