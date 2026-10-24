// Write Case.lean of a final case split at the epilogue spread (`Host.Ts.Sim.FinalCase`).
// usage: bun proofs/host/sim/template/genFinal.ts <case-dir> <Name> <cE> [eos] [--meta <seg.json>] [--addr <addr.json>]
//   <cE>: the cell of the driver's `emitted` binding.
//   eos: an EOS final case (the look-ahead token is EOS): a `Host.Ts.Sim.ExitCase` from the same
//   start whose halt appends only the cut's token (`[.num (.ref 79)]`) to `emitted`.
// Reads <Name>'s split (`tpl_case_split`): T1, the spread's boundary ia, its new array aN, the
// steps to halt and the steps to the state before the spread's (boundary ia - 1), from
// $HOST_STREAM_DIR (default <proofs>/.host-stream)/Host.Load.Run.Tpl.<Name>/split.txt.
// --meta <seg.json>: read the split from the case's seg.json instead (`tpl_case_split`, any number of
// bridges). One spread bridge gives the Case.lean above (the spread's array from the JSON); N > 1
// bridges give the facts of each bridge k (the state before it accepted by segment k - 1's acceptance
// and not halted; for a spread, the returned framed array, the spread frame, room, the array
// prototype and the new array's address; the state after it accepted by `<Name>.okB<k>`) and of the
// halt, for the bridge chain over `gen.ts --meta`'s `runSeg<k>`, `stepA<k>`, `stepB<k>`.
// --addr <addr.json>: the driver's template constants (`Host.Ts.Sim.Addr`): {"module", "name", "fwd",
// "emit", "cE", "tok", "nxt"} (the Lean module and name of its instance; the forwarded and emitted
// arrays, the emitted cell, the token reference, the look-ahead variable). The facts use them, and
// the case is a `Host.Ts.Sim.ExitCaseA` at the instance (`<Name>.exitCaseA`). Without it the
// constants are today's (`addr0`) and the case a `FinalCase`/`ExitCase`.
// seg.json v2 bridge kinds (`bridgeFacts.ts`): each bridge k's facts are its kind's (`kindFacts`): a spread's
// frame and room (the epilogue's `forwarded` and the prompt's `[...promptTokens, …]` alike: `arr` names the
// array), B-len's member frame and framed array (`promptTokens.length`), and the other kinds'.
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
const [dir, name, cE, mode] = argv;
if (!dir || !name || !cE || (mode !== undefined && mode !== "eos")) {
  throw new Error("usage: genFinal.ts <case-dir> <Name> <cE> [eos] [--meta <seg.json>] [--addr <addr.json>]");
}
const eos = mode === "eos";
if (addr && String(addr.cE) !== cE) throw new Error(`--addr: cE ${addr.cE} ≠ ${cE}`);
const FWD = addr?.fwd ?? 2673447, EMIT = addr?.emit ?? 12502, TOK = addr?.tok ?? 79, NXT = addr?.nxt ?? 17;
const appended = eos ? `[.num (.ref ${TOK})]` : `[.num (.ref ${TOK}), .num (.ref Base.S0.tab.length)]`;
const imports = `import host.sim.template.${dir}.Run
${eos ? "" : `import host.sim.template.${dir}.Base
`}import host.sim.template.base.Facts
import host.sim.${eos ? "LoopExit" : "LoopFinal"}
${addr ? `import ${addr.module}
import host.sim.DecodeAddrHalt
` : ""}`;
const header = `${imports}set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
`;
const haltFacts = (F: string) => `/-- The halt's value. -/
noncomputable def ${name}.vF : Val := match ${F}.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl ${name}.haltF : ${F}.ctl = .halt (.normal ${name}.vF)
kernel_rfl ${name}.emit_get : ${F}.heap.get ${EMIT} = some (.obj (objOf ${F} ${EMIT}))
kernel_rfl ${name}.emit_kind :
  (objOf ${F} ${EMIT}).kind = .array (arrOf Base.s0 ${EMIT} ++ ${appended})
kernel_rfl ${name}.cell : ${F}.cell? ${cE} = some (some (.obj ${EMIT}))
`;
if (meta && meta.bridges.length > 1) {
  const bs = meta.bridges;
  const okOf = (k: number) => (k === 0 ? "ok" : `${name}.okB${k}`);
  const F = `${name}.s${meta.T1}`;
  const facts = bs.map((b, j) => {
    const k = j + 1, P = `${name}.s${b.ia - 1}`, A = `${name}.s${b.ia}`, B = `${name}.s${b.ia + 1}`;
    const spread = kindFacts(name, { ...b, arr: b.arr ?? FWD }, k);
    return `/-! Bridge ${k} (${b.kind}): \`${P}\` → \`${A}\` (\`${name}.stepA${k}\`) → \`${B}\` (\`${name}.${isStepped(b) ? "stepB" : "patchB"}${k}\`). -/

kernel_rfl ${name}.okP${k} : ${okOf(j)} ${P} ${name}.S${b.ia - 1} = true
kernel_rfl ${name}.haltP${k} : isHalt ${P}.ctl = false
${spread}kernel_rfl ${name}.okB0_${k} : ${okOf(k)} ${B} ${name}.S${b.ia + 1} = true
`;
  });
  const out = `${header}
/-! Case \`${name}\` split at ${bs.length} bridge points (\`seg.json\`): the segments \`${name}.runSeg<k>\`
(\`Run.lean\`), checked with \`ok\` and \`${name}.okB<k>\`, joined by the bridges' steps; the facts of each
bridge and of the halt \`${F}\`, for the bridge chain.${eos ? " The halt's \`emitted\` array appends\nthe cut's token only: the look-ahead token is EOS." : ""} -/

${eos ? `kernel_rfl ${name}.S0_tab : ${name}.S0.tab = Base.S0.tab ++ [.var ${NXT}]
` : ""}kernel_rfl ${name}.start : ${name}.s0 = finalStart Base.s0 Base.S0.tab.length
kernel_rfl ${name}.okA0 : ok ${name}.s0 ${name}.S0 = true

${facts.join("\n")}
${haltFacts(F)}
end Host.Load.Run.Tpl
`;
  writeFileSync(join(import.meta.dir, dir, "Case.lean"), out);
  console.log(`${name}: Case.lean (T1 ${meta.T1}, ${bs.length} bridges at ${bs.map(b => `${b.ia} (${b.kind})`).join(", ")}, cE ${cE})`);
  process.exit(0);
}
const streams = process.env.HOST_STREAM_DIR ?? join(import.meta.dir, "..", "..", "..", ".host-stream");
const splitFile = join(streams, `Host.Load.Run.Tpl.${name}`, "split.txt");
const b1 = meta?.bridges[0];
if (meta && (!b1 || b1.kind !== "spread")) throw new Error("--meta: one spread bridge, or more than one bridge");
const [t1, ia, aN, steps, nA] = b1 && meta ? [meta.T1, b1.ia, b1.aN, meta.steps, b1.nA]
  : readFileSync(splitFile, "utf8").trim().split(" ").map(Number) as [number, number, number, number, number];
