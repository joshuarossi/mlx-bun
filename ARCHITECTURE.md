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
  A model graph composes layers and kernels; its layers own whether
  operations compile. Keep this implementation choice out of app options.
- The app runs every request on the continuous batching scheduler: one request
  is a batch of one, and `--batch` is only the cap on rows per forward. Choosing
  a cap above one opts into batching, which may move the last bits of a result;
  `--batch 1` says nothing can be batched, so nothing changes. There is no second
  engine for one request. Preserve main's application behavior while giving each
  domain a clear owner; benchmark the full draft afterward.
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
graphs, layers, state contracts, and MLX autograd. Training caches own their rope
positions (`TrainingAttentionCache.ropePositions`); there is no module-level prefix layout. Training progress is a
library contract; job lifecycle and terminal output stay in apps.
Inference and quantization never depend on training.

Interfaces describe required capabilities and ownership, not a selected model
or service. A caller may provide a different implementation satisfying the
same contract. Concrete model loading remains available as a convenience.

### Write the graph before loading it

A graph is a file written before anyone runs it. It imports layers, each binding
its kernel, arranges them in execution order and exports that arrangement.
Profiling determines the bindings for the model and hardware; the file states
them literally. A specialized graph takes weights and artifact configuration,
attaches those weights to the layers it already names and decides nothing.
It takes no composition record and contains no branches or layer loops. Every
graph is an entire graph and extends nothing. One generic graph per family may
inspect the artifact and device at load and loop over the artifact's layer count
to bind its operations. Those choices settle at construction; its forwards do
not reread the device or module configuration.

When the caller supplies no graph, the loader recommends one from the model,
device and module configuration (`contracts/portable/composition.ts`), choosing
the most specific table entry or the family's generic graph. Callers can choose
the generic graph, a file tuned for another machine, or their own arrangement
of exported layers. The matching keys guide default selection; the authoring
rules govern repository code. The loader attaches weights and composes cache
and drafter components, and the scheduler routes work through their contracts.

Known kernel choices belong in the written bindings. Nothing below the scheduler
reads a flag, environment variable or device to select another kernel during
execution. Each module exposes its own configuration: cache storage and paging,
scheduler row caps, draft method and depth, sampling. An adapter is a trained
file named by a request; its delta adds to that request's projection outputs.
Graphs expose projection targets and have no adapter support switch. Compound
fused layers bind the corresponding unfused projection-delta operation when an
active request names an adapter, before the forward runs.

Layers expose their MLX compilation forms as separate bindings, whose performance
must be measured. State can be omitted or kept unmaterialized only when its uses
and lifetime establish that this is correct, with numerical and lifecycle evidence.

Sampling, caches, scheduling, and speculative methods compose through their
contracts. Bind required operations and reject genuinely missing capabilities
at the composition boundary rather than maintaining model/flag combination
allowlists. An operation's presence can itself declare a capability: pooled
embeddings are declared by `embedPooled`, and the bound portable description
derives its support flag from that operation. Graph construction uses
`GraphDeclaration`; consumers that need the portable `GraphCapabilities` report
use `graphCapabilitiesOf`. The types and seam ratchet prevent independent
pooled-embedding flags from returning. A missing draft head is a missing
component. Dynamic request data, batch membership, cancellation, and state transitions still need
runtime handling. Graphs declare their capabilities when constructed; the gateway
plans from those declarations and the app engine binds media through graph
operations. Every graph implements `dispose()` and releases what it built;
providers and the host call it. Facts the server and CLI need (memory plans, native draft heads,
pooled-embedding recipes, tool-call and reasoning marker tokens, media soft
tokens, chat defaults, template fallbacks) are declared by the model layer, in
the family record (`models/families`, one record per family) or the opened
runtime, and consumed as data. The architecture gate rejects model classes,
model-type and architecture checks, family predicates and model-identity checks
in the engine, server and CLI, and model-type comparisons anywhere in the
library outside the family registry, the family directories and the artifact
readers.
Scheduling (`execution/`) is written against the structural `MlxTokenGraph`, not
the registry's closed `RuntimeModel` union of model classes, and moves cache rows
through each layer's row layout (`state/layout`, the `BatchableCache` port) rather
than a concrete cache class. The gate rejects both there, and its composition
rules (the seam ratchet below) hold the mechanical part of this section across
the library. What no rule can see remains a review criterion, not a claim that
every existing path already satisfies it.

