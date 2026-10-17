import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const sourceHash = "cb5bd05e24a13547f5672cbe661c0262bc18969eea62266b185fcc3e68a1d20b";
const hash = (source: string) => createHash("sha256").update(source).digest("hex");

// Trusted byte extraction binds the parsed expression to the actual String.raw
// header. C++ preprocessing, compilation and primitive conformance are separate.
export function checkLiteral(source: string, lean: string): void {
  const header = source.match(/const HEADER = String\.raw`([\s\S]*?)`;/)?.[1];
  const body = header?.match(/^#define MLXQ_F\(q\) (.+)$/m)?.[1];
  const literal = lean.match(/def sourceBody : String := "([^"\n]+)"/)?.[1];
  if (!body || !literal || body !== literal) throw new Error("Affine lift macro literal mismatch");
}

export function checkSource(source: string, lean: string): void {
  if (hash(source) !== sourceHash) throw new Error("Affine row source SHA256 mismatch");
  checkLiteral(source, lean);
}

function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("Affine lift guard mutation accepted");
}

export async function checkAffineLiftSourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const [source, lean] = await Promise.all([
    Bun.file(resolve(root, "../packages/inference/src/kernels/quantization/affine-row.ts")).text(),
    Bun.file(resolve(root, "kernels/quantization/AffineLiftSource.lean")).text(),
  ]);
  checkSource(source, lean);
  if (options.selfTest) {
    for (const bad of [source.replace("0x4B000000u", "0x4A000000u"),
      source.replace("8388608.0f)", "8388607.0f)"),
      source.replace("(uint)(q)", "(float)(q)"),
      source.replace("as_type<float>((uint)(q)", "float((uint)(q)")]) {
      rejected(() => checkSource(bad, lean));
      rejected(() => checkLiteral(bad, lean));
    }
    rejected(() => checkSource(source + "\n", lean));
    rejected(() => checkSource(source, lean.replace("0x4B000000u", "0x4A000000u")));
    rejected(() => checkSource(source, lean.replace("def sourceBody", "def removedBody")));
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await checkAffineLiftSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Affine lift macro bound to pinned source (host extraction boundary).");
}
