// AssistantSource — the optiq KV-borrowing Gemma "-assistant" drafter
// (src/spec/drafter.ts) behind the serve-time DraftSource seam. L2 oracle:
// optiq spec_generate. This is the SAME drafter the standalone specGenerate
// loop (src/spec/generate.ts) drives; here it plugs into the shared
// verify/accept executor (src/spec/serve-loop.ts) so it composes with grammar,
// logits processors, admission accounting, and stats like any other source.
//
// KV-borrowing (why the seam carries a TargetView): the drafter has NO cache
// of its own — each draft step reads the target's donor K/V (last sliding +
// last full layer, in chronological order) and, for the block's first step,
// the target's hidden at the anchor position. Both arrive through the seam:
// donor views from `target.caches`, the anchor hidden from draft()'s
// `anchorHidden` argument (borrowed — never disposed here). See
// [[dspark-seam-kv-borrowing]].
//
// Drafting is GREEDY (the drafter's own argmax head), independent of the
// request sampler — drafts are only proposals; the target's verify (which does
// honor the sampler) decides every emitted token, so correctness holds at any
// temperature and only the acceptance RATE moves. Matches specGenerate.

import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import type { MlxArray } from "../mlx/array";
import { GemmaAssistantDrafter } from "./drafter";
import type { DraftProvider, DraftSource, TargetView, AssistantTarget } from "./source";

/** Sum of the drafter's on-disk safetensors — admission accounting only. */
function safetensorsBytes(dir: string): number {
  let total = 0;
  for (const f of readdirSync(dir))
    if (f.endsWith(".safetensors")) total += statSync(join(dir, f)).size;
  return total;
}

export class AssistantProvider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes: number;

  private constructor(
    private readonly drafter: GemmaAssistantDrafter,
    id: string,
    weightsBytes: number,
  ) {
    this.id = id;
    this.weightsBytes = weightsBytes;
  }

  static async load(modelDir: string): Promise<AssistantProvider> {
    const drafter = await GemmaAssistantDrafter.load(modelDir);
    const id = modelDir.split("/").filter(Boolean).at(-1)!;
    return new AssistantProvider(drafter, id, safetensorsBytes(modelDir));
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    return new AssistantSource(this.drafter, opts.target);
  }

  dispose(): void {
    // The drafter's Weights are process-lifetime (pinned mmaps); nothing to free.
  }
}

export class AssistantSource implements DraftSource {
  readonly weightsBytes = 0; // provider-owned weights; per-request adds nothing
  private readonly target: AssistantTarget;

  constructor(private readonly drafter: Pick<GemmaAssistantDrafter, "forward">, target: TargetView) {
    if (!target.assistant)
      throw new Error("assistant drafter requires a Gemma4 target with donor views");
    this.target = target.assistant;
  }

  /** No own cache to prime — the drafter reads the target's live state. */
  prefill(_promptIds: number[], _ctxML?: MlxArray): void {}

  /** Draft n tokens against the target's donor K/V, conditioning the first
   *  step on the anchor (the last emitted token + its target hidden) and
   *  chaining the drafter's own post-projected hiddens after that — exactly
   *  specGenerate's 2a block. anchorHidden is borrowed; never disposed here. */
  draft(feed: number[], n: number, _stepBase: number, anchorHidden?: MlxArray): number[] {
    if (!anchorHidden) throw new Error("assistant drafter needs the target anchor hidden");
    const position = this.target.position();
    const shared = this.target.readDonors();
    const drafts: number[] = [];
    const ownedHiddens: MlxArray[] = [];
    let dTok = feed[feed.length - 1]!; // the pending token (anchorHidden's token)
    let dHid = anchorHidden; // borrowed for k=0
    let emb: MlxArray | null = null; // hoisted so a mid-loop throw still frees it
    try {
      for (let k = 0; k < n; k++) {
        emb = this.target.embedScaled(dTok);
        const step = this.drafter.forward(emb, dHid, shared, position + k);
        emb.dispose();
        emb = null;
        drafts.push(step.token);
        ownedHiddens.push(step.nextHidden);
        dTok = step.token;
        dHid = step.nextHidden;
      }
    } finally {
      emb?.dispose();
      for (const a of ownedHiddens) a.dispose();
      for (const [k, v] of [shared.sliding, shared.full]) {
        k.dispose();
        v.dispose();
      }
    }
    return drafts;
  }

  /** The serve loop already trims the target caches on rejection; the drafter
   *  borrows them, so it has nothing of its own to roll back. */
  commit(_n: number, _kAccept: number, _vCtxML?: MlxArray): void {}

  dispose(): void {}
}