Two contracts carry the composition. The cache owns its storage and its read:
a layer appends through `AttentionCache` and reads through `AttentionRead.attend`,
and no caller reaches a representation-specific escape hatch; the cache also
owns prefix reuse, paging, SSD offload and eviction behind that interface and
answers hit or miss. The graph names its phases (`MlxTokenPhases`:
`decode`, `verify` and serving `logits` indexed by exact positive row count;
prompt operations, known appends and full-sequence heads listed over contiguous
row or position ranges). A table may state an explicit `default` operation for
other positive row counts, as ordinary inspectable data. No Proxy fills missing
entries. A missing entry without a declared default is an error. Each graph
declares its chunk and tail tables, including an explicit shared table when both
use the same operations; dispatch never supplies an undeclared phase alias.
The scheduler indexes the rows it batched and dispatches prompt pieces to the GPU or Neural Engine as a
resource it manages. Row-wise layers take M rows and do not know whether they
are one sequence or M; only `attend` and the recurrence see the row layout.

## Ownership and dependency direction

![The inference chain: the modules and the features each one owns](docs/inference-chain.svg)


Inside `packages/inference/src/`:

| Owner | Responsibility |
| --- | --- |
| `contracts/portable/` | Backend-independent inference graph, state, output, and scheduling interfaces. No platform imports. |
| `contracts/mlx/` | Tensor, attention, cache, position, weight-source, forward-work and text-to-image stage interfaces. May reference the MLX binding and portable contracts. |
| `runtime/` | Shared configuration scopes, resource ownership helpers, tracing context, and bundled native paths. No model or scheduling dependencies. |
| `kernels/` | Numerical operations and their input layouts. No concrete cache, artifact loader, model, or scheduler imports. |
| `artifacts/` | Configuration, weights, formats, auxiliary checkpoint files, expert storage/residency, and conversion of artifact layouts into kernel descriptors. |
| `layers/` | Reusable graph building blocks, including LoRA application and positional operations. |
| `state/` | Cache legos that own their storage and their read (`attend`), the KV scheme they compose from, the row layouts the scheduler moves rows through (`layout`), snapshots, and the cache service (`cache-service`): one per loaded model, owning prefix reuse, the KV budget, SSD persistence, retention and eviction behind acquire and release. |
| `input/` | Tokenizers, templates, media preprocessing, and prompt assembly through encoder interfaces. |
| `sampling/` | Sampling policy, processors, constraints, and draft sampling. |
| `adapters/` | Loading and mounting adapter weights through named target interfaces. |
| `models/` | Family records and profiles; written graph files for models and hardware, and each family's generic graph; the composition resolver (`composition`) and the selection tables the loader picks a graph from (`factory`); drafter loaders; the Neural Engine programs the shipped compositions load (`ane-install`). |
| `generation/` | Autoregressive, denoising, fill, and speculative methods, flow-matching text-to-image generation over the stage contracts (`image`), and the phase dispatch (`phase-dispatch`) that resolves the operation a graph built for the phase and rows its caller names. `bindings/` connects concrete graphs to those methods. |
| `scoring/`, `embeddings/`, `transcription/` | Operations consuming graphs and caller-supplied inputs. |
| `execution/` | Admission, the plan from declared capabilities, the batch groups that call the graph's phases for the rows they batched, sessions, coordination, and fit estimates: the one component that decides at run time. |
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
so a later isolation step can run the host in another process. The chat (the WebSocket backend, its Pi
adapter, saved chats and tool approvals) is `@mlx-bun/module-chat`, which runs in the persistent state;
`web/` owns browser modules, static assets, and compilation.
Browser code consumes only its own modules, the web shell, the web kit and the leaf job protocol.
`jobs/protocol.ts` owns the browser's job events and runner contracts. Add
other domains with their first migrated consumers and explicit dependency rules.

`@mlx-bun/module-memory` owns Markdown vault storage, initialization, article semantics, HTTP routes, CLI verbs and its companion overlay.
Composition supplies reference sources
explicitly rather than deriving them from repository layout. Read-only memory
tools and prompt context are built by the module and reach the chat through the `registry` service
(`chat.tool` and `chat.guidance`), with
composition supplying the vault and bundled-skill destinations. Query navigation
uses local article structure; scheduling and synthesis have separate lifecycles.

Standalone Pi integration is deferred pending Josh's decision. The web app
uses Pi through the app-owned chat adapter.

