# Colibri oracle pin for the native GLM-5.2 port

- Date recorded: 2026-07-21
- mlx-bun branch: `codex/colibri-glm52-port`
- Gate: Phase 21 G0, oracle inventory and model-free capture record

This note pins the external behavioral and performance oracle used by
[`colibri-glm52-port.md`](../design/colibri-glm52-port.md). It does not vendor,
embed, launch, or ship Colibri. The product remains a native Bun + MLX port.

## Pinned checkout

- Repository: `JustVugg/colibri`
- Local read-only checkout: `/Users/joshrossi/Code/colibri`
- Commit: `44e489b196c9b7876b3d37a0570ebf1c6f90f54c`
- Commit date: `2026-07-21T19:04:16+02:00`
- Commit subject: `Merge #479: CUDA env integration tests (COLI_CUDA modes + expert budget auto-size)`
- Branch at inspection: `main`
- Worktree at inspection: clean, including untracked files
- Ignored build stamp at inspection: `c/.build-config` absent

The checkout is an executable oracle for formats, token/logit behavior,
routing, cache traces, MTP accept/reject behavior, and same-machine
performance. It is not a source dependency. Any result must carry this exact
commit; `main`, `latest`, or an unrecorded later commit is not equivalent.

## License and attribution policy

The pinned repository contains the Apache License 2.0 in `LICENSE`. It contains
no tracked `NOTICE` or `COPYRIGHT` file.

The native port should reimplement the documented behavior and cite Colibri in
the design, user documentation, and third-party attribution. If code or other
copyrightable material is copied or closely derived, the distributed source
must also:

1. include a copy of Apache-2.0;
2. retain applicable copyright, patent, trademark, and attribution notices;
3. mark modified copied files prominently; and
4. reproduce any future upstream `NOTICE` content that applies to the copied
   material.

The Apache license does not grant trademark rights beyond customary
description of origin. Product naming and artwork are not part of the port.

## Public artifact and disk envelope

