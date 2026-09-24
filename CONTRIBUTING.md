# Contributing

Start with the [architecture](ARCHITECTURE.md) and the owning package's README.
Keep a change focused on one responsibility. Preserve the public component
interfaces so consumers can compose lower layers as well as use convenience APIs.

## Verification

Use the workspace commands in [Development](README.md#development), after the
package READMEs' native setup. Typechecking includes portable contracts without
Bun or MLX types. The test suite includes the AST dependency gate and behavior
tests. Run the affected checks; changes to shared interfaces need their consumers
checked too. A skipped hardware or artifact test is not evidence that it passed.

For import or native packaging changes, also install packed artifacts in a clean
Bun project and exercise them there. A working workspace import does not prove
the published package contains its native libraries or resolves its dependencies.
Examples must execute in tests; READMEs link or extract that source.

## Numerical and performance evidence

Preserving an implementation means equal behavior for the same inputs and
settings, including tensor ownership, disposal, state continuation, and
cancellation. Matching source text or passing synthetic tests is insufficient
for claims about real models.

- **L1:** compare logits with the pinned mlx-lm oracle, bit-exact where that
  path's contract requires it. Keep application policy separate from numerics.
- **L2:** use the applicable mlx-optiq reference for its specialized paths.
- **Lab:** a path without an oracle needs explicit numerical acceptance criteria;
  it must win a paired A/B before becoming a default.

Run Python references externally, as required by the architecture. Record the
exact oracle versions and source revisions with the comparison. Use identical
artifacts, tokens, settings, and state transitions; compare the migrated path
with both its applicable oracle and pre-refactor main. State exactly which
models and paths the evidence covers.

Performance claims require paired runs on a quiet, named machine with identical
artifacts and configuration. Compare decode, prefill, complete-request time,
and memory as applicable. Investigate gaps against the applicable oracle rather
than dismissing them as framework differences. Use the architecture's
[measurement rules](ARCHITECTURE.md#documentation) for provenance and storage.

## Commits and review

Use focused commits and a PR title describing the resulting behavior. Explain
the problem, ownership changes, verification, and remaining limits in the PR.
Include documentation changes with the behavior or decision they explain;
remove completed PLAN entries. Keep raw logs, temporary checkpoints, and
investigation output outside Git. A refactor PR must distinguish migrated code
from paths verified with real weights; do not claim parity or speed without evidence.
