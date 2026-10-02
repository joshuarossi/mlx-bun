// The local models a host may load, as the registry knows them: never a scan of the
// hub cache beyond the first (an empty index) and never a download.
import type { ModelOperation } from "@mlx-bun/app-core";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { openRegistry } from "../storage/paths";

/** Local checkpoints that declare `operation`: `generate` for chat models, `transcribe` for Whisper. */
export async function listLocalRecords(operation: ModelOperation): Promise<readonly ModelRecord[]> {
  const { declaredOperations } = await import("@mlx-bun/app-services/catalog");
  const registry = openRegistry();
  try {
    // A fresh machine's index is empty until its first scan.
    if (registry.list().length === 0) await registry.scan();
    return registry.listCanonical().filter(record => declaredOperations(record.modelType).includes(operation));
  } finally { registry.close(); }
}
