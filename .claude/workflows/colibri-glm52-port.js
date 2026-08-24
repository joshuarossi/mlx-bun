export const meta = {
  name: 'colibri-glm52-port',
  description: 'Gate-driven executor for the GLM-5.2 native MLX port (docs/design/colibri-glm52-port.md)',
  whenToUse: 'Invoke with args {gate:"G0"..."G8"} to execute ONE gate of the port plan. Agent-safe work is executed sequentially and adversarially verified against the gate exit criteria; model downloads, full-model runs, and quiet-machine benchmarks are emitted as a manual checklist, never run. Pass {force:true} to override the predecessor-gate check.',
  phases: [
    { title: 'Preflight', detail: 'plan + repo + predecessor-gate evidence' },
    { title: 'Execute', detail: 'agent-safe worklist for the selected gate, sequential' },
    { title: 'Verify', detail: 'independent exit-criteria check per completed item' },
  ],
}

const PLAN = 'docs/design/colibri-glm52-port.md'
const ORACLE = '/Users/joshrossi/Code/colibri'
const PIN = '44e489b196c9b7876b3d37a0570ebf1c6f90f54c'

const GUARDRAILS = `
HARD RULES (violating any means you return status "blocked" instead of proceeding):
- NEVER download models or any multi-GB artifact; NEVER start long-running or persistent servers.
- NEVER touch the GPU while a training run is active; verify by reading process state first.
- No perf number is quotable unless measured on a quiet machine via the plan's manual workflow.
  Implement and unit-test instead; list the measurement as a manual follow-up in your result.
- The Colibri checkout at ${ORACLE} is a READ-ONLY oracle pinned at ${PIN}: study it, build its
  model-free test targets, never modify it.
- Whole-repo typecheck stays at 0 errors; run the test suites you touch.
- Docs land WITH the feature: a change to the served surface updates the reference docs in the
  same change. Record durable findings in ${PLAN} / STATUS.md, not just in your reply.
Before doing anything, Read ${PLAN} — at minimum the section named in your task and the
"What not to copy blindly" and risk-register sections.`