const arr = b1?.arr ?? FWD;
const nB = steps - nA - 2;
const P = `${name}.s${ia - 1}`, A = `${name}.s${ia}`, B = `${name}.s${ia + 1}`, F = `${name}.s${t1}`;
const out = `${imports}set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case \`${name}\` as a checked ${addr ? `${eos ? "EOS " : ""}final case (\`Host.Ts.Sim.ExitCaseA\` at \`${addr.name}\` from the final start)` : eos ? "EOS final case (\`Host.Ts.Sim.ExitCase\` from the final start)" : "final case (\`Host.Ts.Sim.FinalCase\`)"}: segment A
(\`${name}.runA\`, ${nA} steps checked with \`ok\`) to \`${P}\`, the step to the epilogue
spread \`${A}\` (\`${name}.stepA\`; \`ok\` rejects the spread's state), its step
(\`${name}.stepB\`), and segment B (\`${name}.runB\`, ${nB} steps checked with \`${name}.okB\`, which
frames the spread's new array ${aN}) to the halt \`${F}\`.${eos ? " The halt's \`emitted\` array appends\nthe cut's token only: the look-ahead token is EOS." : ""} -/

${eos ? `kernel_rfl ${name}.S0_tab : ${name}.S0.tab = Base.S0.tab ++ [.var ${NXT}]
` : ""}kernel_rfl ${name}.start : ${name}.s0 = finalStart Base.s0 Base.S0.tab.length
kernel_rfl ${name}.okA0 : ok ${name}.s0 ${name}.S0 = true
kernel_rfl ${name}.okP : ok ${P} ${name}.S${ia - 1} = true
kernel_rfl ${name}.haltP : isHalt ${P}.ctl = false
kernel_rfl ${name}.ctlA : ${A}.ctl = .ret (.obj ${arr})

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
kernel_rfl ${name}.emit_kind :
  (objOf ${F} ${EMIT}).kind = .array (arrOf Base.s0 ${EMIT} ++ ${appended})
kernel_rfl ${name}.cell : ${F}.cell? ${cE} = some (some (.obj ${EMIT}))

theorem ${name}.aN_ne : ${aN} ≠ ${FWD} ∧ ${aN} ≠ ${EMIT} := by decide

${addr ? `noncomputable def ${name}.exitCaseA :
    ExitCaseA ${addr.name} ok ${name}.okB Base.s0 (finalStart Base.s0 Base.S0.tab.length) (Base.S0.tab ++ [.var ${NXT}])
      ${aN} ${appended} where` : eos ? `noncomputable def ${name}.exitCase :
    ExitCase ok ${name}.okB Base.s0 (finalStart Base.s0 Base.S0.tab.length) (Base.S0.tab ++ [.var 17]) ${cE} ${aN}
      [.num (.ref 79)] where` : `noncomputable def ${name}.finalCase : FinalCase ok ${name}.okB Base.s0 Base.S0.tab ${cE} ${aN} where`}
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
