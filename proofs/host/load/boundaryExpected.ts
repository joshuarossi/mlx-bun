import { join, resolve } from "node:path";
import { cachedExpectedSources } from "./cachedExpected";

export type BoundaryCase = "fill" | "growth";

/** The same checked 64-stage builder at the two missing capacity branches.
 * The populated layout and embedding are shared with the checked finite
 * decode builder; only the position-dependent stages are constructed anew. */
export function boundaryExpectedSources(kind: BoundaryCase): Map<string, string> {
  if (kind !== "fill" && kind !== "growth") throw new Error("Expected fill or growth");
  const position = kind === "fill" ? 255 : 256;
  const namespace = `Host.Load.Run.Full.${kind === "fill" ? "Fill64" : "Growth64"}.Expected`;
  const prefix = `host.load.boundary.${kind}.expected`;
  const rewrite = (source: string) => source
    .replaceAll("Host.Load.Run.Full.Cached.Expected2", namespace)
    .replaceAll("host.load.run.full.cached.expected2", prefix)
    .replaceAll("id 1 (1 : Int) (2 : Int)", `id ${position} (${position} : Int) (${position + 1} : Int)`)
    .replaceAll("stepGraph stages head 1", `stepGraph stages head ${position}`)
    .replaceAll("stepGraph ls hl 1", `stepGraph ls hl ${position}`);
  const files = new Map([...cachedExpectedSources(2)].map(([name, source]) => [name, rewrite(source)]));
  files.set("Base.lean", `import host.load.run.full.cached.expected2.Base
namespace ${namespace}
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option Elab.async false
abbrev stages := Cached.Expected2.stages
abbrev head := Cached.Expected2.head
abbrev embedded := Cached.Expected2.embedded
theorem embedded.eq_original : embedded = run (embedG (δ := Int) (κ := InKey) id) [] := Cached.Expected2.embedded.eq_original
theorem layer_count : stages.length = 64 := Cached.Expected2.layer_count
theorem stages_eq : layouts firstChoice = some stages := Cached.Expected2.stages_eq
theorem head_eq : linearLayout firstChoice.model.head = some head := Cached.Expected2.head_eq
end ${namespace}
`);
  return files;
}

export async function generateBoundaryExpected(proofRoot: string, kind: BoundaryCase): Promise<string[]> {
  const files: string[] = [];
  for (const [name, source] of boundaryExpectedSources(kind)) {
    const relative = `host/load/boundary/${kind}/expected/${name}`;
    await Bun.write(join(proofRoot, relative), source);
    files.push(relative);
  }
  return files;
}

if (import.meta.main) {
  const kind = process.argv[3] ?? "growth";
  if (kind !== "fill" && kind !== "growth") throw new Error("Expected fill or growth");
  for (const file of await generateBoundaryExpected(resolve(process.argv[2] ?? resolve(import.meta.dir, "../..")), kind)) console.log(file);
}
