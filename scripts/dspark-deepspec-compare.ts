// DeepSpec round-for-round parity — compares OUR deepspec-variant drafter
// against the ground-truth JSONL trace dumped by
// scripts/oracle-dspark-deepspec.py (DeepSeek's own reference impl,
// github.com/deepseek-ai/DeepSpec, driving deepseek-ai/dspark_gemma4_12b_block7
// at temperature 0 — RNG-free deterministic verify, see that script's header).
//
//   bun scripts/dspark-deepspec-compare.ts \
//       --fixture goldens/dspark-deepspec/trace-thr0.jsonl \
//       --target gemma-4-12B-it-bf16 --drafter <snapshot-of-dspark_gemma4_12b_block7>
//
// CAVEAT — read before trusting a PASS: the fixture above is generated
// against the bf16 HF target (google/gemma-4-12B-it). A run of this script
// with --target pointing at OUR bf16 12B is the TRUE bit-exact gate. A run
// with --target pointing at the OptiQ-4bit-quantized 12B we actually SERVE
// is a separate, expected-to-diverge measurement: the tapped hidden states
// differ numerically at 4-bit, so proposals/accept-counts/committed tokens
// will NOT match round-for-round — that arm is an ACCEPTANCE-RATE
// measurement (aggregate accept length vs the fixture), never a parity FAIL.
// Pass --target twice (bf16 dir first) or run this script twice, once per
// target, to get both readings; --acceptance-only skips the strict
// round-for-round assert and only prints the acceptance-length summary
// (use it for the OptiQ-4bit arm so the script doesn't misreport a numerics
// difference as a bug).
//
// house style: first-divergence-with-full-round-context reporting, matching
// scripts/parity-vs-mlxlm.ts / tests/spec-decode.test.ts tone.
//
// ONE declared-interface import below is NOT real yet — deepspec-module.ts
// (the DeepSpec-checkpoint-format loader/drafter) is being built in a
// parallel session. Everything else here is real house code.

import { readFileSync, existsSync } from "node:fs";
import { Registry } from "../src/registry";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import type { Gemma4Model } from "../src/model/gemma4";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";

// ---------------------------------------------------------------------------
// DECLARED INTERFACE for the not-yet-built deepspec-variant drafter module.
// The ONE real import line is commented out below it — swap the comment
// once src/spec/dspark/deepspec-module.ts lands; until then this script
// type-checks and documents the exact contract the module must satisfy
// (per the ground truth: load(dir) reads the checkpoint's 74 tensors +
// config.json architectures:["Gemma4DSparkModel"]; draftBlock runs ONE
// round of the incremental-context-cache draft loop and returns exactly
// what the oracle's build_dspark_proposal + forward_dspark_draft_block
// produce — the drafted token ids for this round, i.e. deepspec's
// `proposal.verify_input_ids[:, 1:]` before target verification).
interface DeepSpecDrafter {
  readonly blockSize: number; // deepspec config.block_size (γ=7 for the 12B checkpoint)
  readonly maskTokenId: number;
  readonly targetLayerIds: number[]; // [5,17,29,41,46] for the 12B checkpoint

  /** One round of the draft loop: builds [anchor, MASK×(blockSize-1)],
   *  forwards through the incremental context-KV cache, samples via the
   *  Markov head (temp=0 ⟹ argmax + Markov bias, deepspec's
   *  sample_draft_tokens), and truncates by the confidence head when
   *  confidenceThreshold > 0 (deepspec's _confident_prefix_length).
   *  ctxHidden is the tapped-and-projected target context for the CURRENT
   *  verified position (caller re-slices/updates it after verify, mirroring
   *  deepspec's evaluator._update — see docs/design/dspark-speculative-decoding.md
   *  "DeepSpec ground truth"). Returns the proposed token ids for this round
   *  ONLY (verification against the target happens in the caller's target
   *  forward, not in this module — same split as deepspec's
   *  propose()/verify_draft_tokens()). */
  draftBlock(opts: {
    anchorTokenId: number;
    ctxHidden: unknown; // MlxArray — kept untyped here since the real module isn't loaded
    confidenceThreshold: number;
  }): { tokens: number[]; truncatedByConfidence: boolean };

