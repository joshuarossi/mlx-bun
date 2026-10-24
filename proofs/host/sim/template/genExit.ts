// Write Case.lean of the EOS exit case split at the epilogue spread (`Host.Ts.Sim.ExitCase` from
// the template start `Base.s0`, nothing appended to `emitted`).
// usage: bun proofs/host/sim/template/genExit.ts <case-dir> <Name> <cE> [--addr <addr.json>]
//   <cE>: the cell of the driver's `emitted` binding.
// Reads <Name>'s split (`tpl_case_split`): T1, the spread's boundary ia, its new array aN, the
// steps to halt and the steps to the state before the spread's (boundary ia - 1), from
// $HOST_STREAM_DIR (default <proofs>/.host-stream)/Host.Load.Run.Tpl.<Name>/split.txt.
// --addr <addr.json>: the driver's template constants (`Host.Ts.Sim.Addr`, as for `genFinal.ts`); the
// case is then a `Host.Ts.Sim.ExitCaseA` at its instance (`<Name>.exitCaseA`).
// --meta <seg.json>: the split from the case's seg.json (`tpl_case_split`): one spread bridge gives the Case.lean
// above; N > 1 bridges of any kind (`bridgeFacts.ts`: the prompt's spread, B-len, …) give the facts of each bridge
// k (the state before it accepted by segment k - 1's acceptance and not halted, its kind's facts, the state
// after it accepted by `<Name>.okB<k>`) and of the halt, for the bridge chain over `gen.ts --meta`'s segments.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { type Meta, isStepped, kindFacts } from "./bridgeFacts.ts";

type Addr = { module: string; name: string; fwd: number; emit: number; cE: number; tok: number; nxt: number };
const argv = process.argv.slice(2);
const mi = argv.indexOf("--meta");
let meta: Meta | undefined;
if (mi >= 0) {
  if (!argv[mi + 1]) throw new Error("--meta needs a seg.json path");
  meta = JSON.parse(readFileSync(argv[mi + 1], "utf8")) as Meta;
  argv.splice(mi, 2);
}
const ai = argv.indexOf("--addr");
let addr: Addr | undefined;
if (ai >= 0) {
  if (!argv[ai + 1]) throw new Error("--addr needs an addr.json path");
  addr = JSON.parse(readFileSync(argv[ai + 1], "utf8")) as Addr;
  argv.splice(ai, 2);
}
const [dir, name, cE] = argv;
if (!dir || !name || !cE) throw new Error("usage: genExit.ts <case-dir> <Name> <cE> [--addr <addr.json>] [--meta <seg.json>]");
if (addr && String(addr.cE) !== cE) throw new Error(`--addr: cE ${addr.cE} ≠ ${cE}`);
const FWD = addr?.fwd ?? 2673447, EMIT = addr?.emit ?? 12502;
if (meta && meta.bridges.length > 1) {
  const bs = meta.bridges;
  const okOf = (k: number) => (k === 0 ? "ok" : `${name}.okB${k}`);
  const F = `${name}.s${meta.T1}`;
  const facts = bs.map((b, j) => {
    const k = j + 1, P = `${name}.s${b.ia - 1}`, A = `${name}.s${b.ia}`, B = `${name}.s${b.ia + 1}`;
    return `/-! Bridge ${k} (${b.kind}): \`${P}\` → \`${A}\` (\`${name}.stepA${k}\`) → \`${B}\` (\`${name}.${isStepped(b) ? "stepB" : "patchB"}${k}\`). -/

kernel_rfl ${name}.okP${k} : ${okOf(j)} ${P} ${name}.S${b.ia - 1} = true
kernel_rfl ${name}.haltP${k} : isHalt ${P}.ctl = false
${kindFacts(name, { ...b, arr: b.arr ?? FWD }, k)}kernel_rfl ${name}.okB0_${k} : ${okOf(k)} ${B} ${name}.S${b.ia + 1} = true
`;
  });
  const out = `import host.sim.template.${dir}.Run
import host.sim.template.base.Facts
import host.sim.LoopExit
${bs.some(b => b.kind !== "spread" && b.kind !== "stage") ? "import host.sim.template.Bridges\n" : ""}${addr ? `import ${addr.module}
import host.sim.DecodeAddrHalt
` : ""}set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case \`${name}\` from the template start \`Base.s0\` split at ${bs.length} bridge points (\`seg.json\`): the
segments \`${name}.runSeg<k>\` (\`Run.lean\`), checked with \`ok\` and \`${name}.okB<k>\`, joined by the bridges'
transitions; the facts of each bridge and of the halt \`${F}\`, for the bridge chain. The halt's \`emitted\` array
is the template's: the EOS token is not yielded. -/

kernel_rfl ${name}.S0_tab : ${name}.S0.tab = Base.S0.tab
kernel_rfl ${name}.start : ${name}.s0 = Base.s0
kernel_rfl ${name}.okA0 : ok ${name}.s0 ${name}.S0 = true

${facts.join("\n")}
/-- The halt's value. -/
noncomputable def ${name}.vF : Val := match ${F}.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl ${name}.haltF : ${F}.ctl = .halt (.normal ${name}.vF)
kernel_rfl ${name}.emit_get : ${F}.heap.get ${EMIT} = some (.obj (objOf ${F} ${EMIT}))
kernel_rfl ${name}.emit_kind : (objOf ${F} ${EMIT}).kind = .array (arrOf Base.s0 ${EMIT} ++ [])
kernel_rfl ${name}.cell : ${F}.cell? ${cE} = some (some (.obj ${EMIT}))

end Host.Load.Run.Tpl
`;
  writeFileSync(join(import.meta.dir, dir, "Case.lean"), out);
  console.log(`${name}: Case.lean (T1 ${meta.T1}, ${bs.length} bridges at ${bs.map(b => `${b.ia} (${b.kind})`).join(", ")}, cE ${cE})`);
  process.exit(0);
}
const b1 = meta?.bridges[0];
if (meta && (!b1 || b1.kind !== "spread")) throw new Error("--meta: one spread bridge, or more than one bridge");
const streams = process.env.HOST_STREAM_DIR ?? join(import.meta.dir, "..", "..", "..", ".host-stream");
const splitFile = join(streams, `Host.Load.Run.Tpl.${name}`, "split.txt");
const [t1, ia, aN, steps, nA] = b1 && meta ? [meta.T1, b1.ia, b1.aN, meta.steps, b1.nA]
  : readFileSync(splitFile, "utf8").trim().split(" ").map(Number) as [number, number, number, number, number];
