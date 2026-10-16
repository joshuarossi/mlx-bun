import { readFileSync } from "node:fs";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import * as ops from "@mlx-bun/mlx/ops";
import { computeG, gatedDeltaUpdate } from "../../src/kernels/delta/gated";
import { gatedDeltaState } from "../../src/kernels/delta/state";
import type { RecurrenceInput } from "./chunked";

// Apply the snapshot experiment to the actual oracle body, without maintaining
// a second copy. Fail if the source anchor changes; report its hash in screen.ts.
const original = readFileSync(new URL("../../src/kernels/delta/gated.ts", import.meta.url), "utf8")
  .match(/const SOURCE = String.raw`([\s\S]*?)`;/)?.[1];
const anchor = "// Increment data pointers to next time step";
if (!original?.includes(anchor)) throw new Error("gated.ts no longer exposes the screened source anchor");
const SOURCE = original.replace(anchor, `
  if (t == 0) for (int i = 0; i < n_per_t; ++i)
    first[(n * Dv + dv_idx) * Dk + n_per_t * dk_idx + i] = state[i];
  ${anchor}`);
let kernel: MetalKernel | undefined;

function snapshot(x: RecurrenceInput): MlxArray[] {
  const [B, T, Hk, Dk] = x.q.shape as [number, number, number, number];
  const Hv = x.v.shape[2]!, Dv = x.v.shape[3]!;
  using g = computeG(x.aLog, x.a, x.dt); using beta = ops.sigmoid(x.b); using t = ops.fromInt32([T], [1]);
  kernel ??= new MetalKernel({ name: "strata_screen_first_state", inputNames: ["q", "k", "v", "g", "beta", "state_in", "Tin"],
    outputNames: ["y", "state_out", "first"], source: SOURCE });
  return kernel.apply([x.q, x.k, x.v, g, beta, x.state, t], {
    outputs: [{ shape: [B, T, Hv, Dv], dtype: x.q.dtype }, { shape: x.state.shape, dtype: Dtype.float32 }, { shape: x.state.shape, dtype: Dtype.float32 }],
    grid: [32, Dv, B * Hv], threadGroup: [32, 4, 1],
    templateInts: { Dk, Dv, Hk, Hv }, templateDtypes: { InT: x.q.dtype, StT: Dtype.float32 },
  });
}
export function retainedBaseline(x: RecurrenceInput, lengths: number[]): MlxArray[] {
  const [y, final] = gatedDeltaUpdate(x.q, x.k, x.v, x.a, x.b, x.aLog, x.dt, x.state);
  const kept = gatedDeltaState(x.k, x.v, x.a, x.b, x.aLog, x.dt, x.state, lengths);
  final.dispose();
  return [y, kept];
}
export function retainedFirst(x: RecurrenceInput, lengths: number[]): MlxArray[] {
  if (lengths.some(n => n < 1)) throw new Error("snapshot screen requires a guaranteed retained first token per row");
  const [y, final, first] = snapshot(x);
  final!.dispose();
  if (lengths.every(n => n === 1)) return [y!, first!];
  const tail = (a: MlxArray) => a.slice(a.shape.map((_, i) => i === 1 ? 1 : 0), a.shape);
  using k = tail(x.k); using v = tail(x.v); using a = tail(x.a); using b = tail(x.b);
  try {
    return [y!, gatedDeltaState(k, v, a, b, x.aLog, x.dt, first!, lengths.map(n => n - 1))];
  } catch (error) { y!.dispose(); throw error; }
  finally { first!.dispose(); }
}
