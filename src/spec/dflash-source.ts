// DflashSource — DSpark (faithful DFlash + Markov + confidence,
// src/spec/dspark/module-dflash.ts) behind the serve-time DraftSource seam.
// L3 (KL/quality-gated). The DRAFT half of the standalone dflashGenerate loop
// (src/spec/dspark/generate-dflash.ts) plugged into the shared verify/accept
// executor (src/spec/serve-loop.ts).
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
// target verify decides). The richer rejection-sampling verify stays in the
// standalone dflashGenerate for the measure script.

import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { DflashDrafter } from "./dspark/module-dflash";
import { loadDsparkDrafter } from "./dspark/loader";
import type { DraftProvider, DraftSource, TargetView, DraftProjection } from "./source";
import { runtimeValue } from "../runtime-config";

function safetensorsBytes(dir: string): number {
  let total = 0;
  for (const f of readdirSync(dir))
    if (f.endsWith(".safetensors")) total += statSync(join(dir, f)).size;
  return total;
}

export class DflashProvider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes: number;
  /** The trained block width — the server pins numDraftTokens to this so the
   *  serve loop never asks for more positions than the block was trained for. */
  readonly gamma: number;

  private constructor(private readonly drafter: DflashDrafter, id: string, weightsBytes: number) {
    this.id = id;
    this.weightsBytes = weightsBytes;
    this.gamma = drafter.cfg.gamma;
  }

  static async load(modelDir: string): Promise<DflashProvider> {
    const drafter = loadDsparkDrafter(modelDir); // variant dispatch (dspark|legacy dflash)
    const id = modelDir.split("/").filter(Boolean).at(-1)!;
    return new DflashProvider(drafter, id, safetensorsBytes(modelDir));
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    return new DflashSource(this.drafter, opts.target);
  }

  dispose(): void {
    // Unlike the assistant drafter (process-pinned mmaps), DflashDrafter
    // materializes owned MlxArrays — free them on teardown.
    this.drafter.dispose();
  }
}

export class DflashSource implements DraftSource {
  readonly weightsBytes = 0; // provider-owned weights
  readonly tapLayers: number[];
  private readonly model: DraftProjection;
  private readonly minConf = runtimeValue("MLX_BUN_DSPARK_MINCONF");
  private hCtx: MlxArray | null = null; // [1, L, m*H] — grows with the accepted stream

  constructor(private readonly drafter: Pick<DflashDrafter, "cfg" | "forwardInfer">, target: TargetView) {
    if (!target.gemmaTaps)
      throw new Error("DSpark drafter requires a Gemma4 target");
    this.model = target.gemmaTaps.projection;
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
