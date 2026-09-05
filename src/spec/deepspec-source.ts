// DeepspecSource — DeepSeek's released DSpark drafter checkpoints
// (Gemma4DSparkModel, e.g. deepseek-ai/dspark_gemma4_12b_block7) behind the
// serve-time DraftSource seam. The reference implementation is DeepSpec
// (github.com/deepseek-ai/DeepSpec, MIT); the module port with transcription
// notes lives in src/spec/dspark/deepspec-module.ts. Oracle: DeepSpec's eval
// at temperature 0 (RNG-free — verify degenerates to argmax token-match),
// scripts/oracle/oracle-dspark-deepspec.py → dspark-deepspec-compare.ts (deleted 2026-08-23; git history).
//
// Seam mapping (why this fits without serve-loop changes): the reference
// recycles target hidden states from each verify pass into the drafter's
// growing context — exactly the tapped ctxML/vCtxML flow the seam carries:
//   prefill(ids, ctxML)      → project the prompt's tapped hiddens into the
//                              per-layer context K/V cache (their DynamicCache
//                              of PROJECTED context rows, positions 0..Lp-1);
//   draft(feed, n)           → one block forward vs the cache (anchor = feed
//                              tail at position ctxLen); confidence truncation
//                              may return 0..n tokens (ℓ=0 = plain step);
//   commit(d, kAccept, vCtxML)→ project + append ONLY the accepted rows
//                              [anchor + kAccept drafts] (their crop()
//                              semantics: rejected rows never enter the
//                              cache), positions ctxLen..ctxLen+kAccept.
// Context rows are cached post-norm-post-rope — bit-equivalent to their
// in-round concat (per-row RMSNorm/RoPE; argued in projectContextKV's doc).

import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { DeepspecDrafter, type ContextKV } from "./dspark/deepspec-module";
import type { DraftProvider, DraftSource, TargetView } from "./source";

function safetensorsBytes(dir: string): number {
  let total = 0;
  for (const f of readdirSync(dir))
    if (f.endsWith(".safetensors")) total += statSync(join(dir, f)).size;
  return total;
}

export class DeepspecProvider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes: number;
  /** Trained block width (config block_size, e.g. 7) — the server pins
   *  numDraftTokens to this. */
  readonly gamma: number;

  private constructor(private readonly drafter: DeepspecDrafter, id: string, weightsBytes: number) {
    this.id = id;
    this.weightsBytes = weightsBytes;
    this.gamma = drafter.gamma;
  }

  static async load(modelDir: string): Promise<DeepspecProvider> {
    const drafter = await DeepspecDrafter.load(modelDir);
    const id = modelDir.split("/").filter(Boolean).at(-1)!;
    return new DeepspecProvider(drafter, id, safetensorsBytes(modelDir));
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    return new DeepspecSource(this.drafter, opts.target);
  }

  dispose(): void {
    this.drafter.dispose(); // owned MlxArrays (transpose views + mmap'd weights)
  }
}

export class DeepspecSource implements DraftSource {
  readonly weightsBytes = 0; // provider-owned weights
  readonly tapLayers: number[];
  private ctxKV: ContextKV[] | null = null; // per-layer projected context rows
  private ctxLen = 0; // context rows cached == the anchor's absolute position

  constructor(private readonly drafter: Pick<DeepspecDrafter,
    "cfg" | "tapLayers" | "projectContext" | "projectContextKV" | "draftBlock">, target: TargetView) {
    if (!target.gemmaTaps)
      throw new Error("DeepSpec drafter requires a Gemma4 target");
    const nLayers = target.gemmaTaps.layerCount;
    if (nLayers !== drafter.cfg.num_target_layers)
      throw new Error(
        `DeepSpec drafter was trained for a ${drafter.cfg.num_target_layers}-layer target; ` +
          `this model has ${nLayers} layers — wrong (target, drafter) pairing`,
      );
    this.tapLayers = drafter.tapLayers;
  }

  /** Project the prompt's tapped hiddens into the context cache (ownership of
   *  ctxML transfers here). */
  prefill(promptIds: number[], ctxML?: MlxArray): void {
    if (!ctxML) throw new Error("DeepSpec drafter: prefill missing tapped context");
    const Lp = ctxML.shape[1]!;
    const projected = this.drafter.projectContext(ctxML);
    ctxML.dispose();
    const positions = Array.from({ length: Lp }, (_, i) => i);
    this.ctxKV = this.drafter.projectContextKV(projected, positions);
    projected.dispose();
    this.ctxLen = Lp;
  }

  /** One block forward against the cached context. Confidence truncation may
   *  return 0..n tokens (0 = skip drafting; the serve loop runs a plain
   *  tapped step and commit still grows the context by the anchor row). */
  draft(feed: number[], n: number, _stepBase: number, _anchorHidden?: MlxArray): number[] {
    if (!this.ctxKV) throw new Error("DeepSpec drafter: draft before prefill");
    const anchorTok = feed[feed.length - 1]!;
    const block = this.drafter.draftBlock(this.ctxKV, anchorTok, this.ctxLen);
    block.baseLogits.dispose(); // serve loop runs its own verify lm-head
    // n < gamma near maxTokens: the block always drafts full γ; hand back
    // only what the round may verify.
    return block.tokens.length > n ? block.tokens.slice(0, n) : block.tokens;
  }

  /** Grow the context cache by the ACCEPTED rows of the verify window —
   *  [anchor + kAccept drafts] from vCtxML [1,d+1,m*H] (ownership transfers
   *  here); rejected rows never enter (reference crop() semantics). */
  commit(_d: number, kAccept: number, vCtxML?: MlxArray): void {
    if (!vCtxML) throw new Error("DeepSpec drafter: commit missing tapped verify context");
    if (!this.ctxKV) throw new Error("DeepSpec drafter: commit before prefill");
    const mH = vCtxML.shape[2]!;
    const keep = kAccept + 1; // anchor + accepted drafts
    const rows = vCtxML.slice([0, 0, 0], [1, keep, mH]);
    vCtxML.dispose();
    const projected = this.drafter.projectContext(rows);
    rows.dispose();
    const positions = Array.from({ length: keep }, (_, i) => this.ctxLen + i);
    const newKV = this.drafter.projectContextKV(projected, positions);
    projected.dispose();
    for (let i = 0; i < this.ctxKV.length; i++) {
      const old = this.ctxKV[i]!;
      const add = newKV[i]!;
      const k = ops.concatAxis([old.k, add.k], 2);
      const v = ops.concatAxis([old.v, add.v], 2);
      old.k.dispose(); old.v.dispose();
      add.k.dispose(); add.v.dispose();
      this.ctxKV[i] = { k, v };
    }
    this.ctxLen += keep;
  }

  dispose(): void {
    if (this.ctxKV) for (const { k, v } of this.ctxKV) { k.dispose(); v.dispose(); }
    this.ctxKV = null;
  }
}
