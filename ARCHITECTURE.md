# Library architecture

mlx-bun provides local AI on Apple Silicon. Bun workspaces contain applications
in `apps/` and importable libraries in `packages/`. The current target is macOS
on Apple Silicon. Keep responsibilities explicit; add packages when a consumer
needs a separate installation or release boundary.

## Composition and public APIs

`@mlx-bun/mlx` owns the native MLX binding. `@mlx-bun/inference` builds on it.
The inference root is the convenient loading and generation API: callers supply
artifacts and graphs; it composes the lower layers. Lower layers never import
this entry point. Component subpaths are public ways to compose kernels, layers,
graphs, state, sampling, and generation directly. A small convenience API does
not require hiding those components.

Interfaces describe required capabilities and ownership, not a selected model
or service. A caller may provide a different implementation satisfying the
same contract. Concrete model loading remains available as a convenience.

## Ownership and dependency direction

Inside `packages/inference/src/`:

| Owner | Responsibility |
| --- | --- |
| `contracts/portable/` | Main's shared contracts, plus backend-independent graph, state, output, and scheduling interfaces. No platform imports. |
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
The test parses both packages' TypeScript and JavaScript, resolves imports,
checks the declared layer DAG, and rejects module cycles, including type-only
cycles. Static imports, re-exports, import types, dynamic imports, and `require`
are checked. New source directories need an explicit owner in this gate.

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
Qwen Trellis, Gemma, and MiniCPM parity and matched performance comparisons
remain migration verification work; no speed improvement is claimed here.
