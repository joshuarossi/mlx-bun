# Preparing mlx-bun for the MLX community

The immediate goal is useful engagement with the MLX community: first a
Discord introduction and technical feedback, then a community-project
comment informed by that feedback. Website inclusion is the maintainers'
decision. Hacker News and wider promotion come later.

Open milestones and their completion state live in [PLAN.md](../../PLAN.md#public-readiness).
This document defines the work and acceptance criteria. Performance results
stay in [benchmarks.md](../reference/benchmarks.md); package decisions belong
in the [engine architecture](../design/unified-engine-frontier-plan.md#1215-package-boundaries-before-community-outreach).

## 1. Make the repository understandable

Correct the README's first-run instructions, platform and distribution
description, batching claims, and numerical guarantees. Give readers direct
paths for using the app, embedding inference, inspecting evidence, and
contributing. Put reference documentation ahead of archived investigations.
Reconcile release wording and known limitations across the reference docs
and the generated website. Keep historical investigations clearly separate.

Provide a short contributor setup and issue forms that collect the machine,
version, artifact, settings, and reproduction needed to investigate a bug.
Bun version is relevant to npm/source users, not standalone-binary users.

Acceptance: documented commands match the implementation; public descriptions
agree about shipped behavior; local links and generated navigation resolve;
the website builds; the docs and hygiene checks pass. Review the rendered
README and website as a new reader. No claim of universal model support,
identical generated text, or guaranteed freedom from model hallucinations.

## 2. Decide package ownership before asking others to build on it

Map imports, exported APIs, runtime dependencies, native assets, build inputs,
tests, and release packaging. Distinguish the reusable inference engine from
the HTTP/CLI assembly and application modules. Decide whether to introduce
workspaces now, which packages would remain private, and which entry points
deserve independent installation. Interfaces within a concern do not each
need their own npm package.

Existing `mlx-bun`, `mlx-bun/engine`, and `mlx-bun/client` imports are already
published. Preserve them through compatibility exports if code moves. Keep
in-process inference and the self-contained executable. Package extraction
must not add transport hops, dispatch layers, or tensor copies to decoding.

Acceptance: record a concrete dependency map and keep/move decisions with
reasons. If extraction is justified before outreach, complete it, check the
installed package rather than only source imports, and run the affected
build, asset, API, and performance checks. Otherwise record what can move
internally later without forcing a consumer migration. Merely postponing the
decision does not complete this milestone.

## 3. Verify the experience we will demonstrate

Inspect the npm file list and release bundle for required assets, accidental
research output, and unnecessary application dependencies. Reuse accepted
release and benchmark evidence where the relevant code is unchanged. Check
first-run instructions in a clean user environment and a small library
consumer against the candidate artifact. Cover browser chat, streaming,
model selection, and actionable errors on the path used in the demonstration.

Prepare a short reproducible demonstration and link to the existing measured
comparisons, naming artifacts and settings. State remaining limitations in
their reference documentation. Fix defects found on this path; do not make
closing every unrelated research item a prerequisite for community feedback.
Memory guidance remains advisory by default, as documented in server config.

Acceptance: the candidate's install and demo paths work as documented, its
assets and library exports resolve, and each claim points to matching evidence.
Record which existing checks were reused and which candidate checks ran.
Use Josh's approval for persistent servers or large downloads when needed.

## 4. Engage in the MLX Discord

Verify the current community invite and appropriate channel before posting.
Prepare a concise introduction: what mlx-bun does, why native TypeScript
integration is useful, a demo, the repository, and specific requests for
feedback on integration and correctness. Credit MLX, mlx-c, mlx-lm, and other
dependencies accurately. Avoid predicting Apple endorsement or reception.

Josh reviews the concrete draft before it is sent unless he has explicitly
authorized posting it. Turn actionable feedback into issues or fixes and
respond with evidence. Keep support expectations realistic for a solo
maintainer; no promised response time is needed.

Acceptance: the introduction is posted in the agreed channel and initial
feedback has been reviewed. Feedback may change the package or demo decisions.

## 5. Request a community-project listing

After Discord engagement, verify the current instructions in the
[MLX community-project discussion](https://github.com/ml-explore/mlx/discussions/654).
Prepare the listing comment with a short project description, supported
platform/runtime, repository link, and a useful example. Incorporate Discord
feedback and submit the reviewed comment when authorized.

Acceptance: the comment is submitted and follow-up questions are handled.
Maintainer acceptance and placement on the website are external outcomes,
not promises or reasons to keep making unrelated changes indefinitely.