const GATES = {
  G0: {
    section: 'G0 — establish the direct Colibri/Metal baseline',
    items: [
      `Record the oracle pin: verify ${ORACLE} is at commit ${PIN}; inventory its license, config surface, public-artifact file expectations (container/tokenizer/int8-MTP shards), and disk envelope into a short oracle-pin note at docs/investigations/colibri-oracle-pin.md. No model download.`,
      `Build and run the model-free oracle suites: \`make -C c check\` and \`make -C c metal-test\` in ${ORACLE}. Capture pass/fail output verbatim in the oracle-pin note.`,
      'Re-verify the disk preflight (diskutil container unallocated + purgeable) and record the numbers with the date.',
      'Export the tiny deterministic GLM/quant/DSA/MTP and routing/cache-trace fixtures the G0 section calls for, using Colibri model-free tooling only; place them under fixtures/ with a README stating provenance.',
    ],
    manual: [
      'Download/convert the public ~370 GB GLM-5.2 artifact (multi-GB — never from a session).',
      'Full-model baseline on the cleared M1 Max 32 GB: footprint, hit rate, disk service/wait, TTFT, cold/warm tok/s — each with MTP on and off. This IS the G0 exit; the gate cannot be marked met without it.',
    ],
  },
  G1: {
    section: 'G1 — unified-memory MLX storage foundation',
    items: [
      "Build a model-free synthetic expert-file generator in Colibri's gate/up/down slab layout (Lab tier — lab/spikes/ or scripts/experiments/ per repo rules).",
      'Implement the native fixed aligned-slab store + bounded positioned-read workers + completion fences (src/native boundary per the plan code map). No JS callbacks in any destructor or completion path.',
      'Stress suite: forced slot churn, generation-tag poison tests, eviction under load, deterministic LRU traces, flat RSS over sustained churn.',
      'Wire both consumers — an MLX zero-copy path and a custom-Metal path — over registered slabs; prove no hidden copy and no stale read (poison-and-check).',
    ],
    manual: [
      'Kernel benchmarks vs Colibri Metal (int4 dense GEMM, routed SwiGLU at decode/prefill row counts, MLA decode) — quiet machine, paired A/B; this selects the winning path per kernel shape.',
      'CPU/GPU power-contention measurement with passive workers (reject busy-spin).',
    ],
  },
  G2: {
    section: 'G2 — native GLM-5.2 correctness spine',
    items: [
      'Write the numeric parity contract into the plan/STATUS FIRST (bitwise: int4/int8 dequant on identical inputs, router top-8 selection, cache byte accounting; trajectory-level: tie-free greedy token match + recorded max-logit-delta bound). Custom kernels pin numerics to dequant->f32-MAC per the oracle (its Metal/CUDA tiers are byte-identical to its CPU engine this way); harden the gate to bitwise where accumulation semantics match.',
      'Implement Glm52 config, tokenizer/template, dense graph, compressed MLA cache, DSA, router/shared MoE, and reference expert math per section N1 — dedicated model files, not the universal glm4 descriptor.',
      'Add Colibri container parsing and per-tensor validation per N2, plus the reference MLX expert composition for fixtures.',
      'Build tiny-fixture layer/op goldens and the 32-token teacher-forcing test against the G0 fixtures.',
    ],
    manual: [
      'Full-model dense/router probes (requires the downloaded artifact).',
    ],
  },
  G3: {
    section: 'G3 — native bounded LRU and slab execution path',
    items: [
      'Implement ExpertResidencyManager per N3: expert-ID->slot table, monotonic LRU clock, pinned set, byte budget and derived slots/layer, generation-tagged leases, RSS guard, startup refusal equation.',
      'Batch-union scheduling per N4 (route whole batch, dedupe per layer, resident-first submit); model-free reference-policy trace tests (forced hit/miss/evict sequences must match the reference exactly).',
      "Integrate the G1-selected routed-SwiGLU kernel behind the model boundary; pure-LRU first, no auto-pin yet.",
    ],
    manual: [
      'Quality-policy token match vs direct Colibri for a tie-free trajectory (requires artifact).',
    ],
  },
  G4: {
    section: 'G4 — serial native MTP (requirement)',
    items: [
      'Implement serial MTP per N6/G4: int8 MTP row sharing target weights and counted in the residency budget; draft-to-gamma, one batched verify forward, exact target+MTP cache trim on rejection.',
      'Pin draft and verify to the same kernel family (SPEC_PIN-equivalent); integrate grammar-forced tokens and prompt-lookup drafts without double-advancing caches.',
      'Metrics: drafted/accepted/rejected, acceptance length, tok/forward, forwards saved, end-to-end speed. Tiny-fixture accept/rollback tests against the G0 MTP fixtures.',
    ],
    manual: [
      'Oracle accept/reject trace comparison + net end-to-end win measurement (artifact + quiet machine). All later gates run MTP-on.',
    ],
  },
  G5: {
    section: 'G5 — 32 GB memory contract (measured with MTP on)',
    items: [
      'Port the full resource equation (dense, expert slots, 64-working-set, MLA/DSA/MTP per slot, reconstructed-KV transient, MLX allocator, Bun, OS reserve) into the existing fit/memory modules with every line item exposed; unit tests for the equation.',
      'Conservative one-slot 4k-context preset for 32 GB; explicit overrides allowed; impossible starts refused. Pressure feedback shrinks only the evictable LRU tier.',
    ],
    manual: [
      '<=25 GB measured 128-token run, MTP on, on the cleared M1 Max 32 GB; record cold/warm speed (MTP on and off) against the G0 baseline.',
    ],
  },
  G6: {
    section: 'G6 — Atlas, overlap, learning, and prefetch',
    items: [
      'I/O worker pool with direct/no-cache reads and resident-first Metal submit; persistent atomic usage profile; live LFRU repin with 25%+4 hysteresis and swap cap.',
      'PILOT measurement first, hint-only prefetch second, real-load PILOT third, coupling/two-step last — each behind a flag, value-preserving, never changing selected experts.',
      'Live tier/heat/hit telemetry (EMAP/HITS equivalents) on a dedicated web data route; port the offline Atlas probe/analyze/validate workflow with replication gates.',
    ],
    manual: [
      'Every lever gets a paired cold/warm A/B, MTP on, on the quiet machine (hit rate, disk GB/token, service vs wait, p50/p95/p99, tok/s). Only positive results become defaults.',
    ],
  },
  G7: {
    section: 'G7 — persistence, concurrency, and full API parity',
    items: [
      'G7a: extend the versioned kv-store with MLA/DSA/MTP cache kinds; atomic async save, validated restore with identity/hash rejection, accurate compressed byte accounting; restore-negative tests.',
      'G7b: batched cache capability (mergeRows/extractRow/projectedBytes) for all three cache families; compressed-byte admission; cross-row expert union with lease release on the shared fence; join/leave/cancel churn tests. Batched rows decode ordinary single-token — batched MTP is post-release.',
      'G7c: serving parity across chat/text completions, Anthropic Messages, Responses; GLM chat-template rendering, thinking-block policy per surface, and tool-call parsing (existing parser is Gemma-only); dual-model API conformance suites; truthful capability discovery.',
    ],
    manual: [
      'Restart-equivalence at multiple sequence lengths on the full model (uninterrupted vs restored logits/offsets).',
    ],
  },
  G8: {
    section: 'G8 — productization',
    items: [
      'Reference-doc mirror in the same changes: README + docs/reference/{models,memory,cli,server-config,server-api,library-api,features-matrix}.md for every flag/field/route/default this port added.',
      'fit/doctor UX exposing the exact resource equation; artifact/disk preflight; acquisition/conversion tooling; third-party notices; 32 GB quickstart with explicit cold/warm expectations.',
    ],
    manual: [
      'Headline bar: >=2 tok/s warm on the M1 Max 32 GB, MTP on, quality-preserving defaults, recorded with provenance in benchmarks/RESULTS.md.',
      'A fresh 32 GB user walkthrough: disk space -> working GLM-5.2 chat with one documented command sequence.',
    ],
  },
}

