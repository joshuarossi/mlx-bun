#!/usr/bin/env python
# Plot positive-control / training run trajectories logged by pref-control.ts.
#   python scripts/experiments/plot-runs.py [runs/a.json runs/b.json ...]
# Defaults to all runs/*.json. Writes runs/<out>.png (default positive-control.png).
import json, glob, sys, os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

args = [a for a in sys.argv[1:] if a.endswith(".json")]
out = next((a for a in sys.argv[1:] if a.endswith(".png")), "runs/positive-control.png")
files = args or sorted(glob.glob("runs/*.json"))
if not files:
    print("no run json files found"); sys.exit(1)

runs = []
for f in files:
    d = json.load(open(f))
    d["_name"] = os.path.basename(f).replace(".json", "")
    runs.append(d)

VAL_N = int(os.environ.get("VAL_N", "148"))  # val-set size (uf-cpm5 = 148); override via env
all_counts, all_margins, all_losses = [], [], []

def ema(ys, alpha=0.06):  # smooth the noisy B=1 per-step train loss into a readable trend
    out, s = [], None
    for y in ys:
        s = y if s is None else alpha * y + (1 - alpha) * s
        out.append(s)
    return out

fig, ax = plt.subplots(1, 3, figsize=(16, 4.6))
for d in runs:
    name = d["_name"]
    tr, vl = d.get("train", []), d.get("val", [])
    if tr:
        ax[0].plot([r["step"] for r in tr], ema([r["loss"] for r in tr]), alpha=0.65, color="tab:blue", label=f"{name} train (EMA)")
    if vl:
        vloss = [(r["step"], r["loss"]) for r in vl if r.get("loss") is not None]
        ax[0].plot([s for s, _ in vloss], [v for _, v in vloss], marker="o", color="tab:red", label=f"{name} val")
        all_losses.extend(v for _, v in vloss)
        cnts = [(r["step"], round(r["accuracy"] * VAL_N)) for r in vl if r.get("accuracy") is not None]
        ax[1].plot([s for s, _ in cnts], [c for _, c in cnts], marker="o", label=name)
        all_counts.extend(c for _, c in cnts)
        mg = [(r["step"], r["margin"]) for r in vl if r.get("margin") is not None]
        ax[2].plot([s for s, _ in mg], [m for _, m in mg], marker="o", label=name)
        all_margins.extend(m for _, m in mg)

ax[0].set_title("loss — val (red) + train EMA (blue)"); ax[0].set_xlabel("step")
if all_losses:  # zoom to the val band so the SFT-saturation curve reads (EMA early transient may clip)
    ax[0].set_ylim(min(all_losses) - 0.04, max(all_losses) + 0.06)
ax[0].grid(alpha=.3); ax[0].legend()
ax[1].set_title(f"val: questions correct (/{VAL_N}, chance={VAL_N // 2})"); ax[1].set_xlabel("step")
ax[1].axhline(VAL_N / 2, ls="--", c="gray", alpha=.6)  # chance line
if all_counts:
    ax[1].set_ylim(min([VAL_N / 2] + all_counts) - 4, max(all_counts) + 12)
ax[1].grid(alpha=.3); ax[1].legend()
ax[2].set_title("val margin (mean log-odds chosen-rejected)"); ax[2].set_xlabel("step")
if all_margins:  # zoom to the data band so the trend reads cleanly
    pad = (max(all_margins) - min(all_margins)) * 0.15 or 0.01
    ax[2].set_ylim(min(all_margins) - pad, max(all_margins) + pad)
ax[2].grid(alpha=.3); ax[2].legend()
plt.tight_layout()
os.makedirs("runs", exist_ok=True)
plt.savefig(out, dpi=120)
print("wrote", out)