Application contracts migrate with their owning apps: Pi UI/provider protocols,
job runner types, engine host, and completion clients. Within the apps, the browser chat
protocol belongs to the chat module, job contracts to job orchestration, and
host/client interfaces to their application boundary. Apps import reusable
inference contracts from the library rather than duplicating them. Portability
is a dependency constraint; domain ownership determines the home.

`jobs/` owns persisted job state, in-process tasks, and subprocess/lease lifetimes. Quantization
job policy and the `convert` verb are the quantize module's (`@mlx-bun/module-quantize`), and fine-tuning
(the `finetune` job, `train`, `fuse`, `draft`) the train module's (`@mlx-bun/module-train`); each
consumes the `jobs`, `storage` and `catalog` services and the public libraries. The CLI composes
child entry paths (a job child activates the module that registered its kind), so jobs
infrastructure imports neither producer implementations nor engine internals. HTTP adapters consume
these domains from `server/`. Dataset generation is the datasets module's
(`@mlx-bun/module-datasets`): its requests reach the served model through the `modelHost`
service and enter the server scheduler without holding an exclusive execution lease.

`publishing/` owns app credential storage and artifact/source selection. Server
routes parse settings and push requests; CLI composition supplies a read-only
job lookup. The hub library owns the upload protocol and receives an explicit
token, without importing application storage or jobs.

On disk, `storage/paths.ts` owns every default the app writes; explicit user
paths win, and libraries take paths from their callers.

| Location | Owner |
| --- | --- |
| `MLX_BUN_HOME` (default `~/.mlx-bun`): `models/`, `adapters/`, `exports/`, `datasets/`, `db/`, `jobs/`, wiki, skills, logs, credentials | the app |
| `MLX_BUN_HOME`: `sessions/`, `pi-sessions/`, `tool-approvals.json` | the chat module |
| `~/.mlx-bun/app-install/` | the installer |
| `MLX_BUN_HOME/cache/` | derived memos (inference artifact identities) |
| `MLX_BUN_HOME/kv/` | saved prompt/KV state, one directory per model identity, one byte budget across them (`--ssd-cache-max`) |
| Hugging Face hub cache (`hubCacheRoot()`) | `@mlx-bun/hub` downloads only |

Application features are moving into modules; see the next section. Until a domain moves, the rules above apply to it.

## Modular application

Target design; [PLAN.md](PLAN.md) orders the migration. The app splits the way the
repository did: features become modules a host enables, so a transcription-only
app installs one module and a native Mac app (Tauri, Electron or Swift) reuses
the same modules.

**Core services** are interfaces in `@mlx-bun/app-core` (types only, no workspace
dependencies). A host implements them once and every module depends only on them:

