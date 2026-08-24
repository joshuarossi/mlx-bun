#!/usr/bin/env bun
export {};
// dspark dispatcher — one entry point, one sub-script per job.
//   bun scripts/dspark.ts <train|regen|calibrate|quantize|ab> [args...]
// Each job lives in scripts/dspark/<job>.ts and reads process.argv
// itself, so the job name is spliced out before the job module loads.
const JOBS = ["train", "regen", "calibrate", "quantize", "ab"] as const;
const job = process.argv[2];
if (!job || !(JOBS as readonly string[]).includes(job)) {
  console.error(`usage: bun scripts/dspark.ts <${JOBS.join("|")}> [args...]`);
  process.exit(2);
}
process.argv.splice(2, 1);
await import(`./dspark/${job}.ts`);
