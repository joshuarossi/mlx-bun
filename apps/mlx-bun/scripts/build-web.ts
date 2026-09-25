import { mkdir } from "node:fs/promises";
import { dirname, resolve } from "node:path";

export const OUTFILE = resolve(import.meta.dir, "../dist/web/app.js");
/** Build the actual browser entry; no backend or native modules may enter it. */
export async function buildWebBundle(): Promise<string> {
  const result = await Bun.build({ entrypoints: [resolve(import.meta.dir, "../src/web/browser/main.ts")], target: "browser", minify: false });
  if (!result.success) throw new Error(result.logs.map(log => log.message).join("\n"));
  if (result.outputs.length !== 1) throw new Error("Expected one browser bundle");
  return result.outputs[0]!.text();
}
if (import.meta.main) {
  await mkdir(dirname(OUTFILE), { recursive: true });
  await Bun.write(OUTFILE, await buildWebBundle());
  console.log(`Built ${OUTFILE}`);
}
