import { existsSync, readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

export const OUTFILE = resolve(import.meta.dir, "../../dist/web/app.js");
const APP = resolve(import.meta.dir, "../..");
const PANELS = resolve(import.meta.dir, "./browser/installed-panels.ts");

/** The package.json of an installed package, found the way Node resolution finds it (the exports map is not consulted). */
function packageManifest(name: string, from: string): { exports?: Record<string, unknown> } {
  for (let directory = from; ; directory = dirname(directory)) {
    const file = join(directory, "node_modules", name, "package.json");
    if (existsSync(file)) return JSON.parse(readFileSync(file, "utf8"));
    if (directory === dirname(directory)) throw new Error(`Installed package not found: ${name}`);
  }
}

/** The modules the host installs that ship a web panel. A host's package.json lists exactly the modules its
 * `src/modules.ts` names (an architecture gate), so the browser build reads that list without loading any module
 * code; a module ships a panel when it exports `./panel`. */
export function panelModules(app = APP): string[] {
  const { dependencies = {} } = JSON.parse(readFileSync(join(app, "package.json"), "utf8")) as { dependencies?: Record<string, string> };
  return Object.keys(dependencies).filter(name => name.startsWith("@mlx-bun/module-") && packageManifest(name, app).exports?.["./panel"] !== undefined);
}

/** Source of the browser's `installed-panels` module for the given modules: each module's panel entry (which defines
 * its custom element) and manifest are imported, and the shell's `panelsFromManifests` lists the panels. */
export function installedPanelsSource(modules: readonly string[] = panelModules()): string {
  return [
    'import { panelsFromManifests } from "@mlx-bun/web-shell";',
    ...modules.flatMap((name, index) => [`import { manifest as manifest${index} } from ${JSON.stringify(`${name}/manifest`)};`, `import ${JSON.stringify(`${name}/panel`)};`]),
    `export const panels = panelsFromManifests([${modules.map((_, index) => `manifest${index}`).join(", ")}]);`,
    "",
  ].join("\n");
}

/** Build the actual browser entry; no backend or native modules may enter it. */
export async function buildWebBundle(): Promise<string> {
  return (await buildWeb()).text;
}

/** The same build with its metafile. Bun records the metafile's input paths
 * relative to the process working directory. The host's installed panels enter through `installedPanelsSource`. */
export async function buildWeb(): Promise<{ text: string; metafile: Bun.BuildMetafile }> {
  const result = await Bun.build({
    entrypoints: [resolve(import.meta.dir, "./browser/main.ts")], target: "browser", minify: false, metafile: true,
    files: { [PANELS]: installedPanelsSource() },
  });
  if (!result.success) throw new Error(result.logs.map(log => log.message).join("\n"));
  if (result.outputs.length !== 1 || !result.metafile) throw new Error("Expected one browser bundle with its metafile");
  return { text: await result.outputs[0]!.text(), metafile: result.metafile };
}
