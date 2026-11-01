// bun genFam.ts <Tag> <family term over refRows> <n0>
// Writes host/simgraph/tpl/fam/<Tag>/{Stages<k>,Join}.lean: a GPU row family's expected graph at the cold layout, one
// literal per layer (ffi_value_literal, checked by ffi_value_literal_eq), joined to `familyGraph` (`family_eq`).
import { mkdirSync } from "fs";
import { dirname, join } from "path";
const [Tag, term, n0] = process.argv.slice(2);
if (!Tag || !term || !n0) throw new Error("usage: genFam.ts <Tag> <family term> <n0>");
const dir = join(dirname(import.meta.path), "fam", Tag);
mkdirSync(dir, { recursive: true });
const NS = `Host.Mlx.SimGraph.Tpl.Fam.${Tag}`;
const LAYERS = 64, PER = 4;
const head = (imports: string[]) => imports.map(i => `import ${i}`).join("\n") + `
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace ${NS}
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)
`;
const frag = (p: number) => {
  const [x, g] = p === 0 ? ["embedded.1", "embedded.2"] : [`fragment${p - 1}.1.1`, `fragment${p - 1}.2`];
  const t = `run (F.layer id 0 ${n0} ${p} stages[${p}] ${x}) ${g}`;
  return `ffi_value_literal fragment${p} : ${t}\nffi_value_literal_eq fragment${p} : ${t}\n`;
};
for (let k = 0; k * PER < LAYERS; k++) {
  let body = "";
  if (k === 0) {
    body += `/-- The family. -/\ndef F : RowOps SimGraph.PKey := (${term}).ops\n\n`;
    body += `ffi_value_literal embedded : run (F.embed (δ := PDim) id) []\nffi_value_literal_eq embedded : run (F.embed (δ := PDim) id) []\n\n`;
  }
  for (let p = k * PER; p < Math.min((k + 1) * PER, LAYERS); p++) body += frag(p) + "\n";
  const imports = k === 0
    ? ["host.simgraph.prompt.ChooseFamily", "host.simgraph.tpl.FamJoin", "host.load.run.full.expected.Base", "host.simgraph.ref.Steps"]
    : [`host.simgraph.tpl.fam.${Tag}.Stages${k - 1}`];
  await Bun.write(join(dir, `Stages${k}.lean`), head(imports) + "\n" + body + `end ${NS}\n`);
}
const last = LAYERS - 1;
let j = head([`host.simgraph.tpl.fam.${Tag}.Stages${Math.floor(last / PER)}`]) + "\n";
j += `def cacheNodes : List (Nat × Nat) := [\n` + Array.from({ length: LAYERS }, (_, p) => `  (fragment${p}.1.2.1, fragment${p}.1.2.2)`).join(",\n") + `]\n\n`;
for (let p = last; p >= 0; p--) {
  const [x, g] = p === 0 ? ["embedded.1", "embedded.2"] : [`fragment${p - 1}.1.1`, `fragment${p - 1}.2`];
  const stmt = `theorem suffix${p} :\n  run (chainP F id 0 ${n0} ${p} (stages.drop ${p}) ${x}) ${g} =\n    ((fragment${last}.1.1, cacheNodes.drop ${p}), fragment${last}.2) := by\n`;
  const pf = p === last
    ? `  exact chainP_join F id 0 ${n0} ${p} stages[${p}] [] ${x} fragment${p}.1.1 fragment${p}.1.2.1 fragment${p}.1.2.2 fragment${last}.1.1\n    [] ${g} fragment${p}.2 fragment${last}.2 fragment${p}.eq_original.symm (chainP_nil F id 0 ${n0} ${p + 1} fragment${last}.1.1 fragment${last}.2)\n`
    : `  exact chainP_join F id 0 ${n0} ${p} stages[${p}] (stages.drop ${p + 1}) ${x} fragment${p}.1.1 fragment${p}.1.2.1 fragment${p}.1.2.2 fragment${last}.1.1\n    (cacheNodes.drop ${p + 1}) ${g} fragment${p}.2 fragment${last}.2 fragment${p}.eq_original.symm suffix${p + 1}\n`;
  j += stmt + pf + "\n";
}
j += `ffi_value_literal finished : run (F.final (δ := PDim) id fragment${last}.1.1) fragment${last}.2\nffi_value_literal_eq finished : run (F.final (δ := PDim) id fragment${last}.1.1) fragment${last}.2\n\n`;
j += `def graph : List (RNode PDim SimGraph.PKey) := finished.2\ndef outNode : Nat := finished.1\n\n`;
j += `/-- **The family's expected graph** at the cold layout. -/\ntheorem family_eq : familyGraph F id 0 ${n0} stages = (graph, outNode, cacheNodes) :=\n  familyGraph_join F id 0 ${n0} stages embedded.1 fragment${last}.1.1 finished.1 cacheNodes embedded.2 fragment${last}.2 finished.2\n    embedded.eq_original.symm suffix0 finished.eq_original.symm\n\n`;
j += `end ${NS}\n`;
await Bun.write(join(dir, "Join.lean"), j);
console.log(`${Tag}: ${Math.ceil(LAYERS / PER)} stage modules, Join`);
