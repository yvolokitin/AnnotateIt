# ADR-001: Module and Layer Boundaries

- Status: Accepted
- Date: 2026-03-14

## Context
The current Flutter codebase contains frequent direct coupling between UI widgets/pages and persistence/services. This makes incremental backend integration and safe refactoring harder.

## Decision
Use an evolutionary 4-layer structure for all new and migrated features:

1. `presentation` (`lib/pages/**`, `lib/widgets/**`)
2. `application services` (`lib/application/**` as target location)
3. `repositories` (interfaces in `lib/domain/**` or `lib/repositories/**`)
4. `adapters` (`lib/data/**`, `lib/services/**`, and future API adapters)

Allowed dependency direction only:

- `presentation -> application services`
- `application services -> repositories`
- `repositories -> adapters` (through interface bindings)
- No reverse dependencies.

Required conventions:

- UI code must not directly call SQLite classes in `lib/data/**` for new work.
- UI code must not orchestrate multi-step domain workflows; move orchestration to application services.
- Adapter code (SQLite, HTTP, ML runtime) must not import UI widgets/pages.

Transitional rule:

- Existing direct UI-to-data calls are tolerated temporarily.
- Any touched feature should move one step toward this boundary model instead of adding new coupling.

## Consequences

- Short-term: some duplication while facades/services are introduced.
- Medium-term: easier backend integration, safer tests, lower change risk.
- This ADR does not require a big-bang folder reorganization.

