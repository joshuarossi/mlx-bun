import { test, expect } from "bun:test";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { ORACLE_PYTHON } from "../support/paths";
const artifact = Bun.env.MLX_BUN_TEST_ASSISTANT_DRAFT;
const oracle = String.raw`
import sys,json,hashlib
from pathlib import Path
import numpy as np
import mlx.core as mx
from optiq.runtime.spec.drafters.gemma_assistant import GemmaAssistantDrafter
model=GemmaAssistantDrafter.from_pretrained(sys.argv[1]); cfg=model.cfg
# The pinned loader assumes centroids from config even when the larger
# artifact omits them. Bind its tied embedding head from tensor presence.
centroids="masked_embedding.centroids.weight" in mx.load(str(next(Path(sys.argv[1]).glob("*.safetensors"))))

def data(shape,seed):
    size=int(np.prod(shape))
    return (((mx.arange(size)+seed)%97-48).astype(mx.float32)/64).reshape(shape).astype(mx.bfloat16)
def digest(a):return hashlib.sha256(np.asarray(a.astype(mx.float32)).tobytes()).hexdigest()
result=[]
for B in [1,2,4]:
    emb=data((B,1,cfg.backbone_hidden_size),3); hidden=data((B,1,cfg.backbone_hidden_size),11)
    shared={'sliding_attention':(data((B,cfg.num_key_value_heads,8,cfg.head_dim),17),data((B,cfg.num_key_value_heads,8,cfg.head_dim),29)),
            'full_attention':(data((B,cfg.num_key_value_heads,8,cfg.global_head_dim),37),data((B,cfg.num_key_value_heads,8,cfg.global_head_dim),43))}
    steps=[]
    for step in range(3):
        h=model.pre_projection(mx.concatenate([emb,hidden],axis=-1))
        for block in model.layers:h=block(h,shared_kv=shared,position=7+step,sliding_window=cfg.sliding_window)
        h=model.model_norm(h)
        tokens=[int(mx.argmax(model._centroid_decode(h[row:row+1]) if centroids else h[row:row+1] @ model.model_embed_tokens.weight.T).item()) for row in range(B)]
        hidden=model.post_projection(h)
        steps.append({'tokens':tokens,'hidden':digest(hidden)})
    result.append({'B':B,'steps':steps})
print(json.dumps(result))
`;

test.skipIf(!artifact)("assistant graph and device head match the pinned same-B oracle", async () => {
  const ref = spawnSync(ORACLE_PYTHON, ["-c", oracle, artifact!], { encoding: "utf8", maxBuffer: 1024 * 1024 });
  expect(ref.status, ref.stderr).toBe(0);
  const expected = JSON.parse(ref.stdout) as { B: number; steps: { tokens: number[]; hidden: string }[] }[];
  const { GemmaAssistantDrafter, plainAssistantDonors } = await import("../../src/spec/drafter");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const cfg = await Bun.file(`${artifact}/config.json`).json(), text = cfg.text_config ?? cfg;
  const backbone = cfg.backbone_hidden_size ?? text.backbone_hidden_size;
  const data = (shape: number[], seed: number) => {
    using input = MlxArray.fromFloat32(Float32Array.from({ length: shape.reduce((a,b)=>a*b,1) }, (_, i) => ((i+seed)%97-48)/64), shape);
    return input.astype(Dtype.bfloat16);
  };
  const drafter = await GemmaAssistantDrafter.load(artifact!);
  try {
    for (const run of expected) {
      const B = run.B;
      using emb = data([B,1,backbone],3);
      let hidden = data([B,1,backbone],11);
      using sk = data([B,text.num_key_value_heads,8,text.head_dim],17), sv = data([B,text.num_key_value_heads,8,text.head_dim],29);
      using fk = data([B,text.num_key_value_heads,8,text.global_head_dim],37), fv = data([B,text.num_key_value_heads,8,text.global_head_dim],43);
      const shared = { sliding: [sk,sv] as [typeof sk,typeof sv], full: [fk,fv] as [typeof fk,typeof fv] };
      try {
        for (const [step,wanted] of run.steps.entries()) {
          const output = drafter.forwardRows(emb,hidden,plainAssistantDonors(shared,7+step),7+step);
          hidden.dispose(); hidden=output.nextHidden;
          try {
            expect(output.tokens.toIntTokens(), `B${B} step${step} tokens`).toEqual(wanted.tokens);
            using floats=hidden.astype(Dtype.float32);
            expect(createHash('sha256').update(floats.rawBytesView()).digest('hex'), `B${B} step${step} hidden`).toBe(wanted.hidden);
          } finally { output.tokens.dispose(); }
        }
      } finally { hidden.dispose(); }
    }
  } finally { drafter.dispose(); clearCache(); }
}, 120000);
