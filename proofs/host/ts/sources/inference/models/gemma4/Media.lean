import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.Media
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/media.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { rowOperationFor } from "../../runtime/row-operations";
import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../../contracts/mlx/cache";
import type { TargetView } from "../../contracts/mlx/draft-target";
import type { MediaEncoders, MediaSidecarProbes, MlxPromptInput, Vision, MlxEmbeddingsRange } from "../../contracts/mlx/media";
import type { MlxHeadForward, MlxLayerCapture, MlxRowTable, MlxPromptRange } from "../../contracts/mlx/graph";
import { bindEmbeddingsInput } from "../media-input";
import { readAssistantDonors } from "./assistant-target";
import type { ModelConfig } from "../../artifacts/config";
import type { QuantizedEmbedding } from "../../layers/quantized-embedding";

/** What the Gemma4 graph's media and draft ports read from it. */
export interface Gemma4MediaGraph {
  readonly config: ModelConfig;
  readonly embed: QuantizedEmbedding;
  readonly embedScale: number;
  readonly numDonors: number;
  readonly layers: readonly { readonly layerType: string }[];
  /** The vision prefill phase: a prompt's prepared embeddings (borrowed), image tokens attending each other both
   *  ways where `imageMask` marks them; `ids` feed the per-layer inputs. */
  prefillEmbeddings?(embeddings: MlxArray, caches: Cache[], imageMask: MlxArray | null,
    ids: MlxArray, multimodalMask: MlxArray | null): MlxArray;
  /** A prompt's token ids after a reused prefix: the window read, or one position the decode read. */
  readonly mediaPrefill?: readonly MlxEmbeddingsRange[];
  readonly prompt: readonly MlxPromptRange[];
  readonly decode: MlxRowTable<import("../../contracts/mlx/graph").MlxCapturingForward>;
  readonly logits: MlxRowTable<MlxHeadForward>;
}

/** Prepared embeddings enter the vision prefill phase; a prompt continuing after a reused prefix and decode
 *  continue from token ids, in the phase the scheduler names. */
export function bindGemma4MediaInput(model: Gemma4MediaGraph, input: Vision): MlxPromptInput {
  return bindEmbeddingsInput((ids, caches, start, phase, width) => start === 0
    ? model.mediaPrefill
      ? model.mediaPrefill.find(range => width >= range.from && width <= range.to)!.operation(input.embeddings, caches, input.imageMask ?? null, ids, input.multimodalMask ?? null)
      : model.prefillEmbeddings!(input.embeddings, caches, input.imageMask ?? null, ids, input.multimodalMask ?? null)
    : (phase === "decode" ? rowOperationFor(model.decode, width) : model.prompt.find(range => width >= range.from && width <= range.to)!.operation)(ids, caches, null) as MlxArray);
}

/** The graph's ports for draft sources over its live caches: donor KV for the
 * assistant drafter and the layer taps for hidden-state drafters. */
export function gemma4DraftTarget(model: Gemma4MediaGraph, caches: Cache[]): TargetView {
  let sliding = -1, full = -1;
  for (let i = 0; i < model.numDonors; i++) {
    if (model.layers[i]!.layerType === "sliding_attention") sliding = i;
    else full = i;
  }
  return Object.freeze({ identity: model, assistantRows: sliding >= 0 && full >= 0 ? {
    hiddenSize: model.config.text.hiddenSize,
    embed(ids: MlxArray) { using embedded = model.embed.encode(ids); return ops.mulScalar(embedded, model.embedScale); },
    readDonors: () => readAssistantDonors(caches[sliding]!, caches[full]!),
  } : undefined, hiddenLayerTaps: Object.freeze({
    layerCount: model.layers.length,
    projection: Object.freeze({ embed: model.embed, logits: model.logits }),
  }) });
}

/** The tower a checkpoint's sidecar ships: the encoder-free gemma4_unified
 * (12B) tower vs the SigLIP encoder (gemma4_vision: e2b/e4b/26B/31B), chosen by
 * the sidecar's vision_config.model_type; and the Conformer audio tower when the
 * sidecar header names its tensors (the local 12B pairs audio_config with a stub
 * sidecar, and a non-null loader advertises audio on every capability surface).
 * Towers load on first use, so text-only sessions never pay for them. */
export async function gemma4MediaEncoders(
  model: Gemma4MediaGraph, modelDir: string, probes: MediaSidecarProbes,
): Promise<MediaEncoders> {
  const config = model.config;
  if (!config.hasVisionSidecar) return { vision: null, audio: null };
  const vc = config.raw.vision_config as Record<string, any> | undefined;
  let vision: MediaEncoders["vision"];
  if (vc?.model_type === "gemma4_vision") {
    const { SiglipVisionTower, parseSiglipConfig } = await import("../vision/siglip");
    const sigCfg = parseSiglipConfig(vc);
    vision = () => SiglipVisionTower.load(modelDir, sigCfg, model.embedScale);
  } else {
    // gemma4_unified_vision (or unlabelled): the encoder-free patch embedder.
    const { VisionTower } = await import("../vision/unified");
    vision = () => VisionTower.load(modelDir, model.embedScale, config.text.rmsNormEps);
  }
  let audio: MediaEncoders["audio"] = null;
  if (config.raw.audio_config && probes.shipsAudioTower(`${modelDir}/optiq_vision.safetensors`)) {
    const { AudioTower, parseAudioConfig } = await import("../audio/conformer");
    const audioCfg = parseAudioConfig(config.raw.audio_config as Record<string, any>);
    audio = () => AudioTower.load(modelDir, audioCfg, model.embedScale);
  }
  return { vision, audio };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.Media
