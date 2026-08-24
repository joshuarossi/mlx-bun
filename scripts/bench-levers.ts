#!/usr/bin/env bun
export {};
// bench-levers dispatcher — one entry point, one sub-script per job.
//   bun scripts/bench-levers.ts <faithful-matrix|fused-prefill|compiled-decode> [args...]
// Each job lives in scripts/bench/<job>.ts and reads process.argv
// itself, so the job name is spliced out before the job module loads.
const JOBS = ["faithful-matrix", "fused-prefill", "compiled-decode"] as const;
const job = process.argv[2];
if (!job || !(JOBS as readonly string[]).includes(job)) {
  console.error(`usage: bun scripts/bench-levers.ts <${JOBS.join("|")}> [args...]`);
  process.exit(2);
}
process.argv.splice(2, 1);
await import(`./bench/${job}.ts`);