The pinned project recommends the public Hugging Face artifact
[`mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp`](https://huggingface.co/mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp).
It is the same-artifact oracle target for G0 and the initial native loader.

- Expected converted size: approximately 372 GB.
- G0 download-time floor: at least 400 GB actually free on fast local storage.
- Source conversion path: approximately 756 GB of network traffic, processed
  one roughly 5 GB source shard at a time; the growing output plus one source
  shard is retained, with a default 20 GB free-space stop margin.
- Previously measured disk preflight, not reverified by this item: about
  556 GB unallocated plus 123 GB purgeable, or about 679 GB practically
  available on the internal SSD on 2026-07-21.
- The artifact revision, complete file manifest, and checksums remain unpinned
  until the user performs the manual download. Record all three before using it
  as a release or reproducibility oracle.

The public mirror without the corrected MTP head is not an equivalent
artifact. The pinned README identifies the correct int8 MTP shard byte sizes
as:

| Shard | Expected bytes |
|---|---:|
| first `out-mtp-*` shard | 3,527,131,672 |
| second `out-mtp-*` shard | 5,366,238,584 |
| third `out-mtp-*` shard | 1,065,950,496 |

These sizes are a preflight signal, not a sufficient integrity check. The
native loader must validate the complete tensor set, names, dtypes, dimensions,
and byte counts before allocation.

## Snapshot metadata contract

Runtime-required and behaviorally material files are:

| File | Contract |
|---|---|
| `config.json` | Required; supplies model geometry, routing, MLA, DSA, and stop metadata. |
| `tokenizer.json` | Required for chat/serve; byte-level BPE vocabulary, merges, added tokens, and `special` flags are material. |
| `tokenizer_config.json` | Preserved by the converter; chat-template/tokenizer policy input for the native port. |
| `generation_config.json` | Optional to the C loader but authoritative for additional EOS IDs; its EOS set is unioned with `config.json`. |
| `*.safetensors` | Runtime indexes every safetensors file in the snapshot, independent of filename prefix, up to 512 shards. |
| `model.safetensors.index.json` | Used by selective conversion/download tooling; not required by the C runtime's directory scan. |

The native GLM config must cover at least:

- `hidden_size`, `num_hidden_layers`, `num_attention_heads`,
  `n_routed_experts`, `num_experts_per_tok`, `n_shared_experts`;
- `intermediate_size`, `moe_intermediate_size`,
  `first_k_dense_replace`;
- `q_lora_rank`, `kv_lora_rank`, `qk_nope_head_dim`,
  `qk_rope_head_dim`, `v_head_dim`;
- `n_group`, `topk_group`, `norm_topk_prob`,
  `routed_scaling_factor`;
- `rms_norm_eps`, RoPE parameters, `vocab_size`, and every EOS ID; and
- `index_topk`, `index_n_heads`, `index_head_dim`, plus either explicit
  `indexer_types` or the frequency/offset schedule.

GLM-5.2 requires `n_group=1` in the pinned engine. DSA is active only when the
indexer geometry is valid and every full-indexer layer has its required
weights. Missing DSA weights disable DSA; the native loader should report this
as a capability decision rather than silently implying full artifact parity.

## Tensor and shard layout contract

The converter emits three logical shard families:

- `out-*`: main model, including resident tensors and main routed experts;
- `out-mtp-*`: MTP layer at index `num_hidden_layers`; and
- `out-idx-*`: DSA lightning-indexer tensors.

The runtime itself keys tensors by name and scans all safetensors files, so the
prefixes are provenance and tooling conventions rather than routing semantics.

Quantized 2-D tensors are stored as:

- `<name>`: `U8` packed int8, int4, or int2 bytes; and
- `<name>.qs`: `F32` scales.

Per-row and grouped int4 use the same packed low/high-nibble weight bytes.
Grouped format is inferred from the scale-array byte count; group sizes in the
pinned detector are 16, 32, 48, 64, 96, 128, 192, or 256. Norms, the router,
one-dimensional biases, and `e_score_correction_bias` remain F32. The native
loader must derive and validate logical `[output,input]` dimensions from the
config and tensor role instead of trusting a flattened U8 payload.

For each routed expert, `gate_proj`, `up_proj`, and `down_proj` plus their
scales form one expert load. The converted layout is optimized so the three
weight matrices can be coalesced into one positioned read and exposed as views
inside an aligned slab; scales occupy a companion F32 slab. A loader may accept
a non-coalescible fixture for correctness, but the full artifact path must
preserve and verify the coalesced layout before claiming I/O parity.

The resident model includes embeddings, LM head, norms, MLA projections, the
first dense MLP layers, shared experts, and routers. Main routed experts remain
disk-backed and enter bounded resident slots on demand.

## Tokenizer and stop contract

The pinned tokenizer is byte-level BPE with `ignore_merges=true`, no byte
fallback, a cl100k-style regex split, and ByteLevel processing without an added
prefix space. `tokenizer.json` must provide `model.vocab` and `model.merges`.

All added tokens are atomic for encode/decode, but `special:true` has a separate
serving meaning: control tokens such as user/assistant/observation boundaries
must stop output, while real content markers such as thinking and tool-call
tokens may be `special:false` and must remain renderable. The native port must
union EOS IDs from config and generation config and apply the tokenizer's
control-token policy without swallowing content tokens.

## MTP artifact contract

MTP is a separate sparse layer at `model.layers.<num_hidden_layers>`. It is
usable only as a complete set. The pinned runtime's sentinel check covers
`eh_proj`, `enorm`, `hnorm`, `shared_head.norm`, attention, norms, router,
shared-expert tensors, and routed-expert endpoints; model initialization then
loads the complete MTP attention/shared/routed-expert family.

The main conversion skips MTP. A separate `--mtp` pass emits `out-mtp-*` and
defaults its resident and expert tensors to int8. Per-row int4 is not an
acceptable substitute: upstream measured roughly 0-4% MTP acceptance because
`eh_proj`'s asymmetric column scales zero its embedding half. The pinned source
reports roughly 39-59% acceptance at int8. Group-scaled int4 is a separate
research option, not the public oracle contract.

The native loader must therefore report MTP as active only after verifying the
complete int8 MTP set. MTP absence, partial shards, int4 dense MTP tensors, or a
scheduler mode that disables drafting must be visible in capability and runtime
telemetry.

## Safe model-free target inventory

No target in this section was executed while creating this note.

| Target | What it covers | Oracle-tree effect |
|---|---|---|
| `make -C c check` | Clean, portable CPU build, dependency-free C tests, Python stdlib tests. This is the upstream macOS CI gate. | Deletes/recreates ignored build outputs and writes a build stamp. |
| `make -C c metal-test` | Int8/int4/int2/F32 matmul, routed SwiGLU, large-batch GEMM, compressed MLA decode, cache writes, and an `S=4` MTP-shaped attention case. | Builds and executes `c/backend_metal_test`. |
| `python3 tools/convert_fp8_to_int4.py --selftest ...` | Model-free FP8 block-dequant check. | Intended to be output-free, but the pinned CLI needs a dummy `--repo` because it formats `None` before reaching the self-test return. |
| `python3 tools/convert_fp8_to_int4.py --selftest-nvfp4 ...` | Model-free NVFP4 decode/requant check. | Output-free when dependencies are present; same dummy-`--repo` issue. |

The checkout is a read-only oracle, but both Make targets mutate ignored files
and the Makefile creates `c/.build-config` during parsing. Do not run them in
place. G0 item 2 must extract the pinned commit to a temporary directory with
`git archive`, run both targets there, and capture output verbatim in this note.
That verifies the exact source without modifying the oracle checkout or its Git
metadata.

At inventory time, Apple clang 21, arm64 Xcode clang, GNU make, and Homebrew
libomp were present. System Python lacked Transformers, Torch, safetensors,
NumPy, and ml-dtypes. The mlx-lm oracle venv had Transformers 5.12,
safetensors, and NumPy, but lacked Torch and ml-dtypes.

## Tiny-fixture feasibility

Available from the pinned source without full GLM-5.2 weights:

- `make_glm_oracle.py`: seed-1234 tiny GLM-MoE with real MLA/DSA geometry,
  optional checkpoint-compatible FP8 emission, unfused per-expert tensors, and
  a 32-position teacher-forcing reference;
- `make_glm_bench_model.py`: deterministic medium model with configurable
  output directory and optional FP8 layout;
- local main and DSA conversion passes over those generated safetensors;
- deterministic synthetic expert layouts in the io_uring test;
- deterministic real-shape Metal matmul, routed-SwiGLU, and MLA fixtures; and
- `ROUTE_TRACE`, which emits per-position/per-layer expert IDs and gate weights
  without changing model computation.

Limitations that must stay explicit:

1. `make_glm_oracle.py` writes `glm_tiny/` and `ref_glm.json` into its current
   working directory. Run it from temporary storage, never the oracle checkout.
2. The generator requires Transformers >=5.11, Torch, and safetensors. The
   inspected Python environments do not currently satisfy that set; provisioning
   dependencies is a separate user-authorized decision. No package installation
   was performed for this inventory.
3. The generator does not produce `tokenizer.json`; token-ID teacher forcing is
   feasible, but chat-template parity needs a separately provenance-pinned
   tokenizer fixture.
4. The pinned project has no model-free generator for a complete native MTP
   layer. Its tiny generator covers GLM/MLA/DSA, not the layer-`n_layers` MTP
   tensor family. G0 cannot honestly claim the requested MTP fixture by merely
   exporting existing tooling. Add a deterministic derived fixture generator in
   mlx-bun from this pinned tensor contract, or explicitly extend a temporary
   copy of the generator; record that derivation in `fixtures/README.md`.
5. The synthetic expert/io_uring fixture is Linux-only. On macOS, use its
   recorded byte layout as provenance and validate the port through the Metal
   fixture and mlx-bun's eventual synthetic expert-file generator.

## Manual G0 baseline checklist

G0 remains incomplete until the user performs this work on the cleared M1 Max
32 GB machine. Agent sessions and CI must not perform it.

- [ ] Reverify at least 400 GB actually free on the target fast local disk;
      record `diskutil` unallocated and purgeable values with date and commands.
- [ ] Download the public artifact; record repository revision/commit, complete
      file manifest, byte sizes, and cryptographic checksums.
- [ ] Verify `config.json`, tokenizer metadata, generation metadata, main
      shards, complete DSA shards, and the three correct int8 MTP shards.
- [ ] Record machine model, chip, 32 GB memory, macOS/build versions, storage
      device/filesystem, Colibri commit, build flags, and all runtime settings.
- [ ] Ensure the machine is cleared and quiet; record competing processes,
      memory pressure, compression, and swap before each run.
- [ ] Run quality-preserving true top-8 defaults. Do not use expert top-p,
      reduced top-k, `CACHE_ROUTE`, or `EXPERT_BUDGET` for the baseline.
- [ ] Measure cold and warm runs with MTP disabled.
- [ ] Measure cold and warm runs with MTP enabled; record draft proposals,
      accepted/rejected tokens, acceptance length, tokens/forward, and whether
      the fixed draft/verify kernel-family contract is active.
- [ ] For every cell capture physical footprint, resident dense bytes,
      LRU/pin capacities, pin/LRU/miss hit split, disk bytes and disk service/
      wait time, TTFT, decode tokens/s, compression, and swap.
- [ ] Preserve prompts, seeds, generated token IDs/text, raw logs, and command
      lines. Report medians and run-to-run spread; do not quote loaded-machine
      or one-off numbers.
- [ ] Compare MTP-on and MTP-off wall time, not only tokens/forward.

This checklist is the G0 exit evidence. Completing this inventory, the
model-free targets, disk preflight, or fixtures alone does not satisfy G0.

## Provenance commands

Read-only commands used for the pin inspection:

```bash
git -C /Users/joshrossi/Code/colibri rev-parse HEAD
git -C /Users/joshrossi/Code/colibri branch --show-current
git -C /Users/joshrossi/Code/colibri status --porcelain=v1 --untracked-files=all
git -C /Users/joshrossi/Code/colibri log -1 --format='%H%n%ad%n%s' --date=iso-strict
git -C /Users/joshrossi/Code/colibri ls-files '*NOTICE*' '*COPYRIGHT*'
git -C /Users/joshrossi/Code/colibri diff --exit-code -- .
```

Required isolated execution pattern for the still-pending model-free suites:

```bash
COLIBRI_PIN=44e489b196c9b7876b3d37a0570ebf1c6f90f54c
COLIBRI_TMP="$(mktemp -d)"
git -C /Users/joshrossi/Code/colibri archive "$COLIBRI_PIN" | tar -x -C "$COLIBRI_TMP"
make -C "$COLIBRI_TMP/c" check
make -C "$COLIBRI_TMP/c" metal-test
```

Capture the complete output before removing the temporary directory. Do not
copy generated binaries back into either repository. G0 item 2 must append the
verbatim pass/fail output and toolchain versions here.


## Isolated model-free suite execution (2026-07-22)

G0 item 2 ran only against an archive of the pinned oracle. Before extraction,
the oracle checkout was exactly at
`44e489b196c9b7876b3d37a0570ebf1c6f90f54c`, with empty porcelain output
and both worktree and index diff checks returning 0. A user-owned
`mlx-bun get mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp` download was
active; no user training, inference, benchmark, Colibri test, or other
Bun/Python MLX compute process was active. This workflow did not start,
interrupt, or modify the download.

The source was extracted with `git archive` into the validated temporary
directory
`/var/folders/t3/bdj253f52sv60p_9rmzm86tr0000gn/T/colibri-g0-pin.XXXXXX.phRD7CaPU1`. It contained no `.git` metadata. Extracted source hashes matched
the pinned objects:

```text
c/Makefile  b14f9deaf67adc6285facff41914b4bc64089316c83711ae7c7e7dbb731c814a
c/glm.c     3be1b4dd663667c8fa2cfbbacdada3e545ff5f924737a0f5d058708d7bc5ad9d
```

Exact extraction and execution commands:

```bash
COLIBRI_PIN=44e489b196c9b7876b3d37a0570ebf1c6f90f54c
COLIBRI_TMP='/var/folders/t3/bdj253f52sv60p_9rmzm86tr0000gn/T/colibri-g0-pin.XXXXXX.phRD7CaPU1'
git -C /Users/joshrossi/Code/colibri archive "$COLIBRI_PIN" | tar -x -C "$COLIBRI_TMP"
make -C "$COLIBRI_TMP/c" check > "$COLIBRI_TMP/make-check.log" 2>&1
make -C "$COLIBRI_TMP/c" metal-test > "$COLIBRI_TMP/make-metal-test.log" 2>&1
```

Recorded toolchain and relevant environment:

```text
date=2026-07-22T05:03:16Z
uname=Darwin Joshs-MacBook-Pro-2.local 25.5.0 Darwin Kernel Version 25.5.0: Tue Jun  9 22:18:58 PDT 2026; root:xnu-12377.121.10~1/RELEASE_ARM64_T6000 arm64
macos_product=macOS 26.5.2 build 25F84
chip=Apple M1 Max
memory_bytes=34359738368
arch=arm64
xcode=Xcode 26.6;Build version 17F113
clang_path=/usr/bin/clang
clang_version=Apple clang version 21.0.0 (clang-2100.1.1.101)
clang_version=Target: arm64-apple-darwin25.5.0
clang_version=Thread model: posix
clang_version=InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
clangxx_path=/usr/bin/clang++
clangxx_version=Apple clang version 21.0.0 (clang-2100.1.1.101)
clangxx_version=Target: arm64-apple-darwin25.5.0
clangxx_version=Thread model: posix
clangxx_version=InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
make_path=/usr/bin/make
make_version=GNU Make 3.81
make_version=Copyright (C) 2006  Free Software Foundation, Inc.
make_version=This is free software; see the source for copying conditions.
make_version=There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
make_version=PARTICULAR PURPOSE.
make_version=
make_version=This program built for i386-apple-darwin11.3.0
python_path=/usr/bin/python3
python_version=Python 3.9.6
sdk_path=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
relevant_environment:
oracle_pin=44e489b196c9b7876b3d37a0570ebf1c6f90f54c
oracle_pre_status=clean
workload_precheck=user mlx-bun get active; no bun/python training, inference, benchmark, or Metal test process
extraction=/var/folders/t3/bdj253f52sv60p_9rmzm86tr0000gn/T/colibri-g0-pin.XXXXXX.phRD7CaPU1
extracted_git_metadata=absent
makefile_sha256=b14f9deaf67adc6285facff41914b4bc64089316c83711ae7c7e7dbb731c814a
glm_c_sha256=3be1b4dd663667c8fa2cfbbacdada3e545ff5f924737a0f5d058708d7bc5ad9d
```

### `make check`

Complete combined stdout/stderr, verbatim:

```text
/Applications/Xcode.app/Contents/Developer/usr/bin/make clean
python3 tools/clean.py
clean: removed 0 files/dirs
/Applications/Xcode.app/Contents/Developer/usr/bin/make portable
/Applications/Xcode.app/Contents/Developer/usr/bin/make glm ARCH=
make[2]: Circular glm <- glm dependency dropped.
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function glm.c   -o glm -lm -L/opt/homebrew/opt/libomp/lib -lomp
/Applications/Xcode.app/Contents/Developer/usr/bin/make test
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_json.c -o tests/test_json -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_st.c -o tests/test_st -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function -DST_PREAD_CHUNK=7 tests/test_st_pread.c -o tests/test_st_pread -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_tier.c -o tests/test_tier -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_grammar.c -o tests/test_grammar -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_schema_gbnf.c -o tests/test_schema_gbnf -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_decode_batch.c -o tests/test_decode_batch -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_idot.c -o tests/test_idot -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_i4_grouped.c -o tests/test_i4_grouped -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_stops.c -o tests/test_stops -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_topp.c -o tests/test_topp -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_sample_nan.c -o tests/test_sample_nan -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_kv_alloc.c -o tests/test_kv_alloc -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_i4_acc512.c -o tests/test_i4_acc512 -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_compat_direct.c -o tests/test_compat_direct -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_dsa_select.c -o tests/test_dsa_select -lm -L/opt/homebrew/opt/libomp/lib -lomp
clang -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -Wall -Wextra -Wno-unused-parameter -Wno-misleading-indentation -Wno-unused-function tests/test_logit_nan.c -o tests/test_logit_nan -lm -L/opt/homebrew/opt/libomp/lib -lomp
python3 tools/run_tests.py tests/test_json tests/test_st tests/test_st_pread tests/test_tier tests/test_grammar tests/test_schema_gbnf tests/test_decode_batch tests/test_idot tests/test_i4_grouped tests/test_stops tests/test_topp tests/test_sample_nan tests/test_kv_alloc tests/test_i4_acc512 tests/test_compat_direct tests/test_dsa_select tests/test_logit_nan
json tests: ok
safetensors primitive tests: ok
test_st_pread: chunk loop + honest truncation error: ok
tier tests: ok
test_grammar: ok
test_schema_gbnf: OK
decode batch helper tests: ok
idot kernel exactness (neon): ok
idot driver exactness (neon): ok
test_i4_grouped: matmul_i4_grouped vs plain-C dequant reference
  gs=64, I multiple of gs                    ok (S=2 I=512 O=8 gs=64 ng=8, worst rel 3.1e-08)
  gs=64, single row single token             ok (S=1 I=128 O=1 gs=64 ng=2, worst rel 9.6e-09)
  gs=64, nibble edges (0x00/0xFF)            ok (S=1 I=256 O=4 gs=64 ng=4, worst rel 2.6e-08)
  gs=64, partial last group (I=200)          ok (S=2 I=200 O=4 gs=64 ng=4, worst rel 2e-08)
  gs=64, I just over a group (I=65)          ok (S=1 I=65 O=3 gs=64 ng=2, worst rel 2e-08)
  gs=64, I one under a group (I=63)          ok (S=1 I=63 O=3 gs=64 ng=1, worst rel 2.4e-08)
  gs=64, odd I (I=201)                       ok (S=2 I=201 O=4 gs=64 ng=4, worst rel 1.5e-08)
  gs=16, odd I (I=33)                        ok (S=1 I=33 O=2 gs=16 ng=3, worst rel 2.2e-08)
  gs=128 > I=64 (single group)               ok (S=1 I=64 O=4 gs=128 ng=1, worst rel 4.5e-08)
  gs=128, I multiple of gs                   ok (S=2 I=512 O=4 gs=128 ng=4, worst rel 3.7e-08)
  gs=64, batch S=8                           ok (S=8 I=320 O=6 gs=64 ng=5, worst rel 7.9e-08)
test_i4_grouped: ok
[stop] 5 stop tokens: 100 101 102 103 104 (4 from the tokenizer's special set)
[stop] 1 stop tokens: 100
test_stops: stop arming vs incomplete checkpoint metadata
  tokenizer: special flag parsed, <think>/<tool_call> excluded   ok
  config eos=[100] + generation_config=[100,101,102] -> 3 stops   ok
  generation_config.json absent -> config alone, no crash   ok
  both configs mutilated -> tokenizer still stops all 5 control tokens   ok
  T=NULL -> config stops only (validation path untouched)   ok
test_stops: ok
  ok [V=1 nuc=0.001 shape=uniform keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.500 shape=uniform keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.900 shape=uniform keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.999 shape=uniform keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.001 shape=peaked keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.500 shape=peaked keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.900 shape=peaked keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.999 shape=peaked keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.001 shape=geometric keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.500 shape=geometric keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.900 shape=geometric keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.999 shape=geometric keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.001 shape=plateau keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.500 shape=plateau keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.900 shape=plateau keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.999 shape=plateau keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.001 shape=sharptail keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.500 shape=sharptail keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.900 shape=sharptail keep=1 sum=1.0000000000]
  ok [V=1 nuc=0.999 shape=sharptail keep=1 sum=1.0000000000]
  ok [V=2 nuc=0.001 shape=uniform keep=1 (ties) sum=1.0000000000]
  ok [V=2 nuc=0.500 shape=uniform keep=1 (ties) sum=1.0000000000]
  ok [V=2 nuc=0.900 shape=uniform keep=2 (ties) sum=1.0000000000]
  ok [V=2 nuc=0.999 shape=uniform keep=2 (ties) sum=1.0000000000]
  ok [V=2 nuc=0.001 shape=peaked keep=1 sum=1.0000000000]
  ok [V=2 nuc=0.500 shape=peaked keep=1 sum=1.0000000000]
  ok [V=2 nuc=0.900 shape=peaked keep=2 sum=0.9999999702]
  ok [V=2 nuc=0.999 shape=peaked keep=2 sum=0.9999999702]
  ok [V=2 nuc=0.001 shape=geometric keep=1 sum=1.0000000000]
  ok [V=2 nuc=0.500 shape=geometric keep=1 sum=1.0000000000]
  ok [V=2 nuc=0.900 shape=geometric keep=2 sum=1.0000000000]
  ok [V=2 nuc=0.999 shape=geometric keep=2 sum=1.0000000000]
  ok [V=2 nuc=0.001 shape=plateau keep=1 (ties) sum=1.0000000000]
  ok [V=2 nuc=0.500 shape=plateau keep=1 (ties) sum=1.0000000000]
  ok [V=2 nuc=0.900 shape=plateau keep=2 (ties) sum=1.0000000000]
  ok [V=2 nuc=0.999 shape=plateau keep=2 (ties) sum=1.0000000000]
  ok [V=2 nuc=0.001 shape=sharptail keep=1 sum=1.0000000000]
  ok [V=2 nuc=0.500 shape=sharptail keep=1 sum=1.0000000000]
  ok [V=2 nuc=0.900 shape=sharptail keep=2 sum=1.0000000000]
  ok [V=2 nuc=0.999 shape=sharptail keep=2 sum=1.0000000000]
  ok [V=8 nuc=0.001 shape=uniform keep=1 (ties) sum=1.0000000000]
  ok [V=8 nuc=0.500 shape=uniform keep=4 (ties) sum=1.0000000000]
  ok [V=8 nuc=0.900 shape=uniform keep=8 (ties) sum=1.0000000000]
  ok [V=8 nuc=0.999 shape=uniform keep=8 (ties) sum=1.0000000000]
  ok [V=8 nuc=0.001 shape=peaked keep=1 sum=1.0000000000]
  ok [V=8 nuc=0.500 shape=peaked keep=1 sum=1.0000000000]
  ok [V=8 nuc=0.900 shape=peaked keep=1 sum=1.0000000000]
  ok [V=8 nuc=0.999 shape=peaked keep=5 sum=0.9999999900]
  ok [V=8 nuc=0.001 shape=geometric keep=1 sum=1.0000000000]
  ok [V=8 nuc=0.500 shape=geometric keep=4 sum=1.0000000447]
  ok [V=8 nuc=0.900 shape=geometric keep=8 sum=1.0000000000]
  ok [V=8 nuc=0.999 shape=geometric keep=8 sum=1.0000000000]
  ok [V=8 nuc=0.001 shape=plateau keep=1 (ties) sum=1.0000000000]
  ok [V=8 nuc=0.500 shape=plateau keep=4 (ties) sum=1.0000000000]
  ok [V=8 nuc=0.900 shape=plateau keep=7 (ties) sum=1.0000000447]
  ok [V=8 nuc=0.999 shape=plateau keep=8 (ties) sum=1.0000000075]
  ok [V=8 nuc=0.001 shape=sharptail keep=1 sum=1.0000000000]
  ok [V=8 nuc=0.500 shape=sharptail keep=3 sum=1.0000000149]
  ok [V=8 nuc=0.900 shape=sharptail keep=7 sum=0.9999999776]
  ok [V=8 nuc=0.999 shape=sharptail keep=8 sum=1.0000000075]
  ok [V=64 nuc=0.001 shape=uniform keep=1 (ties) sum=1.0000000000]
  ok [V=64 nuc=0.500 shape=uniform keep=32 (ties) sum=1.0000000000]
  ok [V=64 nuc=0.900 shape=uniform keep=58 (ties) sum=0.9999999963]
  ok [V=64 nuc=0.999 shape=uniform keep=64 (ties) sum=1.0000000000]
  ok [V=64 nuc=0.001 shape=peaked keep=1 sum=1.0000000000]
  ok [V=64 nuc=0.500 shape=peaked keep=1 sum=1.0000000000]
  ok [V=64 nuc=0.900 shape=peaked keep=2 sum=1.0000000186]
  ok [V=64 nuc=0.999 shape=peaked keep=39 sum=0.9999999860]
  ok [V=64 nuc=0.001 shape=geometric keep=1 sum=1.0000000000]
  ok [V=64 nuc=0.500 shape=geometric keep=32 sum=1.0000000149]
  ok [V=64 nuc=0.900 shape=geometric keep=58 sum=0.9999999814]
  ok [V=64 nuc=0.999 shape=geometric keep=64 sum=0.9999999879]
  ok [V=64 nuc=0.001 shape=plateau keep=1 (ties) sum=1.0000000000]
  ok [V=64 nuc=0.500 shape=plateau keep=5 (ties) sum=1.0000000149]
  ok [V=64 nuc=0.900 shape=plateau keep=13 (ties) sum=0.9999999702]
  ok [V=64 nuc=0.999 shape=plateau keep=35 (ties) sum=0.9999999879]
  ok [V=64 nuc=0.001 shape=sharptail keep=1 (ties) sum=1.0000000000]
  ok [V=64 nuc=0.500 shape=sharptail keep=4 (ties) sum=1.0000000596]
  ok [V=64 nuc=0.900 shape=sharptail keep=10 (ties) sum=0.9999999925]
  ok [V=64 nuc=0.999 shape=sharptail keep=12 (ties) sum=0.9999999925]
  ok [V=257 nuc=0.001 shape=uniform keep=1 (ties) sum=1.0000000000]
  ok [V=257 nuc=0.500 shape=uniform keep=129 (ties) sum=1.0000000563]
  ok [V=257 nuc=0.900 shape=uniform keep=232 (ties) sum=0.9999999963]
  ok [V=257 nuc=0.999 shape=uniform keep=257 (ties) sum=0.9999999998]
  ok [V=257 nuc=0.001 shape=peaked keep=1 sum=1.0000000000]
  ok [V=257 nuc=0.500 shape=peaked keep=1 sum=1.0000000000]
  ok [V=257 nuc=0.900 shape=peaked keep=11 sum=0.9999999867]
  ok [V=257 nuc=0.999 shape=peaked keep=203 sum=0.9999999721]
  ok [V=257 nuc=0.001 shape=geometric keep=1 sum=1.0000000000]
  ok [V=257 nuc=0.500 shape=geometric keep=117 sum=0.9999999702]
  ok [V=257 nuc=0.900 shape=geometric keep=227 sum=0.9999999774]
  ok [V=257 nuc=0.999 shape=geometric keep=257 sum=0.9999999749]
  ok [V=257 nuc=0.001 shape=plateau keep=1 (ties) sum=1.0000000000]
  ok [V=257 nuc=0.500 shape=plateau keep=5 (ties) sum=0.9999999404]
  ok [V=257 nuc=0.900 shape=plateau keep=13 (ties) sum=0.9999999590]
  ok [V=257 nuc=0.999 shape=plateau keep=35 (ties) sum=0.9999999854]
  ok [V=257 nuc=0.001 shape=sharptail keep=1 (ties) sum=1.0000000000]
  ok [V=257 nuc=0.500 shape=sharptail keep=5 (ties) sum=0.9999999553]
  ok [V=257 nuc=0.900 shape=sharptail keep=10 (ties) sum=0.9999999851]
  ok [V=257 nuc=0.999 shape=sharptail keep=12 (ties) sum=0.9999999925]
  ok [V=1519 nuc=0.001 shape=uniform keep=2 (ties) sum=1.0000000000]
  ok [V=1519 nuc=0.500 shape=uniform keep=760 (ties) sum=1.0000000428]
  ok [V=1519 nuc=0.900 shape=uniform keep=1368 (ties) sum=1.0000000075]
  ok [V=1519 nuc=0.999 shape=uniform keep=1518 (ties) sum=1.0000000106]
  ok [V=1519 nuc=0.001 shape=peaked keep=1 sum=1.0000000000]
  ok [V=1519 nuc=0.500 shape=peaked keep=1 sum=1.0000000000]
  ok [V=1519 nuc=0.900 shape=peaked keep=404 sum=0.9999999575]
  ok [V=1519 nuc=0.999 shape=peaked keep=1380 sum=1.0000000113]
  ok [V=1519 nuc=0.001 shape=geometric keep=1 sum=1.0000000000]
  ok [V=1519 nuc=0.500 shape=geometric keep=410 sum=1.0000000135]
  ok [V=1519 nuc=0.900 shape=geometric keep=1118 sum=0.9999999862]
  ok [V=1519 nuc=0.999 shape=geometric keep=1514 sum=1.0000000146]
  ok [V=1519 nuc=0.001 shape=plateau keep=1 (ties) sum=1.0000000000]
  ok [V=1519 nuc=0.500 shape=plateau keep=5 (ties) sum=0.9999999404]
  ok [V=1519 nuc=0.900 shape=plateau keep=13 (ties) sum=0.9999999590]
  ok [V=1519 nuc=0.999 shape=plateau keep=35 (ties) sum=0.9999999854]
  ok [V=1519 nuc=0.001 shape=sharptail keep=1 (ties) sum=1.0000000000]
  ok [V=1519 nuc=0.500 shape=sharptail keep=5 (ties) sum=1.0000000149]
  ok [V=1519 nuc=0.900 shape=sharptail keep=10 (ties) sum=0.9999999702]
  ok [V=1519 nuc=0.999 shape=sharptail keep=12 (ties) sum=1.0000000186]
  ok [guard-off nuc=1.0 keep=256]
  ok [guard-off nuc=0.0 keep=256]
  ok [V=1 keep=1]

test_topp: 123 cases run, 0 failure(s)
test_topp: ok
[SAMPLE] warning: non-finite logits (NaN/Inf) — falling back to argmax; output may be degraded. This usually means a numerical blow-up upstream.
  logit sani: distribuzione valida, picco vivo            ok
  NaN/+Inf iniettato: argmax dei finiti vince, mai 0/NaN   ok
  tutti non-finiti: nessun crash, buffer valido               ok
test_sample_nan: ok
OK kv_alloc re-allocation
test_i4_acc512: skipped (no AVX-512 on this build)
compat direct tests: skipped (POSIX has native O_DIRECT)
  ok [nk=1 keep=1 shape=random]
  ok [nk=1 keep=1 shape=peaked]
  ok [nk=1 keep=1 shape=decreasing]
  ok [nk=1 keep=1 shape=increasing]
  ok [nk=1 keep=1 shape=plateau]
  ok [nk=1 keep=1 shape=all-equal]
  ok [nk=2 keep=1 shape=random]
  ok [nk=2 keep=1 shape=peaked]
  ok [nk=2 keep=1 shape=decreasing]
  ok [nk=2 keep=1 shape=increasing]
  ok [nk=2 keep=1 shape=plateau]
  ok [nk=2 keep=1 shape=all-equal]
  ok [nk=8 keep=1 shape=random]
  ok [nk=8 keep=8 shape=random]
  ok [nk=8 keep=1 shape=peaked]
  ok [nk=8 keep=8 shape=peaked]
  ok [nk=8 keep=1 shape=decreasing]
  ok [nk=8 keep=8 shape=decreasing]
  ok [nk=8 keep=1 shape=increasing]
  ok [nk=8 keep=8 shape=increasing]
  ok [nk=8 keep=1 shape=plateau]
  ok [nk=8 keep=8 shape=plateau]
  ok [nk=8 keep=1 shape=all-equal]
  ok [nk=8 keep=8 shape=all-equal]
  ok [nk=64 keep=1 shape=random]
  ok [nk=64 keep=8 shape=random]
  ok [nk=64 keep=1 shape=peaked]
  ok [nk=64 keep=8 shape=peaked]
  ok [nk=64 keep=1 shape=decreasing]
  ok [nk=64 keep=8 shape=decreasing]
  ok [nk=64 keep=1 shape=increasing]
  ok [nk=64 keep=8 shape=increasing]
  ok [nk=64 keep=1 shape=plateau]
  ok [nk=64 keep=8 shape=plateau]
  ok [nk=64 keep=1 shape=all-equal]
  ok [nk=64 keep=8 shape=all-equal]
  ok [nk=2049 keep=1 shape=random]
  ok [nk=2049 keep=8 shape=random]
  ok [nk=2049 keep=256 shape=random]
  ok [nk=2049 keep=1024 shape=random]
  ok [nk=2049 keep=2048 shape=random]
  ok [nk=2049 keep=1 shape=peaked]
  ok [nk=2049 keep=8 shape=peaked]
  ok [nk=2049 keep=256 shape=peaked]
  ok [nk=2049 keep=1024 shape=peaked]
  ok [nk=2049 keep=2048 shape=peaked]
  ok [nk=2049 keep=1 shape=decreasing]
  ok [nk=2049 keep=8 shape=decreasing]
  ok [nk=2049 keep=256 shape=decreasing]
  ok [nk=2049 keep=1024 shape=decreasing]
  ok [nk=2049 keep=2048 shape=decreasing]
  ok [nk=2049 keep=1 shape=increasing]
  ok [nk=2049 keep=8 shape=increasing]
  ok [nk=2049 keep=256 shape=increasing]
  ok [nk=2049 keep=1024 shape=increasing]
  ok [nk=2049 keep=2048 shape=increasing]
  ok [nk=2049 keep=1 shape=plateau]
  ok [nk=2049 keep=8 shape=plateau]
  ok [nk=2049 keep=256 shape=plateau]
  ok [nk=2049 keep=1024 shape=plateau]
  ok [nk=2049 keep=2048 shape=plateau]
  ok [nk=2049 keep=1 shape=all-equal]
  ok [nk=2049 keep=8 shape=all-equal]
  ok [nk=2049 keep=256 shape=all-equal]
  ok [nk=2049 keep=1024 shape=all-equal]
  ok [nk=2049 keep=2048 shape=all-equal]
  ok [nk=4097 keep=1 shape=random]
  ok [nk=4097 keep=8 shape=random]
  ok [nk=4097 keep=256 shape=random]
  ok [nk=4097 keep=1024 shape=random]
  ok [nk=4097 keep=2048 shape=random]
  ok [nk=4097 keep=1 shape=peaked]
  ok [nk=4097 keep=8 shape=peaked]
  ok [nk=4097 keep=256 shape=peaked]
  ok [nk=4097 keep=1024 shape=peaked]
  ok [nk=4097 keep=2048 shape=peaked]
  ok [nk=4097 keep=1 shape=decreasing]
  ok [nk=4097 keep=8 shape=decreasing]
  ok [nk=4097 keep=256 shape=decreasing]
  ok [nk=4097 keep=1024 shape=decreasing]
  ok [nk=4097 keep=2048 shape=decreasing]
  ok [nk=4097 keep=1 shape=increasing]
  ok [nk=4097 keep=8 shape=increasing]
  ok [nk=4097 keep=256 shape=increasing]
  ok [nk=4097 keep=1024 shape=increasing]
  ok [nk=4097 keep=2048 shape=increasing]
  ok [nk=4097 keep=1 shape=plateau]
  ok [nk=4097 keep=8 shape=plateau]
  ok [nk=4097 keep=256 shape=plateau]
  ok [nk=4097 keep=1024 shape=plateau]
  ok [nk=4097 keep=2048 shape=plateau]
  ok [nk=4097 keep=1 shape=all-equal]
  ok [nk=4097 keep=8 shape=all-equal]
  ok [nk=4097 keep=256 shape=all-equal]
  ok [nk=4097 keep=1024 shape=all-equal]
  ok [nk=4097 keep=2048 shape=all-equal]
  ok [nk=8193 keep=1 shape=random]
  ok [nk=8193 keep=8 shape=random]
  ok [nk=8193 keep=256 shape=random]
  ok [nk=8193 keep=1024 shape=random]
  ok [nk=8193 keep=2048 shape=random]
  ok [nk=8193 keep=1 shape=peaked]
  ok [nk=8193 keep=8 shape=peaked]
  ok [nk=8193 keep=256 shape=peaked]
  ok [nk=8193 keep=1024 shape=peaked]
  ok [nk=8193 keep=2048 shape=peaked]
  ok [nk=8193 keep=1 shape=decreasing]
  ok [nk=8193 keep=8 shape=decreasing]
  ok [nk=8193 keep=256 shape=decreasing]
  ok [nk=8193 keep=1024 shape=decreasing]
  ok [nk=8193 keep=2048 shape=decreasing]
  ok [nk=8193 keep=1 shape=increasing]
  ok [nk=8193 keep=8 shape=increasing]
  ok [nk=8193 keep=256 shape=increasing]
  ok [nk=8193 keep=1024 shape=increasing]
  ok [nk=8193 keep=2048 shape=increasing]
  ok [nk=8193 keep=1 shape=plateau]
  ok [nk=8193 keep=8 shape=plateau]
  ok [nk=8193 keep=256 shape=plateau]
  ok [nk=8193 keep=1024 shape=plateau]
  ok [nk=8193 keep=2048 shape=plateau]
  ok [nk=8193 keep=1 shape=all-equal]
  ok [nk=8193 keep=8 shape=all-equal]
  ok [nk=8193 keep=256 shape=all-equal]
  ok [nk=8193 keep=1024 shape=all-equal]
  ok [nk=8193 keep=2048 shape=all-equal]
  ok [keep==nk nk=100]
  ok [keep==1 argmax=19]
  ok [all-equal keep=500 -> positions 0..499]

test_dsa_select: 129 cases run, 0 failure(s)
test_dsa_select: ok
[SAMPLE] warning: non-finite logits (NaN/Inf) — falling back to argmax; output may be degraded. This usually means a numerical blow-up upstream.
OK test_logit_nan: argmax_v NaN-skip + dist_build finite-collapse
python3 -m unittest discover -s tests -p 'test_*.py'
......ss.sss........................[api] 127.0.0.1 - "OPTIONS /v1/chat/completions HTTP/1.1" 204 -
.[api] 127.0.0.1 - "POST /v1/chat/completions HTTP/1.1" 200 -
.[api] 127.0.0.1 - "GET /health HTTP/1.1" 200 -
.[api] 127.0.0.1 - "POST /v1/completions HTTP/1.1" 200 -
.[api] 127.0.0.1 - "GET /v1/models HTTP/1.1" 200 -
[api] 127.0.0.1 - "GET /v1/models HTTP/1.1" 401 -
.[api] 127.0.0.1 - "GET /profile HTTP/1.1" 200 -
[api] 127.0.0.1 - "GET /profile HTTP/1.1" 200 -
.[api] 127.0.0.1 - "POST /v1/completions HTTP/1.1" 400 -
.[api] 127.0.0.1 - "POST /v1/chat/completions HTTP/1.1" 400 -
.[api] 127.0.0.1 - "POST /v1/chat/completions HTTP/1.1" 400 -
.[api] 127.0.0.1 - "POST /v1/chat/completions HTTP/1.1" 200 -
....[api] 127.0.0.1 - "POST /v1/chat/completions HTTP/1.1" 429 -
[api] 127.0.0.1 - "POST /v1/chat/completions HTTP/1.1" 200 -
......[api] 127.0.0.1 - "GET / HTTP/1.1" 200 -
[api] 127.0.0.1 - "GET /%2e%2e/dist-private/secret.txt HTTP/1.1" 404 -
.....[api] tool-calls: 1 total, 1 strict, 0 de-mangled [CLEAN]
.[api] tool-calls: 1 total, 1 strict, 0 de-mangled [CLEAN]
.[api] tool-calls: 1 total, 1 strict, 0 de-mangled [CLEAN]
.......................
----------------------------------------------------------------------
Ran 84 tests in 5.427s

OK (skipped=5)
```

Exit status: `0`.

### `make metal-test`

A second workload check immediately before this command found the same
user-owned download and no user training, inference, benchmark, Colibri test,
or other Bun/Python MLX compute process.

Complete combined stdout/stderr, verbatim:

```text
clang++ -x objective-c++ -std=gnu++17 -fobjc-arc -O3 tests/test_backend_metal.mm backend_metal.mm -framework Metal -framework Foundation -o backend_metal_test
./backend_metal_test
Metal backend kernel tests:
  int8 gate/up S=1       nerr=2.36e-06  ok
  int4 gate/up S=1       nerr=1.98e-06  ok
  int4 down S=1          nerr=1.03e-06  ok
  int2 gate/up S=1       nerr=1.72e-06  ok
  f32  S=1               nerr=1.77e-06  ok
  int8 gate/up S=4       nerr=2.36e-06  ok
  int4 gate/up S=7 (odd) nerr=1.98e-06  ok
  int4 non-mult-4 dims   nerr=3.78e-06  ok
Metal batched moe_block tests:
  moe decode nb=8        R=8 nerr=2.53e-06  ok
  moe ragged nb=6        R=16 nerr=2.45e-06  ok
Metal large-batch gemm test:
  gemm S=64 int4          nerr=2.85e-06  ok
Metal fused attention tests:
  attn S=1 pos=0           nerr=4.04e-06 cache=1.38e-05  ok
  attn S=1 pos=37          nerr=4.19e-06 cache=1.24e-05  ok
  attn S=4 pos=12 (MTP)    nerr=5.33e-06 cache=1.34e-05  ok
  attn S=3 pos=0           nerr=5.30e-06 cache=1.31e-05  ok
metal backend tests: ok
```

Exit status: `0`.

### Oracle postcondition

At `2026-07-22T05:06:07Z`, after both suites completed:

```text
HEAD=44e489b196c9b7876b3d37a0570ebf1c6f90f54c
status --short: <empty>
git diff --quiet exit status: 0
git diff --cached --quiet exit status: 0
```

No build, test, or mutating command was run from the oracle checkout, no
generated artifact was copied back, and no file in that checkout was changed.

## Target-machine disk preflight — in-progress snapshot

This is a **moving snapshot, not the final stable G0 disk baseline**. A
user-owned artifact download was already active throughout the measurement:

```text
46623 Tue Jul 21 23:00:44 2026           08:37 bun /Users/joshrossi/.bun/bin/mlx-bun get mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp
```

The process was observed only. It was not stopped, signalled, reprioritized, or
otherwise altered. No snapshot was deleted and no space was purged. Capacity
therefore continued to change while these commands ran; repeat this preflight
after the download settles and before recording the full-model baseline.

### Timestamp and target identity

Command:

```sh
date '+%Y-%m-%dT%H:%M:%S%z (%Z)'
system_profiler SPHardwareDataType 2>/dev/null | awk '/Model Name:|Model Identifier:|Chip:|Total Number of Cores:|Memory:/{print}'
sw_vers
sysctl -n hw.memsize
readlink /etc/localtime
mount | awk '$3 == "/" {print}'
```

Output:

```text
2026-07-21T23:09:50-0600 (CST)
      Model Name: MacBook Pro
      Model Identifier: MacBookPro18,2
      Chip: Apple M1 Max
      Total Number of Cores: 10 (8 Performance and 2 Efficiency)
      Memory: 32 GB
ProductName:		macOS
ProductVersion:		26.5.2
BuildVersion:		25F84
34359738368
/var/db/timezone/zoneinfo/America/El_Salvador
/dev/disk3s3s1 on / (apfs, sealed, local, read-only, journaled)
```

The qualifying machine is therefore the plan's M1 Max MacBook Pro with 32 GiB
physical memory, running macOS 26.5.2 in the America/El_Salvador timezone. The
root is the sealed APFS system snapshot; the writable artifact data resides in
the same APFS container through `/System/Volumes/Data`.

### Filesystem capacity

Measurement window: `2026-07-21T23:09:20-0600` through
`2026-07-21T23:09:21-0600` (CST, America/El_Salvador).

Commands:

```sh
df -h /
df -k /
df -h /System/Volumes/Data
df -k /System/Volumes/Data
```

Output:

```text
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s3s1   926Gi    12Gi   506Gi     3%    459k  4.3G    0%   /
Filesystem     1024-blocks      Used Available Capacity iused      ifree %iused  Mounted on
/dev/disk3s3s1   971350180  12270752 531096252     3%  458726 4293644559    0%   /
Filesystem      Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s1   926Gi   398Gi   506Gi    45%    4.5M  5.3G    0%   /System/Volumes/Data
Filesystem   1024-blocks      Used Available Capacity iused      ifree %iused  Mounted on
/dev/disk3s1   971350180 417631284 531096252    45% 4512220 5310962520    0%   /System/Volumes/Data
```

The System and Data volumes share the same 506 GiB available APFS-container
capacity; their different `Used` columns reflect volume roles and are not
additive.

Relevant `diskutil apfs list` command and filtered output:

```sh
diskutil apfs list | awk '/Container disk3 /{show=1} show && /APFS Container Reference:|Size \\(Capacity Ceiling\\):|Capacity In Use By Volumes:|Capacity Not Allocated:|Physical Store Disk:|Mount Point:|Capacity Consumed:/{print}'
```

```text
    APFS Container Reference:     disk3
    Size (Capacity Ceiling):      994662584320 B (994.7 GB)
    Capacity In Use By Volumes:   450821074944 B (450.8 GB) (45.3% used)
    Capacity Not Allocated:       543841509376 B (543.8 GB) (54.7% free)
    |   APFS Physical Store Disk:   disk0s2
    |   Mount Point:               /System/Volumes/Data
    |   Capacity Consumed:         427655487488 B (427.7 GB)
    |   Mount Point:               Not Mounted
    |   Capacity Consumed:         12565250048 B (12.6 GB)
    |   Snapshot Mount Point:      /
    |   Mount Point:               /System/Volumes/Preboot
    |   Capacity Consumed:         9037856768 B (9.0 GB)
    |   Mount Point:               Not Mounted
    |   Capacity Consumed:         1308078080 B (1.3 GB)
        Mount Point:               /System/Volumes/VM
        Capacity Consumed:         20480 B (20.5 KB)
```

Relevant writable-volume identity from `diskutil info
/System/Volumes/Data`:

```text
   Device Identifier:         disk3s1
   Volume Name:               Macintosh HD - Data
   Mount Point:               /System/Volumes/Data
   File System Personality:   APFS
   Container Total Space:     994.7 GB (994662584320 Bytes) (exactly 1942700360 512-Byte-Units)
   Container Free Space:      543.8 GB (543841349632 Bytes) (exactly 1062190136 512-Byte-Units)
   Device Location:           Internal
   Solid State:               Yes
```

### Purgeable and snapshot evidence

Foundation's read-only APFS capacity keys were queried because `df` and
`diskutil apfs list` expose hard unallocated capacity but do not report one
stable scalar named “purgeable”:

```sh
osascript -l JavaScript -e 'ObjC.import("Foundation"); const u=$.NSURL.fileURLWithPath("/"); function g(k){const v=Ref(); const e=Ref(); if(!u.getResourceValueForKeyError(v,k,e)) return "error"; return ObjC.unwrap(v[0]);} JSON.stringify({available:g($.NSURLVolumeAvailableCapacityKey),important:g($.NSURLVolumeAvailableCapacityForImportantUsageKey),opportunistic:g($.NSURLVolumeAvailableCapacityForOpportunisticUsageKey),total:g($.NSURLVolumeTotalCapacityKey)});'
```

```json
{"available":543824449536,"important":590191163121,"opportunistic":643859215665,"total":994662584320}
```

`available` agrees with the hard `diskutil` value to normal sampling drift.
The `important` estimate was 46,366,713,585 bytes above hard available at this
instant, but these Foundation estimates are policy-dependent advisory reclaim
figures—not guaranteed immediately purgeable bytes—and moved while the download
was active. They are not needed to pass the hard-space threshold.

Read-only snapshot commands:

```sh
diskutil apfs listSnapshots /
tmutil listlocalsnapshots /
```

Output:

```text
Snapshot for disk3s3s1 (1 found)
|
+-- BE13DEB1-389A-4346-A93F-502BBAF6176B
    Name:        com.apple.os.update-5B92CE4BA1034457A0921532291F4A4AD939CBE48D3A1381163A9AD3687D5694
    XID:         5287272
    Purgeable:   No
    NOTE:        This snapshot limits the minimum size of APFS Container disk3
Snapshots for disk /:
```

There were no Time Machine local snapshots listed. The sole root-volume OS
update snapshot is explicitly non-purgeable.

### `>=400 GB` verdict

**PASS for this in-progress snapshot:** APFS reported
`543,841,509,376` bytes (`543.8 GB`, approximately `506 GiB`) hard unallocated,
which is `143.8 GB` above the plan's `>=400 GB` pre-download/pre-conversion
threshold without counting advisory reclaimable capacity.

This is deliberately not treated as the final stable G0 baseline. The active
approximately 372 GB artifact transfer can materially change the value. Re-run
the same commands after that user-owned transfer completes and before any
conversion or full-model oracle measurement.

## G0 item 4: model-free capture and derived scaffolding (2026-07-21)

An incomplete model-free starting package is checked in at
[`../../fixtures/colibri-glm52/`](../../fixtures/colibri-glm52/README.md), with
an explicit exact-pin capture orchestrator at
[`../../scripts/capture-colibri-glm52-oracle.ts`](../../scripts/capture-colibri-glm52-oracle.ts),
capture helpers at `scripts/colibri-glm52-capture.{py,c}`, the ordinary
standalone generator at
[`../../scripts/gen-colibri-glm52-fixtures.ts`](../../scripts/gen-colibri-glm52-fixtures.ts)
and consuming model-free tests at
[`../../tests/colibri-glm52-fixtures.test.ts`](../../tests/colibri-glm52-fixtures.test.ts).
Git is the integrity root. The manifest records reproducibility hashes but does
not present itself as an authenticity root.

The capture script first validates that the external checkout has exact HEAD,
empty porcelain, and clean cached/worktree diffs, then executes only a temporary
`git archive`. The recorded run used Apple M1 Max ARM64, Apple clang 21.0.0,
CPython 3.14.5 with existing NumPy 2.4.6, and Bun 1.3.14. It imported the
archived pinned `quant_int8`/`quant_int4_grouped`, and compiled a temporary
harness that includes archived `glm.c`/`tier.h`. Direct captured constants are
limited to Python quantization, ARM `matmul_q`/`matmul_i4_grouped`, DSA
partial-select/tie scans, LFRU score/admission/tie/wrap/decay, and elementary
RMSNorm/sigmoid outputs. Exact tree/blob hashes, source SHA-256 values, helper
hashes, toolchain, target, and executed commands live in
`oracle-capture.json`. No install, download, server, model load, or external
checkout mutation occurred.

The tiny SwiGLU/residual spine, top-8 router composition, LRU trace, and greedy
MTP state trace are explicitly `derived_canonical`, not captured Colibri
runtime outputs. The MTP scaffold covers partial accept, immediate reject,
full accept, accepted-only absorption, next-logit/`hlast` row choice, and
logical main-KV rollback. EOS/special-stop handling, length clamps, adaptive
guard, grammar precedence, sampling rejection, teacher-forced logits, numeric
GLM/MLA/MTP-head/KV values, and neural acceptance remain gaps.

Residual blocker: item 4 and G0 remain incomplete until a real numeric model
oracle is recorded and the required cleared-M1-Max-32-GB same-machine baseline
is run. The earlier approximately 679 GB preflight remains the recorded stable
capacity note; the later moving download snapshot does not replace it, and a
stable refresh after the user-owned transfer settles remains pending.
