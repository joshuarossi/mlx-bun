# DeepSpec oracle — dumps a temp-0 deterministic round trace from DeepSeek's
# OWN reference implementation (github.com/deepseek-ai/DeepSpec, MIT) driving
# their trained drafter `deepseek-ai/dspark_gemma4_12b_block7` against the
# bf16 target `google/gemma-4-12B-it`. At temperature 0 their leaky-rejection
# verify degenerates to exact argmax token-match — the whole trace is
# RNG-free and deterministic (see deepspec/eval/base_evaluator.py
# verify_draft_tokens: selected_target_probs/selected_draft_probs is a
# 0/1-vs-0/1 ratio at temp 0, so accept_prob is 0.0 or 1.0 and
# `rand < accept_prob` is decided before the draw). Round-for-round output
# here is the ground truth dspark-deepspec-compare.ts (deleted 2026-08-23; git history) checks our
# port against (docs/investigations/dspark-handoff.md, PATH A).
#
# This does NOT reuse deepspec's BaseEvaluator/torch.multiprocessing.spawn
# distributed harness (that's built for their multi-GPU eval sweep over 9
# benchmark datasets) — it inlines their exact building blocks
# (generate_decoding_sample + build_dspark_proposal + forward_dspark_draft_block,
# imported verbatim from deepspec) around a flat single-process loop over a
# small fixed prompt set, matching the house oracle-script shape
# (scripts/oracle-spec.py, scripts/oracle-spec-two-model.py) instead of their
# eval.py CLI. Every deepspec import below is real (fetched 2026-07-06 from
# raw.githubusercontent.com/deepseek-ai/DeepSpec/main/...) — nothing here is
# a guessed API.
#
# --- venv setup (does NOT reuse the mlx-lm oracle venv — that one has no
#     torch/deepspec and shouldn't; this needs its own, on THIS machine or
#     wherever the GPU/box that can hold a 12B bf16 target + 6.9GB drafter
#     lives) ---
#
#   python3 -m venv .venv-deepspec
#   source .venv-deepspec/bin/activate
#   pip install torch transformers prettytable
#   git clone https://github.com/deepseek-ai/DeepSpec.git
#   pip install -e DeepSpec          # editable install so `import deepspec` resolves
#
#   HF_HUB_DISABLE_XET=1 huggingface-cli download google/gemma-4-12B-it
#   HF_HUB_DISABLE_XET=1 huggingface-cli download deepseek-ai/dspark_gemma4_12b_block7
#
# --- run ---
#
#   .venv-deepspec/bin/python scripts/oracle/oracle-dspark-deepspec.py \
#       --target <snapshot-dir-of-google/gemma-4-12B-it> \
#       --drafter <snapshot-dir-of-deepseek-ai/dspark_gemma4_12b_block7> \
#       --data prompts.jsonl --n 8 --max-new-tokens 128 \
#       --temperature 0 --confidence-threshold 0 \
#       --out goldens/dspark-deepspec/trace-thr0.jsonl
#
#   # second arm, confidence-threshold pruning active:
#   .venv-deepspec/bin/python scripts/oracle/oracle-dspark-deepspec.py \
#       --target <...> --drafter <...> --data prompts.jsonl --n 8 \
#       --max-new-tokens 128 --temperature 0 --confidence-threshold 0.5 \
#       --out goldens/dspark-deepspec/trace-thr0.5.jsonl
#
# `--data prompts.jsonl` is a plain jsonl of {"prompt": "..."} rows (NOT their
# eval_datasets {"turns": [...]} shape — this is a from-scratch fixed fixture
# set, not one of their 9 benchmark datasets). See
# docs/investigations/dspark-handoff.md "Oracle protocol" for the fixture
# location convention (goldens/ is machine-specific + untracked).
#
# Syntax-checked only (no execution) via: python3 -m py_compile scripts/oracle/oracle-dspark-deepspec.py

from __future__ import annotations

import argparse
import json
import sys
from types import SimpleNamespace

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, DynamicCache

