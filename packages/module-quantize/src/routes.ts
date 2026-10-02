import { join } from "node:path";
import type { JobService, ModelCatalog, RouteHandler, StorageService } from "@mlx-bun/app-core";
import { inspectModel } from "./inspect";
import { quantizedModelName } from "./output-name";

export interface QuantizeRouteServices {
  readonly jobs: Pick<JobService, "submit">;
  readonly storage: StorageService;
  readonly catalog: Pick<ModelCatalog, "find" | "locate">;
}

const readBody = async (request: Request) => (await request.json().catch(() => ({}))) as Record<string, unknown> & {
  model_id?: string; folder_name?: string; rel_path?: string; bits?: number; group_size?: number; target_bpw?: number;
  candidate_bits?: number[]; reference?: string; calibration_mix?: string; n_calibration?: number; rotate_weights?: boolean; rotation_seed?: number;
};

/** The three POST routes the browser's quantize wizard calls. */
export function createQuantizeHandlers(services: QuantizeRouteServices): Record<"inspect" | "resolve-folder" | "submit", RouteHandler> {
  return {
    async inspect(request) {
      const body = await readBody(request);
      return Response.json(await inspectModel(services.catalog, body.model_id ?? ""));
    },
    async "resolve-folder"(request) {
      const body = await readBody(request);
      const found = await services.catalog.locate({ name: body.folder_name ?? "", relPath: body.rel_path ?? "" });
      if (!found) return Response.json({ ok: false, error: "Couldn't locate this folder on disk — paste the path instead." });
      return Response.json({ ok: true, path: found.directory, ...(found.id !== undefined ? { repo_id: found.id } : {}),
        ...(found.type !== undefined ? { model_type: found.type } : {}) });
    },
    async submit(request) {
      const body = await readBody(request);
      if (!body.model_id) return Response.json({ ok: false, error: "model_id required" }, { status: 400 });
      // These name the output directory: anything but a finite number could steer it out of the models store.
      for (const key of ["bits", "target_bpw", "rotation_seed"] as const)
        if (body[key] != null && (typeof body[key] !== "number" || !Number.isFinite(body[key])))
          return Response.json({ ok: false, error: `${key} must be a finite number` }, { status: 400 });
      const bits = body.bits ?? 4;
      const groupSize = body.group_size ?? 64;
      // A plain model directory; the same model and settings name the same
      // directory, which the producer refuses to overwrite.
      const outDir = join(services.storage.path("models"), quantizedModelName(body.model_id, {
        bits, targetBpw: body.target_bpw ?? undefined, rotationSeed: body.rotate_weights ? body.rotation_seed ?? 42 : undefined }));
      const job = await services.jobs.submit({ kind: "quantize", outputPath: outDir, config: {
        model_id: body.model_id,
        out_dir: outDir,
        bits,
        group_size: groupSize,
        target_bpw: body.target_bpw,
        candidate_bits: body.candidate_bits,
        reference: body.reference,
        calibration_mix: body.calibration_mix,
        n_calibration: body.n_calibration,
        rotate_weights: body.rotate_weights,
        rotation_seed: body.rotation_seed,
      } });
      return Response.json({ ok: true, job_id: job.id, output_dir: outDir });
    },
  };
}
