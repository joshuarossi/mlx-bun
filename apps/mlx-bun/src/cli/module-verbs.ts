// The CLI verbs the installed modules declare (`src/modules.ts`): their
// manifests are plain data, so the command list, `--help` and argument parsing
// read them without activating anything. Running one activates the modules over
// this app's core services and hands the verb what the host parsed.
import type { CliVerbSpec } from "@mlx-bun/app-core";
import { manifests } from "../modules";

export const PROGRAM = "mlx-bun";

/** Verb name to its declared spec, in installation order. */
export function installedVerbs(): ReadonlyMap<string, CliVerbSpec> {
  return new Map(manifests.flatMap(manifest => (manifest.verbs ?? []).map(spec => [spec.name, spec] as const)));
}

/** Run an installed module's verb; resolves to the exit code. */
export async function runInstalledVerb(name: string, argv: string[]): Promise<number> {
  const spec = installedVerbs().get(name);
  if (!spec) throw new Error(`Unknown command: ${name}`);
  // The module code and its services load only now, so the command list and help stay light.
  const [{ createHostServices, runVerb }, { installedModules }] = await Promise.all([import("@mlx-bun/app-services"), import("../modules")]);
  return runVerb({ program: PROGRAM, spec, argv, modules: installedModules, services: createHostServices({ log() {} }) });
}
