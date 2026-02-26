# The Flock — Development Plan

This document outlines the step-by-step development process followed to build The Flock.
Each step represents an atomic unit of work committed independently to reflect a clean,
logical progression of the codebase.

---

## FASE 1 — Setup

**Step 1 — Mono-repo structure + Rails scaffold**
Initialize the project structure. Set up Rails 7 API-only backend with PostgreSQL, RSpec,
and all required gems. No models or controllers yet.

**Step 2 — React scaffold**
Set up the React frontend with Vite, TypeScript, Tailwind CSS (dark mode enabled),
React Query, Axios, React Router, and Vitest. Full folder structure initialized.

**Step 3 — Docker**
Add docker-compose.yml to orchestrate PostgreSQL, Rails backend, and React frontend.
Dockerfiles for each service and .env.example included.

---

## FASE 2 — Auth Backend

**Step 4 — User model**
TDD: spec written first. User model with validations, bcrypt password, JWT generation,
and token decoding. FactoryBot factory with Faker.

**Step 5 — Auth endpoints**
TDD: request specs first. Register, login, and me endpoints. Service objects for
registration and authentication. ApplicationController auth helpers. User serializer.
Swagger documentation generated from real curl responses.

---

## FASE 3 — Tweets Backend

**Step 6 — Tweet model**
TDD: spec written first. Tweet model with validations, User association,
and reusable scopes for timeline queries. FactoryBot factory.

**Step 7 — Tweet endpoints**
TDD: request specs first. Create, delete, and paginated timeline endpoints.
Service objects for each action. TweetPolicy via Pundit for authorization.
Tweet serializer with likes_count and liked_by_current_user.
Swagger documentation generated from real curl responses.

---

## FASE 4 — Social Backend

**Step 8 — Follow system**
TDD: spec written first. Follow model with self-follow and duplicate validations.
User association methods. Follow/unfollow service objects. Followers and following
list endpoints with pagination. Swagger documentation generated from real curl responses.

**Step 9 — Like system**
TDD: spec written first. Like model with Likeable concern for future reuse.
Like/unlike service objects. Tweet serializer updated with like data.
Swagger documentation generated from real curl responses.

**Step 10 — User profile and search**
TDD: spec written first. Public profile, profile update, and user search endpoints.
Searchable concern on User model. UserPolicy for authorization.
Swagger documentation generated from real curl responses.

---

## FASE 5 — Seed Data

**Step 11 — Seed data**
Realistic seed with 10 users, tweets, follows, and likes using Faker.
Idempotent — safe to run multiple times. Demo user included for easy testing.

---

## FASE 6 — Frontend

**Step 12 — Types and service layer**
TypeScript interfaces for all domain models. Axios instance with JWT interceptor
and 401 handler. Complete API service layer for auth, tweets, users, follows, and likes.

**Step 13 — Auth layer**
AuthContext with current user, login, and logout. Protected route logic.
Login and Register pages. Reusable common components: Button, Input, Avatar.

**Step 14 — Tweet feed**
TweetCard and TweetForm components. InfiniteScrollList reusable wrapper.
React Query hooks for timeline, create, delete, like, and unlike.
Timeline page with infinite scroll.

**Step 15 — User profile**
React Query hooks for profile, follow, and unfollow.
FollowButton component with optimistic update.
Profile page with header, stats, tweet list, and edit form for own profile.

**Step 16 — Search**
Debounced search hook. Search page with UserCard results, loading state, and empty state.

**Step 17 — Layout and navigation**
Main app layout with Sidebar (desktop) and BottomNav (mobile).
Dark mode toggle with localStorage persistence.
Responsive shell applied to all pages.

---

## FASE 7 — Bonus

**Step 18 — CI/CD**
GitHub Actions workflow with lint, tests, and build on every push to develop and main.
Separate jobs for backend (RSpec + Rubocop) and frontend (Vitest + ESLint + tsc).

---

## FASE 8 — Polish

**Step 19 — README**
Complete README with setup instructions, architecture decisions, trade-offs,
and documentation of AI tools used throughout development.

**Step 20 — Final cleanup**
Remove dead code, fix any remaining linting warnings, verify coverage meets minimums,
final review of commit history and documentation.
