// STS calibration (§3.2.1) of a trained drafter: run the production speculative
// executor over a prompt set with confidence pruning DISABLED, so every draft
// position's confidence AND its real accept/reject outcome are visible (pruning
// would hide the positions it drops), fit per-position thresholds (sts.ts) and
// write them into the checkpoint's dspark.json (`config.sts`). Every other
// field of the checkpoint is preserved verbatim.

import type { RuntimeModel } from "@mlx-bun/inference/models";
import type { ChatTemplate, ChatMessage, LoadedTokenizer } from "@mlx-bun/inference/input";
import { generateSpeculative, DflashSource, type DraftProvider, type DraftSource, type TargetView } from "@mlx-bun/inference/generation/speculative";
import { loadDsparkDrafter, type DflashDrafter, type StsCalibration } from "@mlx-bun/inference/generation/speculative/loader";
import { fitStsThresholds, type ConfSample } from "./sts";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

/** A DSpark draft provider that drafts the FULL unpruned block and reports each
 *  round's (confidence, accepted) outcomes once the target has verified it. */
export class CalibrationProvider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes = 0;
  constructor(private readonly drafter: DflashDrafter, private readonly observe: (samples: ConfSample[]) => void, id: string) { this.id = id; }

  open({ target }: { target: TargetView }): DraftSource {
    let confidence: number[] = [];
    const drafter = this.drafter;
    const unpruned: Pick<DflashDrafter, "cfg" | "forwardInfer"> = {
      cfg: { ...drafter.cfg, sts: undefined },
      forwardInfer(model, hCtx, anchor, gamma, opts) {
        const block = drafter.forwardInfer(model, hCtx, anchor, gamma, { ...opts, thresholds: [], minConf: undefined });
        confidence = block.conf;
        return block;
      },
    };
    const inner = new DflashSource(unpruned, target);
    const observe = this.observe;
    return {
      weightsBytes: 0,
      tapLayers: inner.tapLayers,
      prefill: (ids, context) => inner.prefill(ids, context),
      draft: (...args) => inner.draft(...args),
      commit(drafted, accepted, context) {
        // `drafted` = positions this round verified; the first `accepted` matched.
        observe(Array.from({ length: drafted }, (_, pos) => ({ pos, conf: confidence[pos]!, accepted: pos < accepted })));
        return inner.commit(drafted, accepted, context);
      },
      dispose: () => inner.dispose(),
    };
  }

  dispose(): void { this.drafter.dispose(); }
}

export interface CalibrateOptions {
  /** Prompts to run (chat messages or a plain user message). At most `count` are used. */
  prompts: readonly (string | ChatMessage[])[];
  count?: number;
  maxTokens?: number;
  /** Acceptance precision the kept positions must reach. Default 0.5. */
  target?: number;
  /** Positions with fewer observations are never pruned. Default 50. */
  minSamples?: number;
  onPrompt?: (event: { index: number; promptTokens: number; generated: number; acceptance: number }) => void;
  signal?: AbortSignal;
}

export interface CalibrationFit { sts: StsCalibration; positionSamples: number[]; gamma: number }

/** Collect (confidence, accepted) samples and fit thresholds for the drafter in
 *  `drafterDir`. Does not write; see `writeSts`. */
export async function calibrateDrafter(
  model: RuntimeModel, tokenizer: LoadedTokenizer, template: ChatTemplate, drafterDir: string, opts: CalibrateOptions,
): Promise<CalibrationFit> {
  const drafter = loadDsparkDrafter(drafterDir);
  const gamma = drafter.cfg.gamma, samples: ConfSample[] = [];
  const provider = new CalibrationProvider(drafter, round => samples.push(...round), drafterDir);
  try {
    const count = Math.min(opts.count ?? 32, opts.prompts.length);
    for (let index = 0; index < count; index++) {
      opts.signal?.throwIfAborted();
      const row = opts.prompts[index]!;
      const messages: ChatMessage[] = typeof row === "string" ? [{ role: "user", content: row }] : row;
      let ids = tokenizer.encode(template.render(messages, { addGenerationPrompt: true }), true);
      if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId) ids = ids.slice(1);
      const stats = await generateSpeculative(model, provider, gamma, ids,
        { maxTokens: opts.maxTokens ?? 128, temperature: 0, eosTokenIds: [...model.config.eosTokenIds] }, () => {});
      const spec = stats.spec!;
      opts.onPrompt?.({ index, promptTokens: ids.length, generated: stats.generatedTokens, acceptance: spec.drafted ? spec.accepted / spec.drafted : 0 });
    }
  } finally { provider.dispose(); }
  const sts = fitStsThresholds(samples, gamma, opts.target ?? 0.5, opts.minSamples ?? 50);
  const positionSamples = new Array<number>(gamma).fill(0);
  for (const sample of samples) if (sample.pos >= 0 && sample.pos < gamma) positionSamples[sample.pos]!++;
  return { sts, positionSamples, gamma };
}

/** The calibration a checkpoint carries, if any (read without loading weights). */
export function readSts(dir: string): StsCalibration | undefined {
  return (JSON.parse(readFileSync(join(dir, "dspark.json"), "utf8")) as { config: { sts?: StsCalibration } }).config.sts;
}

/** Set `config.sts` in `<dir>/dspark.json`, preserving every other field. */
export function writeSts(dir: string, sts: StsCalibration): string {
  const path = join(dir, "dspark.json");
  if (!existsSync(path)) throw new Error(`${dir} has no dspark.json — copy the checkpoint directory first`);
  const meta = JSON.parse(readFileSync(path, "utf8")) as { config: Record<string, unknown> };
  meta.config = { ...meta.config, sts };
  writeFileSync(path, JSON.stringify(meta, null, 2));
  return path;
}
