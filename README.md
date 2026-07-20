# GIGGO — Smart Service Marketplace

Monorepo containing three apps:
- `mobile/`      — Flutter app (customer + provider)
- `backend/`     — Spring Boot API (Java 21)
- `ml-service/`  — Python FastAPI service (AI/ML)

## Development Workflow

### First-time setup (after cloning)
Enable the local git hooks (commit-message and branch-name checks):

### Branches
Work happens on short-lived branches off `main`, named `prefix/short-description`
(lowercase, hyphenated). Allowed prefixes:

| Prefix     | For                                |
|------------|------------------------------------|
| `feature/` | new features                       |
| `fix/`     | bug fixes                          |
| `chore/`   | maintenance, config, tooling       |
| `docs/`    | documentation                      |

Examples: `feature/p03-docker-compose`, `fix/login-crash`, `docs/update-readme`.
Tip: name the branch after its WBS task so branch, PR, and plan line up.

### Commits
Commit messages follow [Conventional Commits](https://www.conventionalcommits.org):
`type(optional-scope): short description` — lowercase, present tense, no trailing period.

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
`build`, `ci`, `chore`, `revert`.

Examples:
- `feat(auth): add Google login`
- `fix(booking): prevent double-booking on same slot`
- `ci: add commitlint check to PR pipeline`

### Flow
1. Branch: `git checkout -b feature/my-task`
2. Commit as you go (hooks check each message)
3. Push and open a Pull Request into `main`
4. Let CI checks pass, then merge