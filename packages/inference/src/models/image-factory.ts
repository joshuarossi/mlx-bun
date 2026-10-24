import type { ModelConfig } from "../artifacts/config";
import { loadPipelineConfig } from "../artifacts/pipeline-config";
import type { TextToImagePipeline } from "../contracts/mlx/image-generation";
import type { Composition } from "../contracts/portable/composition";
import { resolveComposition } from "./composition";
import { GraphTable } from "./implementation";
import { openMossImagePipeline } from "./moss-image/pipeline";
import { resolveModelProfile, type ModelGraph, type ResolvedModelProfile, type ResolveModelProfileOptions } from "./profile";

/** A complete image graph opens its stages from the supplied artifact. Its
 * implementation owns partial-construction cleanup; stage handles are borrowed
 * through TextToImagePipeline and the caller owns the returned pipeline. */
export type ImagePipelineGraph = (directory: string, config: ModelConfig) => Promise<TextToImagePipeline>;

/** Image graph recommendations use the same table as token graphs. This table
 * binds only image constructors, so adding one cannot change a token binding. */
export const MLX_IMAGE_GRAPH_TABLES: Readonly<Record<ModelGraph, GraphTable<string, Promise<TextToImagePipeline>>>> = Object.freeze({
  "moss-image": new GraphTable([{ id: "moss-image", serves: {}, create: openMossImagePipeline }]),
});

export interface ImagePipelineOpenOptions {
  readonly profiles?: ResolveModelProfileOptions;
  readonly composition?: Composition;
  /** A shipped graph name or the caller's complete arrangement. A function
   * bypasses profile resolution and needs no registration. */
  readonly graph?: string | ImagePipelineGraph;
}

/** Open the graph bound to a pipeline snapshot. No weights load until a stage
 * opens. Existing token and speech artifact loaders do not call this path. */
export async function openImagePipeline(modelDir: string, options: ImagePipelineOpenOptions = {}):
  Promise<{ pipeline: TextToImagePipeline; profile: ResolvedModelProfile | null; config: ModelConfig }> {
  const config = await loadPipelineConfig(modelDir);
  if (typeof options.graph === "function")
    return { pipeline: await options.graph(modelDir, config), profile: null, config };
  const profile = resolveModelProfile(config, options.profiles);
  const table = MLX_IMAGE_GRAPH_TABLES[profile.profile.execution.graph];
  if (profile.profile.execution.loop !== "flow-matching" || !table)
    throw new Error(`${modelDir} has no text-to-image graph (profile ${profile.profile.id})`);
  const composition = options.composition ?? resolveComposition(config);
  const graph = table.select(config, composition, options.graph);
  return { pipeline: await graph.create(modelDir, config, composition), profile, config };
}
