# CLAUDE.md — Frontend

## Stack

| Technology              | Purpose                  |
|-------------------------|--------------------------|
| React 19 + TypeScript   | UI framework             |
| Vite                    | Build tool               |
| Tailwind CSS            | Styling                  |
| React Query             | Server state management  |
| Axios                   | HTTP client              |
| React Router v6         | Routing                  |
| Vitest                  | Test runner              |
| React Testing Library   | Integration tests        |

---

## Architecture

| Layer        | Location          | Responsibility                              | Never                                      |
|--------------|-------------------|---------------------------------------------|--------------------------------------------|
| Pages        | `src/pages/`      | Compose components, connect hooks to UI     | Fetch data directly or contain logic       |
| Components   | `src/components/` | Render UI, receive data via props           | Call API or contain business logic         |
| Hooks        | `src/hooks/`      | Business logic, React Query calls           | Render JSX                                 |
| Services     | `src/services/`   | Axios calls to the API                      | Contain logic beyond the HTTP call         |
| Context      | `src/context/`    | Global auth state only                      | Be used for server state                   |
| Types        | `src/types/`      | TypeScript interfaces and types             | Contain logic                              |

---

## Folder Structure

```
src/
├── components/
│   ├── common/       # Shared across 2+ features
│   ├── tweets/
│   └── users/
├── hooks/
├── services/
├── pages/
├── context/
└── types/
```

---

## Component Rules

Before creating any component, check `src/components/` first. If it already exists, use and extend it. If it's clearly shared across features (`Avatar`, `Button`, `Input`, `LoadingSpinner`, `TweetCard`, `UserCard`, `InfiniteScrollList`), create it reusable in `components/common/`. Otherwise create it inside the page and extract it only when it appears in a second place.

---

## State Management

| State type                  | Solution              |
|-----------------------------|-----------------------|
| Server data (API responses) | React Query           |
| Local UI (modals, inputs)   | `useState`            |
| Auth (current user, token)  | Context               |
| Form state                  | `useState` local      |

Never use Context for server state — that's React Query's job.

---

## Mobile-First Rules

- Write Tailwind classes mobile-first always — base class is mobile, `md:` and `lg:` scale up
- Add `dark:` variant from the first component — never retrofit dark mode later
- Breakpoints: mobile `< 640px`, tablet `640px–1024px`, desktop `> 1024px`

---

## Definition of Done

A feature is **NOT done** until every item is complete:

- [ ] All components used are either reused from `components/` or created there if reusable
- [ ] All states use the correct solution from the state management table
- [ ] UI is mobile-first and tested at all three breakpoints
- [ ] `dark:` variants applied to all new components
- [ ] No API calls inside components — all calls go through services and hooks
- [ ] No TypeScript errors (`tsc --noEmit`)
- [ ] No linting errors
- [ ] Committed with descriptive message