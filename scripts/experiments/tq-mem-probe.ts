// Per-chunk GPU-memory curve during a long prefill — diagnosis harness for
// the 24 GB M4 async-OOM at ~10-16k prefill offset (2026-08-20). Replicates
// the production prefill op stream (chunked forwardHidden + evalCacheState +
// clearCache) while printing mlx allocator counters each chunk, so the
// growth term and the death offset are measured, not theorized.
//
//   bun scripts/experiments/tq-mem-probe.ts <model-dir> [target=32768] [chunk=2048]

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { activeMemory, cacheMemory, peakMemory, clearCache } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { evalCacheState } from "../../src/generate";

const dir = process.argv[2]!;
const target = Number(process.argv[3] ?? 32768);
const chunkSize = Number(process.argv[4] ?? 2048);

const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config);
const tok = await loadTokenizer(dir);

const PARA =
  "The tidal cycle is driven by the combined gravitational pull of the moon " +
  "and the sun acting on the ocean, modulated by coastline geometry and the " +
  "rotation of the earth through the Coriolis effect. ";
const ids = tok.encode(PARA.repeat(Math.ceil((target * 8) / PARA.length))).slice(0, target);

const gb = (b: number) => (b / 2 ** 30).toFixed(2);
console.log(`mem-probe ${dir} · target ${ids.length} · chunk ${chunkSize}`);
console.log("| offset | active GB | cache GB | peak GB |");
const cache = model.makeCache();
let pos = 0;
while (pos < ids.length) {
  const chunk = ids.slice(pos, pos + chunkSize);
  const cIds = ops.fromInt32(chunk, [1, chunk.length]);
  model.forwardHidden(cIds, cache).dispose();
  cIds.dispose();
  evalCacheState(cache);
  clearCache();
  pos += chunk.length;
  console.log(`| ${pos} | ${gb(activeMemory())} | ${gb(cacheMemory())} | ${gb(peakMemory())} |`);
}
console.log("prefill completed without crash");
