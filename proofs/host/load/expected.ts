import { join, resolve } from "node:path";

const namespace = "Host.Load.Run.Full.Expected";
const modulePrefix = "host.load.run.full.expected";
const groups = [[0, 8], [8, 16], [16, 24], [24, 32], [32, 40], [40, 48], [48, 56], [56, 60], [60, 64]] as const;
const header = (imports: string[]) => imports.map(name => `import ${name}`).join("\n") +
  `\nnamespace ${namespace}\nopen Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts\n` +
  "set_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nset_option Elab.async false\n";
const end = `\nend ${namespace}\n`;

/** Ordinary kernel equalities join each original stageG computation. Native
 * evaluation chooses literals only; no computation result is a proof. */
export function expectedSources(): Map<string, string> {
  const files = new Map<string, string>();
  files.set("Base.lean", header(["host.load.run.full.ChoiceStates", "host.load.Inputs", "host.mlx.GraphBuildCommand"]) + `
ffi_value_literal layoutData : (layouts parameterChoice, linearLayout parameterChoice.model.head)
ffi_value_literal_eq layoutData : (layouts parameterChoice, linearLayout parameterChoice.model.head)

def stages : List StageLayout := layoutData.1.getD []
def head : LinLayout := layoutData.2.getD ⟨.affineRow, 0, 0, 0⟩

theorem layer_count : stages.length = 64 := rfl

theorem stages_eq : layouts parameterChoice = some stages := by
  have h := congrArg Prod.fst layoutData.eq_original.symm
  exact h.trans (by rfl)

theorem head_eq : linearLayout parameterChoice.model.head = some head := by
  have h := congrArg Prod.snd layoutData.eq_original.symm
  exact h.trans (by rfl)

ffi_value_literal embedded : run (embedG (δ := Int) (κ := InKey) id) []
ffi_value_literal_eq embedded : run (embedG (δ := Int) (κ := InKey) id) []
` + end);

  for (const [group, [lo, hi]] of groups.entries()) {
    let source = header([`${modulePrefix}.${group === 0 ? "Base" : `Stages${group - 1}`}`]);
    for (let i = lo; i < hi; i++) {
      const previous = i === 0 ? "embedded" : `fragment${i - 1}`;
      const input = i === 0 ? `${previous}.1` : `${previous}.1.1`;
      const term = `run (stageG id 0 (0 : Int) (1 : Int) stages[${i}] (fun k => InKey.stage ${i} k) ${input}) ${previous}.2`;
      source += `\nffi_value_literal fragment${i} : ${term}\nffi_value_literal_eq fragment${i} : ${term}\n`;
    }
    files.set(`Stages${group}.lean`, source + end);
  }

  let source = header([`${modulePrefix}.Stages${groups.length - 1}`]);
  source += "\ndef cacheNodes : List (Nat × Nat) := [\n" +
    Array.from({ length: 64 }, (_, i) => `  (fragment${i}.1.2.1, fragment${i}.1.2.2)`).join(",\n") + "]\n";
  for (let i = 64; i >= 0; i--) {
    const previous = i === 0 ? "embedded" : `fragment${i - 1}`;
    const input = i === 0 ? `${previous}.1` : `${previous}.1.1`;
    source += `\ntheorem suffix${i} :\n  run (chainG id 0 (0 : Int) (1 : Int) id ${i} (stages.drop ${i}) ${input}) ${previous}.2 =\n    ((fragment63.1.1, cacheNodes.drop ${i}), fragment63.2) := by\n`;
    if (i === 64) source += "  rfl\n";
    else source += `  exact chainG_join id 0 (0 : Int) (1 : Int) id ${i} stages[${i}] (stages.drop ${i + 1})\n` +
      `    ${input} fragment${i}.1.1 fragment${i}.1.2.1 fragment${i}.1.2.2 fragment63.1.1\n` +
      `    (cacheNodes.drop ${i + 1}) ${previous}.2 fragment${i}.2 fragment63.2 fragment${i}.eq_original.symm suffix${i + 1}\n`;
  }
  source += `
ffi_value_literal finished : run (finishG id id head fragment63.1.1 cacheNodes) fragment63.2
ffi_value_literal_eq finished : run (finishG id id head fragment63.1.1 cacheNodes) fragment63.2

def graph : List (RNode Int InKey) := finished.2
def tokenNode : Nat := finished.1.1
def cacheOutputs : List (Nat × Nat) := finished.1.2

theorem step_original : run (stepG id 0 (0 : Int) (1 : Int) id stages head) [] = finished := by
  exact stepG_join id 0 (0 : Int) (1 : Int) id stages head embedded.1 fragment63.1.1 cacheNodes
    finished.1 [] embedded.2 fragment63.2 finished.2 embedded.eq_original.symm suffix0 finished.eq_original.symm

theorem graph_original : stepGraph stages head 0 = (graph, tokenNode, cacheOutputs) := by
  exact congrArg (fun r : (Nat × List (Nat × Nat)) × List (RNode Int InKey) => (r.2, r.1)) step_original

theorem extracted_graph_original :
    ((layouts parameterChoice).bind fun ls => (linearLayout parameterChoice.model.head).map fun hl => stepGraph ls hl 0) =
      some (graph, tokenNode, cacheOutputs) := by
  rw [stages_eq, head_eq]
  change some (stepGraph stages head 0) = _
  rw [graph_original]

def expectedGraph : List (RNode Int InKey) :=
  ((layouts parameterChoice).bind fun ls => (linearLayout parameterChoice.model.head).map fun hl => (stepGraph ls hl 0).1).getD []

theorem graph_eq_original : graph = expectedGraph := by
  unfold expectedGraph
  rw [stages_eq, head_eq]
  change graph = (stepGraph stages head 0).1
  exact (congrArg Prod.fst graph_original).symm

theorem output_count : cacheOutputs.length = 64 := rfl
theorem node_count : graph.length = 4020 := rfl
`;
  files.set("Join.lean", source + end);
  return files;
}

export async function generateExpected(proofRoot: string): Promise<string[]> {
  const files: string[] = [];
  for (const [name, source] of expectedSources()) {
    const relative = `host/load/run/full/expected/${name}`;
    await Bun.write(join(proofRoot, relative), source);
    files.push(relative);
  }
  return files;
}

if (import.meta.main) {
  const files = await generateExpected(resolve(process.argv[2] ?? resolve(import.meta.dir, "../..")));
  for (const file of files) console.log(`  "${file}",`);
}
