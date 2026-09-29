# Architecture

mlx-bun provides local AI on Apple Silicon. Bun workspaces contain applications
in `apps/` and importable libraries in `packages/`. The current target is macOS
on Apple Silicon. Keep responsibilities explicit; add packages when a consumer
needs a separate installation or release boundary.

## Foundational decisions

- One repository and Git history; Bun workspaces, without Turbo. YAGNI and KISS
  guide additions. Josh approves new documentation files; implementation and test
  files needed for the approved refactor do not require individual approval.
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
- Inference and the app do not require a Python environment. Separately runnable
  verification and evaluation tools may use pinned Python environments; their
  reusable code, launch configuration, and instructions belong in Git. Runtime
  environments and generated data stay outside the checkout. Docker runs the
  optional generated-code verifier and CPU evaluation clients; MLX/Metal GPU
  oracles run natively on macOS. Keep mlx-lm in its own external checkout and
  environment: our runner references that path and records its revision and
  versions, without vendoring the oracle or its environment. A containerized
  client may call the native app over HTTP. Fixtures and goldens retained for
  reuse live in external datasets referenced by immutable revision.

## Composition and public APIs

`@mlx-bun/mlx` owns the native MLX binding. `@mlx-bun/inference` builds on it.
The inference root is the convenient loading and generation API: callers supply
artifacts and graphs; it composes the lower layers. Lower layers never import
this entry point. Component subpaths are public ways to compose kernels, layers,
graphs, state, sampling, and generation directly. A small convenience API does
not require hiding those components.

`@mlx-bun/training` owns adapter training and production above the inference
graphs, layers, state contracts, and MLX autograd. Training progress is a
library contract; job lifecycle and terminal output stay in apps.
Inference and quantization never depend on training.

Interfaces describe required capabilities and ownership, not a selected model
or service. A caller may provide a different implementation satisfying the
same contract. Concrete model loading remains available as a convenience.

### Construct the implementation before executing it

The model description is an input to constructing an implementation. Resolve
known architecture, weight layout, quantization, layer roles, and configured
capabilities when loading and binding the graph. Compose the selected layers
and kernels into that implementation so execution does not repeatedly interpret
the descriptor or rediscover what a particular layer does. Adding model support
should reuse these components where they fit and give specialized code an
explicit owner. A universal fallback can remain available.

Here, "compile" means resolving those facts into a concrete implementation;
it does not require generated source or MLX graph compilation. Layers own MLX
compilation choices, whose performance must be measured. State can be omitted
or kept unmaterialized only when its uses and lifetime establish that this is
correct, with numerical and lifecycle evidence.

Sampling, caches, scheduling, and speculative methods compose through their
contracts. Bind required operations and reject genuinely missing capabilities
at the composition boundary rather than maintaining model/flag combination
allowlists. For example, a missing draft head is a missing component. Dynamic
request data, batch membership, cancellation, and state transitions still need
runtime handling. This is the target design and a review criterion for remaining
migration work, not a claim that every existing path already satisfies it.

## Ownership and dependency direction

Inside `packages/inference/src/`:

| Owner | Responsibility |
| --- | --- |
| `contracts/portable/` | Backend-independent inference graph, state, output, and scheduling interfaces. No platform imports. |
| `contracts/mlx/` | Tensor, attention, cache, position, weight-source, and forward-work interfaces. May reference the MLX binding and portable contracts. |
| `runtime/` | Shared configuration scopes, resource ownership helpers, tracing context, and bundled native paths. No model or scheduling dependencies. |
| `kernels/` | Numerical operations and their input layouts. No concrete cache, artifact loader, model, or scheduler imports. |
| `artifacts/` | Configuration, weights, formats, auxiliary checkpoint files, expert storage/residency, and conversion of artifact layouts into kernel descriptors. |
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
public library exports. Model discovery and acquisition remain in
`@mlx-bun/hub`; fit estimates and numerical inference remain in `@mlx-bun/inference`.
`engine/` owns loaded models and continuous scheduling. `server/` consumes its
completion, preparation, and model-binding interfaces; HTTP request shapes,
prompt policy, and JSON/SSE remain server-owned. The server borrows the engine,
while application startup owns closing it. Serve startup is two halves inside
`cli/`: `serve-state.ts` owns the persistent CPU state that outlives a loaded
model and imports no engine or native module at runtime; `serve-host.ts` owns
the model-scoped composition and borrows that state explicitly, lending back
its execution lease, library invalidation, and port through an attached link,
so a later isolation step can run the host in another process. `chat/` owns the WebSocket backend
and its Pi adapter; `web/` owns browser modules, static assets, and compilation.
Browser code consumes only its own modules and the leaf chat/job protocols.
`jobs/protocol.ts` owns the browser's job events and runner contracts. Add
other domains with their first migrated consumers and explicit dependency rules.

`memory/` owns Markdown vault storage, initialization, and article semantics.
Its HTTP adapter belongs to `server/`; composition supplies reference sources
explicitly rather than deriving them from repository layout. Read-only memory
tools and prompt context are built by `memory/` and injected into chat, with
composition supplying the vault and bundled-skill destinations. Query navigation
uses local article structure; scheduling and synthesis have separate lifecycles.

Standalone Pi integration is deferred pending Josh's decision. The web app
uses Pi through the app-owned chat adapter.

