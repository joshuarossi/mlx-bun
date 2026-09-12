/** Native RAM/SSD residency comparison, independent of model decode. */
import { ptr, toArrayBuffer } from "bun:ffi";
import { mkdtempSync, rmSync, mkdirSync, writeFileSync } from "node:fs";
import { tmpdir, hostname, cpus } from "node:os";
import { join, dirname } from "node:path";
import { HostBuffer } from "../../src/storage/host-buffer";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { SSMCache } from "../../src/model/qwen3-delta";
import { SsdCacheStore } from "../../src/ssd-cache";
import { TieredPromptCache } from "../../src/tiered-prompt-cache";
import { disposeResources } from "../../src/engine/resources";
const arg = (key: string, fallback = "") => process.argv.includes(key) ? process.argv[process.argv.indexOf(key) + 1]! : fallback;
const mib = Number(arg("--mib", "64")), turns = Number(arg("--turns", "8"));
using source = new HostBuffer(mib * 1024 ** 2);
new Uint8Array(toArrayBuffer(source.pointer as ReturnType<typeof ptr>, 0, source.bytes)).fill(37);
using tensor = MlxArray.adoptHostBuffer(source, [1, mib * 1024 ** 2 / 4], Dtype.float32);
const model = { makeCache: () => [new SSMCache()] };
const results = [];
for (const session of [false, true, true, false]) {
  const dir = mkdtempSync(join(tmpdir(), "session-residency-"));
  const ssd = new SsdCacheStore({ dir, maxBytes: Infinity, modelId: "residency", configFingerprint: "fixed", tokenizerHash: "fixed" });
  const cache = new TieredPromptCache(3 * (source.bytes + 4), ssd, {
    find(ids, ns) { const hit = ssd.find(ids, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
    findExact(ids, ns) { const hit = ssd.findExact(ids, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
    restore(handle) { const hit = ssd.restore(handle as Parameters<typeof ssd.restore>[0], model); return hit ? { ...hit, retain() {} } : null; },
    async restoreAsync(handle) { const hit = await ssd.restoreAsync(handle as Parameters<typeof ssd.restore>[0], model); return hit ? { ...hit, retain() {} } : null; },
    store: (ids, state, ns) => ssd.store(ids, state, ns),
  });
  const publish = async (ids: number[], id?: string) => {
    const c = new SSMCache(); c.offset = ids.length;
    c.conv = tensor.slice([0, 0], tensor.shape); c.recurrent = MlxArray.fromFloat32(new Float32Array([ids.length]), [1]);
    cache.put(ids, [c], "", undefined, undefined, id);
    if (!(await cache.durability.flush()).durable) throw new Error("persistence failed");
  };
  try {
    const times = []; const started = performance.now(); let ids = [1,2];
    for (let turn = 0; turn < turns; turn++) {
      await publish(ids, session ? "agent" : undefined);
      for (let noise = 0; noise < 4; noise++) await publish([100 + turn * 4 + noise]);
      const prompt = [...ids, 42], start = performance.now();
      const done = await cache.prefetch(prompt, "", session ? "agent" : undefined);
      const hit = cache.take(prompt, "", session ? "agent" : undefined);
      times.push(performance.now() - start);
      if (!hit || hit.tokens.length !== ids.length) throw new Error("wrong checkpoint");
      try {
        const c = hit.caches[0] as SSMCache;
        if (c.recurrent!.toFloat32()[0] !== ids.length || c.conv!.rawBytesView()[0] !== 37) throw new Error("state changed");
      } finally { disposeResources(hit.caches); hit.retain?.(); done(); }
      ids = prompt;
    }
    results.push({ session, times, totalMs: performance.now() - started, restores: ssd.stats.restores,
      restoredBytes: ssd.stats.restores * (source.bytes + 4), residentBytes: cache.totalBytes, sessionHits: cache.sessionHits });
  } finally { await cache.durability.flush(); cache.clear(); rmSync(dir, { recursive: true, force: true }); }
}
const report = { machine: hostname(), cpu: cpus()[0]?.model, bun: Bun.version, mib, turns,
  workload: "ABBA; three-checkpoint RAM budget; four unrelated durable publications between agent continuations; warm filesystem; real SSM bytes, no model decode", results };
const output = arg("--output"); if (output) { mkdirSync(dirname(output), { recursive: true }); writeFileSync(output, JSON.stringify(report, null, 2)); }
console.log(JSON.stringify(report, null, 2));
