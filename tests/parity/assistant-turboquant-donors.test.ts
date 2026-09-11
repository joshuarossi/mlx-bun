import { test, expect } from "bun:test";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { ORACLE_PYTHON } from "../support/paths";

const artifact = Bun.env.MLX_BUN_TEST_ASSISTANT_DRAFT;
const enabled = !!artifact && Bun.env.MLX_BUN_TEST_ASSISTANT_TQ_DONORS === "1";

// Independent codec reference: vendored vllm-metal Python, not the TS codec
// or its unfused kernels. The optiq graph receives its decoded bf16 K/V.
// The key input upcast matches the documented bf16-serving codec contract.
const oracle = String.raw`
import sys,json,hashlib,logging,types
from pathlib import Path
import numpy as np
import mlx.core as mx
logger=types.ModuleType('vllm.logger'); logger.init_logger=logging.getLogger
vllm=types.ModuleType('vllm'); vllm.logger=logger
sys.modules['vllm']=vllm; sys.modules['vllm.logger']=logger
sys.path.insert(0,'lab/repro/vllm-metal-turboquant')
import turboquant_reference as tq
from optiq.runtime.spec.drafters.gemma_assistant import GemmaAssistantDrafter
model=GemmaAssistantDrafter.from_pretrained(sys.argv[1]); cfg=model.cfg
centroids='masked_embedding.centroids.weight' in mx.load(str(next(Path(sys.argv[1]).glob('*.safetensors'))))
def data(shape,seed):
    return (((mx.arange(int(np.prod(shape)))+seed)%97-48).astype(mx.float32)/64).reshape(shape).astype(mx.bfloat16)
def digest(a): return hashlib.sha256(np.asarray(a.astype(mx.float32)).tobytes()).hexdigest()
def encoded_digest(a):
    if a.dtype in (mx.int8,mx.uint8,mx.int32,mx.uint32):
        return hashlib.sha256(np.ascontiguousarray(np.asarray(a)).tobytes()).hexdigest()
    return digest(a)
result=[]
for B in [1,2,4]:
    emb=data((B,1,cfg.backbone_hidden_size),3); hidden=data((B,1,cfg.backbone_hidden_size),11)
    sk=data((B,cfg.num_key_value_heads,8,cfg.head_dim),17); sv=data(sk.shape,29)
    fk=data((B,cfg.num_key_value_heads,8,cfg.global_head_dim),37); fv=data(fk.shape,43)
    kq,vq=tq.turbo_quant_encode(fk.astype(mx.float32),fv.astype(mx.float32),'q8_0',3)
    dk,dv=tq.turbo_quant_decode(kq,vq,mx.bfloat16,key_quant_type='q8_0',value_bits=3)
    shared={'sliding_attention':(sk,sv),'full_attention':(dk,dv)}
    steps=[]
    for step in range(3):
        h=model.pre_projection(mx.concatenate([emb,hidden],axis=-1))
        for block in model.layers: h=block(h,shared_kv=shared,position=7+step,sliding_window=cfg.sliding_window)
        h=model.model_norm(h)
        tokens=[int(mx.argmax(model._centroid_decode(h[row:row+1]) if centroids else h[row:row+1] @ model.model_embed_tokens.weight.T).item()) for row in range(B)]
        hidden=model.post_projection(h)
        steps.append({'tokens':tokens,'hidden':digest(hidden)})
    result.append({'B':B,'shape':list(dk.shape),'keys':np.asarray(dk.astype(mx.float32)).reshape(-1).tolist(),
        'values':np.asarray(dv.astype(mx.float32)).reshape(-1).tolist(),
        'decoded':[digest(dk),digest(dv)],'encoded':[encoded_digest(a) for a in (*kq,*vq)],'steps':steps})
print(json.dumps(result))
`;

interface OracleRow {
  B: number; shape: number[]; keys: number[]; values: number[];
  decoded: string[]; encoded: string[]; steps: { tokens: number[]; hidden: string }[];
}