| Service | Owns |
| --- | --- |
| `modelHost` | Loaded models, leases and residency: a model that fits the memory budget loads beside the others, otherwise the least recently used unpinned, unleased one is drained, has its KV and prefix state flushed under `MLX_BUN_HOME`, and is released; acquiring it again resumes that state. `serve` holds each model in its own worker process (the parent runs this same manager over workers and loads nothing; `--in-process` loads them in the serving process). Companions (Whisper) can be pinned. Consumers ask a lease for a declared operation (`generate`, `embed`, `transcribe`, and `adapters` on a model that mounts LoRA adapters: list, mount, unmount, merge under the model's execution lease, in the process that holds the model), never for a model family. A host that holds several models can switch which one answers requests that name none (`serve`). |
| `jobs` | Persisted job state, task and child-process lifetimes, the GPU lease (`exclusive` jobs drain models first). |
| `storage` | A module's declared entries under `MLX_BUN_HOME`; nothing else is written by default. |
| `catalog` | Local models and adapters (with what the index knows of each: capabilities, quantization, sizes, support tier, snapshot), fit estimates, downloads (awaited, or started to outlive the caller), re-indexing, publishing, registering outputs. It announces `catalog.changed`. |
| `events` | Publish/subscribe: the model host and a scheduler adapter publish loads, unloads, per-model memory, request timings, batch occupancy, queue depth and KV/prefix usage and hit rate; modules subscribe. Publishing appends to each subscriber's bounded queue and never waits for it; handlers run later, in order, and the oldest events of a subscriber that falls behind are dropped and counted. Libraries below the app never import it. |

**Module contract.** A module is a workspace package `@mlx-bun/module-<id>` in
`packages/module-<id>/` whose default export is an `AppModule`: a static manifest
(id, `requires`, HTTP routes mounted under `/api/<id>`, CLI verbs with declared
options, job runners, storage entries, one web panel) plus `activate(context)`,
which receives only the services it required and returns the live handlers. The
manifest is plain data, so inventories and hosts read it without loading a model
or native code. A route or socket may declare `mount: "root"` for wire-compatible or
previously shipped paths (`/v1/audio/transcriptions`, `/ws/chat`); existing paths are
preserved. A panel is a self-contained custom element (`mlx-<id>-panel`) that
receives a `PanelConnection` (API base and event-stream URL), imports only its
module's `panel/` files and data `protocol.ts`, and so loads in any webview.
Modules live in `packages/` because libraries cannot depend on apps and the
native app must import them; a flat `packages/module-*` needs no new workspace
glob. Modules never import each other; cross-module needs go through core
services. One module's contributions to another (memory's tools in chat, a
module's settings in the shell) go through a `registry` core service: the
contributor registers a declared extension and the consumer lists what is
registered, so neither names the other. Browser code is two packages below the hosts. `@mlx-bun/web-kit` is the kit
panels and shells build with: the design tokens and base styles (one copy of the visual system), DOM helpers, the one
JSON API client, the event-stream and socket clients, and formatters; it has no workspace dependencies and touches no
DOM at import. A module's panel may import it, a module's server code never does, so the browser bundle holds one
transport layer and one stylesheet instead of a copy per panel. The web shell (navigation, routing,
theme, the command palette's chrome, panel mounting) is `@mlx-bun/web-shell`, reused by every
host's UI, native webviews included: it depends only on the web kit, takes the panels to mount as plain
`{ tag, title, path, connection }` records (a manifest's `panel` plus its `PanelConnection`) and gives each a tab and a
page, creating the element on first visit. A companion `overlay` panel (memory) mounts immediately without a route or tab. A `workspace` panel (the chat) is the product's own page: it fills the page
without a card, leads the tabs, stays outside the Developer switch and stays attached while another page shows, hearing
`enter()` and `leave()`; the host may hand a panel more than its connection through the element's properties (the chat's
`host`: what lives beside it on the page, such as memory's chips and the settings dialog's agent-tools section). A host's browser build imports each installed module's panel entry from
the host's installed modules (`apps/mlx-bun/src/web/build.ts` reads the host's `package.json`, which the gate ties to `src/modules.ts`), so the bundle holds the panels the host installs and no
others; pages that have not moved into modules stay in the host's own browser code, mounted beside the panels. Panels retain their declared browser paths when a feature moves to a differently named module. A panel that supplies
its own scroll column, heading and cards declares `framed: false`; its developer visibility and connection lifetime
remain the ordinary panel's. Optional `PanelConnection.ui` hooks supply the host's notifications, artifact publication,
active model identity and catalog-consumer refresh; panels do not import host implementations.
The seams, each a typed contract one side can be replaced behind: a panel and its server share only the module's
`protocol.ts` and meet through `PanelConnection.apiBase` and `eventsUrl`; a panel and its host share the `ui` hooks,
the element's own methods (the chat's `host` property and `companionSlots()`, a wizard's `currentStep()`, memory's
`attachChat(slots)`), and the kit's host events (`HOST_EVENTS`: server status, model changed, server recovered,
models changed, panel changed), so a panel never reads the page address, never reaches the host page's elements and
never names another module's panel (the gate scans panel code for all three); a panel and the visual system share
the kit's token names and class vocabulary; the shell and a host page share the ids in the shell's host contract and
the stylesheet order; and every piece reaches the server through the kit's clients, so a fake (the kit's `testing`
entry, the app's fake backend, the in-page mock) stands in for the server in tests and previews.
Modules start as private workspace
packages; publishing them is a separate licensing decision.

**Hosts** compose. `apps/mlx-bun` installs every module; `apps/transcribe`
installs one; a native app installs what it wants. Each host has one composition
file, `src/modules.ts`, the only file that names module packages, plus the
implementations of the core services. The ones hosts share are the host library
`@mlx-bun/app-services`: the Whisper model host over a catalog (lazy load, idle
unload, pinning, the host's execution lock around decoding, and a hook that
lets a host that also generates make room first), the registry-backed catalog, storage
entries under `MLX_BUN_HOME`, verb parsing and help from manifests, route
mounting, module activation and verb running. A host adds only its own execution
lock and serving; `apps/mlx-bun` also owns the generation side of `modelHost`
(`src/residency/model-residency.ts`: residency by memory fit over serving units, with
`src/server/model-routes.ts` routing requests by model id). A module's manifest is also importable alone
(`@mlx-bun/module-<id>/manifest`, data only), so a host lists commands and
`--help` and the documentation generators read verbs and routes without loading
the module. A host refuses a module that declares sockets unless it serves them (`createModuleSockets`: the app's
persistent state does, on the listener that answers the browser; the model composition, the transcription-only host and
`apps/transcribe` do not), and one that declares job runners unless it binds the `jobs` service, which then runs them. Installation
is build-time; a user setting may disable an installed module at start.

