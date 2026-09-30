import type { CliInvocation, ModelCatalog } from "@mlx-bun/app-core";

/** `scan`: re-index the Hugging Face cache without reading tensor bytes. */
export async function runScan(invocation: CliInvocation, catalog: Pick<ModelCatalog, "rescan">): Promise<number> {
  const step = invocation.terminal.step("scanning the Hugging Face cache");
  try {
    const indexed = await catalog.rescan();
    step.done(`indexed ${indexed} model snapshot(s)`);
  } catch (error) { step.fail("scan failed"); throw error; }
  return 0;
}
