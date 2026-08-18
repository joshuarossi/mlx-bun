# v0.0.13 release notes

Everything since v0.0.12. One theme: **Qwen 3.8**. The current-generation
Qwen (released August 2026) is brought up on the published OptiQ
artifact at the repo's standard bar — bit-exact logit parity with
mlx-lm — with its thinking controls served faithfully and its
Qwen-trained multi-token-prediction head wired in as a native draft
kind. Vision and video input for the same model are in bring-up and
land in a later release.

## Qwen3.8-27B (text, bit-exact)

- `mlx-community/Qwen3.8-27B-OptiQ-4bit` serves on the existing
  qwen3_5 hybrid graph (gated DeltaNet + gated attention) — the
  architecture audit found byte-identical geometry to the verified
  port, and parity confirmed it: **every logit at every prompt
  position plus 32 greedy decode steps, bit-exact vs stock mlx-lm**
  (the parity harness grew a full prefill-grid golden and
  manifest-driven step counts in the process).
- The config's new `output_gate_type: "swish"` field is inert in every
  implementation (transformers ground truth included) — a load-time
  guard now fails loudly if a future checkpoint carries a value we
  haven't verified.
- Fit reality: the artifact is 20.35 GB of shards. 32 GB machines
  serve it comfortably; 24 GB machines need `--memory-budget` and
  should prefer the uniform 4-bit conversion until the planned
  ~4 bpw TurboQuant×weights artifact lands (PLAN 14z).

## Thinking controls (Qwen 3.8's serving surface)

- Thinking is on by default and streams as OpenAI `reasoning` deltas;
  `chat_template_kwargs.enable_thinking: false` selects instruct mode.
- `reasoning_effort` is now a real depth control on templates that read
  it: OpenAI levels map onto Qwen's `low`/`medium`/`xhigh` (with
  `xhigh` accepted as a first-class request value), and the variable is
  only passed to templates that declare it — the Qwen 3.8 template
  raises on unknown level names, so the server never forwards unmapped
  strings.
- `preserve_thinking` (new in Qwen 3.8, default on) is forwarded:
  history keeps its think blocks, which also improves prompt-cache
  reuse in agent loops.
- Tool calling: Qwen 3.8's XML call format
  (`<tool_call><function=name><parameter=…>`) parses through the
  existing Qwen-style parser into OpenAI `tool_calls`, multiline
  parameters included.

## Native MTP speculative decoding (opt-in)

- Qwen 3.8 ships a multi-step MTP head trained alongside the model;
  mlx-community publishes it split out
  (`mlx-community/Qwen3.8-27B-MTP-bf16`). It mounts as
  `--draft-model … --draft-kind mtp` (auto-detected from the drafter's
  `model_type`), implemented against mlx-vlm's reference drafter: the
  head consumes the target's pre-final-norm hidden plus the next
  token's embedding, drafts recursively, and shares the target's
  embeddings and LM head — ~0.85 GB of extra weights, no separate
  drafter model.
- Correctness is by construction (greedy MTP output is verified
  token-for-token identical to greedy non-MTP by the shared verify
  loop) and gated by an opt-in A/B test that reports prefill/decode
  TPS, acceptance rate, and tokens-per-forward.

## Also in this release

- The parity harness's step-0 check now covers the full prefill logit
  grid for all Qwen targets — masking/position bugs can no longer hide
  behind a last-position comparison.
- A GPU command-buffer failure mode on memory-saturated machines was
  root-caused (Metal completion-thread exception, uncatchable by
  design) and documented in PLAN 14g, along with the finding that some
  mlx-c paths surface C++ errors as process panics instead of
  catchable errors (hardening item).
