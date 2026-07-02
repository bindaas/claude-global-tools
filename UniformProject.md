# UniformProject.md — Baseline Project Structure

Reference template for bootstrapping a new project on this stack (FastAPI + Postgres + Firebase auth + React/Vite frontend + Expo/React Native mobile, all talking to Anthropic's Claude API). Baseline is **tasksAreUs**, chosen because it has the cleanest separation of concerns of the projects surveyed so far (verified against groceriesAreUs, see `refactorProjectStructure.md` and `refactorTests.md` in that repo for the gap analysis that produced this doc).

This is a structural/tooling template, not a product spec. Product-specific dependencies (e.g. image processing for receipt OCR, fuzzy string matching, a local-LLM fallback via Ollama) get added on top of this baseline per-project — they are not part of the uniform layout itself.

---

## Directory structure

```
<project>/
  ARCHITECTURE.MD                 # system structure, code layout, key flows
  DATA_MODEL_AND_API.MD           # data model, API contracts, auth, domain invariants
  PRODUCT_REQUIREMENTS_DOCUMENT.MD
  RULES_OF_ENGAGEMENT.MD          # copy verbatim from claude-global-tools
  CLAUDE.md                       # project-specific: dev commands, deploy trigger, agent roster
  Dockerfile                      # root — 2-stage prod build (frontend build -> backend+static)
  docker-compose.yml
  railway.toml
  development-plans/              # PLAN-<branch>.md files, reviewed by Sneezy before implementation
  backend/
    app/                          # the importable package — everything deployed lives here
      __init__.py
      main.py                     # FastAPI() instance, lifespan, router registration, /health
      config.py                   # pydantic-settings singleton (see Config pattern below)
      database.py                 # engine, SessionLocal, get_db dependency
      dependencies.py             # auth dependency (get_current_user, get_firebase_claims)
      models.py                   # SQLAlchemy ORM models
      schemas.py                  # Pydantic request/response models
      routers/                    # one file per resource — HTTP layer only
        __init__.py
        <resource>.py
      services/                   # one file per resource — business logic, called by routers
        __init__.py
        <resource>_service.py
    tests/
      __init__.py
      test_api.py                 # integration tests — owned exclusively by /test-review skill
      unit/                       # dev-owned — add/edit alongside business logic changes
        __init__.py
        test_<service_or_router>.py
    scripts/                      # one-off/migration scripts — never in app/ or tests/
    requirements.txt              # pinned exact versions
    Dockerfile                    # local/dev image
    docker-compose.yml
    .env.example
  frontend/
    src/
      api/                        # one file per resource — thin HTTP client wrappers
      components/
      context/                    # React context providers (Auth, etc.)
      hooks/
      pages/
      utils/                      # pure functions — unit test target
      __tests__/                  # Vitest, targets utils/ and api/
      firebase.ts
      App.tsx
      main.tsx
    eslint.config.js              # flat config
    tsconfig.json                 # references tsconfig.app.json + tsconfig.node.json
    package.json
  mobile/
    src/
      api/                        # mirrors frontend/src/api — separate app, same contract
      context/
      hooks/
      screens/                    # mobile equivalent of frontend's pages/
      navigation/
      types/
      utils/
      __tests__/                  # Jest + jest-expo
      firebase.ts
    app.config.js
    eas.json
    package.json
```

---

## Tech stack (pinned)

### Backend (`backend/requirements.txt`)
```
fastapi==0.115.0
uvicorn[standard]==0.30.6
sqlalchemy==2.0.36
psycopg2-binary==2.9.10
pydantic==2.9.2
pydantic-settings==2.5.2
python-dotenv==1.0.1
anthropic==0.40.0
python-dateutil==2.9.0
httpx==0.27.2
pytest==8.3.5
firebase-admin==6.5.0
```
Pin exact versions, not ranges — reproducibility matters more than always getting latest.

### Frontend (`frontend/package.json`)
- React 19, react-dom 19, react-router-dom 7
- Vite 8, TypeScript ~6, Vitest 4, jsdom
- `@firebase/app` + `@firebase/auth` (modular SDK — not the monolithic `firebase` package)
- Tailwind 3 + postcss + autoprefixer
- ESLint flat config: `eslint`, `typescript-eslint`, `eslint-plugin-react-hooks`, `eslint-plugin-react-refresh`, `@eslint/js`, `globals`

### Mobile (`mobile/package.json`)
- Expo ~54 (managed workflow), React Native 0.81.x, React 19.1.x
- `expo-auth-session`, `expo-crypto`, `expo-web-browser`, `expo-updates`, `expo-status-bar`, `expo-linking`
- `@react-native-async-storage/async-storage`, `@react-navigation/native` (+ `bottom-tabs` or `native-stack` depending on nav shape)
- `nativewind` + `tailwindcss` for styling (not raw `StyleSheet`)
- `react-native-reanimated` + `react-native-worklets` + `react-native-gesture-handler` if the UI needs animation/gestures
- `firebase` (JS SDK) for auth
- Jest + `jest-expo` preset

---

## Import convention

`backend/app/` is a real Python package, always run as `uvicorn app.main:app` (never `cd app && uvicorn main:app`, never adding `app/` itself to `sys.path`). Because of that, **all intra-package imports are relative**:

```python
# app/main.py
from .config import settings
from .database import SessionLocal, engine
from .models import Base, User
from .routers import tasks, boards

# app/routers/tasks.py
from ..database import get_db
from ..dependencies import get_current_user
from ..models import Task
from ..services import task_service as svc
```

Never mix relative and absolute (`from app.routers import ...`) within the package — pick relative and use it everywhere. This applies equally to `backend/tests/` — test imports mirror the same relative-vs-absolute discipline (`from app.main import app`, `from app.services import task_service` from outside the package is fine since tests aren't part of the `app` package itself).

Reflect this in the Dockerfile CMD, `docker-compose.yml`'s `command:`, and the `CLAUDE.md`/`ARCHITECTURE.MD` dev-command blocks — every place `main:app` could appear must say `app.main:app`.

---

## Config pattern

Single `pydantic_settings.BaseSettings` instance, not scattered module-level constants:

```python
# app/config.py
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/<dbname>"
    ANTHROPIC_API_KEY: Optional[str] = None
    CLAUDE_MODEL: str = "claude-sonnet-4-6"
    FIREBASE_SERVICE_ACCOUNT_JSON: Optional[str] = None
    FIREBASE_PROJECT_ID: Optional[str] = None
    TEST_AUTH_BYPASS: bool = False  # local/CI only — never true in production

    model_config = {"env_file": ".env", "extra": "ignore"}

settings = Settings()
```

Import `from .config import settings` and read `settings.X` — never `os.getenv(...)` scattered through the codebase.

---

## Auth pattern

Firebase Bearer token, verified in `app/dependencies.py`, with a `TEST_AUTH_BYPASS` escape hatch for local/CI:

- `get_current_user(authorization: Header, x_user_id: Header, db: Session) -> str` resolves the caller to an internal user UUID.
- When `settings.TEST_AUTH_BYPASS` is true, `X-User-ID` is accepted directly (no Firebase call) — the user row must already exist (seed a system user at startup, don't auto-create).
- When bypass is false, `Authorization: Bearer <token>` is verified via `firebase_admin.auth.verify_id_token`.
- Evaluate the bypass flag per-request (`settings.TEST_AUTH_BYPASS`, not a module-level constant captured at import time) so it can be toggled without a server restart.

---

## Test organization

- `backend/tests/test_api.py` — integration tests, hits a real DB via `TestClient`. Owned exclusively by the `/test-review` skill (Sleepy). Never modify directly.
- `backend/tests/unit/` — unit tests, mock the DB session with `unittest.mock.MagicMock`, no real DB required. One file per service/router being tested (`test_task_service.py`, `test_labels_router.py`, etc.). Dev-owned — add/edit alongside the business logic change that motivated it.
- `frontend/src/__tests__/` and `mobile/src/__tests__/` — Vitest/Jest respectively, target pure functions in `utils/` and the API client wrappers in `api/`.

The unit/integration split must be a real subdirectory boundary (`tests/unit/` vs `tests/`), not just a naming convention within one flat directory — a flat mix makes "never modify directly" and "add unit tests freely" apply ambiguously to the same folder.

---

## Deploy setup

- Root `Dockerfile`: 2-stage build — stage 1 builds the frontend (`npm ci && npm run build`, with `VITE_FIREBASE_*` declared as `ARG`s so Railway can inject them at build time), stage 2 installs backend deps, copies `backend/` in, copies stage 1's `dist/` in as `static/`, `CMD uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}`.
- `railway.toml`: `dockerfilePath = "Dockerfile"`, health check on `/health` (or whatever path `app/main.py` exposes).
- Deploy-trigger rule (documented in `CLAUDE.md`): triggers on `backend/app/` only — no exclusion needed, because tests/scripts/tooling already live outside `app/`.
- `.gitignore` must exclude `.env`, `__pycache__/`, `*.pyc`, and any local DB files/dumps — none of those belong in version control. Confirm no `*.db`, `*.sql`, or `*_backup_*` files get committed by accident.
- `.env.example` at `backend/` root lists every var `Settings()` reads, with placeholder values.

---

## Notes

- This doc describes structure and tooling only. Domain-specific decisions (recurring-task rules, belief engines, receipt OCR, etc.) belong in each project's own `DATA_MODEL_AND_API.MD` / `PRODUCT_REQUIREMENTS_DOCUMENT.MD`, not here.
- If a future project's stack diverges intentionally (different DB, different auth provider, no mobile app), don't force-fit this template — note the divergence and why, the same way `RULES_OF_ENGAGEMENT.MD`'s neutrality rules ask agents to reference project docs instead of hardcoding assumptions.
