// The standalone image command composes its own host. Serving compositions
// continue to bind their existing chat and transcription operations.
import type { CliVerbSpec } from "@mlx-bun/app-core";
import { createEventHub, createImageModelHost, createRegistryCatalog, defaultStageBudgetBytes, runVerb, stageBudgetRule } from "@mlx-bun/app-services";
import { installedModules } from "../modules";

export async function runImageVerb(spec: CliVerbSpec,
  input: string[] | { values: Readonly<Record<string, unknown>>; positionals: readonly string[] }): Promise<number> {
  const catalog = createRegistryCatalog(), events = createEventHub();
  const image = createImageModelHost({ catalog, events, stages: stageBudgetRule(defaultStageBudgetBytes()), log() {} });
  try {
    return await runVerb({ program: "mlx-bun", spec, ...(Array.isArray(input) ? { argv: input } : input),
      services: { bindings: { modelHost: () => image, catalog: () => catalog }, events, close: () => image.close() },
      modules: () => installedModules(manifest => manifest.verbs?.some(verb => verb.name === spec.name) ?? false) });
  } finally {
    // Parsing or module activation can fail before runVerb owns the services.
    try { await image.close(); } finally { events.close(); }
  }
}