Application contracts migrate with their owning apps: Pi UI/provider protocols,
job runner types, engine host, and completion clients. Within the apps, browser chat
protocols belong to chat, job contracts to job orchestration, and
host/client interfaces to their application boundary. Apps import reusable
inference contracts from the library rather than duplicating them. Portability
is a dependency constraint; domain ownership determines the home.

`jobs/` owns persisted job state, in-process tasks, and subprocess/lease lifetimes; `quantize/`
owns quantization job policy and consumes jobs contracts plus public libraries.
The CLI composes producers and child entry paths, so jobs infrastructure imports
neither producer implementations nor engine internals. HTTP adapters consume
these domains from `server/`. `dataset/` owns templates, JSONL production, and
HTTP clients; its loopback requests enter the server scheduler without holding
an exclusive execution lease.

`publishing/` owns app credential storage and artifact/source selection. Server
routes parse settings and push requests; CLI composition supplies a read-only
job lookup. The hub library owns the upload protocol and receives an explicit
token, without importing application storage or jobs.

On disk, `storage/paths.ts` owns every default the app writes; explicit user
paths win, and libraries take paths from their callers.

| Location | Owner |
| --- | --- |
| `MLX_BUN_HOME` (default `~/.mlx-bun`): `models/`, `adapters/`, `exports/`, `datasets/`, `db/`, `jobs/`, chat, wiki, skills, logs, credentials | the app |
| `~/.mlx-bun/app-install/` | the installer |
| `MLX_BUN_HOME/cache/` | derived memos (inference artifact identities) |
| Hugging Face hub cache (`hubCacheRoot()`) | `@mlx-bun/hub` downloads only |

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

Composition follows the operations and invariants each component provides.
Compatible graph, cache, sampling, and generation implementations should compose
without a separate model-family allowlist for every combination. Real constraints,
such as an attention operation requiring a particular cache representation, belong
in the owning component's contract and binding; the scheduler consumes that binding.
Prefer the smallest existing interface that expresses the requirement.

For every newly supported model, the target is to compile its description into
a concrete implementation. Here, compilation means resolving known facts during
graph construction or startup; it is distinct from the layers' MLX compilation
policy and can use ordinary functions and explicit graph construction. Resolve
model, artifact, layer, and selected option facts into specific kernels, layers,
state layouts, and bound operations. The specialized Gemma implementations
demonstrate the intended pattern for model support generally. Adding support means assembling
the graph from reusable components and implementing any missing operation in its
owning layer.

Known data flow is part of that construction: which operations produce and consume
a tensor, its layout, and its ownership and lifetime obligations. Use these facts
to determine which intermediate state must be materialized, copied, or retained.
A specialized implementation may avoid that work when it can establish that every
bound consumer's contract, including the state required by a selected generation
method, checkpoint, or exposed output, is still met.
These are properties of the chosen graph and bindings, not guesses about how a
model is usually used; changing those properties requires a corresponding binding
or implementation.

Execution calls the resulting operations without repeatedly interpreting model
descriptors or rediscovering invariant capabilities in the hot path. Current
sequence lengths, cache contents, batch membership, request choices, and
cancellation remain dynamic. A universal fallback is allowed; no universal model
abstraction, code-generation system, or compiler framework is required. This is
the target for refining migrated paths, not a claim that every current path already
follows it; changes still require the
[numerical and performance evidence](CONTRIBUTING.md#numerical-and-performance-evidence).

Main is the baseline for working capabilities, not a requirement to reproduce
every restriction, silently ignored option, or bug. Preserve what works while
removing accidental coupling. Make intentional behavior corrections explicit and
test them; never report an option as implemented when its operation is unavailable.

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
including approval before adding documentation files, remain binding without a gate. A future
agent entry file should stay short: navigation and those policy rules.

Separate decision records are for consequential tradeoffs or costly
investigations likely to recur. Keep the body frozen, allow a small mutable
status header, and append dated corrections. Foundational conventions belong
in the decisions list above. Recover historical decisions only as needed.

Keep reusable runners and instructions, retain compact results, and store large
datasets externally. A result records the command, source commits, runtime and
oracle versions, model and dataset revisions or content hashes, machine,
configuration, seeds, execution shape, scores or timings, and failed or skipped
cases needed to repeat the run. Record corrections explicitly. CI and external
run directories can hold these summaries; curate consequential results in their
owning documentation or PR rather than creating a second status ledger.

Raw tensor captures, generated checkpoints, fixtures, goldens, and bulk
benchmark output do not belong in Git. Keep only the evidence needed for the
current investigation; permanent retention of every capture is not required.
Retained reusable data belongs in an external dataset, such as Hugging Face,
pinned by an immutable revision or content hash. Runners default to an output
directory outside the checkout and distinguish the small result summary from
optional detailed captures. Instructions must make the inputs and procedure
reproducible without requiring a machine-local archive. A negative performance
result merits a decision record only with a paired A/B on a named machine and a
question likely to recur; preserve its conditions rather than generalizing.

Historical source: pre-refactor main at
[`02d723a`](https://github.com/joshuarossi/mlx-bun/tree/02d723a2875153196f8c6c10bce2daf6f0044655)
contains the original code, app contracts, oracle tooling, and investigations.
Use `git show 02d723a:<path>` for recovery; do not copy the archive wholesale.
