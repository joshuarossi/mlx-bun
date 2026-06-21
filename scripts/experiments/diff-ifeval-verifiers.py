#!/usr/bin/env python
# Run OUR (bit-exact = his) IFEval responses through HIS verifier and pinpoint which
# instruction-id verifier disagrees. ours-pass-his-fail = where our impl is too lenient.
#   <optiq-venv>/bin/python scripts/experiments/diff-ifeval-verifiers.py
import json
from collections import Counter
from optiq.eval import ifeval as I

rows = [json.loads(l) for l in open("/tmp/ifeval-ours.jsonl")]
n = len(rows)
our_pass = sum(int(r["ourStrict"]) for r in rows)
his_pass = 0
diverge = []
for r in rows:
    hp, _ = I._verify_response(r["response"], r["instruction_id_list"], r["kwargs"])
    his_pass += int(hp)
    if bool(hp) != bool(r["ourStrict"]):
        diverge.append((r, bool(hp)))

print(f"our strict: {our_pass}/{n} = {our_pass/n*100:.1f}%")
print(f"his strict: {his_pass}/{n} = {his_pass/n*100:.1f}%")
ours_lenient = [(r, hp) for r, hp in diverge if r["ourStrict"] and not hp]
print(f"diverging: {len(diverge)}  (ours-PASS-his-FAIL: {len(ours_lenient)})")

# Which instruction id does HIS verifier fail on, where ours passed the whole prompt?
blame = Counter()
ex = {}
for r, hp in ours_lenient:
    for iid, kw in zip(r["instruction_id_list"], r["kwargs"]):
        fn = I._VERIFIERS.get(iid)
        if fn is None:
            continue
        try:
            his_ok = bool(fn(r["response"], **(kw or {})))
        except Exception:
            his_ok = False
        if not his_ok:
            blame[iid] += 1
            ex.setdefault(iid, (kw, r["response"]))
print("\nINSTRUCTION IDS where HIS verifier FAILS but ours PASSED:")
for iid, c in blame.most_common(20):
    kw, resp = ex[iid]
    print(f"  {c:3}x  {iid}")
    print(f"         kw={kw}")
    print(f"         resp[:130]={resp[:130]!r}")
