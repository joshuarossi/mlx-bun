# ORPO from-base on UltraFeedback (mixed-5bpw) — results + research directions

**Status:** experiment complete (2026-06-23). This is the validation run **and** the
research program it surfaced. Detailed research notes for the session of 2026-06-21…23.

**Companion docs:**
- [orpo-dynamic-lambda.md](../design/orpo-dynamic-lambda.md) — the adaptive-λ / PID controller (extended below).
- [orpo-future-enhancements.md](../design/orpo-future-enhancements.md) — SimPO + objective variants.
- [orpo-uf-testing-handoff.md](orpo-uf-testing-handoff.md) — the **earlier** from-*instruct* UF run (4-bit, seq 2048, no-segment). **Distinct** from this run.
- [segmented-backward-training.md](../design/segmented-backward-training.md), [steel-flash-cce-handoff.md](steel-flash-cce-handoff.md) — the memory/kernel stack this run exercised.

---

## 1. The run

From-**base** (true base, not instruct) ORPO on UltraFeedback, MiniCPM5-1B.

- **Base:** `openbmb/MiniCPM5-1B-Base-OptiQ-mixed-5bpw` — the **true base**, mixed-precision quant (unblocked by the quantization fix). NOT the instruct model the earlier run used.
- **Data:** `uf-binarized-chat` — UltraFeedback as `{prompt:[{role,content}], chosen, rejected}`, **60,630 train pairs**. Prompt is a structured message array; chosen/rejected are raw response strings.
- **Config:** ORPO, **1 epoch (3,790 optimizer steps)**, B=1, **seq 4096**, rank 16 / scale 2, **λ=0.1**, lr **1e-5**, **segmented backward (2 layers/seg)**, **flash-CCE head**, **grad-accum 16** (eff. batch 16), coeff filter ON (`MLX_BUN_CCE_BWD_FILTER_EPS`, real-data ~0.16%).
- **Template:** the base quant has **no `tokenizer_config.chat_template`**; `ChatTemplate.load` falls back to **`chat_template.jinja`** (which *we* dropped into the quant when building it). It's **ChatML** (`<|im_start|>{role}\n…<|im_end|>`) **+ MiniCPM's XML tool format** (`<function><param>…</param></function>`, CDATA) **+ the hybrid `<think>` block**. We rendered `enableThinking:false` (injects an empty `<think>\n</think>\n\n` before the response).
- **Recipe fidelity:** lr 1e-5 + λ 0.1 (NOT the saturating 5e-5); **mean-logp verified length-normalized** over response tokens (`responseOnlyLogpMean`: `sum(logp)/M`, M = response-token count) — this is the single most common ORPO parity break and we are on the right side of it, including in the flash-CCE head (parity-validated to 0.21% vs the full-logits mean path).

## 2. Memory validation (the headline systems result)