const PRE_SCHEMA = {
  type: 'object',
  required: ['predecessorsMet', 'evidence', 'context'],
  properties: {
    predecessorsMet: { type: 'boolean' },
    evidence: { type: 'string', description: 'What was found (or missing) in PLAN.md/STATUS.md/the plan doc for each predecessor gate' },
    context: { type: 'string', description: 'Repo facts an executor of this gate must know: existing files, prior spikes, relevant landed work' },
  },
}

const WORK_SCHEMA = {
  type: 'object',
  required: ['status', 'summary'],
  properties: {
    status: { type: 'string', enum: ['done', 'partial', 'blocked'] },
    summary: { type: 'string' },
    files: { type: 'array', items: { type: 'string' } },
    tests: { type: 'string', description: 'What was run and the actual result' },
    blockers: { type: 'string' },
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  required: ['verdict', 'reasons'],
  properties: {
    verdict: { type: 'string', enum: ['pass', 'partial', 'fail'] },
    reasons: { type: 'string' },
  },
}

const gateId = (args && args.gate) || 'G0'
const gate = GATES[gateId]
if (!gate) {
  return { error: `unknown gate "${gateId}"; valid: ${Object.keys(GATES).join(', ')}` }
}

phase('Preflight')
const pre = await agent(
  `Read ${PLAN} in full, plus STATUS.md and PLAN.md. Target gate: "${gate.section}".
(1) For every gate BEFORE ${gateId}, report whether its exit criteria are recorded as met, with the evidence you found (or state clearly that it is missing). Note that several gates have manual full-model exit items — those must be recorded too, not just agent-side work.
(2) Summarize the repo facts an executor of this gate needs: files that already exist, prior spikes/landed work this builds on, and anything in the plan's risk register that bites this gate.
Read-only: write nothing.`,
  { label: `preflight:${gateId}`, schema: PRE_SCHEMA }
)
if (!pre) return { gate: gateId, status: 'error', reason: 'preflight agent failed' }
log(`Preflight: predecessors ${pre.predecessorsMet ? 'met' : 'NOT met'}`)

if (!pre.predecessorsMet && !(args && args.force)) {
  return {
    gate: gateId,
    status: 'refused',
    reason: 'Predecessor gate exit criteria are not recorded as met. Re-run with args {force:true} to override.',
    evidence: pre.evidence,
    manualActions: gate.manual,
  }
}

phase('Execute')
// Sequential on purpose: items share one working tree and later items build on earlier ones.
const results = []
for (let i = 0; i < gate.items.length; i++) {
  const r = await agent(
    `You are executing ONE item of the "${gate.section}" section of ${PLAN}.

ITEM ${i + 1}/${gate.items.length}: ${gate.items[i]}

Preflight context: ${pre.context}
${GUARDRAILS}

Do the work. Your final output is the structured result only.`,
    { label: `${gateId}:item${i + 1}`, phase: 'Execute', schema: WORK_SCHEMA }
  )
  results.push(r)
  log(`${gateId} item ${i + 1}/${gate.items.length}: ${r ? r.status : 'agent error'}`)
}

phase('Verify')
const verdicts = await parallel(
  results.map((r, i) => () =>
    r && r.status !== 'blocked'
      ? agent(
          `Adversarially verify a claimed work item against ${PLAN}, section "${gate.section}".
ITEM: ${gate.items[i]}
CLAIM: ${JSON.stringify(r)}
Read the section's exit criteria. Re-run cheap read-only checks yourself (typecheck, the named tests, grep for the claimed files/symbols). Default to "fail" when evidence is missing or a claim does not reproduce. Do not fix anything.`,
          { label: `verify:${gateId}:item${i + 1}`, phase: 'Verify', schema: VERDICT_SCHEMA }
        )
      : Promise.resolve(null)
  )
)

const items = gate.items.map((item, i) => ({
  item,
  result: results[i],
  verification: verdicts[i],
}))

return {
  gate: gateId,
  section: gate.section,
  items,
  manualActions: gate.manual,
  note:
    'Agent-side status only. The gate exit is NOT met until the manualActions are done and their ' +
    'numbers are recorded per the plan; several exits (G0 baseline, G5 footprint, G8 headline bar) ' +
    'are inherently manual measurements on the cleared M1 Max 32 GB.',
}
