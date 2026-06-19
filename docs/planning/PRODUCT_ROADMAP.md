# PRODUCT ROADMAP

Working notes for the product shape of mlx-bun. This is intentionally
less settled than PLAN.md: PLAN is the engineering contract; this file is
the evolving UI/UX/DX north star.

## Product north star

Make the answer to "what is the best way to use local AI on my Mac?"
boringly simple:

```sh
mlx-bun
```

The user should not need to research Hugging Face variants, quantization
formats, context windows, Python environments, server commands, or agent
provider config before they can try local AI. They should install one
binary, run one command, wait for one resumable model download, and get a
working local chat UI plus a local AI server.

The intended first-run shape is product, not demo: start with the tiny
welcoming model quickly, begin the stronger recommended model download in the
background, and graduate the user into the best default profile for their
actual Mac without requiring them to learn the model zoo first.

The runtime can still expose every advanced knob. The default path should
not require them.

## Four product faces

The same runtime has to support four related but distinct jobs:

1. **Local AI product** — the one-command experience for someone who just wants
   useful local AI. This path should be opinionated, benchmarked, and boringly
   reliable.
2. **Library for app developers** — the embeddable TypeScript/MLX layer for
   Bun, Tauri, Electron, and desktop tools that want local inference without a
   Python sidecar.
3. **AI lab for researchers** — the place where parity, evals, kernels,
   compiled graphs, ORPO, LoRA adapters, and model experiments can happen in
   the same stack that serves the result.
4. **Autonomous background agent runtime** — the always-available local server
   for scripts, recurring tasks, personal tools, and per-request adapter
   routing.

These are not separate products. They are one runtime with progressive
disclosure: appliance defaults at the front, sharp instruments underneath.

## The three modes (the organizing design law)

mlx-bun has not published anything: the entire CLI, command, and flag
surface is still ours to invent, and we are not married to any flag
name. Where a de-facto standard name exists (mlx-lm's), we adopt it
rather than reinvent. The surface is designed once, to serve three
audiences at three depths — progressive disclosure over ONE set of
verbs and one flag vocabulary, not three separate CLIs:

1. **Automatic mode** — first-time local-AI users. `mlx-bun` (and bare
   verbs) with zero flags. Smart, sane defaults from the device-profile
   table (see Core idea). Typing to a chatbot in a web UI in under a
   minute, with no knowledge of HF variants, quant formats, or context
   windows required.
2. **Compat mode** — people moving over from mlx-lm. The same verbs,
   plus dotted aliases (`mlx-bun.server` *is* `mlx-bun serve`), using
   mlx-lm's flag vocabulary, so existing muscle memory and scripts port
   with a one-token rename. mlx-lm is canonical because it is the
   default Apple references at WWDC and outweighs the alternative by
   ~425× monthly installs (1.64M vs 3.85k; mlx-lm 5.8k stars / 765
   forks; mlx-optiq has no public repo — measured 2026-06-12).
3. **Stick-shift mode** — power users and researchers. The full knob
   surface: every mlx-lm flag, every optiq feature, plus our own
   envelope-pushing ones, all exposed and composable. Build the exact
   system you want.

### Laws that keep the three modes coherent

- **One surface, mlx-lm vocabulary.** The dotted form is a pure alias
  of the space form. Adopt mlx-lm's flag names wherever they are the
  standard; only name a flag ourselves where mlx-lm has no concept for
  it (and there we are free to improve on optiq's name, not bound to
  it).
- **Compatibility = superset, never intersection.** Every documented
  mlx-lm flag/verb behaves faithfully so scripts drop in unchanged. We
  never subtract or gate a capability we already have for free to
  resemble an upstream — e.g. we serve OpenAI + Anthropic + Responses
  from one server, and that stays on: it costs nothing and is invisible
  to a beginner.
- **Gate only on conflict.** A capability is always on UNLESS leaving
  it on would degrade the automatic or compat experience (it changes
  output determinism, trades quality, or surprises a script). Only then
  does it move behind a stick-shift flag. This is rule 3 yielding to
  rules 1 and 2.
- **optiq is a feature set to absorb, not a flag dialect to honor.**
  Its distinctive features (sensitivity mixed-precision convert,
  per-layer KV sensitivity profiling, LoRA rank scaling, dual-protocol
  serving, latency prediction, the Lab UI) graft onto the mlx-lm spine
  as additive flags and a few new verbs.

### Status (2026-06-12; compat surface design remains open as of 2026-06-17)

The compat layer does not exist yet: today's commands (`serve`, `fit`,
`benchmark`, `evals`, `get`/`scan`/`ls`, `pi`, `harness`) are ad-hoc,
not a designed mlx-lm-matching surface — though their flags already
overlap mlx-lm/optiq heavily, so this is mostly rename-and-confirm, not
migration. The work: design the full surface against mlx-lm vocabulary,
reconcile the existing commands into it, and fill the capability matrix
behind it (convert/quantize, LoRA training, eval/perplexity, fuse,
cache_prompt, upload/share). Decomposed into phases in PLAN.md.

