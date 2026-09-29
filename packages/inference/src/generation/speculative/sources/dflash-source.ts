// DflashSource — DSpark (faithful DFlash + Markov + confidence,
// packages/inference/src/models/speculative/dflash.ts) behind the serve-time
// DraftSource seam. L3 (KL/quality-gated). It plugs into the shared
// verify/accept executor (packages/inference/src/generation/speculative/run.ts).
//
// H_ctx (why the seam taps): DSpark drafts by attending to a GROWING
// multi-layer context — the target's tapped hiddens over the accepted stream
// (paper Eq 2-3). The seam declares `tapLayers`, so the serve loop taps the
// target's prefill (→ seeds H_ctx here) and every verify forward (→ grown in
// commit by the accepted window; rejected tips are never appended, mirroring
// the target-cache trim). See [[dspark-seam-kv-borrowing]].
//
// v1 acceptance: the serve loop verifies with TOKEN-MATCH acceptance
// (mlx-lm/optiq style — lossless at any temperature), NOT the paper's
// distribution-level rejection-sampling verify. Greedy is identical; temp>0 is
// still lossless but lower-acceptance. Drafting here is greedy (proposals; the
// target verify decides).

import { artifactIdentity } from "../../../artifacts/identity";
import { projectedDraftGroups } from "../bindings/projected-draft-rows";
import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { DsparkDrafterModel } from "../../../contracts/mlx/drafter";
import { loadDsparkDrafter } from "../../../models/drafters";
import type { DraftProvider, DraftSource, TargetView } from "../source";
import { targetLacks } from "../source";
import type { DraftProjection } from "../../../contracts/mlx/draft-projection";
import { runtimeValue } from "../../../runtime/config";

function safetensorsBytes(dir: string): number {
  let total = 0;
  for (const f of readdirSync(dir))
    if (f.endsWith(".safetensors")) total += statSync(join(dir, f)).size;
  return total;
}

export class DflashProvider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes: number;
  readonly grouped: import("../source").GroupedDraftProvider;
  /** The trained block width — the server pins numDraftTokens to this so the
   *  serve loop never asks for more positions than the block was trained for. */
  readonly gamma: number;

  private constructor(private readonly drafter: DsparkDrafterModel, id: string, weightsBytes: number, namespace: string) {
    this.id = id;
    this.weightsBytes = weightsBytes;
    this.gamma = drafter.cfg.gamma;
    this.grouped = projectedDraftGroups(namespace, drafter.cfg.tapLayers, target => {
      if (!target.hiddenLayerTaps) throw targetLacks("hiddenLayerTaps");
      const projection = target.hiddenLayerTaps.projection;
      const minConf = runtimeValue("MLX_BUN_DSPARK_MINCONF");
      return {
        namespace, schema: "dflash-context-v1",
        layers: drafter.cfg.nLayers,
        project: hidden => drafter.projectContextRows(hidden),
        draft(context, pending, _positions, depth) {
          return drafter.forwardRows(projection, null, pending, depth, {
            collectLogits: false, collectConfidence: false,
            thresholds: drafter.cfg.sts?.thresholds,
            ...(minConf ? { minConf: Number(minConf) } : {}),
          }, context).tokens;
        },
      };
    });
  }

  static async load(modelDir: string): Promise<DflashProvider> {
    const drafter = await loadDsparkDrafter(modelDir); // variant dispatch (dspark|legacy dflash)
    const id = modelDir.split("/").filter(Boolean).at(-1)!;
    try {
      const identity = await artifactIdentity(await Bun.file(`${modelDir}/dspark.json`).text(),
        readdirSync(modelDir).filter(file => file.endsWith(".safetensors"))
          .map(name => ({ name, path: join(modelDir, name) })));
      return new DflashProvider(drafter, id, safetensorsBytes(modelDir), `dflash-context-v1:${identity}`);
    } catch (error) { drafter.dispose(); throw error; }
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    return new DflashSource(this.drafter, opts.target);
  }

  dispose(): void {
    // Provider-owned weights are released when the mounted draft is closed.
    this.drafter.dispose();
  }
}

export class DflashSource implements DraftSource {
  readonly weightsBytes = 0; // provider-owned weights
  readonly tapLayers: number[];
  private readonly model: DraftProjection;
  private readonly minConf = runtimeValue("MLX_BUN_DSPARK_MINCONF");
  private hCtx: MlxArray | null = null; // [1, L, m*H] — grows with the accepted stream

  constructor(private readonly drafter: Pick<DsparkDrafterModel, "cfg" | "forwardInfer">, target: TargetView) {
    if (!target.hiddenLayerTaps) throw targetLacks("hiddenLayerTaps");
    this.model = target.hiddenLayerTaps.projection;
    this.tapLayers = drafter.cfg.tapLayers;
  }

  /** Seed H_ctx from the tapped prompt context (ownership transfers here). */
  prefill(_promptIds: number[], ctxML?: MlxArray): void {
    if (!ctxML) throw new Error("DSpark drafter: prefill missing tapped context");
    this.hCtx = ctxML;
  }

  /** Draft up to n tokens against the current H_ctx, conditioned on the anchor
   *  token (the last emitted token = feed's tail). Greedy — the target verify
   *  decides. anchorHidden is unused (DSpark reads H_ctx, not the target
   *  hidden). Confidence-scheduled pruning (Alg 1) may return FEWER than n:
   *  active when the checkpoint carries STS thresholds (cfg.sts, §3.2.1) or
   *  via the MLX_BUN_DSPARK_MINCONF env override; uncalibrated checkpoints
   *  draft fixed-length exactly as before. The server pins n ≤ cfg.gamma. */
  draft(feed: number[], n: number, _stepBase: number, _anchorHidden?: MlxArray): number[] {
    if (!this.hCtx) throw new Error("DSpark drafter: draft before prefill");
    const anchorTok = feed[feed.length - 1]!;
    const envMin = this.minConf;
    const block = this.drafter.forwardInfer(this.model, this.hCtx, anchorTok, n, {
      thresholds: this.drafter.cfg.sts?.thresholds,
      collectLogits: false, // serve loop runs its own verify lm-head, never reads this
      ...(envMin ? { minConf: Number(envMin) } : {}),
    });
    return block.tokens;
  }

  /** Grow H_ctx by the accepted window [anchor + kAccept drafts] from the
   *  verified positions' tapped context [1,d+1,m*H]; drop the rejected tips
   *  (ownership of vCtxML transfers here). */
  commit(_d: number, kAccept: number, vCtxML?: MlxArray): void {
    if (!vCtxML) throw new Error("DSpark drafter: commit missing tapped verify context");
    if (!this.hCtx) throw new Error("DSpark drafter: commit before prefill");
    const mH = vCtxML.shape[2]!;
    const add = vCtxML.slice([0, 0, 0], [1, kAccept + 1, mH]); // anchor + accepted
    const grown = ops.concatAxis([this.hCtx, add], 1);
    this.hCtx.dispose();
    add.dispose();
    vCtxML.dispose();
    this.hCtx = grown;
  }

  dispose(): void {
    this.hCtx?.dispose();
    this.hCtx = null;
  }
}
