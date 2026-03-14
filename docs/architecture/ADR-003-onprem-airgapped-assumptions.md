# ADR-003: On-Prem and Air-Gapped Deployment Assumptions

- Status: Accepted
- Date: 2026-03-14

## Context
Product direction requires on-prem deployment with AI-assisted annotation and no SaaS dependency.

## Decision
Use these baseline assumptions for all new architecture work:

1. No required SaaS runtime dependency for core product workflows.
2. Backend is authoritative for:
   - project/media/annotation state
   - policy and authorization
   - review/audit decisions
   - heavy AI/media processing
3. Flutter client focuses on:
   - annotation UX and editing
   - local caching/working set
   - progress + error feedback loops
4. Heavy real-time video inference and large batch media processing must run on backend workers, not on client devices.
5. Air-gapped mode must not depend on public CDN/GitHub downloads at runtime.
6. Model/runtime assets must be customer-hosted or pre-bundled for the deployment.

Deployment conventions:

- Environment config must support customer-hosted API endpoints.
- Capability checks should be runtime-driven (for example backend capability endpoints) rather than hardcoded assumptions.

## Consequences

- Existing direct external model/runtime fetching paths need migration for strict air-gapped installs.
- Client-side inference remains optional for lightweight/local fallback only, not as primary heavy-processing path.

