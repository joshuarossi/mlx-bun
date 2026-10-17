import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { checkAffineLiftSourceBinding } from "./AffineLiftSourceBinding.ts";

const sourceHash = "cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const hash = (source: string) => createHash("sha256").update(source).digest("hex");

export function checkLiteral(source: string, lean: string): void {
  const header = source.match(/const HEADER = String\.raw`([\s\S]*?)`;/)?.[1];
  const body = header?.match(/w \+= 3 \* i;\n      ([\s\S]*?)\n    \}/)?.[1];
  const literal = lean.match(/def sourceBody : String := r#"([\s\S]*?)"#/)?.[1];
  if (!body || !literal || body !== literal) throw new Error("Affine three-bit statement literal mismatch");
}

export function checkSource(source: string, lean: string): void {
  if (hash(source) !== sourceHash) throw new Error("Affine row source SHA256 mismatch");
  checkLiteral(source, lean);
}

function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("Affine three-bit guard mutation accepted");
}

export async function checkAffineDot3SourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const [source, lean] = await Promise.all([
    Bun.file(resolve(root, "../packages/inference/src/kernels/quantization/affine-row.ts")).text(),
    Bun.file(resolve(root, "kernels/quantization/AffineDot3Syntax.lean")).text(),
  ]);
  await checkAffineLiftSourceBinding(options);
  checkSource(source, lean);
  if (options.selfTest) {
    for (const [before, after] of [
      ["w[0] & 0x07", "w[0] & 0x0f"], ["w[1] & 0x01", "w[0] & 0x01"],
      ["(x_thread[2] * 256.0f)", "(x_thread[2] * 128.0f)"],
      ["(x_thread[5] * 256.0f)", "(x_thread[6] * 256.0f)"],
      ["accum += MLXQ_F(w[2] & 0xe0)", "accum = MLXQ_F(w[2] & 0xe0)"],
    ] as const) {
      const bad = source.replace(before, after);
      rejected(() => checkSource(bad, lean));
      rejected(() => checkLiteral(bad, lean));
    }
    rejected(() => checkSource(source + "\n", lean));
    rejected(() => checkSource(source, lean.replace("0x38", "0x30")));
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await checkAffineDot3SourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Affine three-bit accumulation bound to pinned source (host extraction boundary).");
}
