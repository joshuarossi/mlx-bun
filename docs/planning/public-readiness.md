# Preparing mlx-bun for the MLX community

Success means that a curious developer can understand the project, reproduce
its numerical claims, and build something with it. The listing is a discovery
link; the repository and working examples have to earn further attention.

The public pitch is MLX inference as a TypeScript/Bun library, with a signed
executable serving OpenAI/Anthropic-compatible APIs. Correctness claims name
the tested artifact and configuration. Specialized kernels, quantization,
and reusable cache state support that product; ancillary applications do not
need equal space in the introduction.

Open milestones live in [PLAN.md](../../PLAN.md#public-readiness).
Numbers belong in [benchmarks.md](../reference/benchmarks.md), with historical
experiments in its linked ledger. Package decisions belong in the
[engine architecture](../design/unified-engine-frontier-plan.md#1215-package-boundaries-before-community-outreach).

## P0. Contribute the GPTQ finding upstream

Check the reported indexing errors against a pinned upstream revision and
search existing issues and pull requests before filing. Produce a minimal
CPU-only reproduction that needs no model download. Demonstrate both the
out-of-block update window and the global index into a block-local error
buffer; a one-line fix is not enough. Keep the report about the numerical bug,
with a proposed patch and a useful regression test.

Acceptance: the reproduction runs against the cited revision, a reviewed
issue or pull request is submitted when authorized, and the discussion is
followed up. Upstream acceptance is not required to proceed with community
feedback. Submitted as [mlx-lm #1878](https://github.com/ml-explore/mlx-lm/issues/1878) with the complete CPU-only
reproduction, observed results and proposed two-line correction. Follow-up
and an independent-reference regression test remain open.

## P1. Make the first visit clear and credible

Remove session-specific instructions, personal approvals, and handoff prose
from README, STATUS, model/configuration references, benchmarks, and pages
rendered by the website. Preserve observed CPU, swap, memory, artifact, and
sampling conditions as technical facts. Do not turn diagnostic measurements
into controlled experiments by removing their qualifications.

The benchmark reference should open with its parity summary, then the latest
standard head-to-head with wins and losses, then reproduction instructions.
Move historical campaign details into a linked ledger and preserve old
section links. Map every roster row claiming L1 to a concrete artifact and
test, or explicitly describe the remaining evidence gap. Family support does
not establish parity for every checkpoint or modality.

Lead the README and site with the library and server. Link to contribution
instructions instead of internal work tracking from the main README. Keep
secondary applications in a short, separate line. Distinguish the first-run
starter from the preferred model used once suitable weights are available.

Acceptance: the public wording agrees with the implementation; no personal
approval language remains in these public entry points; local links and the
website build pass; desktop and narrow-screen presentation are reviewed.
The claims about numerical agreement remain bounded by recorded evidence.

## P2. Make correctness independently reproducible

Provide `setup.sh` under `scripts/oracle/` and a committed dependency lock for the
reference environment. Select it through `MLX_BUN_ORACLE_VENV`; no contributor
should need the maintainer's directory layout. Pin the native MLX/Metal build,
Python dependencies, model revision, tokenizer/template inputs, and oracle
fixture-generation command. Explain the machine-specific fixtures and the
attention-dispatch boundary that makes another Mac's binary goldens unsuitable.

Publish a small-model recipe ending in the MiniCPM parity test. It must create
fixtures from the Python oracle and fail clearly on missing inputs, rather
than reporting skipped tests as success. Measure the setup and test duration;
do not promise ten minutes until a clean-machine run supports it. Explain
what is compared before sampling and which execution shapes are tested.

Acceptance: a clean checkout can install the pinned reference, obtain the
specified artifact, regenerate its own oracle fixtures, and run a documented
logit comparison. Publish enough provenance for each summary table row to be
traceable. Existing accepted checks do not need wholesale reruns; this work
checks whether an outsider can reproduce them.

## P3. Settle package ownership

Map imports, public APIs, dependencies, native assets, builds, tests and
release packaging. Distinguish the reusable engine from HTTP/CLI assembly
and applications. Decide whether workspaces improve independent installation
and development enough to introduce them before outreach.

Keep `mlx-bun`, `mlx-bun/engine`, and `mlx-bun/client` imports compatible.
Preserve in-process execution, specialized kernels, tensor ownership and the
self-contained executable. Interfaces do not each need their own package.
No package extraction should add transport hops or copies in the decode path.

Acceptance: record and implement justified pre-outreach moves, or document
which internal moves can safely follow later. Test an installed consumer and
bundled assets when extraction changes them. Postponing the decision without
a dependency map does not complete this milestone.

## P4. Verify the candidate and its presentation

Inspect the npm tarball and release bundle. Keep runtime assets complete and
exclude accidental research output. Check first-run chat, streaming, model
selection, a small library consumer, and actionable errors against the
candidate artifact. Reuse release and benchmark evidence where code and
configuration have not changed. Default memory guidance remains advisory.

Prepare a short demonstration and evidence bundle. Set an accurate GitHub
repository description, homepage and topics: `mlx`, `apple-silicon`, `bun`,
`llm`, `metal`. Verify that the intended release is easy to find; use the
available GitHub release/highlight controls without promising a nonexistent
pinning feature. Include straightforward issue reporting and contributor setup.

Acceptance: the installed candidate and demo work as documented, repository
metadata matches the pitch, and every public performance claim points to its
machine and workload. Persistent servers and large downloads follow the
repository's existing session rules.

## P5. Engage, then request the listing

Order: upstream GPTQ report, Discord introduction, GitHub Show and tell,
then the community-project comment. Verify current venue instructions before
posting. The [MLX Community Discord invite](https://discord.gg/wXk8tEqAcG)
is a starting point to verify, not evidence about audience size or reception.

Ask for feedback on the library integration and reproducible correctness
comparison. Credit MLX, mlx-c, mlx-lm and mlx-optiq accurately. Treat rotation
and trellis findings as a separate technical discussion with their quality
tradeoffs; do not imply that all quantization methods preserve L1 numerics.

The [Show and tell category](https://github.com/ml-explore/mlx/discussions/categories/show-and-tell)
provides a durable, searchable introduction containing the example,
reproduction steps, known limits and upstream contribution. Incorporate
Discord feedback before preparing that post. Then follow the instructions in
[community-project discussion #654](https://github.com/ml-explore/mlx/discussions/654).

Draft listing sentence, for review:

> [mlx-bun](https://github.com/joshuarossi/mlx-bun) brings MLX inference to TypeScript/Bun applications and ships a signed executable serving OpenAI/Anthropic-compatible APIs on Apple Silicon, with bit-exact logit tests against mlx-lm for validated configurations.

The listing sentence deliberately omits an unqualified family-wide parity
claim. Add the reproducible example and coverage link to the Show-and-tell
post, where readers can inspect the precise scope.

Acceptance: review the concrete drafts, post when authorized, triage feedback,
and submit the listing comment. Website placement and maintainer enthusiasm
are external outcomes, not completion promises. Hacker News comes later.
