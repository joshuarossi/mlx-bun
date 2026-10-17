import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { checkAffineDot4SourceBinding } from "./AffineDot4SourceBinding.ts";

export function checkLiteral(source: string, lean: string): void {
  const headers = [...source.matchAll(/for \(int i = 0; i < 4; i\+\+\) \{/g)];
  const literal = lean.match(/def sourceHeader : String := "([^"\n]+)"/)?.[1];
  if (headers.length !== 1 || headers[0]![0] !== literal) throw new Error("Affine four-bit loop header mismatch");
}
function rejected(check: () => void): void {
  let failed = false;
  try { check(); } catch { failed = true; }
  if (!failed) throw new Error("Affine four-bit loop mutation accepted");
}
export async function checkAffineDot4LoopSourceBinding(options: { proofsRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  await checkAffineDot4SourceBinding(options);
  const root = options.proofsRoot ?? resolve(fileURLToPath(new URL("../../", import.meta.url)));
  const [source, lean] = await Promise.all([
    Bun.file(resolve(root, "../packages/inference/src/kernels/quantization/affine-row.ts")).text(),
    Bun.file(resolve(root, "kernels/quantization/AffineDot4LoopSource.lean")).text(),
  ]);
  checkLiteral(source, lean);
  if (options.selfTest) {
    const header = "for (int i = 0; i < 4; i++) {";
    for (const bad of [source.replace(header, header.replace("i = 0", "i = 1")),
      source.replace(header, header.replace("i < 4", "i <= 4")),
      source.replace(header, header.replace("i++", "i += 2")), source + header]) rejected(() => checkLiteral(bad, lean));
    rejected(() => checkLiteral(source, lean.replace(header, header.replace("i < 4", "i < 3"))));
    rejected(() => checkLiteral(source, lean.replace("def sourceHeader", "def removedHeader")));
  }
}
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  await checkAffineDot4LoopSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Affine four-bit loop bound to pinned source (host extraction boundary).");
}
