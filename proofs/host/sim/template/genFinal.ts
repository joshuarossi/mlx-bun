// Write Case.lean of a final case split at the epilogue spread (`Host.Ts.Sim.FinalCase`).
// usage: bun proofs/host/sim/template/genFinal.ts <case-dir> <Name> <cE>
//   <cE>: the cell of the driver's `emitted` binding.
// Reads <Name>'s split (`tpl_case_split`): T1, the spread's boundary ia, its new array aN, the
// steps to halt and the steps to the state before the spread's (boundary ia - 1), from <proofs>/.host-stream/Host.Load.Run.Tpl.<Name>/split.txt.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [dir, name, cE] = process.argv.slice(2);
if (!dir || !name || !cE) throw new Error("usage: genFinal.ts <case-dir> <Name> <cE>");
const splitFile = join(import.meta.dir, "..", "..", "..", ".host-stream", `Host.Load.Run.Tpl.${name}`, "split.txt");
const [t1, ia, aN, steps, nA] = readFileSync(splitFile, "utf8").trim().split(" ").map(Number) as [number, number, number, number, number];
const nB = steps - nA - 2;
const P = `${name}.s${ia - 1}`, A = `${name}.s${ia}`, B = `${name}.s${ia + 1}`, F = `${name}.s${t1}`;
const out = `import host.sim.template.${dir}.Run
import host.sim.template.${dir}.Base
import host.sim.template.base.Facts
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case \`${name}\` as a checked final case (\`Host.Ts.Sim.FinalCase\`): segment A
(\`${name}.runA\`, ${nA} steps checked with \`ok\`) to \`${P}\`, the step to the epilogue
spread \`${A}\` (\`${name}.stepA\`; \`ok\` rejects the spread's state), its step
(\`${name}.stepB\`), and segment B (\`${name}.runB\`, ${nB} steps checked with \`${name}.okB\`, which
frames the spread's new array ${aN}) to the halt \`${F}\`. -/

kernel_rfl ${name}.start : ${name}.s0 = finalStart Base.s0 Base.S0.tab.length
kernel_rfl ${name}.okA0 : ok ${name}.s0 ${name}.S0 = true
kernel_rfl ${name}.okP : ok ${P} ${name}.S${ia - 1} = true
kernel_rfl ${name}.haltP : isHalt ${P}.ctl = false
kernel_rfl ${name}.ctlA : ${A}.ctl = .ret (.obj 2673447)

/-- The spread frame's accumulator, environment and the frames below it. -/
noncomputable def ${name}.accA : List Val := match ${A}.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def ${name}.envA : Env := match ${A}.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def ${name}.fsA : List Frame := match ${A}.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl ${name}.stackA : ${A}.stack = .l (.spread ${name}.accA [] ${name}.envA) :: ${name}.fsA
kernel_rfl ${name}.roomA_check : Nat.blt (${A}.next + margin) Sim.bound = true
kernel_rfl ${name}.arrA : (${A}.heap.get aArrayProto).isSome = true
kernel_rfl ${name}.newA : ${A}.next = ${aN}
kernel_rfl ${name}.okB0 : ${name}.okB ${B} ${name}.S${ia + 1} = true

/-- The halt's value. -/
noncomputable def ${name}.vF : Val := match ${F}.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl ${name}.haltF : ${F}.ctl = .halt (.normal ${name}.vF)
kernel_rfl ${name}.emit_get : ${F}.heap.get 12502 = some (.obj (objOf ${F} 12502))
kernel_rfl ${name}.emit_kind :
  (objOf ${F} 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79), .num (.ref Base.S0.tab.length)])
kernel_rfl ${name}.cell : ${F}.cell? ${cE} = some (some (.obj 12502))

theorem ${name}.aN_ne : ${aN} ≠ 2673447 ∧ ${aN} ≠ 12502 := by decide

noncomputable def ${name}.finalCase : FinalCase ok ${name}.okB Base.s0 Base.S0.tab ${cE} ${aN} where
  S0 := ${name}.S0
  tab := ${name}.S0_tab
  nA := ${nA}
  sP := ${P}
  SP := ${name}.S${ia - 1}
  okA0 := by rw [← ${name}.start]; exact ${name}.okA0
  runA := by rw [← ${name}.start]; exact ${name}.runA
  okP := ${name}.okP
  haltP := ${name}.haltP
  sA := ${A}
  SA := ${name}.S${ia}
  stepA := ${name}.stepA
  acc := ${name}.accA
  env := ${name}.envA
  fs := ${name}.fsA
  ctlA := ${name}.ctlA
  stackA := ${name}.stackA
  roomA := Nat.le_of_ble_eq_true ${name}.roomA_check
  arrA := ${name}.arrA
  newA := ${name}.newA
  sB := ${B}
  SB := ${name}.S${ia + 1}
  stepB := ${name}.stepB
  okB0 := ${name}.okB0
  nB := ${nB}
  sF := ${F}
  SF := ${name}.S${t1}
  runB := ${name}.runB
  halt := ⟨_, ${name}.haltF⟩
  emitG := ⟨_, ${name}.emit_get, ${name}.emit_kind⟩
  cell := ${name}.cell

end Host.Load.Run.Tpl
`;
writeFileSync(join(import.meta.dir, dir, "Case.lean"), out);
console.log(`${name}: Case.lean (T1 ${t1}, spread boundary ${ia}, nA ${nA}, nB ${nB}, aN ${aN}, cE ${cE})`);
