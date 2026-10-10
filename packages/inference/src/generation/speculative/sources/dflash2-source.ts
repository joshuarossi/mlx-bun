// Dflash2Provider — the DFlash 2 block drafter (models/speculative/dflash2.ts)
// behind the grouped draft seam. Context rows are the target's tapped layer
// outputs over the accepted stream (prefill seeds them; each commit appends
// the anchor plus accepted rows), projected once into per-layer K/V.
// Drafting is greedy; the shared verify decides acceptance.
//
// The drafter's projections are quantized to 4 bits at load (1.0 GB resident
// instead of the 3.85 GB BF16 checkpoint). MLX_BUN_DFLASH2_TARGET_BASIS names
// the JSON file {"seed": 42, "finalGain": [...hidden]} describing a target
// whose residual stream carries a TurboQuant R1 fold (our Trellis artifact);
// absent, the target basis is the drafter's.

import { artifactIdentity } from "../../../artifacts/identity";
import { projectedDraftGroups } from "../bindings/projected-draft-rows";
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import type { DraftProvider, DraftSource, GroupedDraftProvider } from "../source";
import { targetLacks } from "../source";
import { runtimeValue } from "../../../runtime/config";
import type { Dflash2DrafterModel, Dflash2TargetBasis } from "../../../contracts/mlx/drafter";
import { loadDflash2Drafter } from "../../../models/drafter-loaders";

/** R1 sign lane 0 of the rotation fold (packages/quantize/src/rotate.ts signVector). */
function r1Signs(seed: number, n: number): Float32Array {
  let state = (seed ^ Math.imul(1, 0x9e3779b9)) >>> 0;
  const out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    state = (state + 0x9e3779b9) >>> 0;
    let z = state;
    z = Math.imul(z ^ (z >>> 16), 0x21f0aaad);
    z = Math.imul(z ^ (z >>> 15), 0x735a2d97);
    z ^= z >>> 15;
    out[i] = (z & 1) === 0 ? 1 : -1;
  }
  return out;
}

function targetBasis(path: string | undefined): Dflash2TargetBasis | null {
  if (!path) return null;
  const raw = JSON.parse(readFileSync(path, "utf8")) as { seed: number; finalGain: number[] };
  const finalGain = Float32Array.from(raw.finalGain);
  return { seed: raw.seed, signs: r1Signs(raw.seed, finalGain.length), finalGain };
}

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

  static async load(modelDir: string): Promise<Dflash2Provider> {
    const bits = 4;
    const basis = targetBasis(runtimeValue("MLX_BUN_DFLASH2_TARGET_BASIS"));
    const drafter = await loadDflash2Drafter(modelDir, { bits, basis });
    const id = modelDir.split("/").filter(Boolean).at(-1)!;
    try {
      const files = readdirSync(modelDir).filter(file => file.endsWith(".safetensors"));
      const identity = await artifactIdentity(await Bun.file(`${modelDir}/config.json`).text(),
        files.map(name => ({ name, path: join(modelDir, name) })));
      const bytes = files.reduce((total, file) => total + statSync(join(modelDir, file)).size, 0);
      const basisTag = basis ? `:r1-${basis.seed}` : "";
      return new Dflash2Provider(drafter, id, bytes, `dflash2-context-v1:${identity}:b${bits}${basisTag}`);
    } catch (error) { drafter.dispose(); throw error; }
  }

  open(): DraftSource {
    throw new Error("the DFlash 2 drafter runs only in the batched speculative lane");
  }

  dispose(): void { this.drafter.dispose(); }
}
