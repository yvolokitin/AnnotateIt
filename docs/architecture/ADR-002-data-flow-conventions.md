# ADR-002: Data Flow Conventions

- Status: Accepted
- Date: 2026-03-14

## Context
Feature code currently mixes UI state updates, persistence, media operations, and inference calls in the same widget flows.

## Decision
Adopt a standard data flow for feature operations:

- UI event -> Application service command -> Repository -> Adapter(s) -> Result -> UI state update

Query flow:

- UI query request -> Application service query -> Repository -> Adapter(s) -> View model/data -> UI render

Conventions:

1. Application services own orchestration, retries, and multi-step workflow logic.
2. Repositories expose domain-focused operations, not widget-specific methods.
3. Adapters handle technology details (SQLite, filesystem, HTTP, model runtime).
4. UI only owns rendering, editing interactions, and user feedback loops.
5. Errors are normalized at application service boundary before UI display.

Client storage convention:

- In server-connected mode, SQLite is a local cache/working store, not the authoritative system of record.
- In local-only mode, SQLite remains authoritative.

## Non-goals

- No mandatory state-management framework change in this ADR.
- No schema redesign in this ADR.

## Consequences

- New features become testable at service/repository boundaries.
- Offline and sync behavior can be implemented consistently later.