# --- deepspec imports (real names, verified against the actual source) ---
from deepspec.eval.base_evaluator import (
    DraftProposal,
    VerificationResult,
    assert_no_final_target_layer,
    generate_decoding_sample,
    resolve_stop_token_ids,
)
from deepspec.eval.dspark.draft_ops import (
    DSparkDraftProposal,
    build_dspark_proposal,
    forward_dspark_draft_block,
)
from deepspec.modeling.dspark.common import extract_context_feature
from deepspec.modeling.dspark.gemma4 import Gemma4DSparkModel
from deepspec.utils import seed_all


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--target", required=True, help="snapshot dir of google/gemma-4-12B-it")
    p.add_argument("--drafter", required=True, help="snapshot dir of deepseek-ai/dspark_gemma4_12b_block7")
    p.add_argument("--data", required=True, help="jsonl of {\"prompt\": str} rows")
    p.add_argument("--n", type=int, default=8, help="number of prompts to run (first N rows of --data)")
    p.add_argument("--max-new-tokens", type=int, default=128)
    p.add_argument("--temperature", type=float, default=0.0, help="oracle protocol is temp=0 (RNG-free verify)")
    p.add_argument("--confidence-threshold", type=float, default=0.0)
    p.add_argument("--seed", type=int, default=980406, help="deepspec's own default eval seed")
    p.add_argument("--out", required=True, help="output JSONL path")
    args = p.parse_args()
    if args.temperature != 0.0:
        print(
            "WARNING: temperature != 0 — verify is rejection sampling with real "
            "randomness there; the round trace will NOT be reproducible across "
            "runs/stacks. The documented oracle protocol is temp=0 only.",
            file=sys.stderr,
        )
    return args


