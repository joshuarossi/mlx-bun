# Memory docs organization + DAG-view refresh — review & plan

Status: **proposal**, 2026-07-01. Read-only review; nothing here has been
executed. Two mandates: (A) get the Dreaming doc set into an organized state,
(B) assess and plan the refresh of the parity-tier DAG view. Josh's live,
uncommitted edits (`dreaming-nightly-pipeline.md` + the two SUPERSEDED banners)
are treated as the direction of record and untouched.

---

## A. The Dreaming doc set

### A.1 Inventory — role and verdict per doc

| Doc | Role | State (verified 2026-07-01) | Verdict |
|---|---|---|---|
| `docs/design/dreaming-nightly-pipeline.md` (new, uncommitted) | **CANONICAL system design** — pipeline, fixed principles, decisions-overridden table, work plan | Current; self-declares supersession over master-plan / memory-synthesis / handoff | **Keep as the hub.** It's already the entry point by construction. |
| `docs/design/the-dreaming-master-plan.md` | Execution spec (P0–P10 task DAG, port-source map, schemas) | Bannered PARTIALLY SUPERSEDED (Josh's edit). Carries no as-built state — a reader can't tell P0–P9 are DONE | Keep, banner is right. **Add a one-line as-built note** ("built through P9; live state in STATUS.md") so the task list reads as history+reference, not TODO. |
| `docs/design/the-dreaming-handoff.md` | Session log / live handoff (2026-06-28) | **Stale as a handoff:** cursor 720 (now 900/2096 paused), "everything is uncommitted" (merged 2026-07-01), "wire through persistent server" (in-process gateway landed instead), batch default (now 1). Lessons §1–8 remain valuable | **Demote to historical.** Banner: "Session log 2026-06-28 — live state is STATUS.md § THE DREAMING; the numbered LEARNED/CORRECTED list remains load-bearing." Stop maintaining two live handoffs. |
| `docs/design/memory-synthesis.md` | M1 design, 1st iteration (embeddings, section-route) | Bannered SUPERSEDED (Josh's edit) | Keep for history. No further action. |
| `docs/design/bucketing-stage.md` | Classify-stage design (2026-06-26) | **No banner.** Core content (embeddings as candidate-narrower) is dead under "no embeddings anywhere"; the binary-question ladder survives inside the nightly BUCKET stage | **Needs a SUPERSEDED banner** (same shape as memory-synthesis's): dead = embedding narrower + silhouette; survives = capacity-by-decomposition, one-binary-question-at-a-time. |
| `docs/design/write-pipeline-entity.md` | Entity-keyed routing design (2026-06-26); itself "supersedes bucket-centric routing" | **No banner.** Half-dead: pure entity ROUTE (no bucket layer) is replaced by BUCKET→RESOLVE; the personal-notability checklist is dead. Survives: articles-are-THINGS, name/alias/category lookup, no-embeddings routing | **Needs a PARTIALLY SUPERSEDED banner** mapping survives/dead — otherwise its own "supersedes bucketing" claim inverts the actual chain for a newcomer. |
| `docs/design/memory-system.md` | M0 substrate design (vault, read tools, CLI, scheduling, consent) | **Status header is FALSE**: "synthesize is currently a safe no-op stub", "stage modules throw if called" — the pipeline is built and has produced 677+ articles. Directly contradicts `docs/reference/memory.md`. The four-adapter table + "Next implementation steps" describe the abandoned M1 sketch | **Fix the header + scope it down.** Retitle scope to "M0 substrate: vault + read path (landed)"; delete or banner the "Synthesis pipeline design (M1/M2)" and "Next implementation steps" sections, pointing at dreaming-nightly-pipeline. The substrate half (storage layout, tools, skill, scheduling, consent) is still the best writeup of the read side — keep it. |
| `docs/design/memory-inference-path.md` | Inference-path rework: design + measured verification | Accurate, self-bannered (BUILT + VERIFIED; batching measured a loss). It's really an investigation record | Fine as-is. Optional (low priority): move to `docs/investigations/` where measured-experiment records live. |
| `docs/reference/memory.md` | User-facing reference | Mostly current (synthesize description matches as-built stages; status truth fixed 2026-07-01). **But** the "Synthesis roadmap" section still tells the old four-named-LoRA / HF-adapter-pack story (memory-bucket/memory-synthesis/memory-editor LoRAs "distributed from Hugging Face") — not the plan of record (`memory-<stage>` convention, only `memory-chunk` exists, base+policy otherwise) | **Rewrite the roadmap section** to the as-built stage list + the `memory-<stage>` adapter convention; update stage names again when BUCKET/RESOLVE land. |
| `STATUS.md` § THE DREAMING | Live state | Current and correct (batch default 1, third-person fix merged, import paused at cursor 900/2096, inference-path landed) | Keep as the ONLY live-state location. |

### A.2 Contradictions / staleness found (the concrete list)

1. **memory-system.md vs reference/memory.md** — "synthesize is a no-op stub"
   vs "runs the full local synthesis DAG". Two tracked docs, opposite claims.
   Worst offender; fix first.
2. **Stage-name drift across four vocabularies:**
   - memory-system: `ingest→chunk→cluster→synthesize→wikify→changelog`
   - memory-synthesis: `CHUNK→FILTER→CLASSIFY→SYNTHESIZE→NORMALIZE→WIKIFY`
   - as-built (`stages.ts`, handoff, reference): `segment→extract→route→create/patch→reconcile→link→wikify`
   - canonical target (nightly pipeline): `SEGMENT→BUCKET→RESOLVE→SYNTHESIZE→gates→RECONCILE→LINK→NORMALIZE→EDITORIAL`
   Rule going forward: **reference/memory.md speaks as-built; dreaming-nightly-pipeline speaks target**; every other doc is history and says so.
3. **Unbannered middle links of the supersession chain**: the chain is
   memory-synthesis → bucketing-stage → write-pipeline-entity → master-plan →
   nightly-pipeline, and only the first and fourth links carry banners.
   bucketing-stage still presents embeddings as production machinery;
   write-pipeline-entity still presents the notability checklist.
4. **Two live handoffs** (the-dreaming-handoff.md and STATUS.md § Dreaming)
   with diverged facts (cursor 720 vs 900; uncommitted vs merged).
5. **Four-adapter product story duplicated** (memory-system.md AND
   reference/memory.md) vs the actual `memory-<stage>`-iff-exists convention.
6. **CLAUDE.md doc map out of sync**: `dreaming-nightly-pipeline.md`,
   `generic-model-support.md`, `mlx-lm-tool-parity-plan.md`,
   `batching-v2-plan.md` are on disk but absent from the doc-map lists.

### A.3 Proposed end-state

No renames, no folder moves, no merges mid-flight (the import is paused
mid-run and the nightly doc is uncommitted). Organization = **banners +
one scope-fix + one hub table + reading order**, all cheap and link-stable:

1. **Canonical entry point: `dreaming-nightly-pipeline.md`.** Add a short
   "Doc family" table at its top covering ALL of: master-plan (task refs),
   handoff (history), memory-synthesis / bucketing-stage /
   write-pipeline-entity (history), memory-system (M0 substrate),
   memory-inference-path (inference seam), reference/memory.md (user-facing),
   STATUS.md (live state). Today it names only three of these.
2. **Banner the two unbannered history docs** (bucketing-stage,
   write-pipeline-entity) with survives/dead maps as in A.1.
3. **Fix memory-system.md's header + amputate its M1 sketch** (A.1 row).
4. **Demote the-dreaming-handoff.md to a dated session log** pointing at
   STATUS.md; add the as-built one-liner to the master plan.
5. **Rewrite reference/memory.md's roadmap section** to as-built.
6. **Sync the CLAUDE.md doc map** (A.2 item 6).

**Newcomer reading order** (to be stated in the nightly doc's family table):
1. `docs/reference/memory.md` — what it is, how to use it
2. `docs/design/dreaming-nightly-pipeline.md` — the canonical design +
   decisions-overridden table
3. `STATUS.md` § THE DREAMING — where it stands, what's next
4. `docs/design/the-dreaming-master-plan.md` — per-task file/port/schema
   references (respect the banner)
5. History, only for archaeology: memory-synthesis → bucketing-stage →
   write-pipeline-entity → the-dreaming-handoff → memory-inference-path

---

## B. The DAG view (docs/dag/training-inference-map.html + parity-tier-dag.md)

### B.1 What exists today

- **parity-tier-dag.md** — the framework doc. **Already refreshed 2026-07-01**:
  it carries the corrected lever table (perf-kernel = L3/opt-in, off in bare
  `--l2`), the f1bf5cc post-mortem, and the two-axes rule. Not stale.
- **training-inference-map.html** — a hand-authored cytoscape control-flow map,
  **MiniCPM5-1B only**, two tabs (inference ~150 nodes: generate loop → forward
  → attention → sdpa dispatch → tiled/unfused kernels → KV bf16/quant →
  sampler; training ~90 nodes: step loop → segmented/prefix → SFT/DPO/ORPO loss
  heads incl. flash-CCE → AdamW → metrics). Every node carries a hardcoded
  `file:line`. Branch edges carry the exact flag/predicate
  (`perfKernelEnabled()`, `fusedSdpaSupported`, `MLX_BUN_TRAIN_ATTN`, …).
- **Gap vs its own billing:** PLAN.md and parity-tier-dag.md call it
  "tier-tagged" — it is **not**. Nodes are colored by *subsystem*; no node
  carries an L1/L2/L3 tag. The tier story exists only in prose.

### B.2 Staleness after 2026-07-01

| Area | What changed | Map impact |
|---|---|---|
| L2 tier contract (commit `381382c`) | `TIERS.l2.perf → false`; bare `--l2` = stock unfused L=1 decode; perf kernel is L3/`--l3` | The `perfKernelEnabled()` branch (n92→n95) still exists, so the *structure* is right — but nothing in the map encodes tier presets, so the map can't show that `--l2` and `--l3` now take different sdpa routes. This is exactly the "for each config, how is it actually running" question the map is supposed to answer. |
| Sampling processors (2026-07-01) | L1-faithful min_p / XTC / presence+frequency penalties / logit_bias landed end-to-end | Sampler subtree (n177–n194) shows only curve/HLG/topP/topK/temp — the new mlx-lm-parity processor chain is absent. |
| Training `sft_scope` (d32fe32) | ORPO chosen-NLL default `full` (prompt+response token-mean CE), `response` = legacy | ORPO loss subtree (t46/t55) has no sft_scope branch. |
| Tier-0 generic models (9bd9f1b) | `UniversalDenseModel`, 11 archs, factory ladder dedicated→generated→generic→reject | **Absent entirely.** The map is titled MiniCPM5-1B; no model-dispatch view exists at all (no gemma4 generated specializations, no Qwen3/3.5, no DiffusionGemma denoising route, no batching lane either). |
| Line numbers | ~3 weeks of commits incl. today's uncommitted gemma4-base.ts / cli.ts edits | Every `file:line` is drift-suspect; they were the map's credibility feature. |

### B.3 Refresh plan — three deliverables, ordered by value/effort

**B3.1 Minimal manual patch to un-stale the current HTML (~0.5 day).**
Keep it hand-authored, make it honest:
1. Header banner: "hand-authored snapshot 2026-06-21, MiniCPM5-1B; line
   numbers approximate; tier semantics in parity-tier-dag.md".
2. **Add real tier tags** — a `tier` field per node + border color. Even
   tagging just the dispatch nodes delivers the promised feature: `n87
   ops.sdpa` (bf16) = L1 · `n83/n98` quantizedSdpa/tiled = L2 · `n92/n95`
   perf-kernel/fusedDecodeSdpa = **L3 opt-in, off in bare `--l2` (381382c)**
   · `n22/n27/n28` compiled-decode = tier-preserving (bit-exact) ·
   flash-CCE/ORPO/segmented/prefix training nodes = L3.
3. Sampler: insert one node before the temp/topP chain — "logits processors
   (mlx-lm L1): repetition/presence/frequency · logit_bias · min_p · XTC".
4. Training: add the `sft_scope full|response` branch at the ORPO chosen-NLL
   node.
5. Add a tiny third tab "model dispatch" (~10 nodes): the `factory.ts`
   ladder — DiffusionGemma → MiniCPM5 → Qwen3.5 → Qwen3 → gemma4
   generated/monolith → **UniversalDense (Tier-0, 11 archs, L1-gated)** →
   reject.

**B3.2 Runtime route explainer (recommended first "derive from code" step,
~1 day).** Josh's ask is literally "for each model and config, how it is
actually running" — the cheapest ground-truth answer is not static analysis
but a CLI verb, e.g. `mlx-bun route <model> [--l1|--l2|--l3] [--kv-quant …]`,
that:
- runs `applyDecodeRoute()` (cli.ts:723 — the TIERS preset table is already a
  machine-readable matrix), loads **config only** (no weights),
- evaluates the actual exported predicates (`perfKernelEnabled`,
  `fusedDecodeKernelSupported`, `fusedSwiglu/GeluEnabled+Supported`,
  `NO_FUSED_SDPA`, `CompiledDecode.for` eligibility, kv-quant resolution,
  factory ladder selection),
- prints the resolved route as a tree/JSON: which model class, which sdpa
  path, which kernels, which tier each hop sits in, and **which flag would
  change each hop**.
Correct by construction (it calls the same functions the server calls), zero
drift, and it answers per-model × per-config today. The HTML map becomes the
anatomy poster; this verb is the live X-ray.

**B3.3 Derived DAG + CI parity gate (the two open PLAN boxes, ~2–4 days).**
What "derive the DAG from code" concretely means here:
- **Roots are curated, extraction is mechanical.** A bun generator script
  (ts-morph / TS compiler API) walks from a small fixed root list —
  `generate()`, `createModel()`, the trainer step, `sampleStep`, each model's
  `quantizedSdpa`/attention dispatch — and records: every branch on a
  `process.env.MLX_BUN_*` read or an exported `*Enabled()`/`*Supported()`
  call, plus call edges between the roots' subgraphs. Nodes get
  `{id, label, file, line}` extracted from the AST (line numbers can never
  drift again). Output: `docs/dag/dag.json`, one graph per model class
  (the factory ladder gives the model dimension).
- **Tier tags live in a checked-in sidecar** (`docs/dag/tiers.json`:
  `node → {tier, oracleTest}`) merged into the JSON at generation time. The
  generator fails if a tagged node vanished (renames get caught).
- **CI gate**: a workflow step asserts every **L1-tagged** node names an
  `oracleTest` file that exists and passes (`bun test <file>`); an L1 node
  without a passing bit-exact test fails CI or must be re-tagged L3. This is
  PLAN's "the oracle is the gate becomes a check" box — and it composes with
  STATUS finding #4 (no CI at all): land the `tsc + bun test` gate first,
  hang the L1-tag check off it.
- **Rendering**: keep the existing cytoscape HTML shell; replace the
  hardcoded `INFER`/`TRAIN` consts with the generated JSON (inlined by the
  generator so the file stays a self-contained artifact).
- **Deliberate non-goal**: fully deriving the fine-grained *op-level* nodes
  (the tiled-sdpa online-softmax internals, AdamW math). That's 1–2 weeks of
  static-analysis plumbing for content that changes rarely. Two-level design
  instead: derived flag/route/dispatch graph (auto, CI-checked) + the
  hand-authored op subgraphs kept as leaf expansions, refreshed manually.

**Sequencing:** B3.1 now (un-stale the artifact) → B3.2 (the per-model/config
truth Josh asked for) → B3.3 (kills the hand-authored map and closes the two
PLAN checkboxes). The fourth PLAN box (rationalize the flag surface) falls out
of B3.2+B3.3: once every flag maps to a route edge in the JSON, the
always-on / knob / parity⇄opt classification in parity-tier-dag.md §"Why this
matters" can be generated instead of argued.
