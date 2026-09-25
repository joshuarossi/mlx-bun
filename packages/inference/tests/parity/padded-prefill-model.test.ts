// External report: { runtime, configSha256, rows: main padded-prefill oracle output }.
// Python/reference generation and all report data stay outside this package.
import { test, expect } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { strict as assert } from "node:assert";
const artifact = Bun.env.MLX_BUN_TEST_PADDED_PREFILL_MODEL;
const reportPath = Bun.env.MLX_BUN_TEST_PADDED_PREFILL_REFERENCE;
if (artifact && !existsSync(`${artifact}/config.json`)) throw new Error(`unavailable model: ${artifact}`);
const speculativeRotatingLayout = Bun.env.MLX_BUN_TEST_SPECULATIVE_ROTATING_LAYOUT === "1";
const delayedFullLayout = Bun.env.MLX_BUN_TEST_PADDED_FULL_LAYOUT;
const delayedRotatingLayout = Bun.env.MLX_BUN_TEST_PADDED_ROTATING_LAYOUT === "1";
type PaddedRow = {
  prompts: number[][]; side: "left" | "right"; counts: number[];
  states: (string[] | null)[][]; steps: string[][]; offsets: number[][];
};
type PaddedReference = { runtime: string; configSha256: string; rows: PaddedRow[] };
const sequences = [[1,101,201,301,401,501,601], [1,111,211,311,411,511,611,711,811,911,1011], [1,121,221,321,421]];
function expectedCases(wide: boolean) {
  const first = sequences[0]!;
  const cohorts = [sequences, [first], [first, first, first]];
  if (wide) cohorts.push(sequences.slice(0, 2), [...sequences, first], Array(8).fill(first));
  return cohorts.flatMap(prompts => {
    const width = Math.max(...prompts.map(p => p.length));
    return (["left", "right"] as const).flatMap(side =>
      [[width], [Math.floor(width / 2), width - Math.floor(width / 2) - 1, 1], Array(width).fill(1)]
        .map(counts => ({ prompts, side, counts })));
  });
}
/** Reject empty or incomplete references before loading native libraries. */
function validateReference(value: unknown, configSha256: string, wide: boolean): asserts value is PaddedReference {
  assert(value && typeof value === "object");
  const report = value as PaddedReference;
  assert.equal(typeof report.runtime, "string");
  assert(report.runtime.length > 0);
  assert.equal(report.configSha256, configSha256, "reference model config differs");
  assert(Array.isArray(report.rows));
  const cases = expectedCases(wide);
  assert.equal(report.rows.length, cases.length, "missing or extra padded cases");
  const hash = (v: unknown) => assert(typeof v === "string" && /^[a-f0-9]{64}$/.test(v), "invalid tensor hash");
  for (const [index, expected] of cases.entries()) {
    const row = report.rows[index]!;
    assert.deepEqual({ prompts: row.prompts, side: row.side, counts: row.counts }, expected, `case ${index} differs`);
    assert.equal(row.steps.length, 4, "prefill and three decode steps required");
    for (const step of row.steps) { assert.equal(step.length, row.prompts.length); step.forEach(hash); }
    assert.equal(row.states.length, row.counts.length, "missing prefill state");
    assert(row.offsets.length > 0, "missing cache layers");
    for (const offsets of row.offsets) assert.deepEqual(offsets, row.prompts.map(p => p.length));
    for (const chunk of row.states) {
      assert.equal(chunk.length, row.offsets.length, "missing cache state layer");
      for (const planes of chunk) if (planes !== null) { assert(planes.length > 0); planes.forEach(hash); }
    }
  }
}
test("padded reference requires the complete case matrix, tensors and matching model", () => {
  const report = { runtime: "0.32.2", configSha256: "a".repeat(64), rows: expectedCases(false).map(row => ({
    ...row, steps: Array.from({ length: 4 }, () => row.prompts.map(() => "b".repeat(64))),
    states: row.counts.map(() => [null]), offsets: [row.prompts.map(p => p.length)],
  })) };
  validateReference(report, report.configSha256, false);
  for (const mutate of [
    (r: typeof report) => { r.rows = []; },
    (r: typeof report) => { r.rows.pop(); },
    (r: typeof report) => { r.rows[1] = r.rows[0]!; },
    (r: typeof report) => { r.rows[0]!.steps.pop(); },
    (r: typeof report) => { r.rows[0]!.steps[0]![0] = ""; },
    (r: typeof report) => { r.rows[0]!.states = []; },
    (r: typeof report) => { r.configSha256 = "c".repeat(64); },
  ]) {
    const broken = structuredClone(report); mutate(broken);
    expect(() => validateReference(broken, report.configSha256, false)).toThrow();
  }
  expect(() => validateReference(report, report.configSha256, true)).toThrow();
});

