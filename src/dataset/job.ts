// The dataset JobRunner: wires a submitted dataset job to generate(). Speaks
// the shared src/jobs/types.ts contract. The submit config carries the
// template id, user inputs, output dir, the server's own loopback API base,
// and an optional model name.

import type { JobRunner } from "../jobs/types";
import { makeLlmClient } from "./llm";
import { generate } from "./registry";

export const datasetRunner: JobRunner = async (emit, config) => {
  const template_id = String(config.template_id ?? "");
  const inputs = (config.inputs as Record<string, unknown>) ?? {};
  const output_dir = String(config.output_dir ?? "");
  const api_url = String(config.api_url ?? "");
  const model_name = (config.model_name as string | undefined) ?? "local";

  if (!template_id) throw new Error("dataset job: missing template_id");
  if (!output_dir) throw new Error("dataset job: missing output_dir");

  emit({
    type: "stage",
    stage: "starting",
    progress: 0.05,
    message: `Starting template ${template_id}…`,
  });

  const llm = api_url ? makeLlmClient(api_url, model_name) : undefined;
  const r = await generate(template_id, inputs, output_dir, emit, llm);
  return { outputPath: r.output_dir };
};

function applyRegister(mod: any): boolean {
  const register =
    mod?.registerRunner ?? mod?.register ?? mod?.default?.registerRunner ?? mod?.default?.register;
  if (typeof register === "function") {
    register("dataset", datasetRunner); // idempotent: registry is a Map by kind
    return true;
  }
  return false;
}

/**
 * Best-effort self-registration with the jobs runner registry. Registers the
 * "dataset" kind so both submitInProcess (server path) and the subprocess
 * job-entry resolver can find this runner. Tries a synchronous require first
 * (so registration completes before any submit on the same tick — the
 * convention quantize/finetune use), then an async import as a fallback.
 * Wrapped in try/catch so importing job.ts never fails in tests or standalone
 * use where ../jobs/runner isn't present. Returns true if registration
 * succeeded synchronously; an async fallback may still complete shortly after.
 *
 * job-entry.ts's KIND_MODULES can map `dataset → ../dataset/job.ts` and rely on
 * the top-level call below; the server orchestrator can alternatively await
 * this explicitly at bootstrap.
 */
export function registerDatasetRunner(): boolean {
  // 1. Synchronous require — Bun supports import.meta.require for ESM. This is
  //    the path that matters for in-process submit on the same tick.
  try {
    const req = (import.meta as any).require ?? (globalThis as any).require;
    if (typeof req === "function") {
      if (applyRegister(req("../jobs/runner"))) return true;
    }
  } catch {
    // fall through to async
  }
  // 2. Async fallback — completes on a later microtask. The orchestrator that
  //    needs guaranteed timing should call/await the runner module directly.
  void (async () => {
    try {
      applyRegister(await import("../jobs/runner"));
    } catch {
      // runner module not present — orchestrator will wire registration.
    }
  })();
  return false;
}

// Self-register on import so `kind: "dataset"` resolves wherever this module is
// loaded (mirrors quantize/finetune's top-level registration on import).
registerDatasetRunner();