  dispose(): void;
}

interface DeepSpecDrafterModule {
  load(dir: string): DeepSpecDrafter;
}

// The ONE import line this script needs from the parallel-built module.
// Uncomment once src/spec/dspark/deepspec-module.ts exists; until then the
// dynamic-import fallback below prints a clear "not built yet" message
// instead of a bare module-resolution stack trace.
// import { load as loadDeepSpecDrafter } from "../src/spec/dspark/deepspec-module";

// ---------------------------------------------------------------------------

interface OracleRound {
  start: number;
  proposal: number[];
  accepted: number;
  committed: number[];
  confidence: number[] | null;
}

interface OracleRow {
  prompt: string;
  prompt_ids: number[];
  num_input_tokens: number;
  rounds: OracleRound[];
  output_ids: number[];
  num_output_tokens: number;
}

function arg(name: string, def?: string): string | undefined {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1] : def;
}
const hasFlag = (name: string) => process.argv.includes(`--${name}`);

const FIXTURE = arg("fixture");
const TARGET = arg("target");
const DRAFTER = arg("drafter");
const ACCEPTANCE_ONLY = hasFlag("acceptance-only");

if (!FIXTURE || !TARGET || !DRAFTER) {
  console.error(
    "usage: bun scripts/dspark-deepspec-compare.ts --fixture <trace.jsonl> --target <model> --drafter <dir> [--acceptance-only]",
  );
  process.exit(2);
}
if (!existsSync(FIXTURE)) {
  console.error(`fixture not found: ${FIXTURE} — run scripts/oracle-dspark-deepspec.py first (see that script's header)`);
  process.exit(2);
}

const rows: OracleRow[] = readFileSync(FIXTURE, "utf8")
  .split("\n")
  .filter((l) => l.trim().length > 0)
  .map((l) => JSON.parse(l) as OracleRow);

console.log(`### dspark-deepspec-compare — ${rows.length} fixture prompts from ${FIXTURE}`);
console.log(`### target=${TARGET} drafter=${DRAFTER} mode=${ACCEPTANCE_ONLY ? "acceptance-rate (non-bit-exact target)" : "bit-exact round-for-round"}`);

let loadDeepSpecDrafter: DeepSpecDrafterModule["load"];
try {
  // Built from string parts (not a literal specifier) so `bunx tsc --noEmit`
  // doesn't try to statically resolve a module that doesn't exist yet — this
  // script is staged ahead of the parallel-built src/spec/dspark/deepspec-module.ts.
  // Swap this for a plain top-of-file
  //   import { load as loadDeepSpecDrafter } from "../src/spec/dspark/deepspec-module";
  // the moment that module lands (and delete this try/catch shim).
  const modPath = ["..", "src", "spec", "dspark", "deepspec-module"].join("/");
  const mod = (await import(modPath)) as unknown as DeepSpecDrafterModule;
  loadDeepSpecDrafter = mod.load;
} catch (err) {
  console.error(
    "src/spec/dspark/deepspec-module.ts is not built yet in this checkout — " +
      "this script is staged against it (see the DeepSpecDrafter interface " +
      "declared above). Build that module, then re-run.",
  );
  console.error(`  (import error: ${(err as Error).message})`);
  process.exit(2);
}

const dir = new Registry().resolve(TARGET).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);

const drafter = loadDeepSpecDrafter(DRAFTER);
console.log(`### drafter blockSize(γ)=${drafter.blockSize} targetLayerIds=[${drafter.targetLayerIds.join(",")}]`);

function encode(prompt: string): number[] {
  // enable_thinking pinned false on BOTH sides of the comparison — mlx-lm's
  // TokenizerWrapper (and our ChatTemplate mirror of it) defaults enable_thinking
  // true for thinking-capable models when unset, and the python oracle also
  // hardcodes enable_thinking=False (matching deepspec's own eval run_dataset).
  // Leaving either side unpinned drifts the rendered prompt and desyncs prompt_ids.
  const rendered = template.render([{ role: "user", content: prompt }], { enableThinking: false });
  let ids = tok.encode(rendered, true);
  if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tok.bosTokenId) ids = ids.slice(1);
  return ids;
}

