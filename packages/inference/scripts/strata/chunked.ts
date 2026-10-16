import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import * as ops from "@mlx-bun/mlx/ops";
import { computeG } from "../../src/kernels/delta/gated";
import { body, strataSource, replaceOnce } from "./source";

export interface RecurrenceInput {
  q: MlxArray; k: MlxArray; v: MlxArray; a: MlxArray; b: MlxArray;
  aLog: MlxArray; dt: MlxArray; state: MlxArray;
}

/** Strata's WY/UT kernels with mlx-bun's normalized inputs. State is already
 * in their [Dk,Hv,Dv] layout; its one-time preparation is outside the timing.
 * No inputs are mutated: the state and inter-chunk output have new outputs.
 * B=1 and Dk=Dv=128 only, for an isolated algorithm screen. */
export class ChunkedDelta {
  readonly sha256: string;
  readonly prep: MetalKernel;
  readonly state: MetalKernel;
  readonly out: MetalKernel;
  constructor(root: string) {
    const { source, sha256 } = strataSource(root, "gdn_prompt.metal");
    this.sha256 = sha256;
    const header = "struct GdnPArgs { int n_tok, h_k, h_v; }; constant constexpr int GC = 32;";
    const prelude = `const uint3 tg = threadgroup_position_in_grid;
      const ushort tid = thread_index_in_threadgroup, sg = simdgroup_index_in_threadgroup, lane = thread_index_in_simdgroup;
      const GdnPArgs a{NTOK, HK, HV};\n`;
    const adapted = (name: string) => replaceOnce(body(source, name), "hk = h % hkn", "hk = h / (hv / hkn)");
    this.prep = new MetalKernel({ name: "strata_screen_cprep", inputNames: ["qn", "kn", "vc", "gb"],
      outputNames: ["U", "W", "lgo"], header, source: prelude + "const device float2* gb2 = (const device float2*)gb;\n" + adapted("gdn_cprep").replaceAll("gb[", "gb2[") });
    this.state = new MetalKernel({ name: "strata_screen_cstate", inputNames: ["state", "qn", "kn", "U", "W", "lgo"],
      outputNames: ["delta", "o", "next"], header,
      source: prelude + replaceOnce(adapted("gdn_cstate"), "state[((i0 + r) * hv + h) * S + j] = st[r]", "next[((i0 + r) * hv + h) * S + j] = st[r]") });
    this.out = new MetalKernel({ name: "strata_screen_cout", inputNames: ["qn", "kn", "delta", "lgo", "o"],
      outputNames: ["y"], header, source: prelude + replaceOnce(replaceOnce(adapted("gdn_cout"),
        "const float scale = 1.0f / sqrt(float(S));", "const float scale = 1.0f;"),
        "o[((t0 + t) * hv + h) * S + j] = s * scale", "y[((t0 + t) * hv + h) * S + j] = s * scale") });
  }
  apply(x: RecurrenceInput): MlxArray[] {
    const [B, T, HK, DK] = x.q.shape, HV = x.v.shape[2]!;
    if (B !== 1 || DK !== 128 || x.v.shape[3] !== 128) throw new Error("chunked screen requires B=1, Dk=Dv=128");
    const NC = Math.ceil(T! / 32), templateInts = { NTOK: T!, HK: HK!, HV };
    using qn = x.q.astype(Dtype.float32); using kn = x.k.astype(Dtype.float32); using vc = x.v.astype(Dtype.float32);
    using g = computeG(x.aLog, x.a, x.dt); using beta = ops.sigmoid(x.b); using beta32 = beta.astype(Dtype.float32);
    using gb = ops.stackAxis([g, beta32], -1);
    const output = (shape: number[]) => ({ shape, dtype: Dtype.float32 });
    const [U, W, lgo] = this.prep.apply([qn, kn, vc, gb], { outputs: [output([HV, NC, 32, 128]), output([HV, NC, 32, 128]), output([HV, NC, 32])],
      grid: [HV * 256, NC, 1], threadGroup: [256, 1, 1], templateInts });
    try {
      const [delta, o, next] = this.state.apply([x.state, qn, kn, U!, W!, lgo!], { outputs: [output([HV, NC, 32, 128]), output([1, T!, HV, 128]), output(x.state.shape)],
        grid: [HV * 4 * 256, 1, 1], threadGroup: [256, 1, 1], templateInts });
      try {
        const [y] = this.out.apply([qn, kn, delta!, lgo!, o!], { outputs: [output([1, T!, HV, 128])],
          grid: [HV * 128, NC, 1], threadGroup: [128, 1, 1], templateInts });
        using wide = y!;
        return [wide.astype(x.q.dtype), next!];
      } catch (error) { next?.dispose(); throw error; }
      finally { delta?.dispose(); o?.dispose(); }
    } finally { U?.dispose(); W?.dispose(); lgo?.dispose(); }
  }
  dispose() { this.prep.dispose(); this.state.dispose(); this.out.dispose(); }
  [Symbol.dispose]() { this.dispose(); }
}