## Core idea: finite matrix runtime

The local-AI problem is not continuous for Mac users. MLX means Apple Silicon,
and Apple ships a finite set of real chip/RAM/bandwidth combinations. The
supported model universe is also curated. For each physical device profile and
model snapshot, we can research and preselect the best known model artifact,
context target, KV mode, memory budget, kernel route, graph route, and runtime
flags.

That means first-run behavior can be a measured lookup table, not a wizard or
an exploratory benchmark:

```text
detect exact Mac profile
fingerprint the model snapshot
choose the task mode: chat, vision, tool loop, adapter, training, eval
look up the measured execution plan
download/resume the exact model artifact
start the tuned local server
open the built-in UI
show how to connect external tools and harnesses
```

The current `fit` endpoint is the nucleus of this idea: it already reasons over
real Apple Silicon profiles, model bytes, KV bytes, context, and predicted
decode. The product version should evolve from "does this fit?" into:

```text
device profile + model checksum + task mode + live memory pressure
  -> recommended execution plan
```

Execution plans can eventually include specialized graph variants, fused kernel
routes, prompt-cache policy, adapter policy, safe context limits, expected
decode/TTFT, and user-facing rationale. The research work feeds the table. The
table feeds the user.

## Recommended profiles

Initial profile work should stay narrow and excellent. Start with the
Gemma 4 OptiQ family and expand only when the project has a better answer.

Candidate shape:

| Device profile | Default model | Intent |
|---|---|---|
| MacBook Air / 16 GB | `mlx-community/gemma-4-e4b-it-OptiQ-4bit` | Fast first local-AI experience. |
| MacBook Pro / 24-32 GB | `mlx-community/gemma-4-12B-it-OptiQ-4bit` | Strong default chat/agent model. |
| Mac Studio / 64 GB | `mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit` | Larger local-agent profile. |

Exact model choices, context lengths, and flags are not frozen here. They
should be updated from benchmarks, evals, fit predictions, and real use.

Each profile should eventually carry:

```ts
{
  id: "macbook-pro-24gb",
  model: "mlx-community/gemma-4-12B-it-OptiQ-4bit",
  context: 65536,
  kv: "mixed",
  memoryBudgetBytes: "...",
  compiledDecode: true,
  perfKernel: false,
  expectedDecodeTps: 30,
  expectedTtftMs: 100,
  label: "Recommended for this Mac",
}
```

The important rule: an optimization matters for product defaults when it
changes a device-tier decision, unlocks a larger useful context window,
keeps decode above a user-visible threshold, improves quality at the same
budget, or prevents failure. Saving memory for its own sake is secondary.

## Specialization strategy

For the curated product path, it is acceptable to trade more work up front for a
better hot path later. The Mac is known, the model snapshot is known, and the
task mode is known. That lets us precompute or cache exact plans instead of
shipping every decision to runtime.

Candidate plan fields:

- Model checksum and architecture fingerprint.
- Apple Silicon profile: chip, unified memory, bandwidth tier, GPU/CPU shape.
- Context buckets and fixed-shape cache layouts.
- Kernel choices: MLX built-ins, MLX fast paths, custom Metal kernels, or
  eager fallback.
- Graph choices: eager, compiled exact-shape graph, compiled bucketed graph,
  or prebuilt graph table.
- Adapter choices: none, single LoRA, stacked LoRA, task-routed LoRA.
- Measured results: TTFT, decode tok/s, peak memory, failure envelope.

This is where loop unrolling, branch deletion, static DAG extraction, fused
kernels, and shape-specialized compiled graphs become product features rather
than abstract optimizations. They matter when they let the default profile be
faster, larger, more stable, or better aligned without asking the user to tune
anything.

