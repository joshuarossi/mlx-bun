import { resolve } from "node:path";

export const OUTFILE = resolve(import.meta.dir, "../../dist/web/app.js");
/** Build the actual browser entry; no backend or native modules may enter it. */
export async function buildWebBundle(): Promise<string> {
  return (await buildWeb()).text;
}

/** The same build with its metafile. Bun records the metafile's input paths
 * relative to the process working directory. */
export async function buildWeb(): Promise<{ text: string; metafile: Bun.BuildMetafile }> {
  const result = await Bun.build({ entrypoints: [resolve(import.meta.dir, "./browser/main.ts")], target: "browser", minify: false, metafile: true });
  if (!result.success) throw new Error(result.logs.map(log => log.message).join("\n"));
  if (result.outputs.length !== 1 || !result.metafile) throw new Error("Expected one browser bundle with its metafile");
  return { text: await result.outputs[0]!.text(), metafile: result.metafile };
}
