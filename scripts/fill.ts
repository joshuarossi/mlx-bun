#!/usr/bin/env bun
export {};
// fill dispatcher — the token-fast-forwarding measurement harness (PLAN K3d;
// design: docs/design/speculative-decoding.md §7).
//
//   bun scripts/fill.ts replay --sessions <file|dir> --server-url <url>
//   bun scripts/fill.ts ab     --sessions <file|dir> --url-a <off> --url-b <on>
//   bun scripts/fill.ts ab     --showcase fixtures/showcase-silicon-exchange.txt --url-a … --url-b …
//   bun scripts/fill.ts report <runs.jsonl> [--by-tool]
//   bun scripts/fill.ts trace  <fill-trace.jsonl> [--all]      # proposal vs model output
//
// Replays recorded agent sessions with their tool results MOCKED VERBATIM —
// the transcript is the environment, so a run is deterministic and
// side-effect-free — and reports the paired verdict the echo tier has to pass.
// Each job lives in scripts/fill/<job>.ts and reads process.argv itself, so
// the job name is spliced out before the job module loads.
const JOBS = ["replay", "ab", "report", "trace"] as const;
const job = process.argv[2];
if (!job || !(JOBS as readonly string[]).includes(job)) {
  console.error(`usage: bun scripts/fill.ts <${JOBS.join("|")}> [args...]`);
  process.exit(2);
}
process.argv.splice(2, 1);
await import(`./fill/${job}.ts`);