## First-run UX

The no-args command should be the friendly path:

```sh
mlx-bun
```

Likely behavior:

1. Detect the hardware profile. *(not yet: `recommendedRepoId()` at `src/fit.ts:86` returns `DEFAULT_REPO_ID` unconditionally — device-profile lookup table is unimplemented)*
2. Pick the recommended runtime profile. *(same caveat as above)*
3. Show the selected model and why it was chosen. *(not yet: model is printed, rationale is not)*
4. Start or resume the background download. **Shipped** — auto-download on first run; resumable.
5. Start the local server when ready. **Shipped.**
6. Open or serve the built-in chat UI. **Shipped** — browser tab opened automatically; URL printed either way; `--no-open` skips the tab.
7. Show connection details for OpenAI/Anthropic-compatible clients. **Shipped** — printed at startup.
8. Offer harness setup actions for Pi, Hermes, OpenClaw, and others. *Partially shipped: `mlx-bun harness pi` configures an existing Pi install; Hermes and OpenClaw adapters do not exist.*

This should feel like an appliance, not a framework tutorial.

## Adapter catalog vision

The average user should not have to train adapters to benefit from them. The
product path can ship or offer a curated catalog of lightweight LoRA adapters:
assistant, coding, writing, research, planning, personal-ops, and other
well-scoped modes. A user can install one small adapter and get a better local
assistant without changing the base model.

Advanced users can still train their own adapters with mlx-bun. The broader
product loop is:

```text
curate conversations and task data
train / ORPO task adapters
publish small adapter artifacts
route requests through the right adapter per task
keep the base model resident
```

This makes ORPO performance directly product-relevant. If training is cheap and
repeatable enough, the project can keep improving small local models through
adapter updates instead of asking every user to download a larger base model.

## Built-in UI

Bun can serve the UI directly from the same executable. The default UI
does not need to be elaborate at first, but it should work immediately.

Expected surfaces:

- Chat UI backed by the local model server.
- Download progress, resume status, and model readiness.
- Current device profile and selected model.
- Server URL and API compatibility hints.
- Simple controls for common settings: context, temperature, max tokens.
- Advanced panel for explicit model/profile overrides.
- Integration panel for harnesses and external clients.

### Model hot-swap from the UI (candidate)

Let the user switch the served model at runtime — e.g. Gemma e4b →
MiniCPM5 — from a picker in the web UI, without restarting the server.
Weight load is cheap (mmap is lazy, load runs on the CPU stream; ~0.5 s
for a small model), so a swap can feel like changing a setting rather
than a relaunch. `/library` already enumerates every model on disk with
a per-machine fit assessment and flags the active one (`serving`), so the
menu and the "does it fit" data already exist — the missing pieces are a
swap action and a mutable served context.

Sketch:
- Today the server is single-model-per-process: `serve()` captures one
  `ServerContext` as a const in the `Bun.serve` closure. Hot-swap needs a
  mutable "current context" ref that all handlers and the generation
  gateway read through.
- A swap endpoint (e.g. `POST /library/activate`) drains in-flight
  generations, frees the old model's GPU buffers + KV/prompt caches,
  `loadContext()`s the target, rebuilds the gateway, then atomically
  swaps the ref. `/v1/models`, `/status`, and the Pi probe report the new
  id afterward.

Constraints to honor:
- On a memory-bound Mac you can't hold two models at once — unload before
  load. There is an unavoidable brief "swapping…" gap, not an instant
  switch. Validate fit() before unloading the current model.
- Load time scales with model size; don't promise instant for large ones.
- Decide adapter behavior on swap (dropped vs. model-scoped) and surface
  it. Active LoRA adapters are tied to the base model.

The UI should not hide that this is local. It should make "local" feel
easy: predictable memory, transparent downloads, offline-capable serving,
and clear integration instructions.

### SigLIP vision sidecar — image input for gemma e4b (shipped, 2026-06-17)

The Gemma 4 e4b vision encoder (`src/vision/siglip.ts`) is a faithful port
of the optiq SigLIP tower. It auto-loads on first image input and falls back
to text-only mode when no image is present, so the chat UI gains image support
with no startup cost. Features are within ~1% rel-RMSE of the optiq oracle;
every MLX primitive (rms_norm, gelu, matmul, SDPA, RoPE, pooling) is bit-exact.
The residual is sub-bf16 floating-point accumulation across the deep encoder,
not a porting gap. L1/L2/L3 paths all work; vision falls back to the monolith
path on L1 and L2.

