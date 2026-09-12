# src/lab — quarantined, no-oracle code

Everything here is a Lab-tier module (docs/design/unified-engine-frontier-plan.md):
no external oracle, off by default, kept only while a measurement decides its
fate (PLAN.md "Maintainability program", D6 darlings). Rules, gate-enforced by
`scripts/check-hygiene.ts` (check 11):

- nothing outside `src/lab/` may import from `src/lab/` except the edges listed
  in `LAB_IMPORT_ALLOWLIST` — those are recorded debt, not permission;
- a new production dependency on a Lab module is a decision, not a default:
  either promote the module out of the lab with an oracle/measurement, or
  route it through an option seam.

| module | flag / entry | oracle |
|---|---|---|
| `curve/` (curve sampler + designer page) | `--curve-*`, `/curves` | none (Lab) |
| `paged-kv/` | `--paged-kv`; direct read via `MLX_BUN_PAGED_ATTN` | gathered storage is bit-exact; direct Metal is tolerance-tested, with paired M1/M4 measurements in benchmarks.md |
| `expert-trace/` | `MLX_BUN_EXPERT_TRACE` hook in gemma4 | closed study (expert-offload) |

The optional paged layout has a separate backend persistence codec. Its
allowlisted import keeps `kv-store` independent of row-execution modules and
preserves RAM/SSD reuse without promoting direct-attention numerics to L1.
