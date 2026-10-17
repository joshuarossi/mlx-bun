import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { checkAffineDot3SourceBinding } from "./AffineDot3SourceBinding.ts";
import { checkAffineDot4FunctionSourceBinding } from "./AffineDot4FunctionSourceBinding.ts";

// The initializer and final return are shared by both qdot branches and
// already parsed by AffineDot4FunctionSyntax. This guard adds the three-bit
// branch's actual loop header and cumulative pointer increments.
export function checkLiteral(source: string, lean: string): void {
  const header = source.match(/const HEADER = String\.raw`([\s\S]*?)`;/)?.[1];
  const body = header?.match(/inline float mlxq_qdot\([^\n]+\) \{([\s\S]*)\n\}/)?.[1];
  const fragments = [
    ["sourceHeader", body?.match(/(for \(int i = 0; i < 2; i\+\+\) \{)/)?.[1]],
    ["sourcePointers", body?.match(/(x_thread \+= [^\n]*\n      w \+= [^\n]*)/)?.[1]],
  ];
  for (const [name, statement] of fragments) {
    const literal = lean.match(new RegExp(`def ${name} : String := ("(?:\\\\.|[^"\\\\])*")`))?.[1];
    if (!statement || !literal || statement !== JSON.parse(literal)) throw new Error(`Affine three-bit ${name} mismatch`);
  }
}

function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("Affine three-bit function mutation accepted");
}

export async function checkAffineDot3FunctionSourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  await checkAffineDot3SourceBinding(options);
  await checkAffineDot4FunctionSourceBinding(options);
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const [source, lean] = await Promise.all([
    Bun.file(resolve(root, "../packages/inference/src/kernels/quantization/affine-row.ts")).text(),
    Bun.file(resolve(root, "kernels/quantization/AffineDot3LoopSource.lean")).text(),
  ]);
  checkLiteral(source, lean);
  if (options.selfTest) {
    for (const [before, after] of [
      ["i < 2; i++", "i < 3; i++"], ["x_thread += 8 * i", "x_thread += 4 * i"],
      ["w += 3 * i", "w += 6 * i"], ["x_thread += 8 * i", "x_thread = 8 * i"],
    ] as const) rejected(() => checkLiteral(source.replace(before, after), lean));
    rejected(() => checkLiteral(source, lean.replace("i < 2; i++", "i < 1; i++")));
    rejected(() => checkLiteral(source, lean.replace("w += 3 * i", "w += 2 * i")));
  }
}

if (process.argv[1] && import.meta.url ===pathToFileURL(resolve(process.argv[1])).href) {
  await checkAffineDot3FunctionSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Affine three-bit loop, pointer updates and shared function tail bound to pinned source.");
}