const nB = steps - nA - 2;
const P = `${name}.s${ia - 1}`, A = `${name}.s${ia}`, B = `${name}.s${ia + 1}`, F = `${name}.s${t1}`;
const out = `import host.sim.template.${dir}.Run
import host.sim.template.base.Facts
import host.sim.LoopExit
${addr ? `import ${addr.module}
import host.sim.DecodeAddrHalt
` : ""}set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case \`${name}\` as a checked exit case (${addr ? `\`Host.Ts.Sim.ExitCaseA\` at \`${addr.name}\`` : "\`Host.Ts.Sim.ExitCase\`"}) from the template start
\`Base.s0\`: segment A (\`${name}.runA\`, ${nA} steps checked with \`ok\`) to \`${P}\`, the step to the
epilogue spread \`${A}\` (\`${name}.stepA\`; \`ok\` rejects the spread's state), its step
(\`${name}.stepB\`), and segment B (\`${name}.runB\`, ${nB} steps checked with \`${name}.okB\`, which
frames the spread's new array ${aN}) to the halt \`${F}\`. The halt's \`emitted\` array is the
template's: the EOS token is not yielded. -/

kernel_rfl ${name}.S0_tab : ${name}.S0.tab = Base.S0.tab
kernel_rfl ${name}.start : ${name}.s0 = Base.s0
kernel_rfl ${name}.okA0 : ok ${name}.s0 ${name}.S0 = true
kernel_rfl ${name}.okP : ok ${P} ${name}.S${ia - 1} = true
kernel_rfl ${name}.haltP : isHalt ${P}.ctl = false
kernel_rfl ${name}.ctlA : ${A}.ctl = .ret (.obj ${FWD})

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
kernel_rfl ${name}.emit_get : ${F}.heap.get ${EMIT} = some (.obj (objOf ${F} ${EMIT}))
kernel_rfl ${name}.emit_kind : (objOf ${F} ${EMIT}).kind = .array (arrOf Base.s0 ${EMIT} ++ [])
kernel_rfl ${name}.cell : ${F}.cell? ${cE} = some (some (.obj ${EMIT}))

theorem ${name}.aN_ne : ${aN} ≠ ${FWD} ∧ ${aN} ≠ ${EMIT} := by decide

${addr ? `noncomputable def ${name}.exitCaseA : ExitCaseA ${addr.name} ok ${name}.okB Base.s0 Base.s0 Base.S0.tab ${aN} [] where` : `noncomputable def ${name}.exitCase : ExitCase ok ${name}.okB Base.s0 Base.s0 Base.S0.tab ${cE} ${aN} [] where`}
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
