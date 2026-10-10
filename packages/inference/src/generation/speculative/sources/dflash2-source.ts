// Dflash2Provider — the DFlash 2 block drafter (models/speculative/dflash2.ts)
// behind the grouped draft seam. Context rows are the target's tapped layer
// outputs over the accepted stream (prefill seeds them; each commit appends
// the anchor plus accepted rows), projected once into per-layer K/V.
// Drafting is greedy; the shared verify decides acceptance.
//
// The drafter loads in the basis it was trained on, its projections quantized
// to the width its composer passes (the draft registry passes 4: 1.0 GB
// resident instead of the 3.85 GB BF16 checkpoint). A target whose residual
// stream carries a TurboQuant R1 fold declares it on its draft target
// (`residualBasis`); binding a draft group applies it before the first draft.

import { artifactIdentity } from "../../../artifacts/identity";
import { projectedDraftGroups } from "../bindings/projected-draft-rows";
import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import type { DraftProvider, DraftSource, GroupedDraftProvider } from "../source";
import { targetLacks } from "../source";
import type { Dflash2DrafterModel } from "../../../contracts/mlx/drafter";
import { loadDflash2Drafter } from "../../../models/drafter-loaders";

export class Dflash2Provider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes: number;
  readonly grouped: GroupedDraftProvider;
  readonly gamma: number;

  private constructor(private readonly drafter: Dflash2DrafterModel, id: string, weightsBytes: number, namespace: string) {
    this.id = id;
    this.weightsBytes = weightsBytes;
    this.gamma = drafter.gamma;
    this.grouped = projectedDraftGroups(namespace, drafter.tapLayers, target => {
      if (!target.hiddenLayerTaps) throw targetLacks("hiddenLayerTaps");
      const layers = drafter.cfg.numTargetLayers;
      if (target.hiddenLayerTaps.layerCount !== layers) throw new Error(
        `DFlash 2 drafter was trained for a ${layers}-layer target; this model has ` +
        `${target.hiddenLayerTaps.layerCount} layers — wrong (target, drafter) pairing`);
      drafter.bindResidualBasis(target.residualBasis ?? null);
      const projection = target.hiddenLayerTaps.projection;
      return {
        namespace, schema: "dflash2-context-v1", layers: drafter.cfg.layers,
        project(hidden, positions) {
          using context = drafter.projectContext(hidden);
          return drafter.projectContextKVRows(context, positions);
        },
        draft: (context, pending, positions, depth) => drafter.draftRows(context, projection, pending, positions, depth),
        draftDevice: (context, pending, positions, depth) => drafter.draftRowsDevice(context, projection, pending, positions, depth),
      };
    });
  }

  /** `bits`: the drafter's projection width (0 keeps BF16). Persisted context is
   *  keyed by the drafter and that width; the target's own identity scopes it
   *  to one residual basis. */
  static async load(modelDir: string, options: { bits: number }): Promise<Dflash2Provider> {
    const { bits } = options;
    const drafter = await loadDflash2Drafter(modelDir, { bits });
    const id = modelDir.split("/").filter(Boolean).at(-1)!;
    try {
      const files = readdirSync(modelDir).filter(file => file.endsWith(".safetensors"));
      const identity = await artifactIdentity(await Bun.file(`${modelDir}/config.json`).text(),
        files.map(name => ({ name, path: join(modelDir, name) })));
      const bytes = files.reduce((total, file) => total + statSync(join(modelDir, file)).size, 0);
      return new Dflash2Provider(drafter, id, bytes, `dflash2-context-v1:${identity}:b${bits}`);
    } catch (error) { drafter.dispose(); throw error; }
  }

  open(): DraftSource {
    throw new Error("the DFlash 2 drafter runs only in the batched speculative lane");
  }

  dispose(): void { this.drafter.dispose(); }
}
