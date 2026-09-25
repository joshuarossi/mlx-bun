# Architecture

mlx-bun provides local AI on Apple Silicon. Bun workspaces contain applications
in `apps/` and importable libraries in `packages/`. The current target is macOS
on Apple Silicon. Keep responsibilities explicit; add packages when a consumer
needs a separate installation or release boundary.

## Foundational decisions

- One repository and Git history; Bun workspaces, without Turbo. YAGNI and KISS
  guide additions. The empty-tree rebuild admits only files Josh approves.
- Libraries publish under `@mlx-bun/`; the runnable app keeps `mlx-bun`.
- Libraries use MIT. Licensing for future apps remains a separate decision.
- Ship required native binaries inside package artifacts, outside Git. Support
  the current Apple Silicon Mac target; other Apple devices remain undecided.
- Keep one inference package with enforced internal boundaries. Split a package
  when a consumer needs that boundary, not merely because a directory exists.
- Preserve behavior during migration; numerical optimization is separate work.
  A specialized model graph composes layers and kernels; its layers own whether
  operations compile. Keep this implementation choice out of app options.
- The app uses continuous batching by default, including a single request. Do
  not add a separate serial serving lane. Preserve main's application behavior
  while giving each domain a clear owner; benchmark the full draft afterward.
- Python reference oracles run externally. This repository has no Python
  dependency, venv, oracle setup script, or Python dependency lock. Gather
  comparison data externally and record curated evidence in approved docs.

## Composition and public APIs

`@mlx-bun/mlx` owns the native MLX binding. `@mlx-bun/inference` builds on it.
The inference root is the convenient loading and generation API: callers supply
artifacts and graphs; it composes the lower layers. Lower layers never import
this entry point. Component subpaths are public ways to compose kernels, layers,
graphs, state, sampling, and generation directly. A small convenience API does
not require hiding those components.

`@mlx-bun/training` owns adapter training and production above the inference
graphs, layers, state contracts, and MLX autograd. It uses the quantize package
only to preserve auxiliary checkpoint files during adapter fusion. Training
progress is a library contract; job lifecycle and terminal output stay in apps.
Inference and quantization never depend on training.

Interfaces describe required capabilities and ownership, not a selected model
or service. A caller may provide a different implementation satisfying the
same contract. Concrete model loading remains available as a convenience.

## Ownership and dependency direction

Inside `packages/inference/src/`:

| Owner | Responsibility |
| --- | --- |
| `contracts/portable/` | Backend-independent inference graph, state, output, and scheduling interfaces. No platform imports. |
| `contracts/mlx/` | Tensor, attention, cache, position, weight-source, and forward-work interfaces. May reference the MLX binding and portable contracts. |
| `runtime/` | Shared configuration scopes, resource ownership helpers, tracing context, and bundled native paths. No model or scheduling dependencies. |
| `kernels/` | Numerical operations and their input layouts. No concrete cache, artifact loader, model, or scheduler imports. |
| `artifacts/` | Configuration, weights, formats, expert storage/residency, and conversion of artifact layouts into kernel descriptors. |
| `layers/` | Reusable graph building blocks, including LoRA application and positional operations. |
| `state/` | Cache implementations, snapshots, row storage, retention, and persistence. |
| `input/` | Tokenizers, templates, media preprocessing, and prompt assembly through encoder interfaces. |
| `sampling/` | Sampling policy, processors, constraints, and draft sampling. |
| `adapters/` | Loading and mounting adapter weights through named target interfaces. |
| `models/` | Concrete graphs and graph construction from artifacts. |
| `generation/` | Autoregressive, denoising, fill, and speculative methods. `bindings/` connects concrete graphs to those methods. |
| `scoring/`, `embeddings/`, `transcription/` | Operations consuming graphs and caller-supplied inputs. |
| `execution/` | Optional admission, scheduling, sessions, and coordination of generation work. |
| `index.ts` | High-level public entry point consuming these components. |

Dependencies form a DAG, with independent branches rather than one universal
sequence. Models compose lower components; generation consumes models and their
contracts; execution coordinates generation. Input can consume state for encoder
caching, and sampling can consume tokenizer interfaces for grammar constraints.
These do not give their dependencies permission to import back upward.

