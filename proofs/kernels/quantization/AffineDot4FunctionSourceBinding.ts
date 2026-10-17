import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { checkAffineDot4LoopSourceBinding } from "./AffineDot4LoopSourceBinding.ts";

export function checkLiteral(source: string, lean: string): void {
  const header = source.match(/const HEADER = String\.raw`([\s\S]*?)`;/)?.[1];
  const body = header?.match(/inline float mlxq_qdot\([^\n]+\) \{([\s\S]*)\n\}/)?.[1];
  if (!body) throw new Error("Affine qdot function missing");
  const statements = [
    ["sourceInitializer", body.match(/\n  (float accum[^\n]*)/)?.[1]],
    ["sourcePointer", body.match(/\n    (const device uint16_t\* ws[^\n]*)/)?.[1]],
    ["sourceReturn", body.match(/\n  (return [^\n]*)/)?.[1]],
  ];
  for (const [name, statement] of statements) {
    const literal = lean.match(new RegExp(`def ${name} : String := ("(?:\\\\.|[^"\\\\])*")`))?.[1];
    if (!statement || !literal || statement !== JSON.parse(literal)) throw new Error(`Affine qdot ${name} mismatch`);
  }
}
function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("Affine qdot function mutation accepted");
}

export async function checkAffineDot4FunctionSourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  await checkAffineDot4LoopSourceBinding(options);
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const [source, lean] = await Promise.all([
    Bun.file(resolve(root, "../packages/inference/src/kernels/quantization/affine-row.ts")).text(),
    Bun.file(resolve(root, "kernels/quantization/AffineDot4FunctionSyntax.lean")).text(),
  ]);
  checkLiteral(source, lean);
  if (options.selfTest) {
    for (const [before, after] of [
      ["float accum = 0;", "float accum = 1;"],
      ["const device uint16_t* ws = (const device uint16_t*)w;", "const device uint16_t* ws = (const device uint16_t*)(w + 2);"],
      ["return scale * accum + sum * bias;", "return sum * bias + scale * accum;"],
      ["return scale * accum + sum * bias;", "return scale * accum - sum * bias;"],
    ]) {
      rejected(() => checkLiteral(source.replace(before!, after!), lean));
      rejected(() => checkLiteral(source, lean.replace(before!, after!)));
    }
    rejected(() => checkLiteral(source, lean.replace("def sourcePointer", "def removedPointer")));
  }
}
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await checkAffineDot4FunctionSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Affine four-bit initialization, pointer cast and return bound to pinned source (host extraction boundary).");
}
