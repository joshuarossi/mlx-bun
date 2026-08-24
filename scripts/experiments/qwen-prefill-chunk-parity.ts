// Compare the serving-visible final logits produced by 2,048- and 512-token
// Qwen prefill chunks. This gates the token-zero memory fix against an output
// change caused by DeltaNet chunk boundaries.

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Qwen35Model } from "../../src/model/qwen3_5";
import { clearCache } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { withModelWiredLimit } from "../../src/generate";

const MODEL = process.env.MODEL;
if (!MODEL) throw new Error("set MODEL to a local Qwen3.8 snapshot");
const N = Number(process.env.PROMPT_TOKENS ?? 1125);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const runtimeModel = createModel(weights, config);
if (!(runtimeModel instanceof Qwen35Model))
  throw new Error(`expected Qwen35Model, got ${runtimeModel.constructor.name}`);
const model = runtimeModel;
const prompt = Array.from({ length: N }, (_, i) => 1000 + (i % 10000));

async function logitsWithChunk(chunkSize: number): Promise<Float32Array> {
  const cache = model.makeCache();
  let pos = 0;
  try {
    while (prompt.length - pos - 1 > chunkSize) {
      const chunk = prompt.slice(pos, pos + chunkSize);
      const ids = ops.fromInt32(chunk, [1, chunk.length]);
      const h = model.forwardHidden(ids, cache);
      ids.dispose();
      h.dispose();
      ops.evalAll(cache.flatMap((c) => c.state()));
      clearCache();
      pos += chunk.length;
    }
    if (pos < prompt.length - 1) {
      const chunk = prompt.slice(pos, prompt.length - 1);
      const ids = ops.fromInt32(chunk, [1, chunk.length]);
      const h = model.forwardHidden(ids, cache);
      ids.dispose();
      h.dispose();
      ops.evalAll(cache.flatMap((c) => c.state()));
      clearCache();
      pos = prompt.length - 1;
    }
    const ids = ops.fromInt32(prompt.slice(pos), [1, prompt.length - pos]);
    const h = model.forwardHidden(ids, cache);
    ids.dispose();
    const logits = model.logitsFromHidden(h);
    h.dispose();
    const out = logits.toFloat32();
    logits.dispose();
    return out;
  } finally {
    for (const c of cache) c.dispose();
    clearCache();
  }
}

await withModelWiredLimit(model, async () => {
  const oldPath = await logitsWithChunk(2048);
  const newPath = await logitsWithChunk(512);
  let maxAbs = 0;
  let differing = 0;
  let oldArgmax = 0;
  let newArgmax = 0;
  for (let i = 0; i < oldPath.length; i++) {
    const diff = Math.abs(oldPath[i]! - newPath[i]!);
    if (diff !== 0) differing++;
    if (diff > maxAbs) maxAbs = diff;
    if (oldPath[i]! > oldPath[oldArgmax]!) oldArgmax = i;
    if (newPath[i]! > newPath[newArgmax]!) newArgmax = i;
  }
  console.log(JSON.stringify({
    model: MODEL,
    promptTokens: N,
    logits: oldPath.length,
    maxAbs,
    differing,
    oldArgmax,
    newArgmax,
    exact: differing === 0,
  }));
});

weights.dispose();
clearCache();
