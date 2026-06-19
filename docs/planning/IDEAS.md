# Ideas

Framing, positioning, and vision notes for mlx-bun — the "what is this, really"
captures. Technical prototype theses live in [ResearchTopics.md](ResearchTopics.md);
work in flight lives in [PLAN.md](../../PLAN.md).

---

## Positioning: what mlx-bun is becoming

### The finite-matrix local AI appliance

`mlx-bun` can be a local AI product in a way generic LLM runtimes cannot. On
MLX, the hardware universe is Apple Silicon Macs: a finite list of real shipped
chip/RAM/bandwidth combinations. The supported model universe is curated, and
the runtime usually knows the task mode: chat, tool use, vision, eval,
training, adapter routing, or background automation.

That means the default path can be a table of measured choices instead of a
pile of user-facing knobs:

```text
physical Mac SKU + model checksum + task mode -> optimized execution plan
```

The plan can choose the model, context budget, KV policy, adapter policy,
kernel route, compile route, and memory envelope before the user has to care.
The user runs `mlx-bun`; the system gives them the most useful local assistant
their Mac can comfortably run. Power users still get the stick-shift controls,
but the product default is curated.

This is also why optimization work belongs in the product vision, not just the
lab notebook. Loop unrolling, branch deletion, DAG extraction, custom kernels,
compiled graph tables, Cut Cross Entropy, Liger-style fused heads, and
ORPO-trained adapters matter when they move a real device/model profile from
"cute demo" to "leave it running because it is useful."

### Local in the deeper sense

Two phrases that capture the thesis — especially **mlx-bun × Lucien**:

1. **"A truly local model in a deeper sense."**
   Not just local *compute* (runs on your Mac, nothing leaves it) — local to
   *you*: grounded in your own context and memory, not only your hardware.

2. **"The best model at being yours."**
   Not the best model in the absolute / benchmark sense — the best at *being
   yours*. A small local model, fine-tuned and wired to your personal memory,
   can lose every general benchmark and still win the only one that matters here.

**The connection — Lucien × mlx-bun.** Lucien (the Dreaming) is the synthesized,
persistent memory of *you*; mlx-bun is the local, private model runtime.
Combined: a model that runs entirely on your machine **and** is continuously
grounded in your own accumulated context — local in both senses, and yours in a
way no hosted frontier model can be.
