import { join, resolve } from "node:path";
import { expectedSources } from "./expected";

/** Reuse the original checked stage/chain builder with the actual populated
 * cache layout at the preceding source cut. Each chosen literal is followed
 * by its ordinary kernel equality to the unchanged builder. */
export function cachedExpectedSources(forward: number): Map<string, string> {
  if (!Number.isInteger(forward) || forward < 2 || forward > 5) throw new Error("Expected forward 2..5");
  const n = forward - 1;
  const namespace = `Host.Load.Run.Full.Cached.Expected${forward}`;
  const prefix = `host.load.run.full.cached.expected${forward}`;
  const previous = "firstChoice";
  const original = expectedSources();
  const rewrite = (s: string) => s
    .replaceAll("Host.Load.Run.Full.Expected", namespace)
    .replaceAll("host.load.run.full.expected", prefix)
    .replaceAll("parameterChoice", previous)
    .replaceAll("id 0 (0 : Int) (1 : Int)", `id ${n} (${n} : Int) (${n + 1} : Int)`)
    .replaceAll("stepGraph stages head 0", `stepGraph stages head ${n}`)
    .replaceAll("stepGraph ls hl 0", `stepGraph ls hl ${n}`)
    .replace(/^theorem node_count : graph.length = 4020 := rfl\n/m, "");
  const imports = ["host.load.run.full.FirstChoice"];
  const files = new Map<string, string>();
  const base = rewrite(original.get("Base.lean")!).replace("import host.load.run.full.ChoiceStates", imports.map(m => `import ${m}`).join("\n"));
  files.set("Base.lean", base);
  for (let group = 0; group < 16; group++) {
    let s = `import ${prefix}.${group === 0 ? "Base" : `Stages${group - 1}`}\nnamespace ${namespace}\n` +
      "open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts\n" +
      "set_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nset_option Elab.async false\n";
    for (let i = group * 4; i < (group + 1) * 4; i++) {
      const prev = i === 0 ? "embedded" : `fragment${i - 1}`;
      const input = i === 0 ? `${prev}.1` : `${prev}.1.1`;
      const term = `run (stageG id ${n} (${n} : Int) (${n + 1} : Int) stages[${i}] (fun k => InKey.stage ${i} k) ${input}) ${prev}.2`;
      s += `\nffi_value_literal fragment${i} : ${term}\nffi_value_literal_eq fragment${i} : ${term}\n`;
    }
    files.set(`Stages${group}.lean`, s + `\nend ${namespace}\n`);
  }
  files.set("Join.lean", rewrite(original.get("Join.lean")!).replace(`${prefix}.Stages8`, `${prefix}.Stages15`));
  return files;
}

export async function generateCachedExpected(proofRoot: string, forward: number): Promise<string[]> {
  const files: string[] = [];
  for (const [name, source] of cachedExpectedSources(forward)) {
    const relative = `host/load/run/full/cached/expected${forward}/${name}`;
    await Bun.write(join(proofRoot, relative), source);
    files.push(relative);
  }
  return files;
}

if (import.meta.main) {
  const forward = Number(process.argv[3] ?? 2);
  for (const file of await generateCachedExpected(resolve(process.argv[2] ?? resolve(import.meta.dir, "../..")), forward)) console.log(file);
}