- **Peak 4.82 GB** — the legitimate high-watermark, driven by the longest example (~2,354 tok chosen+rejected, idx 5582, **+ the prompt**), **not** the 4096 cap (all UF < 4096; 0 examples exceed it — that's *why* 4096 was chosen). My earlier ~4 GB estimate was ~0.5 GB low (slope under-call), not a leak.
- **Active flat at 0.892 GB** across ~3,300+ steps — **bit-identical early-to-recent, zero drift → NO leak.** Active (the baseline), not peak (example-length-driven), is the leak signal. The ~0.4 MB/step leak we caught earlier would've surfaced as **~1.3 GB of drift** over the run; we saw **0**. So any residual leak is bounded *below detectability*.
- The whole stack — flash-CCE, steel GEMM, segmented backward, AdamW, grad-accum, the coeff filter + block-skip — ran **dispose-balanced end-to-end** for a full epoch. **A 1B ORPO epoch in < 5 GB, holding flat.** This retires the memory risk for the bigger runs below.

**Predictive memory model (validated):** peak ≈ resting + (2-layer-segment activation) × (longest sequence). Deterministic, bounded; plateaus once the longest example runs. Watch `active_gb` for drift = the leak detector.

## 3. Results — the model

- **Val preference accuracy FLAT ~55.5%** across every eval (500→3000: 55.1, 55.1, 56.3, 55.9, 56.3, 55.9). Plateaued by step 500, **never strengthened**. The 55→56 wobble is 1–3 of 256 examples — inside the ±3.1% SE. n=256.
- **Val loss** crept down (1.356 → 1.305 — the NLL/format half); **train margin** rose slightly (mean 0.19 → 0.25). A **weak, stable preference** reached early and held.
- This is the **two-ORPO-halves-decouple** result again: the SFT/NLL half learns the format fast; the preference half barely generalizes on a 1B with subtle UF pairs.

## 4. Vibe-check — 20 questions through base+UF

**Single-turn (fresh context each):**
- **Good:** simple **code** (prime function correct, sqrt-optimized), **arithmetic** (17×23=391 ✓, 3+5−2=6 ✓), **creative persona** (the pirate plays the role).
- **Weak/wrong:** **factual recall** ("capital of Australia" → *"there is no specific capital"*; "most recent election" → *"Trump won 2020"*), **translation** ("I love programming" → *"Je love à programmer"*), **identity/privacy/weather** (hedging non-answers), **instruction constraints** ("list exactly three… and nothing else" → preambled anyway).

**Two failure MODES (the actually-useful findings):**
1. **Multi-turn copying loop** — in a running conversation, once a generic disclaimer enters the history, the model **parrots its own previous assistant turn** for nearly every subsequent question (Q4–9, 15–20 were byte-identical). **Root cause: UF is single-turn preference data** — it never learned to hold a conversation, so the path of least resistance is copy-the-last-turn.
2. **Hedging-disclaimer boilerplate** ("I'm here to help… I am a language model… respectful and safe… I will never fab[ricate]") — over-learned from UF's RLHF-safety filler.

## 5. Conclusions

1. **VALIDATION SUCCESS.** The chain works end-to-end: quant **base** loads → trains clean a full epoch → **zero leak** → **chats**. ORPO replicated at ~1/60th scale, **on a laptop**, single-stage base→assistant.
2. **Modest-as-predicted.** base + 1 epoch UF + λ=0.1 = a weak preference (flat 55.5%) and modest quality. We forecast this; it is the expected outcome, **not a miss**.
3. **The failure modes are DATA artifacts, not method artifacts.** Multi-turn collapse ← single-turn UF; hedging ← UF's disclaimer filler. Both fixable by **changing the data** → this *reinforces* the specialist-curation direction (we control the data). The vibe-check effectively handed us the **curation spec**: add multi-turn examples, filter the disclaimer filler, use our tools in our format.
4. **CONFOUND CORRECTION (load-bearing).** The gap vs `MiniCPM5-1B-SFT` is **NOT** evidence that single-stage can't replace SFT. We changed **method AND data simultaneously** — 60k UF pairs vs ~400B-token SFT (~1000×). The data difference dominates. The only clean claim is the near-tautological **"60k UF pairs ≠ 400B-token SFT"** (a *data* statement). The **method** question (single-stage vs multi-stage) is **untested** — it requires holding data constant (see §6.5).

## 6. Research directions (crystallized this session)

These form a build: each removes a confound or fixes a measured weakness of the prior.

### 6.1 SimPO, and why it's nearly free for us
SimPO = reference-free, length-normalized, `−log σ(β·(ℓw−ℓl) − γ)` with a **target margin γ** and **no SFT term** (pure preference; applied *after* SFT). We already compute the length-normalized `ℓw`, `ℓl` (`branchLogpMean`), so SimPO is a **one-term loss swap** → a `--method simpo` + `--beta`/`--gamma`. Natural fit for **SimPO-on-`MiniCPM5-1B-SFT`** (the staged comparison).

### 6.2 ORPO + SimPO's margin (the γ-hybrid) — the fix aimed at *our* result
For our regime (ℓw≈ℓl), ORPO's odds-ratio ≈ the logp difference already; what SimPO *adds* is the **target margin γ**. ORPO's `−log σ(separation)` gradient **vanishes once chosen ≥ rejected** (separation ≥ 0) → the model plateaus at tiny separation = **our flat margin**. The γ margin **moves the saturation point from 0 to γ**, keeping gradient alive. So: `L = NLL(chosen) + λ·[−log σ(β·(ℓw−ℓl) − γ)]` — ORPO's SFT anchor + SimPO's non-saturating push. Aimed directly at the flat-55.5% we measured.

### 6.3 SFT + SimPO single-stage (the SimPO analog of ORPO)
"SFT + SimPO at the same time," the way ORPO is "SFT + DPO at the same time." Composes cleanly (both NLL and SimPO push chosen-logp **up** → reinforce). **Watch-out:** SimPO also pushes `logp(rejected)` **down**, and the NLL anchor grounds chosen but **not** rejected — over-aggressive β/γ over-suppresses coherent rejected text → fluency erosion. Tune so the push doesn't outrun the anchor.

### 6.4 Dynamic preference controller (PID/AIMD) — see [orpo-dynamic-lambda.md](../design/orpo-dynamic-lambda.md)
The flat margin looks like **saturation**, and the *optimal* preference pressure is **non-stationary** (fragile early, robust late) → **no fixed λ is optimal**; a controller tracks the moving target and **beats any fixed value** (a sweep finds the best *constant*; this finds the best *trajectory*). Reframed this session as a **control problem**: NLL = the process variable, the preference weight = the actuator, AIMD/PID = the law. The integral term (the "missing letter") kills chronic steady-state degradation; the derivative (slope) is a **leading** indicator that catches the helping→hurting inflection *before* the level rises. Build **P → PD → PID**, each term earning its place against an observed failure of the prior. Folds the λ/β/γ sweep into one run. Detail + the control-theory framing now in orpo-dynamic-lambda.md §"Control-theory framing (PID/AIMD)".

### 6.5 SFT-as-preference / SPIN comparison — the confound-free method test
**The interesting one.** Take a **chunk of `UltraData-SFT-2605`** (CPM5's *own* SFT data), make preference pairs **SPIN-style** (chosen = the gold answer, **rejected = on-policy: the model's own generation** for that prompt), train single-stage. Removes the data confound (same data CPM5-SFT saw). Two comparisons:
- **Method-isolating (rigorous):** plain SFT vs single-stage-preference on the **same chunk** → proves "preference-formatted SFT ≥/= SFT" with no confound. *Why it could be ≥:* ORPO on (gold vs self-gen) = NLL does the SFT **+** the preference term adds "commit to gold over your own output."
- **"Approach CPM5-SFT" (aspirational, data-gated):** needs a large fraction of 400B tokens → the data gap re-enters; don't let it quietly re-import the confound.
- Smart first cut: a **single-domain chunk** (knowledge or instruction-following — where base+UF was weakest) — small, legible.
- **NOT an ORPO-paper replication** — a *different*, arguably more novel comparison.

### 6.6 Scale-up to a standard 7B, on the laptop
Memory math (validated): 7B resting ~4.4 GB + 2-layer-segment activations → **~8–12 GB peak at seg 2** on UF-length data; **seg 1** halves the activation term (more recompute = slower) for headroom. **Fits 32 GB with room** — the segmented backward was *built* for exactly this (e4b targeted ~10 GB @ 8192; UF < 4096 is the easy end). **Time, not memory, is the cost** (~7× FLOPs/token → days on a laptop). Prefer a **standard dense 7B (Mistral-7B-base** — the ORPO paper's flagship) over e4b for direct literature comparison; it's standard Llama-arch (≈ MiniCPM5's family) so the handler is ~a day. **Strategic flip:** "7B preference-aligned on a 32 GB consumer laptop" *is* the local-to-you thesis at scale — scale-up strengthens the accessibility pitch instead of diluting it.

### 6.7 Diffusion-LM frontier (high-novelty, low *marginal* cost)
Apply ORPO/SimPO/the controller to a **diffusion language model** (e.g. a Gemma-diffusion). Likely **open territory** (DPO-for-diffusion exists for *images* — Diffusion-DPO — not for diffusion *LMs* + single-stage/dynamic). The diffusion **forward is product-justified anyway** (mlx-optiq has it, mlx-lm doesn't, mlx-vlm does) → once it exists, the preference objective is the same **loss-head swap**. Technical crux: the likelihood is a **stochastic ELBO** (not exact logp), so `ℓw`/`ℓl` are noisy MC estimates → **the dynamic controller's noise-robustness is a *synergy*, not a mismatch.** Length normalization must be rederived for the diffusion loss. Base quality lags AR (24B-diff ≈ 12B-AR), so the contribution is *"does single-stage preference-opt work on diffusion LMs,"* novel regardless.

## 7. Template note (for any future run)

- For **portability / paper-grade** runs, impose a **clean plain-ChatML** template (no MiniCPM XML-tool / `<think>` extensions) at data-prep instead of falling back to the model's custom one. Trivial (drop a clean `chat_template.jinja` / override `renderDpoPrompt`).
- The model's **native tool format is the XML `<function>/<param>`** one — any tool-use training data must use **that**, not OpenAI JSON `tool_calls`.

## 8. The data — `UltraData-SFT-2605` (the substrate for §6.5)

[openbmb/UltraData-SFT-2605](https://huggingface.co/datasets/openbmb/UltraData-SFT-2605) — the actual SFT data behind `MiniCPM5-1B-SFT`:
- **15,036,178 examples · 319 GB · ~400B tokens** (200B deep-thinking + 200B hybrid-thinking). **Apache 2.0.**
- **Single-response (gold only) — NOT preference pairs** → the rejected must be manufactured (SPIN-style on-policy).
- **Single-turn** (no multi-turn) → won't, by itself, fix the multi-turn copying loop.
- Domains: math / code / knowledge / instruction-following. Thinking split **6.5M deep / 8.5M non-thinking**. **Chunked by domain** → take a slice, never the full 319 GB. (Multi-GB download is the user's to kick off, not a session's.)
- The three published models: `MiniCPM5-1B-Base` → `MiniCPM5-1B-SFT` → `MiniCPM5-1B` (instruct, RL+OPD on top of SFT).

## 9. The framing that ties it together

- **What SFT builds vs what preference-opt aligns:** our failure list (multi-turn, instruction discipline, breadth, `<think>`) is ~the SFT stage's job description — but per §5.4 that's mostly a **data** statement (400B curated tokens), not proof the SFT *method* is irreplaceable.
- **Where single-stage genuinely wins:** specialists (narrow curated data — no foundation breadth needed) and as a **final alignment stage on a good SFT**. NOT a foundation-SFT replacement — *and our own run is the evidence for that boundary, honestly scoped.*
- **The narrow specialist is the product** (welcome-agent / memory-agent on our closed tool surface); the general UF model was always the **validation**, and it handed us the curation spec for free.

## 10. Choosing what's next — the three lenses (NO decision made yet)

Apply all three to any §6 direction; they point different ways:

1. **Will it work + be useful to US?** (the *product* lens — primary.) Does it improve the specialists we actually ship? Usually gated by a **cheap diagnostic first** — e.g. for the controller: does a *higher fixed λ* or the **γ-margin** even unstick the flat preference? If a fixed push does nothing, *no controller can.* Run the cheap fixed-knob version before the fancy one.
2. **Interesting paper?** (read / replicated / adds to the ORPO-style discourse.) Strong hooks (control-theory/PID, SFT-as-preference, diffusion-LM preference-opt), but it's a **crowded, competitive space** → the result has to be the non-stationarity / confound-free kind to be more than "auto-tuning," and credibility likely needs **scale** (7B+, standard model, standard benches).
3. **Fundable / by whom?** The *technique* funds itself via the **product** (cheaper specialist training), independent of any paper. As a paper/grant: compute-cost-sensitive trainers + the local-AI community + project credibility. It's a *method* contribution, not a product.

**The trap + the rule:** don't let the *paper* lens drive the work. **Let the product need drive it** (lens 1), run the cheap diagnostics first, and treat the **paper as a harvest** if the result turns out strong — the experiments that make it a good feature are the same ones that'd make it a paper, so the lens-2/3 decision can wait until lens 1 reports.

**Rough risk / novelty / cost of the §6 directions (for when we pick):**
- **§6.2 γ-hybrid / higher-λ diagnostic** — lowest cost, directly targets the measured flat preference. *The cheap first cut.*
- **§6.1/6.3 SimPO-on-SFT / SFT+SimPO** — low (loss-swap), needs the SFT checkpoint pulled.
- **§6.4 PID controller** — medium (build + tune), highest method-novelty of the AR options.
- **§6.5 SPIN-on-UltraData** — medium (chunk + on-policy generation), the **confound-free method test**, distinct from ORPO replication.
- **§6.6 7B-Mistral-on-laptop** — ~a day handler + days of compute; the credibility + thesis-at-scale move.
- **§6.7 diffusion** — highest novelty, lift mostly paid by the product (the forward exists anyway); the ambitious swing.