def load_prompts(path: str, n: int) -> list[str]:
    rows: list[str] = []
    with open(path, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            row = json.loads(line)
            rows.append(row["prompt"])
            if len(rows) >= n:
                break
    return rows


def build_models(target_dir: str, drafter_dir: str, device: torch.device):
    target_model = (
        AutoModelForCausalLM.from_pretrained(target_dir, dtype=torch.bfloat16, attn_implementation="sdpa")
        .to(device)
        .eval()
    )
    draft_model = (
        Gemma4DSparkModel.from_pretrained(drafter_dir, dtype=torch.bfloat16, attn_implementation="sdpa")
        .to(device)
        .eval()
    )
    assert_no_final_target_layer(target_model, draft_model.target_layer_ids)
    tokenizer = AutoTokenizer.from_pretrained(target_dir)
    return target_model, draft_model, tokenizer


def run_one(
    *,
    target_model,
    draft_model,
    tokenizer,
    device: torch.device,
    prompt: str,
    max_new_tokens: int,
    temperature: float,
    confidence_threshold: float,
    stop_token_ids: list[int] | None,
) -> dict:
    """Runs deepspec's OWN generate_decoding_sample loop and captures a
    per-round trace via post_verify — the same hook their ConfidenceHeadRecorder
    uses (deepspec/eval/dspark/evaluator.py), repurposed here to log rounds
    instead of fitting calibration bins."""
    max_proposal_tokens = int(draft_model.block_size)

    messages = [{"role": "user", "content": prompt}]
    prompt_str = tokenizer.apply_chat_template(
        messages, add_generation_prompt=True, tokenize=False,
        # pinned explicitly — mlx-lm's TokenizerWrapper defaults
        # enable_thinking=True for thinking-capable models when unset; the
        # deepspec reference eval also hardcodes False in run_dataset. Pin
        # on BOTH sides of the comparison or rendered prompts drift.
        enable_thinking=False,
    )
    input_ids = tokenizer(prompt_str, return_tensors="pt", add_special_tokens=False).input_ids.to(device)

    rounds: list[dict] = []

    def init_context(*, initial_output, **kwargs) -> SimpleNamespace:
        return SimpleNamespace(
            past_key_values_draft=DynamicCache(),
            target_hidden_states=extract_context_feature(
                initial_output.hidden_states,
                draft_model.target_layer_ids,
            ),
        )

    def propose(
        *,
        context: SimpleNamespace,
        output_ids: torch.Tensor,
        position_ids: torch.Tensor,
        start: int,
        stop_token_ids: list[int] | None = None,
    ) -> DraftProposal:
        draft_input_ids = torch.full(
            (output_ids.size(0), max_proposal_tokens),
            int(draft_model.mask_token_id),
            dtype=torch.long,
            device=output_ids.device,
        )
        draft_input_ids[:, 0] = output_ids[:, start]
        block_hidden = forward_dspark_draft_block(
            draft_model,
            draft_input_ids=draft_input_ids,
            position_ids=position_ids,
            past_key_values_draft=context.past_key_values_draft,
            target_hidden_states=context.target_hidden_states,
            start=start,
            block_size=max_proposal_tokens,
        )
        return build_dspark_proposal(
            model=draft_model,
            draft_input_ids=draft_input_ids,
            block_hidden=block_hidden,
            block_size=max_proposal_tokens,
            temperature=float(temperature),
            confidence_threshold=float(confidence_threshold),
        )

    def update(context: SimpleNamespace, verification: VerificationResult) -> None:
        verified_target_hidden = extract_context_feature(
            verification.target_output.hidden_states,
            draft_model.target_layer_ids,
        )
        context.target_hidden_states = verified_target_hidden[:, : verification.accepted_draft_tokens + 1, :]

    def post_verify(proposal: DraftProposal, verification: VerificationResult) -> None:
        assert isinstance(proposal, DSparkDraftProposal)
        proposed = proposal.verify_input_ids[0, 1:].tolist()  # the drafted tokens (excludes the leading anchor)
        committed = (
            verification.committed_tokens[0].tolist()
            if verification.committed_tokens is not None
            else []
        )
        rounds.append({
            "start": None,  # filled below once we know it (post_verify has no `start` arg)
            "proposal": proposed,
            "accepted": int(verification.accepted_draft_tokens),
            "committed": committed,
            "confidence": (
                proposal.confidence_logits.sigmoid()[0].tolist()
                if proposal.confidence_logits is not None
                else None
            ),
        })

    # generate_decoding_sample doesn't thread `start` into post_verify, so we
    # reconstruct it after the fact from cumulative committed-token counts
    # (round r's start = num_input_tokens + sum(len(committed) for rounds<r)).
    result = generate_decoding_sample(
        target_model=target_model,
        input_ids=input_ids,
        max_new_tokens=max_new_tokens,
        max_proposal_tokens=max_proposal_tokens,
        temperature=float(temperature),
        stop_token_ids=stop_token_ids,
        init_context=init_context,
        propose=propose,
        update=update,
        post_verify=post_verify,
    )

    num_input_tokens = int(result.num_input_tokens)
    cursor = num_input_tokens
    for r in rounds:
        r["start"] = cursor
        cursor += len(r["committed"])

    output_ids = result.output_ids[0].tolist()
    return {
        "prompt": prompt,
        "prompt_ids": input_ids[0].tolist(),
        "num_input_tokens": num_input_tokens,
        "rounds": rounds,
        "output_ids": output_ids,
        "num_output_tokens": int(result.num_output_tokens),
    }


def main() -> None:
    args = parse_args()
    seed_all(int(args.seed))

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    target_model, draft_model, tokenizer = build_models(args.target, args.drafter, device)
    stop_token_ids = resolve_stop_token_ids(target_model, tokenizer)

    prompts = load_prompts(args.data, args.n)
    print(
        f"[oracle-dspark-deepspec] {len(prompts)} prompts, gamma(block_size)="
        f"{draft_model.block_size}, temp={args.temperature}, "
        f"confidence_threshold={args.confidence_threshold}, device={device}",
        file=sys.stderr,
    )

    with open(args.out, "w", encoding="utf-8") as out_fh:
        for idx, prompt in enumerate(prompts):
            seed_all(int(args.seed) + idx)  # match deepspec's run_dataset per-sample reseed
            row = run_one(
                target_model=target_model,
                draft_model=draft_model,
                tokenizer=tokenizer,
                device=device,
                prompt=prompt,
                max_new_tokens=args.max_new_tokens,
                temperature=args.temperature,
                confidence_threshold=args.confidence_threshold,
                stop_token_ids=stop_token_ids,
            )
            out_fh.write(json.dumps(row) + "\n")
            out_fh.flush()
            print(
                f"[{idx + 1}/{len(prompts)}] {len(row['rounds'])} rounds, "
                f"{row['num_output_tokens']} output tokens",
                file=sys.stderr,
            )

    print(f"[oracle-dspark-deepspec] wrote {args.out}", file=sys.stderr)


if __name__ == "__main__":
    main()
