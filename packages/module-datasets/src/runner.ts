// The dataset job runner: wires a submitted job to generate(). The config
// carries the template id, user inputs, output dir and an optional model name.
// LLM-driven templates reach the served model through the model host's
// `generate` operation (an OpenAI chat request bound to the model), leased on
// the first call and released when the job ends; the job holds no exclusive
// GPU lease, so each request joins the scheduler like any client's.

import type { JobRunner, ModelHost, ModelLease } from "@mlx-bun/app-core";
import { makeLlmClient } from "./llm";
import type { VerifyPython } from "./python-verifier";
import { generate } from "./registry";

/** The chat client addresses the wire by path; the model host's `generate` ignores the origin. */
const WIRE = "http://model.local";

export interface DatasetRunnerDependencies {
  /** Where LLM-driven templates find the served model. */
  models: Pick<ModelHost, "acquire" | "defaultFor">;
  /** Hugging Face imports (default: global fetch). */
  fetch?: typeof fetch;
  /** Replaces the Docker verifier for verified_code. */
  verifyPython?: VerifyPython;
}

export function createDatasetRunner(deps: DatasetRunnerDependencies): JobRunner {
  return async (emit, config, signal) => {
    const template_id = String(config.template_id ?? "");
    const inputs = (config.inputs as Record<string, unknown>) ?? {};
    const output_dir = String(config.output_dir ?? "");
    const model_name = (config.model_name as string | undefined) ?? "local";

    if (!template_id) throw new Error("dataset job: missing template_id");
    if (!output_dir) throw new Error("dataset job: missing output_dir");

    emit({
      type: "stage",
      stage: "starting",
      progress: 0.05,
      message: `Starting template ${template_id}…`,
    });

    let lease: ModelLease | undefined;
    const wire = (async (input: string | URL | Request, init?: RequestInit) => {
      if (!lease) {
        const id = await deps.models.defaultFor("generate");
        if (id === undefined) throw new Error("no model can generate: none is served");
        lease = await deps.models.acquire(id, { need: ["generate"], signal });
      }
      return lease.operations.generate!(new Request(input, init));
    }) as typeof fetch;
    try {
      const llm = makeLlmClient(WIRE, model_name, { fetch: wire, signal });
      const r = await generate(template_id, inputs, output_dir, emit, llm, { ...(deps.fetch ? { fetch: deps.fetch } : {}), signal }, deps.verifyPython);
      return { outputPath: r.output_dir };
    } finally { lease?.release(); }
  };
}
