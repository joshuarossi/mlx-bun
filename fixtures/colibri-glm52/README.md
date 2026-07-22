# Colibri GLM-5.2 G0 fixture scaffolding

This directory is a small, model-free starting contract for the MLX/Bun port.
It is pinned to Colibri commit
`44e489b196c9b7876b3d37a0570ebf1c6f90f54c`. It is not a complete GLM-5.2,
MLA, router, cache, or MTP oracle, and it does not complete G0 item 4.

Git is the authenticity and integrity root for these files. SHA-256 values in
`manifest.json` are reproducibility and accidental-drift checks, not signatures
and not a substitute for the recorded Git tree/blob identities.

## Files and provenance

- `oracle-capture.json` is immutable input to ordinary regeneration. It records
  the exact Colibri tree/blob hashes, archive/compile commands, helper hashes,
  Apple target, clang, Python, NumPy, and Bun versions used for the capture.
- `v1.json` combines the captured constants with explicitly labeled derived
  canonical traces.
- `manifest.json` describes the boundary and hashes both data files. Its former
  machine-local checkout path was removed; the absolute path retained in the
  capture evidence is explicitly advisory capture-host metadata required to
  reproduce the historical command transcript.

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

## Remaining gaps

There is still no teacher-forced numeric GLM/MLA/MTP-head/KV capture, complete
tiny MTP exporter, or measured neural acceptance oracle. The derived MTP trace
also does not capture EOS/special-stop handling, `n_new`/`max_t` length clamps,
the 24-proposal adaptive guard, grammar precedence, or sampling rejection.
Those gaps and the cleared-M1-Max-32-GB full-runtime baseline keep item 4 and G0
incomplete.
