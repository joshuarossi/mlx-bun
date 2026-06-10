// Phase 1 exit-criterion script, part 1: load a model from the HF cache,
// print every tensor's name/shape/dtype, and wrap each one as a zero-copy
// mlx array (lazy — no weight pages are touched).
//
// Usage: bun scripts/inspect-model.ts <model-dir> [--quiet]

import { loadModelConfig, quantFor } from "../src/config";
import { Weights } from "../src/weights";
import { activeMemory } from "../src/mlx/ffi";

const modelDir = process.argv[2];
const quiet = process.argv.includes("--quiet");
if (!modelDir) {
  console.error("usage: bun scripts/inspect-model.ts <model-dir> [--quiet]");
  process.exit(1);
}

const t0 = performance.now();
const config = await loadModelConfig(modelDir);
const weights = await Weights.open(modelDir);
const tLoad = performance.now() - t0;

let totalBytes = 0;
let wrapped = 0;
for (const name of weights.tensorNames) {
  const info = weights.info(name);
  const arr = weights.tensor(name); // zero-copy wrap
  const sizeBytes = info.end - info.begin;
  totalBytes += sizeBytes;
  // cross-check mlx's view of the tensor against the safetensors header
  if (arr.shape.join(",") !== info.shape.join(","))
    throw new Error(`${name}: mlx shape ${arr.shape} != header ${info.shape}`);
  wrapped++;
  if (!quiet)
    console.log(`${name}  ${info.dtype}  [${info.shape.join(", ")}]`);
}
const tWrap = performance.now() - t0;

console.log(`\nmodel_type: ${config.modelType} (${config.architectures.join(", ")})`);
console.log(`layers: ${config.text.numHiddenLayers}, hidden: ${config.text.hiddenSize}, vocab: ${config.text.vocabSize}`);
if (config.quantization) {
  const q = config.quantization;
  console.log(`quantization: default ${q.default.bits}-bit g${q.default.groupSize} ${q.default.mode}, ${q.perLayer.size} per-layer overrides`);
  const sample = "language_model.model.embed_tokens";
  console.log(`  e.g. ${sample}: ${JSON.stringify(quantFor(q, sample))}`);
}
if (config.kvQuant) {
  const bits = new Set(config.kvQuant.map((e) => e.bits));
  console.log(`kv quant: ${config.kvQuant.length} layers, bits used: ${[...bits].join("/")}`);
}
console.log(`vision sidecar: ${config.hasVisionSidecar}`);
console.log(`tensors: ${wrapped}, total ${(totalBytes / 1e9).toFixed(2)} GB across ${weights.shards.files.size} shard(s)`);
console.log(`config+mmap: ${tLoad.toFixed(0)} ms, + wrap all tensors as mlx arrays: ${tWrap.toFixed(0)} ms`);
console.log(`mlx active memory: ${(activeMemory() / 1e6).toFixed(1)} MB (counts wrapped external buffers — accounting, not allocation)`);
console.log(`process rss: ${(process.memoryUsage.rss() / 1e6).toFixed(0)} MB (zero-copy: stays tiny; pages fault in only when the GPU touches them)`);
