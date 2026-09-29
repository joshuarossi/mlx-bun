// What the served model is, as the browser needs it (`ready` frame). Read over the model host's
// own wire when each chat connects: the wire describes whichever model is current, in this process
// or behind an isolation worker, so chat never asks a model family anything.
import type { ModelHost } from "@mlx-bun/app-core";

export interface ServedModel {
  readonly modelId: string;
  /** The context the server enforces; undefined when it reports none. */
  readonly contextWindow: number | undefined;
  readonly vision: boolean;
  readonly audio: boolean;
  readonly thinking: boolean;
  /** A speech-to-text checkpoint is available: the composer offers hold-to-talk. */
  readonly transcription: boolean;
  readonly genDefaults: { readonly temperature: number | null; readonly topP: number | null; readonly topK: number | null };
}

const number = (value: unknown): number | undefined => typeof value === "number" && Number.isFinite(value) ? value : undefined;

/** Reads the current model's discovery row and its enforced context. Rejects when no model is served or the wire answers with an error. */
export async function describeModel(models: Pick<ModelHost, "acquire" | "defaultFor">, signal?: AbortSignal): Promise<ServedModel> {
  const id = await models.defaultFor("generate");
  if (id === undefined) throw new Error("no model is served");
  const lease = await models.acquire(id, { need: ["generate"], ...(signal ? { signal } : {}) });
  try {
    const generate = lease.operations.generate;
    if (!generate) throw new Error(`model ${id} cannot generate`);
    const read = async (path: string) => {
      const response = await generate(new Request(`http://model.local${path}`, signal ? { signal } : {}));
      if (!response.ok) { await response.body?.cancel().catch(() => {}); throw new Error(`the model host answered ${response.status} on ${path}`); }
      return await response.json() as Record<string, unknown>;
    };
    const [models_, stats] = await Promise.all([read("/v1/models"), read("/stats")]);
    const rows = (Array.isArray(models_.data) ? models_.data : []) as Record<string, unknown>[];
    const row = rows.find(item => item.id === id) ?? rows.find(item => item.current === true) ?? rows.find(item => item.transcription !== true) ?? {};
    const defaults = (row.gen_defaults ?? {}) as Record<string, unknown>;
    const capabilities = (row.capabilities ?? {}) as Record<string, unknown>;
    const admission = (stats.admission ?? {}) as Record<string, unknown>;
    return {
      modelId: id,
      contextWindow: number(admission.enforced_context_tokens) ?? number(row.context_window),
      vision: row.vision === true, audio: row.audio === true, thinking: row.reasoning === true,
      transcription: capabilities.transcription === true,
      genDefaults: { temperature: number(defaults.temperature) ?? null, topP: number(defaults.top_p) ?? null, topK: number(defaults.top_k) ?? null },
    };
  } finally { lease.release(); }
}