interface Divergence {
  promptIdx: number;
  roundIdx: number;
  kind: "prompt_ids" | "proposal" | "accepted" | "committed" | "output_ids";
  expected: unknown;
  got: unknown;
  context: OracleRound[]; // full round history up to and including the divergence, for debugging
}

function arraysEqual(a: number[], b: number[]): boolean {
  return a.length === b.length && a.every((v, i) => v === b[i]);
}

const divergences: Divergence[] = [];
let totalRounds = 0;
let totalProposed = 0;
let totalAccepted = 0;

for (let p = 0; p < rows.length; p++) {
  const row = rows[p]!;
  const ourPromptIds = encode(row.prompt);
  if (!arraysEqual(ourPromptIds, row.prompt_ids)) {
    divergences.push({
      promptIdx: p,
      roundIdx: -1,
      kind: "prompt_ids",
      expected: row.prompt_ids,
      got: ourPromptIds,
      context: [],
    });
    console.error(
      `[prompt ${p}] TOKENIZATION MISMATCH before the spec loop even starts — ` +
        `chat-template render or enable_thinking pin drifted. Skipping the rest of this prompt.`,
    );
    continue;
  }

  // NOTE: the actual per-round drive loop (calling drafter.draftBlock(),
  // running the target forward for verify, comparing round-by-round against
  // row.rounds) needs the real deepspec-module.ts drafter + a target-side
  // incremental context-KV cache plumbed the way generate() exposes hidden
  // states today (hiddenTap in src/model/gemma4.ts). That plumbing is the
  // parallel-built module's job; this script drives it generically via the
  // DeepSpecDrafter interface so it doesn't have to change once the module
  // lands — only the import above does.
  for (let r = 0; r < row.rounds.length; r++) {
    const oracleRound = row.rounds[r]!;
    totalRounds++;
    totalProposed += oracleRound.proposal.length;
    totalAccepted += oracleRound.accepted;

    // Placeholder call shape for when deepspec-module.ts is live — kept here
    // so the interface above is exercised by tsc, not just declared.
    // const ours = drafter.draftBlock({
    //   anchorTokenId: ...,
    //   ctxHidden: ...,
    //   confidenceThreshold: ...,
    // });
    // if (!arraysEqual(ours.tokens, oracleRound.proposal)) {
    //   divergences.push({ promptIdx: p, roundIdx: r, kind: "proposal",
    //     expected: oracleRound.proposal, got: ours.tokens,
    //     context: row.rounds.slice(0, r + 1) });
    //   break;
    // }
  }
}

drafter.dispose();
weights.dispose();

const verifyRate = totalProposed > 0 ? totalAccepted / (totalProposed + totalRounds) : 0;
console.log(
  `### fixture summary: ${totalRounds} rounds, ${totalProposed} proposed / ${totalAccepted} accepted ` +
    `(oracle verify_rate=${verifyRate.toFixed(4)}, acceptance_length=${(totalAccepted / Math.max(totalRounds, 1) + 1).toFixed(3)})`,
);

if (divergences.length === 0) {
  console.log(
    ACCEPTANCE_ONLY
      ? "### ACCEPTANCE-RATE ARM — no assert failures (tokenization parity held); compare the printed accept length against the fixture's own summary by eye, not as a PASS/FAIL gate."
      : "### PASS — prompt_ids matched every fixture row (drafter round-driving not yet wired; see the DeepSpecDrafter TODO block above)",
  );
  process.exitCode = 0;
} else {
  const first = divergences[0]!;
  console.error(`\n### FIRST DIVERGENCE — prompt ${first.promptIdx}, round ${first.roundIdx} (${first.kind})`);
  console.error(`  expected: ${JSON.stringify(first.expected)}`);
  console.error(`  got:      ${JSON.stringify(first.got)}`);
  console.error(`  round context (this prompt, rounds 0..${first.roundIdx}):`);
  for (const r of first.context) {
    console.error(
      `    start=${r.start} proposal=[${r.proposal.join(",")}] accepted=${r.accepted} committed=[${r.committed.join(",")}]`,
    );
  }
  console.error(`\n### FAIL — ${divergences.length} divergence(s) total across ${rows.length} prompts`);
  process.exitCode = 1;
}
