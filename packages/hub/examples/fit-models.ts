import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { Registry, DEFAULT_HUB, DEFAULT_CHUNK, fit, thisMachine, type MachineSpec } from "@mlx-bun/hub";

/** Scan a Hugging Face cache and report which downloaded models fit a machine
 *  at a context length. Estimates are advisory; the caller decides what to run. */
export async function fitModels(hubDir: string, contextTokens: number, machine: MachineSpec = thisMachine()) {
  const registry = new Registry(":memory:");
  try {
    await registry.scan(hubDir);
    const reports = [];
    for (const record of registry.list()) {
      const config = await loadModelConfig(record.path);
      const report = fit(config, record.sizeBytes, contextTokens, machine, DEFAULT_CHUNK, record.expertsBytes);
      reports.push({ repoId: record.repoId, fits: report.fits, maxSafeContext: report.maxSafeContext });
    }
    return reports;
  } finally {
    registry.close();
  }
}

if (import.meta.main) {
  const [hub = DEFAULT_HUB, context = "8192"] = process.argv.slice(2);
  console.log(await fitModels(hub, Number(context)));
}
