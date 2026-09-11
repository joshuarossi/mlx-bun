import { test, expect } from "bun:test";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { ORACLE_VENV } from "../support/paths";

const enabled = Bun.env.MLX_BUN_TEST_MASKED_DELTA === "1";
const oracle = String.raw`
import json,hashlib,numpy as np
import mlx.core as mx
from mlx_lm.models.gated_delta import gated_delta_update
def tensor(shape,shift,dtype=mx.bfloat16):
    size=int(np.prod(shape))
    return mx.array([((i*7+shift)%101-50)/256 for i in range(size)],dtype=dtype).reshape(shape)
def digest(a):return hashlib.sha256(np.asarray(a.astype(mx.float32)).tobytes()).hexdigest()
runs=[]
for B in [1,3]:
    Hk,Hv,Dk,Dv=16,48,128,128
    state=tensor([B,Hv,Dv,Dk],13,mx.float32)
    aLog=tensor([Hv],19); bias=tensor([Hv],23); steps=[]
    for index,T in enumerate([4,1,3,1]):
        q=tensor([B,T,Hk,Dk],index+1);k=tensor([B,T,Hk,Dk],index+3)
        v=tensor([B,T,Hv,Dv],index+5);a=tensor([B,T,Hv],index+7);b=tensor([B,T,Hv],index+9)
        mask=mx.array([[((row+index+t)%3!=0) and not (row==2 and index==0) for t in range(T)] for row in range(B)]) if index<3 else None
        y,state=gated_delta_update(q,k,v,a,b,aLog,bias,state,mask,use_kernel=True)
        steps.append({'T':T,'y':digest(y),'state':digest(state)})
    runs.append({'B':B,'steps':steps})
print(json.dumps(runs))
`;

test.skipIf(!enabled)("masked DeltaNet output and state match the pinned GPU oracle", async () => {
  const result = spawnSync(`${ORACLE_VENV}/bin/python`, ["-c", oracle], { encoding: "utf8" });
  expect(result.status, result.stderr).toBe(0);
  const reference = JSON.parse(result.stdout) as { B: number; steps: { T: number; y: string; state: string }[] }[];
  const { gatedDeltaUpdate } = await import("../../src/model/qwen3-delta");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype } = await import("../../src/mlx/ffi");
  const tensor = (shape: number[], shift: number, dtype = Dtype.bfloat16) => {
    using source = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a, b) => a * b, 1) },
      (_, i) => ((i * 7 + shift) % 101 - 50) / 256), shape);
    return source.astype(dtype);
  };
  const digest = (a: InstanceType<typeof MlxArray>) => {
    using f32 = a.astype(Dtype.float32);
    return createHash("sha256").update(f32.rawBytesView()).digest("hex");
  };
  for (const { B, steps } of reference) {
    let state = tensor([B, 48, 128, 128], 13, Dtype.float32);
    using aLog = tensor([48], 19), bias = tensor([48], 23);
    try {
      for (const [index, step] of steps.entries()) {
        const T = step.T;
        using q = tensor([B,T,16,128],index+1), k = tensor([B,T,16,128],index+3);
        using v = tensor([B,T,48,128],index+5), a = tensor([B,T,48],index+7), b = tensor([B,T,48],index+9);
        using flags = index < 3 ? MlxArray.fromInt32(Int32Array.from({ length: B*T }, (_, i) => {
          const row=Math.floor(i/T), t=i%T;
          return Number((row+index+t)%3!==0 && !(row===2 && index===0));
        }),[B,T]) : null;
        using mask = flags?.astype(Dtype.bool) ?? null;
        const [output, next] = gatedDeltaUpdate(q,k,v,a,b,aLog,bias,state,mask);
        state.dispose(); state = next;
        try { expect(digest(output),`B${B} step ${index} output`).toBe(step.y); expect(digest(state)).toBe(step.state); }
        finally { output.dispose(); }
      }
    } finally { state.dispose(); }
  }
},120_000);
