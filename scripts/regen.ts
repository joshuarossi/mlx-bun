#!/usr/bin/env bun
export {};
// regen dispatcher — one entry point, one sub-script per job.
//   bun scripts/regen.ts <parity|parity-26b|kvq|rotating-kvq|mixed-kv|lora|fused-sdpa|universal|qwen-parity|minicpm5|minicpm5-kv|turboquant|audio-fixtures> [args...]
// Each job lives in scripts/regen/<job>.ts and reads process.argv
// itself, so the job name is spliced out before the job module loads.
const JOBS = ["parity", "parity-26b", "kvq", "rotating-kvq", "mixed-kv", "lora", "fused-sdpa", "universal", "qwen-parity", "minicpm5", "minicpm5-kv", "turboquant", "audio-fixtures"] as const;
const job = process.argv[2];
if (!job || !(JOBS as readonly string[]).includes(job)) {
  console.error(`usage: bun scripts/regen.ts <${JOBS.join("|")}> [args...]`);
  process.exit(2);
}
process.argv.splice(2, 1);
await import(`./regen/${job}.ts`);