test.skipIf(!artifact || !reportPath)("padded prompt batches and continuation match same-B model logits", async () => {
  const report: unknown = JSON.parse(readFileSync(reportPath!, "utf8"));
  const configSha256 = createHash("sha256").update(readFileSync(`${artifact}/config.json`)).digest("hex");
  validateReference(report, configSha256, Bun.env.MLX_BUN_TEST_PADDED_PREFILL_WIDE === "1");
  const reference = report.rows;
  const { Weights, loadModelConfig } = await import("@mlx-bun/inference/artifacts");
  const { createModel } = await import("@mlx-bun/inference/models");
  const { RotatingKVCache, SSMCache, BatchedSSMCache, BatchedKVCache, SpeculativeRotatingKVCache,
    BatchedRotatingCache, DelayedQuantizedKVCache, DelayedTurboQuantKVCache,
    DelayedRotatingQuantizedKVCache, createKvMaintenance } = await import("@mlx-bun/inference/state");
  const { MlxArray } = await import("@mlx-bun/mlx/array");
  const { Dtype, clearCache, MLX_VERSION } = await import("@mlx-bun/mlx/ffi");
  expect(report.runtime).toBe(MLX_VERSION);
  const weights = await Weights.open(artifact!), model = createModel(weights, await loadModelConfig(artifact!));
  try {
    for (const expected of reference) {
      const prompts=expected.prompts, B=prompts.length, width=Math.max(...prompts.map(p=>p.length)), pads=prompts.map(p=>width-p.length);
      const source=model.makeCache();
      // This mode checks the delayed layout's padded model execution before
      // conversion. Mixed-precision attention/state has its separate geometry
      // gate; the live model oracle here retains its plain KV representation.
      const caches=source.map(c=>c instanceof SSMCache ? new BatchedSSMCache() : c instanceof RotatingKVCache
        ? speculativeRotatingLayout ? new SpeculativeRotatingKVCache(c.maxSize) : delayedRotatingLayout ? new DelayedRotatingQuantizedKVCache(c.maxSize,64,4,Infinity,
          createKvMaintenance({kvBits:4,kvGroupSize:64,quantizedKvStart:Infinity}))
          : new BatchedRotatingCache(c.maxSize,Array(B).fill(0))
          : delayedFullLayout === "affine" ? new DelayedQuantizedKVCache(64,4,Infinity,
            createKvMaintenance({kvBits:4,kvGroupSize:64,quantizedKvStart:Infinity}))
          : delayedFullLayout === "turbo" ? new DelayedTurboQuantKVCache(8,3,Infinity,
            createKvMaintenance({turboQuant:{kBits:8,vBits:3},quantizedKvStart:Infinity})) : new BatchedKVCache());
      for(const c of source)c.dispose();
      try {
        for(const c of caches)c.preparePrefill({lengths:expected.side==='left'?Array(B).fill(width):prompts.map(p=>p.length),
          ...(expected.side==='left'?{leftPadding:pads}:{rightPadding:pads})});
        const inputs=prompts.map((p,row)=>expected.side==='left'?[...Array(pads[row]).fill(0),...p]:[...p,...Array(pads[row]).fill(0)]);
        let start=0;
        const { evalCacheState } = await import("@mlx-bun/inference/generation");
        const last=prompts.map((p)=>expected.side==='left'?width-1:p.length-1);
        const check = (logits: InstanceType<typeof MlxArray>, row: number, position: number, step: number) => {
          using slice=logits.slice([row,position,0],[row+1,position+1,logits.shape[2]!]);
          using f32=slice.astype(Dtype.float32);
          expect(createHash('sha256').update(f32.rawBytesView()).digest('hex'),`${expected.side} chunks ${expected.counts} step ${step} row ${row}`).toBe(expected.steps[step]![row]!);
        };
        for(const [chunk,count] of expected.counts.entries()) {
          using ids=MlxArray.fromInt32(Int32Array.from(inputs.flatMap(row=>row.slice(start,start+count))),[B,count]);
          using hidden=model.forwardHidden(ids,caches), logits=model.logitsFromHidden(hidden);
          for(let row=0;row<B;row++)if(start<=last[row]! && last[row]!<start+count)check(logits,row,last[row]!-start,0);
          evalCacheState(caches);
          for (const [layer,c] of caches.entries()) if (c instanceof SSMCache) {
            const hashes = c.state().map(a=>{
              using f32=a.astype(Dtype.float32);
              return createHash('sha256').update(f32.rawBytesView()).digest('hex');
            });
            expect(hashes,`${expected.side} chunk ${chunk} layer ${layer} recurrent/conv state`).toEqual(expected.states[chunk]![layer]!);
          }
          for(const c of caches)if('releaseRopeArr' in c)c.releaseRopeArr();
          start+=count;
        }
        for(const c of caches)c.finalizePrefill();
        expect(caches.map(c=>'rowOffsets' in c?c.rowOffsets:c.offsetArr)).toEqual(expected.offsets);
        for(let step=1;step<4;step++) {
          using ids=MlxArray.fromInt32(Int32Array.from(prompts.map((_,row)=>70+step+row)),[B,1]);
          using hidden=model.forwardHidden(ids,caches), logits=model.logitsFromHidden(hidden);
          for(let row=0;row<B;row++)check(logits,row,0,step);
          for(const c of caches)if('releaseRopeArr' in c)c.releaseRopeArr();
        }
      } finally {for(const c of caches)c.dispose();clearCache();}
    }
  } finally {weights.dispose();clearCache();}
},300_000);