The exact direct-dependency rules live in
[`architecture.test.ts`](packages/inference/tests/architecture.test.ts).
The test discovers every `packages/*/src` and `apps/*/src` directory and parses its TypeScript
and JavaScript. Package manifests declare dependencies; cross-package imports
must use public exports, and package dependencies must form a DAG. Within
inference, the stricter layer rules also apply. The gate rejects module cycles
across libraries and apps, including type-only cycles. Libraries cannot depend
on apps; app domains also have explicit dependency directions. Static imports, re-exports,
import types, dynamic imports, and `require` are checked. New inference source
directories need an explicit layer owner in this gate.

## Application ownership

`apps/mlx-bun` owns the runnable terminal application and its server and web
surfaces. Its `cli/` domain parses arguments and presents results, consuming
public library exports. Model discovery, acquisition, and fit remain in
`@mlx-bun/hub`; numerical inference remains in `@mlx-bun/inference`.
Only `cli/` exists so far. Add server, engine-host, web, and job domains with
their first migrated consumers and explicit dependency rules; do not invent
shared utilities or placeholder contracts ahead of those consumers.

Standalone Pi integration is deferred pending Josh's decision. The web app
may use Pi as its agentic component when that surface migrates.

Application contracts migrate with their owning apps: Pi UI/provider protocols,
job runner types, engine host, and completion clients. Within the apps, Pi
protocols belong to the Pi integration, job contracts to job orchestration, and
host/client interfaces to their application boundary. Apps import reusable
inference contracts from the library rather than duplicating them. Portability
is a dependency constraint; domain ownership determines the home.

Extract a shared app-contract package only when the app consumers require it.

## Changing or replacing a piece

Move shared interfaces below their consumers. Keep platform-free contracts
portable; keep MLX tensor interfaces concrete. Domain-specific contracts can
stay beside their owning domain when no lower layer needs them.

For example, paged attention accepts numerical storage without knowing its
allocator; adapter mounting consumes named mount points rather than the model
union; prompt preparation consumes encoders rather than Gemma or Qwen classes.
A new implementation must preserve the contract's tensor shapes, ownership,
state transitions, cancellation, and disposal semantics. Specialized numerical
paths remain explicit and reusable.

## Refactor verification

Preserving implementation means preserving numerical results and behavior for
the same inputs and settings, including native lifetimes and operation order.
File similarity alone is not proof. Run `bun run typecheck` and `bun run test`;
typechecking also compiles portable contracts with only the ES2022 library.
`isolatedModules` checks type re-exports for Bun's per-file transpilation.

Pack and exercise the libraries from a separate Bun project when imports or
native packaging change. Model-free and small synthetic-model tests do not
replace bit-exact real-weight parity against the pinned oracle. Real-weight
parity and performance work is tracked in [PLAN.md](PLAN.md).

## Documentation

Read the root README, this architecture, the owning package README, then code.
Read [PLAN.md](PLAN.md) when choosing work and decision records when asking why.
Keep documentation reachable within two links of the root README.

One fact has one owner. Cross-package ownership lives here; package design
explanations live in the package README. Export JSDoc describes obligations
types cannot express: tensor ownership, disposal, cancellation, and numerical
guarantees. Test those obligations where possible.

Generate inventories from source; write explanations and getting-started prose.
Examples come from executable files tested in CI, including suitable behavior
tests; include or extract those examples rather than maintaining another copy.
Generated reference is build-only, with generator and inputs in Git and a
coverage check for registered public surfaces. Procedures belong in executable
scripts with `--help`. Add that tooling with its actual consumer.

Documentation changes follow a code change, decision, measurement, or misleading
guide. Update it with that change. Open work lives only in PLAN; delete completed
blocks. No STATUS file, parallel issue backlog for this refactor, or scheduled
documentation passes. Mechanical rules get gates and pointers; policy rules,
including approval before adding files, remain binding without a gate. A future
agent entry file should stay short: navigation and those policy rules.

Separate decision records are for consequential tradeoffs or costly
investigations likely to recur. Keep the body frozen, allow a small mutable
status header, and append dated corrections. Foundational conventions belong
in the decisions list above. Recover historical decisions only as needed.

Keep curated measurement records in Git, raw output elsewhere. Record machine,
chip, RAM, OS, commit, artifact, configuration, context length, batch, date, and
results. Corrections reference the original record. A negative performance
result merits a decision record only with a paired A/B on a named machine and
a question likely to recur; preserve its conditions rather than generalizing.

Historical source: pre-refactor main at
[`02d723a`](https://github.com/joshuarossi/mlx-bun/tree/02d723a2875153196f8c6c10bce2daf6f0044655)
contains the original code, app contracts, oracle tooling, and investigations.
Use `git show 02d723a:<path>` for recovery; do not copy the archive wholesale.
