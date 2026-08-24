// Fit STS calibration (§3.2.1) for a trained DFlash drafter: run GREEDY
// dflashGenerate with pruning DISABLED (thresholds: []) so we measure the
// UNPRUNED head's confidence vs actual acceptance, collect per-position
// samples via onRound, fit per-position thresholds (calibration.ts), and
// write them into the checkpoint's dspark.json (config.sts) — every other
// field preserved verbatim.
//
//   bun scripts/dspark.ts calibrate --drafter <ckpt> --data <prompts.jsonl>

import { Gemma4Model } from "../../src/model/gemma4";
import { ChatTemplate, type ChatMessage } from "../../src/chat-template";
import { loadDsparkDrafter } from "../../src/spec/dspark/loader";
import { dflashGenerate } from "../../src/spec/dspark/generate-dflash";
import { fitStsThresholds, type ConfSample } from "../../src/spec/dspark/calibration";
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const { Registry } = await import("../../src/registry");
const { loadModelConfig } = await import("../../src/config");
const { Weights } = await import("../../src/weights");
const { createModel } = await import("../../src/model/factory");
const { loadTokenizer } = await import("../../src/tokenizer");

const arg = (n: string, d?: string) => { const i = process.argv.indexOf(`--${n}`); if (i >= 0 && i + 1 < process.argv.length) return process.argv[i + 1]!; if (d !== undefined) return d; throw new Error(`missing --${n}`); };
const flag = (n: string) => process.argv.includes(`--${n}`);
const num = (n: string, d: string) => parseInt(arg(n, d), 10);
const fnum = (n: string, d: string) => parseFloat(arg(n, d));

const MODEL = arg("model", "gemma-4-e4b-it-OptiQ-4bit");
const DRAFTER = arg("drafter");
const DATA = arg("data");
const N = num("n", "32");
const MAX_TOKENS = num("max-tokens", "128");
const TARGET = fnum("target", "0.5");
const MIN_SAMPLES = num("min-samples", "50");
const OUT = arg("out", DRAFTER); // default: in-place
const FORCE = flag("force");

const host = (await Bun.$`scutil --get LocalHostName`.text().catch(() => "unknown")).trim();
const ram = Math.round(Number((await Bun.$`sysctl -n hw.memsize`.text()).trim()) / 1073741824);

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const model = createModel(await Weights.open(dir), config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const template = await ChatTemplate.load(dir);
const eos = config.eosTokenIds;

const drafter = loadDsparkDrafter(DRAFTER);
if (drafter.cfg.sts && !FORCE) {
  throw new Error(
    `${DRAFTER} already has STS calibration (target=${drafter.cfg.sts.target}, samples=${drafter.cfg.sts.samples ?? "?"}) — pass --force to recalibrate`,
  );
}
console.log(`[calibrate] ${host} · ${ram}GB · ${MODEL} · γ=${drafter.cfg.gamma} tapLayers=${drafter.cfg.tapLayers}`);

interface Row { prompt: ChatMessage[] }
const rows = (await Bun.file(DATA).text()).split("\n").filter(Boolean).map((l) => JSON.parse(l) as Row);
const enc = (row: Row) => { const t = template.render(row.prompt, { addGenerationPrompt: true }); let ids = tok.encode(t, true); if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tok.bosTokenId) ids = ids.slice(1); return ids; };

// Collect (confidence, accepted) samples across all prompts, over the
// UNPRUNED head (thresholds: [] disables Alg-1 pruning during calibration —
// we need to see every position's confidence AND its real accept/reject
// outcome, which pruning would otherwise hide by never drafting the
// position at all).
const samples: ConfSample[] = [];
let used = 0;
for (let i = 0; i < rows.length && used < N; i++) {
  const ids = enc(rows[i]!);
  used++;
  const res = dflashGenerate(model, drafter, ids, {
    maxTokens: MAX_TOKENS,
    thresholds: [], // unpruned — measure the raw head
    onRound: (round) => samples.push(...round),
  });
  console.log(`  [${used}] ctx=${ids.length} emitted=${res.stats.emitted} acceptRate=${res.stats.acceptanceRate.toFixed(3)} meanConf=${res.stats.meanConf.toFixed(3)}`);
}

const sts = fitStsThresholds(samples, drafter.cfg.gamma, TARGET, MIN_SAMPLES);

// Per-position sample counts (provenance for the printout).
const counts = new Array(drafter.cfg.gamma).fill(0);
for (const s of samples) if (s.pos >= 0 && s.pos < drafter.cfg.gamma) counts[s.pos]++;

console.log(`\n[calibrate] fit over ${samples.length} samples (target=${TARGET}, minSamples=${MIN_SAMPLES})`);
for (let k = 0; k < drafter.cfg.gamma; k++) {
  console.log(`  pos ${k}: threshold=${sts.thresholds[k]!.toFixed(4)}  n=${counts[k]}`);
}

// Preserve every existing field in dspark.json; only set config.sts.
const metaPath = join(DRAFTER, "dspark.json");
const meta = JSON.parse(readFileSync(metaPath, "utf8")) as { config: Record<string, unknown>; [k: string]: unknown };
meta.config = { ...meta.config, sts };
if (OUT !== DRAFTER) {
  // Writing to a different dir: mirror the whole checkpoint dir's metadata,
  // but weights already live at DRAFTER — OUT must be an existing copy of
  // the checkpoint (this script only ever rewrites dspark.json).
  if (!existsSync(join(OUT, "dspark.json"))) throw new Error(`--out ${OUT} has no dspark.json — copy the checkpoint dir first`);
}
writeFileSync(join(OUT, "dspark.json"), JSON.stringify(meta, null, 2));
console.log(`\n[calibrate] wrote sts to ${join(OUT, "dspark.json")}`);
