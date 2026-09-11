import { expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { ORACLE_VENV } from "../support/paths";

const draft = Bun.env.MLX_BUN_TEST_MTP_PREFILL_DRAFT;
// Pinned mlx-lm supplies the decoder, norms, projections, RoPE and KV storage.
// Only the companion's fc/norm wrapper and its token/hidden pairing are supplied
// here. Each fixture explicitly lists those pairs, independently of the driver.
const oracle = String.raw`
import sys,json,hashlib,glob,copy
import numpy as np
import mlx.core as mx
import mlx.nn as nn
from mlx_lm.models.qwen3_5 import DecoderLayer,TextModelArgs
from mlx_lm.models.cache import KVCache,BatchKVCache
cfg=json.load(open(sys.argv[1]+'/config.json'));args=TextModelArgs.from_dict(cfg['text_config']);H=args.hidden_size
class Companion(nn.Module):
 def __init__(self):
  super().__init__();self.fc=nn.Linear(2*H,H,bias=False)
  self.pre_fc_norm_embedding=nn.RMSNorm(H,eps=args.rms_norm_eps)
  self.pre_fc_norm_hidden=nn.RMSNorm(H,eps=args.rms_norm_eps)
  self.layers=[DecoderLayer(args,args.full_attention_interval-1)]
  self.norm=nn.RMSNorm(H,eps=args.rms_norm_eps)
 def merged(self,e,h):return self.fc(mx.concatenate([self.pre_fc_norm_embedding(e),self.pre_fc_norm_hidden(h)],axis=2))
 def __call__(self,e,h,c):
  x=self.merged(e,h);return self.norm(self.layers[0](x,c.make_mask(x.shape[1],return_array=False,window_size=None),c))
m=Companion();weights={}
for f in glob.glob(sys.argv[1]+'/*.safetensors'):weights.update(mx.load(f))
q=cfg['quantization'];nn.quantize(m,group_size=q['group_size'],bits=q['bits'],class_predicate=lambda p,l: q.get(p,True) if p+'.scales' in weights else False)
m.load_weights(list(weights.items()));mx.eval(m.parameters())
def features(ids,factor):
 ids=mx.array(ids,dtype=mx.int32)[:,:,None];cols=mx.arange(H)[None,None,:]
 return (((ids*factor+cols*7)%127-63).astype(mx.float32)/128).astype(mx.bfloat16)
def digest(a):return hashlib.sha256(np.asarray(a.astype(mx.float32)).tobytes()).hexdigest()
def clone(c):
 x=KVCache();x.keys=c.keys;x.values=c.values;x.offset=c.offset;return x
rows=[];hidden=[];donor=None;result=[]
frames=json.load(sys.stdin)
for f in frames:
 if 'keep' in f:rows=[rows[i] for i in f['keep']];hidden=[hidden[i] for i in f['keep']]
 if 'append' in f:
  for value in f['append']:
   if value is None:rows.append(KVCache());hidden.append(None)
   else:rows.append(clone(donor[0]));hidden.append(donor[1])
 if 'pairs' not in f:continue
 for pair in f['pairs']:
  ids=pair['ids'];ctx=pair['hidden'];B=len(ids);N=len(ids[0]);layer=m.layers[0];a=layer.self_attn
  x=layer.input_layernorm(m.merged(features(ids,17),features(ctx,31)))
  k=a.k_norm(a.k_proj(x).reshape(B,N,args.num_key_value_heads,args.head_dim)).transpose(0,2,1,3)
  v=a.v_proj(x).reshape(B,N,args.num_key_value_heads,args.head_dim).transpose(0,2,1,3)
  offsets=[c.offset for c in rows]
  k=a.rope(k,offset=offsets[0] if len(set(offsets))==1 else mx.array(offsets,dtype=mx.int32))
  mx.eval(k,v)
  for i,c in enumerate(rows):
   if pair.get('keep',[True]*B)[i]:c.update_and_fetch(k[i:i+1],v[i:i+1])
 hidden=[features([[t]],31) for t in f['tail']]
 states=[]
 for c,h in zip(rows,hidden):
  states.append({'offset':c.offset,'arrays':([digest(c.keys[...,:c.offset,:]),digest(c.values[...,:c.offset,:])] if c.offset else [])+[digest(h)]})
 if f.get('save'):donor=(clone(rows[0]),hidden[0])
 # Full decoder continuation checks attention/MLP after the prepared KV.
 c=BatchKVCache.merge(rows)
 if len(set(x.offset for x in rows))==1:
  scalar=KVCache();scalar.keys=c.keys;scalar.values=c.values;scalar.offset=rows[0].offset;c=scalar
 ids=[[71+i] for i in range(len(rows))]
 out=m(features(ids,17),features(ids,31),c);mx.eval(out)
 result.append({'states':states,'continuation':digest(out)})
print(json.dumps(result))
`;

const frames = [
  { append: [null], tokens: [[1, 2, 3]], pairs: [{ ids: [[2, 3]], hidden: [[1, 2]] }], tail: [3], save: true },
  { append: [null, 0], tokens: [[4, 5], [11, 12], [4, 5]], pairs: [
    { ids: [[4], [11], [4]], hidden: [[3], [0], [3]], keep: [true, false, true] },
    { ids: [[5], [12], [5]], hidden: [[4], [11], [4]] }], tail: [5, 12, 5] },
  { keep: [1, 0], tokens: [[13], [6]], pairs: [{ ids: [[13], [6]], hidden: [[12], [5]] }], tail: [13, 6] },
  { keep: [], append: [0], tokens: [[4]], pairs: [{ ids: [[4]], hidden: [[3]] }], tail: [4] },
  { append: [null, null, null], tokens: [[5, 6], [21, 22], [31, 32], [41, 42]], pairs: [
    { ids: [[5], [21], [31], [41]], hidden: [[4], [0], [0], [0]], keep: [true, false, false, false] },
    { ids: [[6], [22], [32], [42]], hidden: [[5], [21], [31], [41]] }], tail: [6, 22, 32, 42] },
  { keep: [], append: [null], tokens: [Array.from({ length: 2051 }, (_, i) => i + 1)], pairs: [
    { ids: [Array.from({ length: 2048 }, (_, i) => i + 2)], hidden: [Array.from({ length: 2048 }, (_, i) => i + 1)] },
    { ids: [[2050, 2051]], hidden: [[2049, 2050]] }], tail: [2051] },
];

test.skipIf(!draft)("MTP prefill KV and full decoder continuation match pinned same-B operations through cold joins and restored prefixes", async () => {
  const ref = spawnSync(`${ORACLE_VENV}/bin/python`, ["-c", oracle, draft!], {
    input: JSON.stringify(frames), encoding: "utf8", maxBuffer: 8 * 1024 ** 2,
  });
  expect(ref.status, ref.stderr).toBe(0);
  const expected = JSON.parse(ref.stdout) as Array<{ states: Array<{ offset: number; arrays: string[] }>; continuation: string }>;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { MtpModule } = await import("../../src/spec/qwen-mtp-module");
  const { QwenMtpRows } = await import("../../src/spec/qwen-mtp-rows");
  const { BatchedKVCache } = await import("../../src/model/batched-kv");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  using resources = new DisposableStack();
  const weights = await Weights.open(draft!); resources.defer(() => weights.dispose());
  const config = await loadModelConfig(draft!), H = config.text.hiddenSize;
  const module = new MtpModule(weights, config, resources);
  const features = (ids: number[][], factor: number) => {
    using f32 = MlxArray.fromFloat32(Float32Array.from(ids.flatMap(row => row.flatMap(token =>
      Array.from({ length: H }, (_, col) => ((token * factor + col * 7) % 127 - 63) / 128)))), [ids.length, ids[0]!.length, H]);
    return f32.astype(Dtype.bfloat16);
  };
  const digest = (array: InstanceType<typeof MlxArray>) => {
    using f32 = array.astype(Dtype.float32); using contiguous = ops.contiguous(f32);
    return createHash("sha256").update(contiguous.rawBytesView()).digest("hex");
  };
  const target = { hiddenSize: H, layerCount: 1,
    embed(ids: InstanceType<typeof MlxArray>) {
      using packed = ops.contiguous(ids);
      const tokens = packed.toIntTokens(), N = ids.shape[1]!;
      return features(Array.from({ length: ids.shape[0]! }, (_, row) => tokens.slice(row * N, (row + 1) * N)), 17);
    }, logitsFromHidden(): InstanceType<typeof MlxArray> { throw new Error("prefill must not project logits"); },
  };
  const rows = new QwenMtpRows(target, module, null, []);
  type State = import("../../src/spec/qwen-mtp-rows").MtpRowState;
  let donor: State | undefined;
  try {
    for (const [step, frame] of frames.entries()) {
      if (frame.keep) rows.filterRows(frame.keep);
      if (frame.append) rows.append(frame.append.map(value => value === null ? null : donor!));
      using ids = ops.fromInt32(frame.tokens.flat(), [frame.tokens.length, frame.tokens[0]!.length]);
      using context = features(frame.tokens, 31);
      rows.prefill(ids, context);
      const states = Array.from({ length: rows.rowCount }, (_, row) => rows.extractRow(row));
      try {
        for (const [row, state] of states.entries()) {
          const arrays = state.cache.offset ? [...state.cache.temporalView(), state.hidden] : [state.hidden];
          try {
            const reference = expected[step]!.states[row]!;
            expect({ offset: state.cache.offset, arrays: arrays.map(digest) }, `step ${step}, row ${row}`).toEqual({offset:reference.offset,arrays:reference.arrays});
          } finally { for (const a of arrays) if (a !== state.hidden) a.dispose(); }
        }
        if (frame.save) donor = rows.extractRow(0);
        const cache = new BatchedKVCache(); cache.mergeRows(states.map(state => state.cache));
        try {
          const tokens = states.map((_, row) => [71 + row]);
          using embeds = features(tokens, 17), hidden = features(tokens, 31);
          using output = module.forward(embeds, hidden, cache);
          expect(digest(output), `step ${step} full decoder continuation`).toBe(expected[step]!.continuation);
        } finally { cache.dispose(); }
      } finally { for (const state of states) { state.cache.dispose(); state.hidden.dispose(); } }
    }
  } finally { rows.dispose(); donor?.cache.dispose(); donor?.hidden.dispose(); clearCache(); }
}, 180000);