The `events` bus is `createEventHub` in `@mlx-bun/app-services`, one per app state (`AppState.events`), so the
model loader, the Whisper host and the engine adapter (`apps/mlx-bun/src/engine/telemetry.ts`, which times each
request from the run's own stats and samples the gateway and caches) publish into the bus the modules subscribe to.
A module's scoped bus publishes only its own `<id>.*` events, never a core type. A module that requires `jobs`
(datasets, metrics, benchmarks) or declares `placement: "app"` (models: it drives the serving host's residency and reaches a model only through
its lease) activates in the app's persistent state, and one that requires `jobs` gets the job service over the app's job host; a
runner that declares `gpu: "exclusive"` holds the engine's execution lease for its run.

`@mlx-bun/app-host` is the loader every host shares. `loadModules(modules,
{ services })` validates the manifests before activating anything (unique ids,
routes, verbs, job kinds and storage paths, where two modules that declare the same entry, one path
and kind, share it; every `requires` implemented by the host), activates the modules in order with only the services they required, built
per module by the host's bindings, and returns what they declared: routes at
`/api/<id>/...` or at their declared root paths (collisions with each other and
the host's own routes are rejected), sockets, verbs, job runners and storage
entries. It also implements `registry`, and answers `status(moduleId)` with the
counters a module reports for the host's health and stats surfaces. The host
serves, dispatches and creates what it returns; `stop()` disposes the modules in
reverse order. The mlx-bun app activates them in its serve composition, next to
the engine's execution lock, and stops them first in its drain, then releases
the weights they leased. The app composes its services at two scopes: modules that
require `jobs` (datasets, metrics, quantize, benchmarks, train) or declare sockets (chat) activate in the persistent state, beside the job store, with
`jobs` (the job host's `task` runners in this process, and `process` runners as a child that
stops with its parent under the execution lease, which activates the owning module itself),
`storage`, `catalog` and a `modelHost` that leases the serving host's model for `generate` over
its own HTTP surface (so the isolated parent, which loads no model, runs them too); the
others activate with the model host. The chat talks to the model only through that `modelHost`: each connection reads the
current model's description from its wire (`GET /v1/models`, `/stats`), and the Pi SDK, which takes no transport of ours,
reaches the model through a private loopback (a per-run bearer token, started with the first chat) that leases
the current model's `generate` per request; the request's own `local` model id is the host's to route. The state also serves the
modules' sockets on the app's listener and stops the modules (closing the sockets) before the listener drains. A one-shot CLI verb (`convert`, `train`) activates only its own
module over a private, throwaway job store, and a translated spelling of a verb (`mlx-bun.convert`,
`mlx-bun.lora`) reaches it through the same verb table. A verb that names no model asks the catalog for
the host's automatic choice (`pickDefault`), which the app supplies from the selection `serve` makes.

**Gate rules** (in `packages/inference/tests/architecture.test.ts`, each proven by a synthetic workspace):

- `app-core` has no runtime exports and no workspace imports.
- A module imports only `@mlx-bun/app-core`, declared domain libraries and its
  own files: no other module, no app, no core-service implementation.
- Libraries below the app never import `app-core`.
- Only a host's `modules.ts` imports module packages, and the host's
  `package.json` lists exactly the modules it names; hosts never import hosts.
- A host's import closure holds exactly the modules it names (`apps/transcribe`'s
  test walks it); no rule above lets a library or another host add one.
- Module, host-library and host code obey the engine's model-identity rule: declared
  operations only, no `instanceof <Model>` or model-type checks.
- Seam ratchet: model-class and cache-class `instanceof`, imports of concrete model
  modules (`models/<family>`, from other inference layers and other packages), model-type,
  `architectures` and repo-id/name checks, family-named env flags read outside
  `models/`, and scheduler-core imports beyond contracts and runtime; and the
  composition rules: a graph class that extends a graph or reads `super.` of one, a
  runtime flag, env read, `deviceArchitecture()`, `globalThis` access or layer, cache
  or model `instanceof` inside a forward, read, append or kernel body, or a text-to-image stage operation (`encode`, `velocity`) (construction,
  acceptance and the loader are exempt; profiling hooks and the two compile-context
  queries, `isCompiledTrace` and `isShapelessTracing`, which ask whether the graph is
  being recorded rather than run, by name), a
  representation-specific cache read outside `state/`, an independent pooled-embedding
  flag passed to `declareGraph` or read from a graph's declaration, and the removed whole-forward
  entry points reached from `execution/` or `generation/`. Code that breaks them is
  listed per file in `seamRatchet`, whose counts may only fall; the table is empty,
  so any finding fails the gate with the paved road in its message.
- Panel code imports only panel files, its `protocol.ts` (which imports
  nothing) and `@mlx-bun/web-kit`; this generalizes the browser rule for `chat/` and `jobs/`. A module's
  server code never imports the web kit: it is browser code, and only the panel runs in a browser.
- `web-kit` is browser code with no workspace dependencies and no imports beyond its own files. `web-shell` is
  browser code that imports only its own files and the web kit; no module imports the shell (a panel is handed its
  connection, not the shell), and an app's browser code may import both.
- Manifest checks in `@mlx-bun/app-host`'s tests: unique ids, routes, verbs, job
  kinds and storage paths (an identical entry in two modules is one shared entry);
  every `requires` satisfied.

## Changing or replacing a piece

Move shared interfaces below their consumers. Keep platform-free contracts
portable; keep MLX tensor interfaces concrete. Domain-specific contracts can
stay beside their owning domain when no lower layer needs them.

For example, paged attention accepts numerical storage without knowing its
allocator; adapter mounting consumes named mount points rather than the model
union; prompt preparation consumes encoders rather than Gemma or Qwen classes.
A new implementation must preserve the contract's tensor shapes, ownership,
state transitions, cancellation, and disposal semantics. Every numerical
path is explicit and reusable: one kernel, bound by one layer.

Composition follows the operations and invariants each component provides.
Compatible graph, cache, sampling, and generation implementations should compose
without a separate model-family allowlist for every combination. Real constraints,
such as an attention operation requiring a particular cache representation, belong
in the owning component's contract and binding; the scheduler consumes that binding.
Prefer the smallest existing interface that expresses the requirement.

One supported way per pattern; a second way is a gate failure, not a style note:

- Add a model by writing its graph file: import layers, arrange them and export
  the arrangement. Write the selected bindings for each model and machine;
  a model may have several files, and the loader recommends a default.
- Add a kernel as one file in `kernels/` bound by exactly one layer.
- Read a cache through `attend`; add a representation as a cache lego, never as
  a read path inside a layer.
- Add a phase through the graph contract (`MlxTokenPhases`) and call it from the
  scheduler by name.
- Add a composition fact as a field of the composition record the loader
  resolves, never as a flag read inside a forward.

The architecture gate holds these rules where they are mechanical, with a
ratchet of violators (empty) whose counts only fall; every failure message
names the paved road.

Every specialized graph states each layer and its kernel choices directly.
Changing the M1 Max file changes that file; the M4 Pro file is untouched. A change
to a shared layer or kernel reaches the files that import it and runs those
files' gates. No generator, description format or generator drift test is part
of graph authoring. Bit gates, numerical parity suites and paired measurements
verify the actual files. Users compose their own graphs from the same public
components, with no registration requirement.

Known data flow is part of that construction: which operations produce and consume
a tensor, its layout, and its ownership and lifetime obligations. Use these facts
to determine which intermediate state must be materialized, copied, or retained.
An implementation may avoid that work when it can establish that every
bound consumer's contract, including the state required by a selected generation
method, checkpoint, or exposed output, is still met.
These are properties of the chosen graph and bindings, not guesses about how a
model is usually used; changing those properties requires a corresponding binding
or implementation.

Execution calls the resulting operations without repeatedly interpreting model
descriptors or rediscovering invariant capabilities in the hot path. Current
sequence lengths, cache contents, batch membership, request choices, and
cancellation remain dynamic. A family's generic graph is the loader's selection
when no more constrained entry matches; no graph falls back inside its forward.
No universal model abstraction or compiler framework is required. This is
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
blocks. Unplanned ideas and research questions live in PLAN's Ideas section, one
line each; picking one up makes it a PLAN item with an exit, and an answered one
moves its finding to the owning documentation and is deleted. No STATUS file, parallel issue backlog for this refactor, or scheduled
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
