#!/usr/bin/env python
# Score OUR (bit-exact = his) GSM8K responses with HIS extractor; find divergent items.
import json
from optiq.eval.gsm8k import _extract_answer, _extract_ground_truth, _normalize_number
rows = [json.loads(l) for l in open("/tmp/gsm8k-ours.jsonl")]
our_c = sum(int(r["ourCorrect"]) for r in rows)
his_c = 0
div = []
for r in rows:
    ps = _extract_answer(r["response"])
    gs = _extract_ground_truth(r["answer"])
    pred = _normalize_number(ps) if ps else None
    gt = _normalize_number(gs)
    hc = gt is not None and pred is not None and abs(gt - pred) < 1e-3
    his_c += int(hc)
    if hc != bool(r["ourCorrect"]):
        div.append((r, hc, ps))
print(f"our correct: {our_c}/{len(rows)}   his correct: {his_c}/{len(rows)}")
print(f"divergent items: {len(div)}")
for r, hc, ps in div[:12]:
    print(f"  ourCorrect={r['ourCorrect']} hisCorrect={hc} | ourPred={r['ourPred']} hisPred={ps!r}")
    print(f"     resp_tail={r['response'][-90:]!r}")