test.skipIf(!enabled)("assistant TQ donors match independent codec and same-B optiq graph, fused on/off", async () => {
  const ref = spawnSync(ORACLE_PYTHON, ["-c", oracle, artifact!], {
    cwd: `${import.meta.dir}/../..`, encoding: "utf8", maxBuffer: 16 * 1024 * 1024,
  });
  expect(ref.status, ref.stderr).toBe(0);
  const expected = JSON.parse(ref.stdout) as OracleRow[];
  const { GemmaAssistantDrafter, plainAssistantDonors } = await import("../../src/spec/drafter");
  const { readAssistantDonors } = await import("../../src/backends/mlx/assistant-target");
  const { KVCache } = await import("../../src/model/gemma4-base");
  const { BatchedTurboQuantKVCache } = await import("../../src/model/batched-turboquant-kv");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const cfg = await Bun.file(`${artifact}/config.json`).json(), text = cfg.text_config ?? cfg;
  const backbone = cfg.backbone_hidden_size ?? text.backbone_hidden_size;
  const array = (shape: number[], values: number[]) => {
    using input = MlxArray.fromFloat32(new Float32Array(values), shape); return input.astype(Dtype.bfloat16);
  };
  const data = (shape: number[], seed: number) => array(shape,
    Array.from({ length: shape.reduce((a, b) => a * b, 1) }, (_, i) => ((i + seed) % 97 - 48) / 64));
  const digest = (a: InstanceType<typeof MlxArray>) => {
    using floats = a.astype(Dtype.float32); using contiguous = ops.contiguous(floats);
    return createHash("sha256").update(contiguous.rawBytesView()).digest("hex");
  };
  const encodedDigest = (a: InstanceType<typeof MlxArray>) => {
    if ([Dtype.int8, Dtype.uint8, Dtype.int32, Dtype.uint32].includes(a.dtype)) {
      using contiguous = ops.contiguous(a);
      return createHash("sha256").update(contiguous.rawBytesView()).digest("hex");
    }
    return digest(a);
  };
  const previous = process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE;
  const drafter = await GemmaAssistantDrafter.load(artifact!);
  try {
    for (const fused of ["0", "1"]) for (const run of expected) {
      process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE = fused;
      const B = run.B, label = `fused=${fused} B=${B}`;
      using emb = data([B, 1, backbone], 3);
      using sk = data([B, text.num_key_value_heads, 8, text.head_dim], 17), sv = data(sk.shape, 29);
      using fk = data(run.shape, 37), fv = data(run.shape, 43);
      using dk = array(run.shape, run.keys), dv = array(run.shape, run.values);
      const sliding = new KVCache(), full = new BatchedTurboQuantKVCache(8, 3);
      let hidden = data([B, 1, backbone], 11), controlHidden = data([B, 1, backbone], 11);
      let donors: ReturnType<typeof readAssistantDonors> | undefined;
      try {
        for (const a of sliding.updateAndFetch(sk, sv)) a.dispose();
        full.preparePrefill({ lengths: Array(B).fill(8) });
        for (const a of full.updateAndFetch(fk, fv)) a.dispose();
        const encoded = full.state().map(a => {
          using live = a.slice([0, 0, 0, 0], [B, a.shape[1]!, 8, a.shape[3]!]); return encodedDigest(live);
        });
        expect(encoded, `${label} independent codec encoding`).toEqual(run.encoded);
        const decoded = full.captureDonorRows();
        try {
          expect(decoded.keys.shape).toEqual(run.shape); expect(decoded.values.shape).toEqual(run.shape);
          expect([digest(decoded.keys), digest(decoded.values)], `${label} independent codec decoding`).toEqual(run.decoded);
          expect(decoded.starts).toEqual(Array(B).fill(0)); expect(decoded.ends).toEqual(Array(B).fill(8));
        } finally { decoded.keys.dispose(); decoded.values.dispose(); }
        donors = readAssistantDonors(sliding, full);
        expect(donors.positions).toEqual(Array(B).fill(7));
        // This second control is explicitly the frozen TS graph, with Python
        // decoded inputs. It is not an independent assistant implementation.
        const control = plainAssistantDonors({ sliding: [sk, sv], full: [dk, dv] }, 7);
        // Both views own their state, including lazy decoder dependencies.
        sliding.dispose(); full.dispose();
        for (const [step, wanted] of run.steps.entries()) {
          const output = drafter.forwardRows(emb, hidden, donors, 7 + step);
          hidden.dispose(); hidden = output.nextHidden;
          let controlTokens: InstanceType<typeof MlxArray> | undefined;
          try {
            const result = drafter.forwardRows(emb, controlHidden, control, 7 + step);
            controlHidden.dispose(); controlHidden = result.nextHidden; controlTokens = result.tokens;
            expect(output.tokens.toIntTokens(), `${label} step${step} optiq tokens`).toEqual(wanted.tokens);
            expect(digest(hidden), `${label} step${step} optiq hidden`).toBe(wanted.hidden);
            expect(controlTokens.toIntTokens(), `${label} step${step} frozen graph tokens`).toEqual(wanted.tokens);
            expect(digest(controlHidden), `${label} step${step} frozen graph hidden`).toBe(wanted.hidden);
          } finally { output.tokens.dispose(); controlTokens?.dispose(); }
        }
      } finally { donors?.dispose(); hidden.dispose(); controlHidden.dispose(); sliding.dispose(); full.dispose(); }
    }
  } finally {
    drafter.dispose(); clearCache();
    if (previous === undefined) delete process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE;
    else process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE = previous;
  }
}, 180000);
