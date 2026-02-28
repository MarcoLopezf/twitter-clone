# The Flock

A full-stack Twitter clone built as a technical challenge to demonstrate professional software development practices: Test-Driven Development, clean architecture, meaningful git history, and effective use of AI-assisted tooling.

---

## Tech Stack

| Layer      | Technology                             |
|------------|----------------------------------------|
| Backend    | Ruby on Rails 7.1 (API mode)           |
| Frontend   | React 19 + TypeScript + Vite           |
| Database   | PostgreSQL 15                          |
| Auth       | JWT (JSON Web Tokens)                  |
| Styling    | Tailwind CSS                           |
| Testing    | RSpec (backend) + Vitest / RTL (frontend) |
| Docs       | Swagger / OpenAPI via rswag            |
| CI/CD      | GitHub Actions                         |

---

## Local Setup

### Prerequisites

- Ruby 3.3+
- Node 20+
- Docker and Docker Compose

### 1. Clone the repository

```bash
git clone https://github.com/MarcoLopezf/twitter-clone.git
cd twitter-clone
```

### 2. Configure environment variables

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

Edit both `.env` files with your local values. The defaults in `.env.example` work out of the box for local development.

### 3. Start the database

```bash
docker-compose up db
```

### 4. Set up the backend

```bash
cd backend
bundle install
rails db:create db:migrate db:seed
rails server
```

### 5. Set up the frontend

```bash
cd frontend
npm install
npm run dev
```

### Access

| Service  | URL                          |
|----------|------------------------------|
| API      | http://localhost:3000        |
| UI       | http://localhost:5173        |
| Swagger  | http://localhost:3000/api-docs |

### Demo credentials

```
Email:    demo@theflock.com
Password: demo1234
```

---

## Architecture Decisions

### JWT over session-based auth

Rails API mode has no session middleware by default, making stateless JWT a natural fit. JWTs allow the frontend to authenticate requests independently without round-trips to the server to validate session state. Tokens are short-lived and stored in memory (not localStorage) to reduce XSS exposure.

### Service Objects for business logic

Controllers are kept thin — they receive a request, call a service, and return a response. All business logic lives in `app/services/`, organized by domain (`auth/`, `tweets/`, `follows/`, `likes/`). This makes logic independently testable, easy to reuse across controllers, and straightforward to reason about without loading the full request cycle.

### React Query for server state

Server state (API responses, loading states, cache invalidation) is fundamentally different from local UI state. React Query handles caching, background refetching, optimistic updates, and pagination out of the box — removing the need for a global state store like Redux for data that ultimately lives on the server. Context is reserved exclusively for auth state.

### Pundit for authorization

Pundit provides a clean, explicit policy layer where authorization rules live in plain Ruby objects (`app/policies/`). Each resource has its own policy class, making it straightforward to answer "who can do what" without scattering `if current_user.admin?` checks across controllers.

### Mobile-first with Tailwind

All Tailwind classes are written mobile-first: base styles target small screens, with `md:` and `lg:` modifiers scaling up. Dark mode variants (`dark:`) were applied from the first component to avoid retrofitting. The layout adapts from a bottom navigation bar on mobile to a sidebar on desktop.

---

## Trade-offs and Known Limitations

- **No refresh tokens.** JWT tokens expire and the user must log in again. A refresh token flow would improve UX in production but was out of scope for this challenge.
- **No real-time updates.** The timeline does not update in real time. Implementing WebSockets (ActionCable) would require a more complex infrastructure setup.
- **No image uploads.** Avatars use generated initials. Supporting file uploads would require Active Storage and a cloud storage provider (S3 or similar).
- **Search is basic.** User search uses a `ILIKE` query, which works at small scale but would need full-text search (PostgreSQL `tsvector` or Elasticsearch) for production.
- **Frontend test coverage is partial.** Integration tests cover the main user flows (login, tweet creation, follow/unfollow) using Vitest and React Testing Library. Unit-level tests for individual presentational components were not prioritized within the scope of this challenge.

---

## AI Tools Used

Both **Claude Code** (the CLI) and **Claude.ai** (the web interface) were used throughout development as a pair programming assistant, not as a code generator.

### How they were used

**Spec-first TDD flow.** Before writing any implementation, the spec for each feature was drafted collaboratively — describing the expected behavior, edge cases, and failure scenarios. Claude Code was used to generate the initial RSpec structure, which was then reviewed and adjusted before any implementation code was written. This kept the Red → Green → Refactor discipline consistent.

**Swagger documentation from real responses.** After each endpoint was implemented and tested, a `curl` command was run against the live local server. The real request and response were fed to Claude.ai, which generated the correct `rswag` documentation block. This ensured all Swagger docs reflect actual API behavior — no invented examples.

**Maintaining consistency across the codebase.** As the codebase grew, Claude Code was used to check that new service objects, serializers, and controllers followed the same patterns as existing ones. This was particularly valuable for repetitive structures (factory definitions, shared examples, policy classes) where consistency matters more than creativity.

**Directing architecture, not generating it.** The architectural decisions (service objects, Pundit, React Query) were made before writing code. Claude was used to validate trade-offs and explore alternatives, but the direction was always set explicitly. The AI followed the architecture — it did not define it.

---

## Bonus Features

- **Dark mode** — System preference detection with manual toggle. Persisted in `localStorage`. Applied consistently via Tailwind `dark:` variants across all components.
- **CI/CD** — GitHub Actions workflow running on every push to `develop` and `main`. Separate jobs for backend (RSpec + RuboCop) and frontend (Vitest + ESLint + `tsc --noEmit`). The pipeline must be green before any branch can merge.
