# Colibri GLM-5.2 oracle and gate fixtures

This directory combines a small model-free contract with a compact, validated
real-model oracle for the MLX/Bun port. It is pinned to Colibri commit
`44e489b196c9b7876b3d37a0570ebf1c6f90f54c` and public-artifact revision
`3cc8db99b1b13fc79325d987ba3c1c430766b3b8`.

Git is the authenticity and integrity root for these files. SHA-256 values in
`manifest.json` are reproducibility and accidental-drift checks, not signatures
and not a substitute for the recorded Git tree/blob identities.

## Files and provenance

- `oracle-capture.json` is immutable input to ordinary regeneration. It records
  the exact Colibri tree/blob hashes, archive/compile commands, helper hashes,
  Apple target, clang, Python, NumPy, and Bun versions used for the capture.
- `v1.json` combines the captured constants with explicitly labeled derived
  canonical traces.
- `real-model-oracle.json` is the deterministic compact reduction of 140 raw
  real-model tensor records: GLM layer stages, MLA compressed KV, true top-8
  routing, MTP fusion/head state, full-logit top-128 summaries, and the
  teacher-token decode. The raw 54 MB payload remains machine-local and is
  reproducible through the recorded instrumentation patch and provenance.
- `oracle-instrumentation.patch` is that exact measurement-only diff against
  pinned `c/glm.c`; apply it only to an isolated archive, never the oracle
  checkout.
- `manifest.json` describes the boundary and hashes all four data files. Its former
  machine-local checkout path was removed; the absolute path retained in the
  capture evidence is explicitly advisory capture-host metadata required to
  reproduce the historical command transcript.

Later gate records are reviewed, tracked evidence rather than inputs to the G0
generator:

- `production-probe.json`, `g3-production-expert-probe.json`, and
  `g3-full-model-trajectory.json` close the production Q4/router and bounded
  streamed-residency gates.
- `g4-direct-mtp-trace.json` records the direct
  `IDOT=0,SPEC_PIN=1` 64-token MTP trajectory and the exact tie-free acceptance
  prefix used as the cross-engine oracle.
- `g4-native-mtp-e2e.json` is the concise native-MTP on/off correctness,
  telemetry, footprint, and end-to-end performance record. Its raw
  separate-process reports remain gitignored and are bound by SHA-256.

Direct exact-pin captures are limited to:

- `quant_int8` and `quant_int4_grouped` outputs imported from the archived
  pinned Python converter with NumPy 2.4.6, including half-to-even and clipping
  unit vectors;
- Apple ARM64 outputs from the archived pinned `matmul_q` and
  `matmul_i4_grouped` functions, preserving their NEON reduction order;
- archived pinned `partial_select_desc` plus its production DSA threshold/tie
  scans;
- archived pinned LFRU score, admission, deterministic tie, uint32-age-wrap,
  and decay functions;
- elementary archived pinned `rmsnorm` and `sigmoidf` outputs used only as
  captured inputs to derived scaffolding.

The tiny dense SwiGLU/residual spine, top-8 router composition, LRU trace, and
greedy MTP state trace are `derived_canonical`, not executed Colibri model or
runtime outputs. Their purpose is to make the intended port shape testable
without falsely presenting locally reimplemented arithmetic as an oracle.

## Ordinary regeneration

Ordinary tests and regeneration do not require the external Colibri checkout,
Python, NumPy, clang, network access, or model weights. They consume the tracked
capture:

```sh
bun scripts/gen-colibri-glm52-fixtures.ts
```

To check observed reproducibility without touching the tracked package:

```sh
bun scripts/gen-colibri-glm52-fixtures.ts --out /tmp/colibri-glm52-a
bun scripts/gen-colibri-glm52-fixtures.ts --out /tmp/colibri-glm52-b
diff -ru /tmp/colibri-glm52-a /tmp/colibri-glm52-b
```

Byte identity is asserted for the recorded Bun 1.3.14 macOS ARM64 runtime. The
generator does not claim byte-identical JSON or `Math` behavior across arbitrary
Bun/JavaScript runtime versions.

## Explicit recapture

Recapture is separate and must use a clean checkout at the exact pin. The
capture script validates HEAD, porcelain, cached diff, and worktree diff before
creating a temporary `git archive`. It imports only the archived source and
compiles only inside that temporary tree:

```sh
bun scripts/capture-colibri-glm52-oracle.ts \
  --oracle /Users/joshrossi/Code/colibri \
  --python /Users/joshrossi/Code/mlx-lm/.venv/bin/python
```

The recorded run used existing NumPy 2.4.6 and Apple clang/libomp. No package
was installed, no file was downloaded, no model was loaded, and the external
checkout remained clean. Different target/toolchain captures must be reviewed
as new evidence rather than silently replacing the recorded constants.

## Scope boundary

The real-model oracle closes G0's teacher-forced GLM/MLA/router/MTP-head/KV
gap. The tiny `v1.json` MTP trace remains derived scaffolding and intentionally
does not claim coverage for every serving control path (EOS/special-stop,
length clamps, adaptive drafting, grammar precedence, or sampling rejection).
Those paths are exercised in later implementation gates against the direct
runtime trace rather than being mislabeled as model-free oracle output.
