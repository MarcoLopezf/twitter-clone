# CLAUDE.md

## Project Overview

The Flock is a Twitter clone built as a full-stack technical challenge.
It demonstrates professional software devment practices including
TDD (backend), clean code, meaningful git history, and effective use
of agentic coding tools.

## Stack

| Layer      | Technology                        | Location    |
|------------|-----------------------------------|-------------|
| Backend    | Ruby on Rails 7 (API mode)        | `/backend`  |
| Frontend   | React 19 + TypeScript + Vite      | `/frontend` |
| Database   | PostgreSQL                        | —           |
| Auth       | JWT                               | —           |
| Styling    | Tailwind CSS                      | —           |

## Repository Structure

```
the-flock/
├── backend/            # Rails API — see backend/CLAUDE.md
├── frontend/           # React app — see frontend/CLAUDE.md
├── docker-compose.yml
└── README.md
```

---

## Branching Strategy

| Branch           | Purpose                                              |
|------------------|------------------------------------------------------|
| `main`           | Always stable, production-ready                      |
| `dev`        | Integration branch — all features merge here first   |
| `feature/<name>` | One branch per feature, created from `dev`       |

**Rules:**
- Feature branches are always created from `dev`
- Feature branches merge back to `dev` via PR
- `dev` merges into `main` only at stable milestones
- Branch naming examples: `feature/auth`, `feature/tweets`, `feature/likes`

---

## Commit Convention

All commits must follow **Conventional Commits** format:

```
<type>(<scope>): <short description>
```

### Types

| Type       | When to use                                          |
|------------|------------------------------------------------------|
| `feat`     | New feature                                          |
| `test`     | Adding or updating tests                             |
| `fix`      | Bug fix                                              |
| `refactor` | Code improvement without behavior change             |
| `docs`     | Documentation only                                   |
| `chore`    | Setup, config, dependencies                          |

### Examples

```
feat(auth): add JWT login endpoint
feat(tweets): add create and delete endpoints
test(tweets): add request specs for tweet creation
refactor(users): extract follow logic into service object
chore(infra): add docker-compose for local devment
docs(api): add Swagger documentation for auth endpoints
```

### Rules

- **English only** — all code, commits, comments, and documentation
- **One concern per commit** — never mix two features in one commit
- **Tests travel with the feature** — committed in the same commit, never at the end
- **No squash** — full history must remain visible at all times
- **No vague messages** — never: "fix stuff", "WIP", "updates", "misc", "changes"

---

## General Coding Rules

| Rule                     | Detail                                                    |
|--------------------------|-----------------------------------------------------------|
| Descriptive names        | No `data`, `res`, `tmp`, `val`, `obj`                     |
| No abbreviations         | Unless universally known: `id`, `url`, `api`, `db`        |
| Early returns            | Avoid nested conditionals — return early when possible    |
| DRY                      | If written twice, extract it                              |
| No dead code             | Never comment out code and leave it — delete it           |
| No magic numbers         | Extract constants with descriptive names                  |

---

## What Goes Where

Specific patterns, testing rules, coverage requirements, libraries,
and folder structure are documented in each subproject:

- **Backend rules** → `backend/CLAUDE.md`
- **Frontend rules** → `frontend/CLAUDE.md`