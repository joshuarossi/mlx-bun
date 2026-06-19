// Where does flash's 30× backward slowness come from? Time flash forward vs
// backward vs ops.sdpa (fwd + bwd), and the wall-clock of each. A fused kernel
// should be FASTER; if it isn't, the bottleneck is GPU efficiency (occupancy /
// vectorization), not round-trips.  bun scripts/experiments/flash-profile.ts
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { Vjp } from "../../src/mlx/autograd";
import { flashForward, flashBackward } from "../../src/model/flash-attention";

const B = 1, H = 8, D = 64;
const scale = 1 / Math.sqrt(D);
const rand = (shape: number[], s: number) => ops.randomNormal(shape, Dtype.float16, 0, 1, ops.randomKey(BigInt(s)));

function time(label: string, fn: () => MlxArray[], reps = 10): void {
  for (const a of fn()) a.dispose();           // warmup
  const t0 = Date.now();
  for (let i = 0; i < reps; i++) { const out = fn(); ops.evalAll(out); for (const a of out) a.dispose(); }
  console.log(`  ${label.padEnd(26)} ${((Date.now() - t0) / reps).toFixed(1)} ms`);
}

for (const T of [2048]) {
  console.log(`\n=== T=${T} B=${B} H=${H} D=${D} causal ===`);
  const q = rand([B, H, T, D], 1), k = rand([B, H, T, D], 2), v = rand([B, H, T, D], 3), dO = rand([B, H, T, D], 4);

  // ops.sdpa fwd + bwd
  time("ops.sdpa fwd", () => [ops.sdpa(q, k, v, scale, "causal")]);
  // Build the Vjp ONCE outside the timed loop (its construction is not what we're
  // measuring) and free the forward outputs each rep so only the bwd cost is timed.
  const sdpaVjp = new Vjp((p) => [ops.sdpa(p[0]!, p[1]!, p[2]!, scale, "causal")], 1);
  time("ops.sdpa fwd+bwd (vjp)", () => {
    const { outputs, vjps } = sdpaVjp.apply([q, k, v], [dO]);
    for (const o of outputs) o.dispose();
    return vjps;
  });
  sdpaVjp.dispose();

  // flash fwd, then bwd given the forward's O/L
  time("flash fwd", () => { const [O, L] = flashForward(q, k, v, scale, true); return [O, L]; });
  const [O, L] = flashForward(q, k, v, scale, true); ops.evalAll([O, L]);
  time("flash bwd (D+dKV+dQ)", () => flashBackward(q, k, v, O, L, dO, scale, true));
  O.dispose(); L.dispose();

  for (const a of [q, k, v, dO]) a.dispose();
}
