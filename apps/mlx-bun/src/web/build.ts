import { resolve } from "node:path";
import type { AppModule } from "@mlx-bun/app-core";
import { manifests } from "../modules";

export const OUTFILE = resolve(import.meta.dir, "../../dist/web/app.js");
const PANELS = resolve(import.meta.dir, "./browser/installed-panels.ts");

/** Source of the browser's `installed-panels` module for the given installed modules: one import of each panel entry
 * (which defines the module's custom element) and the list the shell mounts. A panel is connected to its module's
 * routes: `apiBase` is `/api/<id>` and `eventsUrl` its first server-sent route, empty when the module serves none. */
export function installedPanelsSource(installed: readonly Omit<AppModule, "activate">[] = manifests): string {
  const withPanel = installed.filter(module => module.panel !== undefined);
  const imports = withPanel.map(module => `import ${JSON.stringify(module.panel!.entry)};`);
  const list = withPanel.map(module => {
    const stream = module.routes?.find(route => route.response === "sse" && route.method === "GET" && route.mount !== "root");
    return { tag: module.panel!.tag, title: module.panel!.title, path: module.panel!.path,
      connection: { apiBase: `/api/${module.id}`, eventsUrl: stream ? `/api/${module.id}${stream.path}` : "" } };
  });
  return `${imports.join("\n")}\nexport const panels = ${JSON.stringify(list, null, 2)};\n`;
}

/** Build the actual browser entry; no backend or native modules may enter it. */
export async function buildWebBundle(): Promise<string> {
  return (await buildWeb()).text;
}

/** The same build with its metafile. Bun records the metafile's input paths
 * relative to the process working directory. The host's installed modules enter through `installedPanelsSource`. */
export async function buildWeb(): Promise<{ text: string; metafile: Bun.BuildMetafile }> {
  const result = await Bun.build({
    entrypoints: [resolve(import.meta.dir, "./browser/main.ts")], target: "browser", minify: false, metafile: true,
    files: { [PANELS]: installedPanelsSource() },
  });
  if (!result.success) throw new Error(result.logs.map(log => log.message).join("\n"));
  if (result.outputs.length !== 1 || !result.metafile) throw new Error("Expected one browser bundle with its metafile");
  return { text: await result.outputs[0]!.text(), metafile: result.metafile };
}
