import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { checkAffineOutputSourceBinding } from "./AffineOutputSourceBinding.ts";

const sourceHash = "cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const leanHash = "2db2ea815de66b2489027cc1c09cd95deafe9516e3b902b9a18cf3e1ef30bbe0";
const hash = (source: string) => createHash("sha256").update(source).digest("hex");

// Pins a reviewed host translation; no TypeScript frontend/native metadata
// equivalence is claimed. In particular, eligibility does not by itself prove
// that the model installs this wrapper for a particular projection.
export function checkTranslation(source: string, lean: string): void {
  if (hash(source) !== sourceHash) throw new Error("Affine row host source drift");
  if (hash(lean) !== leanHash) throw new Error("Affine row reviewed host translation drift");
  for (const fragment of [
    "const R = 4, S = 16;",
    'if (spec.mode !== "affine" || spec.groupSize !== 64 || (spec.bits !== 3 && spec.bits !== 4)) return false;',
    "const N = scales.shape[0]!, K = scales.shape[1]! * 64;",
    "return rows === 1 && K % 512 === 0 && K <= 7680 && N % (R * S) === 0 && w.shape.length === 2;",
    "const K = x.shape.at(-1)!, M = x.size / K, N = scales.shape[0]!;",
    "if (M !== 1) throw new Error(`affineRow: M=${M}, one row only`);",
    "ensureRowContiguous: true",
    "grid: [32, N / R, 1], threadGroup: [32, S, 1],",
    "templateDtypes: { T: x.dtype },",
    "templateInts: { N, K, BITS: bits, R, S },",
  ]) if (!source.includes(fragment)) throw new Error("Affine row host translation fragment mismatch");
}

function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("Affine row host mutation accepted");
}

export async function checkAffineRowHostSourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const [source, lean] = await Promise.all([
    Bun.file(resolve(root, "../packages/inference/src/kernels/quantization/affine-row.ts")).text(),
    Bun.file(resolve(root, "kernels/quantization/AffineRowHostSelection.lean")).text(),
  ]);
  await checkAffineOutputSourceBinding(options);
  checkTranslation(source, lean);
  if (options.selfTest) {
    for (const [before, after] of [
      ["S = 16", "S = 8"], ["K <= 7680", "K <= 8192"],
      ["N % (R * S) === 0", "N % R === 0"], ["spec.groupSize !== 64", "spec.groupSize !== 32"],
      ["w.shape.length === 2", "w.shape.length === 3"], ["N / R", "N / S"],
      ["threadGroup: [32, S, 1]", "threadGroup: [32, R, 1]"],
    ]) rejected(() => checkTranslation(source.replace(before!, after!), lean));
    rejected(() => checkTranslation(source, lean.replace("m.scaleRows%(4*16)", "m.scaleRows%4")));
    rejected(() => checkTranslation(source, lean.replace("m.scaleGroups*64≤7680", "m.scaleGroups*64≤8192")));
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await checkAffineRowHostSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Affine row reviewed host translation binding passed (manual translation boundary).");
}
