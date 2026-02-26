# CLAUDE.md — Backend

## Stack

| Technology    | Version |
|---------------|---------|
| Ruby          | 3.3+    |
| Rails         | 7.1+    |
| PostgreSQL    | 15+     |
| RSpec         | 3.12+   |

## Gems

| Gem                  | Purpose                         |
|----------------------|---------------------------------|
| `jwt`                | Token generation/verification   |
| `bcrypt`             | Password hashing                |
| `jsonapi-serializer` | JSON serialization              |
| `pundit`             | Authorization policies          |
| `pagy`               | Pagination                      |
| `rack-cors`          | CORS configuration              |
| `rspec-rails`        | Testing framework               |
| `factory_bot_rails`  | Test data factories             |
| `shoulda-matchers`   | Readable model specs            |
| `faker`              | Realistic seed and factory data |
| `rswag`              | Swagger/OpenAPI documentation   |
| `simplecov`          | Test coverage reporting         |

---

## Architecture

Every layer has one responsibility. Violating these boundaries is not allowed.

| Layer           | Location                  | Responsibility                                | Never                                        |
|-----------------|---------------------------|-----------------------------------------------|----------------------------------------------|
| Controllers     | `app/controllers/api/v1/` | Receive request, call service, return response | Contain business logic or format JSON manually |
| Service Objects | `app/services/`           | Contain all business logic                    | Access request/response objects              |
| Serializers     | `app/serializers/`        | Format JSON responses                         | Contain logic beyond presentation            |
| Policies        | `app/policies/`           | Authorization rules                           | Contain business logic                       |
| Models          | `app/models/`             | Validations, associations, scopes             | Contain business logic — use Service Objects |
| Concerns        | `app/models/concerns/`    | Shared behavior between models                | Be used for business logic                   |

### Service Object Structure

```
app/services/
├── auth/
│   ├── register_user.rb
│   └── authenticate_user.rb
├── tweets/
│   ├── create_tweet.rb
│   ├── delete_tweet.rb
│   └── build_timeline.rb
├── follows/
│   ├── follow_user.rb
│   └── unfollow_user.rb
└── likes/
    ├── like_tweet.rb
    └── unlike_tweet.rb
```

---

## Folder Structure

```
app/
├── controllers/api/v1/
├── models/
│   └── concerns/
├── policies/
├── serializers/
└── services/
    ├── auth/
    ├── tweets/
    ├── follows/
    └── likes/

spec/
├── factories/
├── models/
├── requests/api/v1/
└── services/
```

---

## TDD — Methodology

Every feature follows **Red → Green → Refactor**. No exceptions.
Never write implementation code without a failing test first.

- Use descriptive `describe`, `context`, `it` blocks that read as full sentences
- Always use FactoryBot factories — never raw `Model.create(...)` in specs
- Use `build` when persistence is not needed, `create` only when required
- Use shared examples for repeated patterns (e.g. requires authentication)

---

## Coverage Requirements

Run with: `COVERAGE=true bundle exec rspec`

| Section         | Minimum  | What to cover                                       |
|-----------------|----------|-----------------------------------------------------|
| Models          | 95%+     | Validations, associations, scopes, instance methods |
| Request specs   | 90%+     | All endpoints, all status codes, auth and unauth    |
| Service objects | 85%+     | All business logic paths and edge cases             |
| **Global**      | **80%+** | Overall minimum — non-negotiable                    |

---

## Definition of Done

A feature is **NOT done** until every item is complete:

- [ ] Tests written **before** implementation (TDD — Red first)
- [ ] All tests passing (`bundle exec rspec` with zero failures)
- [ ] Coverage for the corresponding section is met
- [ ] No linting errors (`bundle exec rubocop`)
- [ ] Feature and tests committed **together** in the same commit
- [ ] Swagger updated if a new endpoint was added
- [ ] If there were database changes, migration generated and executed — never edit `db/schema.rb` directly

---

## Rails Patterns

- `rescue_from` in `ApplicationController` for all common exceptions — never handle them individually per controller
- Strong parameters always defined in the controller — never pass raw params to a service or model
- Scopes must return `ActiveRecord::Relation` — never an array
- No business logic in model callbacks — always use Service Objects
- Every database change requires a migration file — never modify an executed migration, create a new one
- Migrations committed together with the model that requires them
- Indexes on all foreign keys and frequently queried columns

---

## HTTP Status Codes

| Situation                                 | Code |
|-------------------------------------------|------|
| Successful GET / PATCH                    | 200  |
| Resource created (POST)                   | 201  |
| Successful DELETE                         | 204  |
| Validation error                          | 422  |
| Not authenticated (missing/invalid token) | 401  |
| Authenticated but not authorized          | 403  |
| Resource not found                        | 404  |
| Server error                              | 500  |

---

## API Response Format

```
// Success     → { "data": {}, "meta": {} }
// Collection  → { "data": [], "meta": { "total": 42, "page": 1 } }
// Error       → { "error": "description", "details": {} }
```
---

## Documentation Workflow
After all tests pass for an endpoint:

Run a curl command against the local server (http://localhost:3000) to get a real response
Use the real request and response to generate the rswag documentation block for that endpoint
Run rake rswag:specs:swaggerize to update swagger.json
Commit endpoint, tests, and documentation together


The server must be running on port 3000. Never document with invented examples — always use real responses.

---

## API Versioning

All routes namespaced under `/api/v1/` — non-negotiable.