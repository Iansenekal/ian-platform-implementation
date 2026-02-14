# Repository Conventions

This document captures recommended conventions for branches, commits, pull requests, naming, and releases. These are intentionally simple and technology-agnostic; adapt when the platform's toolchain is chosen.

Branching
- `main` — protected, production-ready (always deployable)
- `develop` — optional integration branch for ongoing work
- Feature branches: `feature/<ticket>-short-desc` (e.g., `feature/123-add-auth`)
- Fix branches: `fix/<ticket>-short-desc`
- Hotfix branches: `hotfix/<short-desc>`

Commits
- Use Conventional Commits style: `type(scope?): subject`
  - Examples: `feat(auth): add login endpoint`, `fix(db): handle timeout`
- Common types: `feat`, `fix`, `chore`, `docs`, `test`, `ci`, `refactor`

Pull Requests
- PR title should include ticket/id and short description when applicable.
- A PR must include:
  - Description of changes
  - Testing steps or verification notes
  - Linked issue or ticket (if available)
  - At least one reviewer (two for larger changes)
- Require passing CI checks before merge; prefer merge via squash or rebase depending on team preference.

Naming
- Files and folders: lowercase and use hyphens (e.g., `service-config`, `infra-scripts`) unless platform idioms prescribe otherwise.
- Code identifiers should follow language-specific conventions.

Releases and Tags
- Use semantic versioning (SemVer) for releases: `vMAJOR.MINOR.PATCH`.
- Maintain a changelog referencing notable changes per release.

Code Review and Quality
- Keep PRs small and focused; aim for incremental, reviewable changes.
- Add automated checks (linters, unit tests) early and require them in CI.

Exceptions
- When a technology or tool requires a different convention, document the rationale in this file and update team docs.
