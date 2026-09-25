// The dataset JobRunner: wires a submitted dataset job to generate(). Speaks
// the app-owned jobs protocol. The submit config carries the
// template id, user inputs, output dir, the server's own loopback API base,
// and an optional model name.

import type { JobRunner } from "../jobs/protocol";
import { makeLlmClient, type DatasetHttp } from "./llm";
import { generate } from "./registry";

export function createDatasetRunner(http: Pick<DatasetHttp, "fetch"> = {}): JobRunner {
  return async (emit, config, signal) => {
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

    const llm = api_url ? makeLlmClient(api_url, model_name, { ...http, signal }) : undefined;
    const r = await generate(template_id, inputs, output_dir, emit, llm, { ...http, signal });
    return { outputPath: r.output_dir };
  };

}
