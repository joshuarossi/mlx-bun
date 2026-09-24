# Agent entry

Read [README](README.md), [ARCHITECTURE](ARCHITECTURE.md), the owning package's
README, then its code. Read [CONTRIBUTING](CONTRIBUTING.md) before changing
behavior or packaging. [PLAN](PLAN.md) holds open refactor work; history is Git.

## Policies

- Josh approves new files and migration scope. Do not carry material over just
  because it exists on main. YAGNI and KISS govern the rebuild.
- During this refactor, main is reference-only. Create reviewable chunk PRs
  targeting `refactor/monorepo`; do not merge them without Josh's instruction.
- Preserve numerical behavior during migration. Optimization is separate work;
  follow the evidence requirements in CONTRIBUTING.
- Never use the GPU while training is active. Check before numerical runs.
  Ask before starting persistent servers or multi-GB downloads.
- Do not release or publish packages without Josh's instruction.

## Ownership and verification

Architecture owns dependency direction and documentation policy. Package
READMEs own local setup; the root README owns workspace verification commands.
Keep the executable boundary gate authoritative for mechanical import rules.
Use codebase-memory-mcp for discovery when available; fall back to source search
when its coverage is insufficient. Read the implementation before changing it.

Do not add status ledgers, session summaries, or memory files. Report progress
in the conversation and PR; remove completed work from PLAN.
