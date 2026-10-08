// The CLI verbs the installed modules declare (`src/modules.ts`): their
// manifests are plain data, so the command list, `--help` and argument parsing
// read them without activating anything. Running one activates the verb's
// module over this app's core services and hands the verb what the host parsed.
import type { CliVerbSpec } from "@mlx-bun/app-core";
import { manifests } from "../modules";

export const PROGRAM = "mlx-bun";

/** Verb name to its declared spec, in installation order. */
export function installedVerbs(): ReadonlyMap<string, CliVerbSpec> {
  return new Map(manifests.flatMap(manifest => (manifest.verbs ?? []).map(spec => [spec.name, spec] as const)));
}

/** Run an installed module's verb, from its argv or from the values another spelling of the verb (`mlx-bun.convert`) already parsed; resolves to the exit code. */
export async function runInstalledVerb(name: string, input: string[] | { values: Readonly<Record<string, unknown>>; positionals: readonly string[] }): Promise<number> {
  const spec = installedVerbs().get(name);
  if (!spec) throw new Error(`Unknown command: ${name}`);
  // The module code and its services load only now, so the command list and help stay light.
  const [{ createHostServices, runVerb }, { installedModules }, { createCatalogHub }, terminal, { createJobHost }, { createJobService }, { JobStore }, { fileURLToPath }, fs, os, path] = await Promise.all([
    import("@mlx-bun/app-services"), import("../modules"), import("../publishing/catalog-hub"), import("./terminal"), import("../jobs/host"), import("../jobs/service"), import("../jobs/db"),
    import("node:url"), import("node:fs"), import("node:os"), import("node:path") ]);
  // A one-shot verb records the jobs it starts in a store of its own, created on first use and removed when it ends:
  // nothing of it is left in the app's job history. Its children hold no lease: no model is loaded beside them.
  const scratch = path.join(os.tmpdir(), `mlx-bun-verb-${crypto.randomUUID()}`);
  const jobs = createJobHost({ entry: fileURLToPath(new URL("./job-entry.ts", import.meta.url)), acquire: async () => ({ dispose() {} }),
    createStore: () => new JobStore(path.join(scratch, "jobs.db"), path.join(scratch, "logs")) });
  const jobService = createJobService(jobs);
  // A verb that names no model runs on the app's automatic choice (`cli/model-selection.ts`), the same one `serve` makes.
  const host = createHostServices({ log() {}, hub: { ...createCatalogHub(), async pickDefault(signal) {
    const { m } = await (await import("./model-selection")).resolveModelAuto(null, {}, signal);
    return { id: m.repoId, directory: m.path };
  } } });
  const memoryDependencies = name === "memory" || name === "setup" ? (await import("./memory")).defaultMemoryDependencies() : undefined;
  try {
    return await runVerb({ program: PROGRAM, spec, ...(Array.isArray(input) ? { argv: input } : input), services: { ...host, bindings: { ...host.bindings, jobs: () => jobService, ...(memoryDependencies ? { storage: (scope) => {
        const storage = host.bindings.storage!(scope);
        return { path: (key, options) => key === "vault" ? memoryDependencies.vault : storage.path(key, options) };
      } } : {}) } },
      // Only the verb's own module activates (a verb of one module never starts another's runners).
      modules: async () => installedModules(manifest => manifest.verbs?.some(verb => verb.name === name) ?? false,
        name === "memory" || name === "setup" ? { memory: { cli: () => (memoryDependencies!) } } : {}),
      activated: loaded => jobService.serve(loaded.jobs),
      terminal: { step: terminal.step, box: lines => terminal.box([...lines]), heading: terminal.h1,
        table: (columns, rows) => terminal.table(columns.map(column => ({ ...column })), rows.map(row => [...row])),
        style: { ...terminal.style, gradient: terminal.gradient } } });
  } finally {
    try { await jobs.close(); } finally { fs.rmSync(scratch, { recursive: true, force: true }); }
  }
}
