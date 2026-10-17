import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { checkAffineLiftSourceBinding } from "./AffineLiftSourceBinding.ts";

const sourceHash = "cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const hash = (source: string) => createHash("sha256").update(source).digest("hex");

// Trusted extraction of the complete four-bit accumulation statement. Loop
// execution, pointer attachment and compiler lowering are separate obligations.
export function checkLiteral(source: string, lean: string): void {
  const header = source.match(/const HEADER = String\.raw`([\s\S]*?)`;/)?.[1];
  const body = header?.match(/for \(int i = 0; i < 4; i\+\+\) \{\n      ([\s\S]*?)\n    \}/)?.[1];
  const literal = lean.match(/def sourceBody : String := ("(?:\\.|[^"\\])*")/)?.[1];
  if (!body || !literal || body !== JSON.parse(literal)) throw new Error("Affine four-bit statement literal mismatch");
}

export function checkSource(source: string, lean: string): void {
  if (hash(source) !== sourceHash) throw new Error("Affine row source SHA256 mismatch");
  checkLiteral(source, lean);
}

function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("Affine four-bit guard mutation accepted");
}

export async function checkAffineDot4SourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const [source, lean] = await Promise.all([
    Bun.file(resolve(root, "../packages/inference/src/kernels/quantization/affine-row.ts")).text(),
    Bun.file(resolve(root, "kernels/quantization/AffineDot4Syntax.lean")).text(),
  ]);
  await checkAffineLiftSourceBinding(options);
  checkSource(source, lean);
  if (options.selfTest) {
    for (const bad of [source.replace("0x000f", "0x001f"),
      source.replace("x_thread[4 * i + 2]", "x_thread[4 * i + 1]"),
      source.replace("* MLXQ_F(ws[i] & 0x00f0)", "+ MLXQ_F(ws[i] & 0x00f0)"),
      source.replace("for (int i = 0; i < 4; i++)", "for (int i = 0; i < 3; i++)")]) {
      rejected(() => checkSource(bad, lean));
      rejected(() => checkLiteral(bad, lean));
    }
    rejected(() => checkSource(source + "\n", lean));
    rejected(() => checkSource(source, lean.replace("0xf000", "0xe000")));
    rejected(() => checkSource(source, lean.replace("def sourceBody", "def removedBody")));
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await checkAffineDot4SourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Affine four-bit accumulation bound to pinned source (host extraction boundary).");
}