### Adapter web selector and CLI /v1/adapters (shipped)

Trained LoRA adapters can be selected from the chat UI via a per-conversation
picker (`#chat-adapter` in `src/web/app.html`). The picker lists adapters
discovered by `GET /v1/adapters/available`, mounts the chosen one via
`POST /v1/adapters`, and sends a `set_adapter` message to Pi-web so that
every subsequent turn is routed through the right adapter — including the
`before_provider_request` hook in `src/pi-web.ts`. Adapters are base-model-scoped
and dropped on model swap.

### The UI must never lag while the AI is busy (candidate, 2026-06-16)

A product guarantee: **the AI may crash, the UI never may** — and the UI
must stay responsive no matter how hard the model is working. Waiting for
a *chat reply* is fine and expected (local inference takes time). A laggy
web UI — slow refreshes, stalled `/status`, a frozen page while an agentic
pipeline hammers the GPU — is not.

One `mlx-bun` process plays three roles on one event-loop thread: it
serves the UI, serves the API, and runs the AI. The AI work is synchronous
blocking GPU/FFI (each `mlx_eval` is atomic and uninterruptible), so it
starves the loop — worst in the non-streaming path and during prefill,
where nothing hands a macrotask back. Yielding between tokens helps the
common case but cannot isolate the UI under sustained load.

Direction (decided: **subprocess**, not worker thread — only address-space
isolation survives the uncatchable GPU OOM): move the inference runtime
into its own persistent child process behind the existing
`GenerationGateway` seam. The main process becomes a pure reactor (UI +
API + routing, zero MLX calls); one GPU lease serializes all GPU consumers
(chat, API, quantize, finetune) — reusing the spawn/lease pattern jobs
already prove. Converges with model hot-swap (model lives off the main
thread either way). Full design + phasing: `docs/design/runtime-isolation.md`.

## Harness UX

Harness setup should be executable, not just documented.

```sh
mlx-bun harness
mlx-bun harness pi
mlx-bun harness hermes
mlx-bun harness openclaw
```

`mlx-bun harness` should open an interactive picker. Direct subcommands
should configure a specific harness.

Each harness adapter can:

- Detect whether the harness is installed.
- Preserve existing user config.
- Add or update the local mlx-bun provider entry.
- Point it at the local server.
- Select the right API protocol.
- Validate the connection with a tiny request.
- Show the command to launch the harness.

Pi deserves a first-class path because it can be embedded through its SDK:

```sh
mlx-bun harness pi
mlx-bun pi
```

