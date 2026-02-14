# ian-platform-implementation

Purpose
-------

This repository contains the foundational platform for building production-ready services and infrastructure for the organization. It provides conventions, CI scaffolding, and a reproducible developer environment so teams can incrementally implement a secure, observable, and maintainable platform.

Quickstart (minimum)
---------------------

Prerequisites
- Docker (for the dev container)
- VS Code with the Remote - Containers / Dev Containers extension
- Git

Clone the repo

```bash
git clone https://github.com/Iansenekal/ian-platform-implementation.git
cd ian-platform-implementation
```

Environment
- Copy the environment pattern and populate secrets locally:

```bash
cp .env.example .env
# edit .env to add secrets and environment-specific values
```

Dev container (recommended)
- Open the repository in VS Code and use the Remote - Containers / Dev Containers extension to open in the provided dev container. This ensures a consistent environment across machines.
- In the dev container, use the repository's developer scripts to start services or run tasks (examples below).

Common developer commands (placeholders)

```bash
# run linters
make lint

# run tests
make test

# start local dev environment (example)
make dev

# build artifacts
make build
```

Notes
- This README is intentionally technology-agnostic. Concrete scripts and targets (Makefile, scripts/, docker-compose, etc.) will be added as the platform's technologies are chosen.
- Do not commit secrets. See Environment section and `.env.example`.

Repository conventions and contribution
------------------------------------

Follow the repository conventions documented in [REPO_CONVENTIONS.md](REPO_CONVENTIONS.md). Key points:
- `main` is the protected production branch.
- Feature branches: `feature/<ticket>-short-desc`.
- Use Conventional Commits (e.g., `feat(auth): add login`) for clear history.
- Pull requests must include a description, testing steps, and at least one reviewer.

Platform roadmap
-----------------

See [docs/PLATFORM_ROADMAP.md](docs/PLATFORM_ROADMAP.md) for the complete vision and implementation phases (00–99 workflow). The roadmap spans infrastructure (Proxmox), identity (Keycloak), document management (Nextcloud), search, voice, workflow/eSign, automation, monitoring, and Day-2 Ops — with observability and security as foundational pillars.

CI and automation
-----------------

This repo uses GitHub Actions for CI (lint/build/test placeholders). The pipeline is intentionally minimal to start and will be expanded as components are added.

Files to check or edit
- [docs/PLATFORM_ROADMAP.md](docs/PLATFORM_ROADMAP.md) — full platform vision and phases
- [REPO_CONVENTIONS.md](REPO_CONVENTIONS.md) — branching, commits, PR process
- .env.example — safe environment pattern (do not commit secrets)
- .gitignore — ensure `.env` and other secrets are ignored

License
-------

TBD — add license file if required.

Contact
-------

Platform owners and maintainers: add names/contacts here once established.
# ai-platform-implementation
