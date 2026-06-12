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

The runtime can still expose every advanced knob. The default path should
not require them.

## Core idea

The local-AI problem is not continuous for Mac users. People own a small
set of real Apple Silicon SKUs: 16 GB, 24 GB, 32 GB, 36 GB, 48 GB,
64 GB, and larger workstation tiers. For each profile, we can research
and preselect the best known model artifact, context target, KV mode,
memory budget, and runtime flags.

That means first-run behavior can be a lookup table, not a wizard or a
benchmark:

```text
detect Mac profile
look up recommended runtime profile
download/resume the exact model artifact
start the tuned local server
open the built-in UI
show how to connect external tools and harnesses
```

The research work feeds the table. The table feeds the user.

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

## First-run UX

The no-args command should be the friendly path:

```sh
mlx-bun
```

Likely behavior:

1. Detect the hardware profile.
2. Pick the recommended runtime profile.
3. Show the selected model and why it was chosen.
4. Start or resume the background download.
5. Start the local server when ready.
6. Open or serve the built-in chat UI.
7. Show connection details for OpenAI/Anthropic-compatible clients.
8. Offer harness setup actions for Pi, Hermes, OpenClaw, and others.

This should feel like an appliance, not a framework tutorial.

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

The UI should not hide that this is local. It should make "local" feel
easy: predictable memory, transparent downloads, offline-capable serving,
and clear integration instructions.

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

- What exact profile table should ship first?
- Should no-args open the UI automatically, print a local URL, or both?
- Which UI stack should be embedded?
- How much of Pi should be bundled, embedded, or configured externally?
- What is the minimum first-run UI that feels good enough?
- What is the right install path: Homebrew, curl installer, GitHub
  release, or all of the above?
- How should background downloads interact with server startup and UI
  readiness?
- How should profile recommendations be versioned as benchmarks improve?
- When Qwen lands, what evals decide whether it replaces a Gemma default?