`mlx-bun harness pi` configures the user's existing Pi install. `mlx-bun
pi` should start the local mlx-bun runtime and launch Pi itself against
that runtime. If the Pi TUI is the right surface, use it. If an embedded
SDK session is the right surface, use that.

Other harnesses should follow the same adapter pattern.

Sketch:

```ts
interface HarnessAdapter {
  id: "pi" | "hermes" | "openclaw";
  label: string;
  detect(): Promise<Detection>;
  configure(profile: RuntimeProfile): Promise<ConfigureResult>;
  validate(profile: RuntimeProfile): Promise<ValidationResult>;
  launch?(profile: RuntimeProfile): Promise<void>;
}
```

## CLI shape

Possible command map:

```sh
mlx-bun                         # recommended model + server + UI
mlx-bun serve                   # server only
mlx-bun ui                      # UI only, connect to local/running server
mlx-bun repl                    # Bun REPL with a local AI client preloaded
mlx-bun pi                      # launch embedded Pi against mlx-bun
mlx-bun harness                 # interactive harness setup
mlx-bun harness pi              # configure existing Pi
mlx-bun harness hermes          # configure Hermes
mlx-bun harness openclaw        # configure OpenClaw
mlx-bun models                  # installed and recommended models
mlx-bun fit                     # device/model fit information
mlx-bun doctor                  # diagnostics
```

Flags should compose with these modes. The default is opinionated, not
restrictive.

Examples:

```sh
mlx-bun --model gemma-4-12b --context 65536
mlx-bun serve --no-ui --port 8090
mlx-bun pi --model qwen-profile
mlx-bun harness pi --base-url http://localhost:8090/v1
```

## Research loop behind the product

The product table should be backed by the same research discipline as
PLAN.md:

1. Pick a small set of real target devices.
2. Pick a small set of candidate model artifacts.
3. Measure fit, context, decode speed, TTFT, memory, and quality.
4. Specialize the runtime for winning artifacts.
5. Promote only defaults that pass clean-machine measurements.
6. Keep fallback and explicit override paths for research and power users.

The first family is Gemma 4 OptiQ. Qwen is the next obvious family to
evaluate. The default model should be whichever gives the best experience
for a device profile and use case, not whichever family arrived first.

## Artifact design

Longer term, mlx-bun may not only choose among existing model artifacts.
It may create artifacts for exact device/use-case targets.

The useful question is not "can we save 1% RAM?" It is:

```text
Can this model fit on this device,
with this context window,
above this decode-speed floor,
while preserving enough quality for this use case?
```

TurboQuant plus sensitivity analysis fits this direction. The quantizer
can target concrete SKU boundaries and context tiers:

- Make a specific model fit on 16 GB with useful context.
- Make a 12B-class model hit 64k context on 24-32 GB.
- Keep decode above 30 tok/s on the recommended profile.
- Preserve tool/agent behavior under the chosen quantization.

This turns quantization from generic compression into product-driven
artifact design.

## Runtime specialization

When a user asks to run a specific model, there is no ambiguity in the hot
path. The artifact, config, tensor shapes, KV config, quantization layout,
chat template, and architectural quirks are known.

The generic runtime is scaffolding for research, portability, and
fallback. The served instance can be specialized:

- Generated per-model execution paths.
- Branches and loops removed where the model shape is fixed.
- Per-layer quant bits/group sizes baked in.
- Known cache layouts and attention patterns used directly.
- Custom kernels generated or selected for exact dispatch sites.

Compatibility paths remain the oracle. Specialized paths are promoted
only when they are correct, measured, and useful.

## Lucien / memory-system direction (candidate, 2026-06-12)

A second product direction under debate alongside the UI/harness work:
make mlx-bun the local-model engine for Lucien (the Dreaming memory
system), in two stages.

1. **Prove the models do real work.** Run Lucien's pipeline tasks
   (session ingestion, synthesis into articles, recall-grounded chat)
   against mlx-bun-served models. Measure quality and performance per
   task — this is a real-workload eval, not a benchmark row, and it
   feeds the profile table (which model tier can sustain synthesis
   work? what context does recall actually need?).
2. **Package it.** If the models hold up: mlx-bun as a Lucien backend
   option — one executable that creates the memory store, gathers
   session transcripts, synthesizes them into articles, and serves
   conversations grounded on those articles. Same appliance principle
   as the chat default: one binary, one command, a working memory
   system.

This stresses exactly the things the runtime is good at measuring:
long-context prefill, sustained batch-ish generation, prompt-cache
reuse across pipeline stages.

## Non-goals for the default UX

- Do not make the user choose from thousands of Hugging Face variants on
  first run.
- Do not benchmark their machine before giving a recommendation.
- Do not require Python, a venv, or manual server setup.
- Do not require hand-editing harness config files.
- Do not expose every research flag before the user has a working local
  AI experience.

## Open questions

- What exact profile table should ship first? *(The device-profile lookup
  table is unimplemented — `recommendedRepoId()` returns `DEFAULT_REPO_ID`
  for every SKU. The profile shape in this doc is the spec; the research
  work and the fill remain open.)*
- How should background downloads interact with server startup and UI
  readiness?
- How should profile recommendations be versioned as benchmarks improve?
- When Qwen lands, what evals decide whether it replaces a Gemma default?

### Resolved

- **Should no-args open the UI automatically, print a local URL, or both?**
  Both: the browser tab is opened automatically on start; the URL is always
  printed; `--no-open` suppresses the tab without hiding the URL.
- **Which UI stack should be embedded? / How much of Pi should be bundled?**
  Resolved by harness-pi + pi-web shipping: the web UI is the bundled
  `src/web/app.html` chat page talking to Pi via `pi-web.ts`; Pi is
  configured externally via `mlx-bun harness pi`, or launched embedded via
  `mlx-bun pi`.
- **What is the right install path?** All of the above — shipped: npm
  publish (v0.0.4, `bunx mlx-bun`), Homebrew release pipeline (sign,
  notarize, `joshuarossi/homebrew-tap`), and GitHub release binary.
