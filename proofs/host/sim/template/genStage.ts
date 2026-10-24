// Write the modules of a stage site template cut from the route (`tpl_stage`, or a stage instance `tpl_chain` emits).
// usage: bun proofs/host/sim/template/genStage.ts <case-dir> <Name> --meta <stage.json> [--world <w>] [--out <dir>]
//   [--states <module>] [--frames] [--closed]
//   <case-dir>: the directory of the stage's modules; <Name>: its stream (e.g. FSA); --meta: the stage's stage.json
//   (T1, steps, frames, world, the footprint); --world: default the stage.json's; --states: the modules H0 imports, comma-
//   separated (default host.sim.template.<case-dir>.States; a chain's instance: the chain's States and the chain's
//   state module holding the call, whose page constants the instance's boundaries name).
// Writes H<j>.lean (`host_stream_state`, 32 boundaries each); Ok.lean (`<Name>.okL`: the world's acceptance under the
// caller's frames, `Conv.isoCtxW`: stage.json's `frames` (the caller's framed arrays the start holds) and `wide`
// (its wide frames there; --frames is the default now), at local states only, `Host.Ts.Sim.Template.okLocal`); K<j>.lean (chunks 0 … T1-2 checked with `<Name>.okL`, `sim_chunk`; chunk
// T1-1 is the return step, `<Name>.last`); Run.lean (`<Name>.run`, chunks 0 … T1-2); Tpl.lean: the facts and the stage
// template `<Name>.tpl : Host.Ts.Sim.Stage.StageTpl <Name>.F <Name>.okL` (s0 the isolated call state, s1 = s<T1-1> the
// last local state, s2 = s<T1> the return state) with `<Name>.loc` (`okL` accepts local states only); Foot.lean: the
// site template's footprint (`host.sim.conv`): `Conv.StageFoot`'s written and fresh addresses `<Name>.wr` (`<Name>.wrE`:
// the written ranges `<Name>.wrR` and the fresh range of the return state's heap) with the heap equality
// `<Name>.heapFoot : s<T1>.heap = setAll s0.heap <Name>.wrE` (`same`, as stage/CacheHolds) and `<Name>.grows`;
// `Conv.NFoot`'s written and fresh handles `<Name>.wh` and items `<Name>.wi` with the equalities `<Name>.arrsFoot`,
// `objsFoot`, `nodesFoot`, `itemsFoot` and `<Name>.counters`. With --closed also Keys.lean and Closed.lean: s0's
// closedness (`tpl_keys`, `tpl_all_blocks` of `bHobj` and of the bound, `checkRootsSupp`) as for the loop template
// (base/Closed.lean), and the native start's `checkSSt` (`<Name>.ssT`).
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { worlds } from "./bridgeFacts.ts";

type StageMeta = { instance: string; piece: string; fn: string; world: string; T1: number; steps: number;
  frames: number[]; vars: [number, string][]; tab0: number; wrR: [number, number][]; wh: number[]; wi: number[];
  wide?: [number, string][]; loadP?: number[] };
const argv = process.argv.slice(2);
const take = (flag: string): string | undefined => {
  const i = argv.indexOf(flag);
  if (i < 0) return undefined;
  const v = argv[i + 1];
  if (!v) throw new Error(`${flag} needs a value`);
  argv.splice(i, 2);
  return v;
};
const flag = (f: string): boolean => {
  const i = argv.indexOf(f);
  if (i >= 0) argv.splice(i, 1);
  return i >= 0;
};
const framesArg = flag("--frames"), closed = flag("--closed");
const metaPath = take("--meta"), worldArg = take("--world"), out = take("--out"), statesArg = take("--states");
const [dir, name] = argv;
if (!dir || !name || !metaPath) {
  throw new Error("usage: genStage.ts <case-dir> <Name> --meta <stage.json> [--world <w>] [--out <dir>] [--states <module>] [--frames] [--closed]");
}
const meta = JSON.parse(readFileSync(metaPath, "utf8")) as StageMeta;
const world = worlds[worldArg ?? meta.world];
if (!world) throw new Error(`unknown world ${worldArg ?? meta.world}`);
for (const f of ["T1", "steps", "tab0", "wrR", "wh", "wi"] as const) if (meta[f] === undefined) throw new Error(`stage.json lacks ${f} (rerun its tpl_stage)`);
const n = meta.T1;
if (!Number.isSafeInteger(n) || n < 2) throw new Error("a stage template needs T1 ≥ 2 (a local run and the return step)");
const root = out ?? join(import.meta.dir, dir);
mkdirSync(root, { recursive: true });
const s = (i: number) => `${name}.s${i}`, S = (i: number) => `${name}.S${i}`;
const mod = (file: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${file}`;
// the module running the command, and the modules defining the caller's page constants the stream names
const states = (statesArg ?? mod("States")).split(",");
const NL = "\n";
const header = (...imps: string[]) =>
  imps.map(i => `import ${i}${NL}`).join("") +
  `set_option Elab.async false${NL}namespace Host.Load.Run.Tpl${NL}set_option maxRecDepth 1000000${NL}set_option maxHeartbeats 0${NL}`;
const end = `end Host.Load.Run.Tpl${NL}`;
const write = (file: string, lines: string[]) => writeFileSync(join(root, file), lines.join(""));

// states
const per = 32;
const hCount = Math.floor(n / per) + 1;
for (let j = 0; j < hCount; j++) {
  const lines = [header(...(j === 0 ? states : [mod(`H${j - 1}`)]))];
  for (let i = j * per; i < Math.min((j + 1) * per, n + 1); i++) lines.push(`host_stream_state ${name} ${i}${NL}`);
  lines.push(end);
  write(`H${j}.lean`, lines);
}
// the acceptance: the framed list and the wide frames are the caller's preimages (`Conv.isoCtxW`; at the site's own
// call the caller's frames the start holds: stage.json's `frames`, `wide`)
const frames = meta.frames;
const wide = meta.wide ?? [];
const jsp = meta.loadP && world.jspP
  ? `${meta.loadP[3] === meta.loadP[4] && world.jspPD ? world.jspPD : world.jspP} ⟨${meta.loadP.join(", ")}, []⟩ [${frames.join(", ")}] [${wide.map(([a, t]) => `(${a}, ${t})`).join(", ")}]`
  : wide.length > 0 && world.jspW
  ? `${world.jspW} [${frames.join(", ")}] [${wide.map(([a, t]) => `(${a}, ${t})`).join(", ")}]`
  : `${world.jsp} [${frames.join(", ")}]`;
void framesArg;
// a band-free load parameter (a prompt-route chain's): the acceptance with the trace-back continuations (`Disp.okJSK` at
// `Full.okBackF`, A1's `host.sim.full.BackSim`)
const backP = meta.loadP && world.jspP && meta.loadP[3] === meta.loadP[4] ? `⟨${meta.loadP.join(", ")}, []⟩` : undefined;
const accept = process.env.CHAIN_ACCEPT ?? (meta as { accept?: string }).accept ?? "auto", D0 = Number(process.env.CHAIN_D0 ?? (meta as { D0?: number }).D0 ?? 4096);
const okE = accept === "jskx" && backP ? `Disp.okJSK (${jsp.replace("Template.fullJSPPD ", "Template.fullJSPPX ")}) (Host.Ts.Sim.Full.okBackFX ${backP})`
  : accept === "jsj" && backP ? `Disp.okJSJ (${jsp}) (Host.Ts.Sim.Full.okBackF ${backP}) ${D0}`
  : (accept === "jsk" || accept === "auto") && backP ? `Disp.okJSK (${jsp}) (Host.Ts.Sim.Full.okBackF ${backP})`
  // a banded P (a decode loop's): `okJSK` without continuations (its JS-level disjunct, `Full.fullStepSimXBK`)
  : accept === "js" ? `Disp.okJS (${jsp})` : `Disp.okJSK (${jsp}) (fun _ _ => false)`;
write("Ok.lean", [`import ${world.okModule}${NL}import host.sim.template.Stage${NL}${backP ? `import host.sim.full.BackSim${NL}${accept === "jsj" ? `import host.sim.dispatch.OkJs${NL}` : ""}` : ""}`,
  `namespace Host.Load.Run.Tpl${NL}open Host.Ts Host.Ts.Sim${NL}${NL}`,
  `/-- The acceptance of stage \`${name}\` (${meta.piece}, \`${meta.fn}\`): the world's under the caller's frames (its framed${NL}`,
  `arrays and wide frames the start holds, \`Conv.isoCtxW\`), at local states only. -/${NL}`,
  `noncomputable def ${name}.okL : St ${world.S} → SSrv → Bool :=${NL}`,
  `  Host.Ts.Sim.Template.okLocal (${okE})${NL}${NL}`, end]);
// the checked run and the return step
const cPer = 4;
const cCount = Math.ceil(n / cPer);
for (let j = 0; j < cCount; j++) {
  const lastChunk = Math.min((j + 1) * cPer, n) - 1;
  const k = [header(mod(`H${Math.floor((lastChunk + 1) / per)}`), mod("Ok"), "host.sim.Chunk"), `open Host.Ts Host.Ts.Sim${NL}`];
  for (let i = j * cPer; i <= lastChunk; i++) {
    if (i < n - 1) k.push(`sim_chunk ${name} ${name}.okL ${i}${NL}`);
    else k.push(`kernel_rfl ${name}.last : interpS (step ${name}.F ${s(i)}).run ${S(i)} = some (${s(i + 1)}, ${S(i + 1)})${NL}`);
  }
  k.push(end);
  write(`K${j}.lean`, k);
}
write("Run.lean", [header(...Array.from({ length: cCount }, (_, j) => mod(`K${j}`)), "host.sim.template.ChainRange"),
  `open Host.Ts.Sim Host.Ts.Sim.Template${NL}`, `sim_chain_range ${name} ${name}.okL 0 ${n - 1} run${NL}`, end]);
// the stage template
const vars = meta.vars.map(([v, q]) => `\`${v}\` ${q}`).join(", ") || "none";
write("Tpl.lean", [header(mod("Run"), "host.sim.StageRel"), `open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template${NL}${NL}`,
  `/-! Stage \`${name}\` (${meta.piece}: \`${meta.fn}\`) as a stage template: the isolated call state \`${s(0)}\`, the checked${NL}`,
  `local run (\`${name}.run\`, ${meta.steps - 1} steps with \`${name}.okL\`) to \`${s(n - 1)}\` and the return step (\`${name}.last\`)${NL}`,
  `to \`${s(n)}\`. Its variables (the stage specs' map): ${vars}. -/${NL}${NL}`,
  `kernel_rfl ${name}.ok0 : ${name}.okL ${s(0)} ${S(0)} = true${NL}`,
  `kernel_rfl ${name}.ok1 : ${name}.okL ${s(n - 1)} ${S(n - 1)} = true${NL}`,
  `kernel_rfl ${name}.halt1 : isHalt ${s(n - 1)}.ctl = false${NL}`,
  `kernel_rfl ${name}.top_check : noBlockTop ${s(n)}.stack = true${NL}${NL}`,
  `theorem ${name}.loc : ∀ s Sv, ${name}.okL s Sv = true → Disp.localB s = true := okLocal_localB${NL}${NL}`,
  `/-- The stage template. -/${NL}noncomputable def ${name}.tpl : Host.Ts.Sim.Stage.StageTpl ${name}.F ${name}.okL where${NL}`,
  `  s0 := ${s(0)}${NL}  S0 := ${S(0)}${NL}  s1 := ${s(n - 1)}${NL}  S1 := ${S(n - 1)}${NL}  s2 := ${s(n)}${NL}  S2 := ${S(n)}${NL}`,
  `  n := ${meta.steps - 1}${NL}  ok0 := ${name}.ok0${NL}  run := ${name}.run${NL}  ok1 := ${name}.ok1${NL}  halt := ${name}.halt1${NL}`,
  `  last := ${name}.last${NL}  top := noBlockTop_sound ${name}.top_check${NL}${NL}`, end]);
// the footprint
const X0 = world.mlx(s(0)), X2 = world.mlx(s(n));
const ls = (xs: number[]) => `[${xs.join(", ")}]`;
// the footprint's facts need only the states (not the checked run: a site's conversion facts compile beside its chunks)
write("Foot.lean", [header(mod(`H${hCount - 1}`), "host.sim.stage.Mlx"), `open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template${NL}${NL}`,
  `/-! The footprint of stage \`${name}\`'s site template (\`Conv.StageFoot\`, \`Conv.NFoot\`): every entry of the return${NL}`,
  `state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/${NL}${NL}`,
  `/-- The written heap ranges below the start's counter. -/${NL}`,
  `def ${name}.wrR : List (Nat × Nat) := [${meta.wrR.map(([a, b]) => `(${a}, ${b})`).join(", ")}]${NL}`,
  `/-- The written and fresh entries of the return state. -/${NL}`,
  `noncomputable def ${name}.wrE : List (Nat × Host.Ts.HObj) :=${NL}  rangesOf ${s(n)}.heap ${name}.wrR ++ freshOf ${s(n)}.heap ${s(0)}.next ${s(n)}.next${NL}`,
  `noncomputable def ${name}.wr : List Nat := ${name}.wrE.map (·.1)${NL}${NL}`,
  `kernel_rfl ${name}.heapFoot : ${s(n)}.heap = setAll ${s(0)}.heap ${name}.wrE${NL}`,
  `kernel_rfl ${name}.grows_check : Nat.ble ${s(0)}.next ${s(n)}.next = true${NL}`,
  `theorem ${name}.grows : ${s(0)}.next ≤ ${s(n)}.next := Nat.le_of_ble_eq_true ${name}.grows_check${NL}${NL}`,
  `/-- The written and fresh handles; the written readback items of old nodes. -/${NL}`,
  `def ${name}.wh : List Nat := ${ls(meta.wh)}${NL}def ${name}.wi : List Nat := ${ls(meta.wi)}${NL}${NL}`,
  `kernel_rfl ${name}.arrsFoot : ${X2}.arrs = setAll ${X0}.arrs (${name}.wh.filterMap fun h => (${X2}.arrs.get h).map (h, ·))${NL}`,
  `kernel_rfl ${name}.objsFoot : ${X2}.objs = setAll ${X0}.objs (${name}.wh.filterMap fun h => (${X2}.objs.get h).map (h, ·))${NL}`,
  `kernel_rfl ${name}.nodesFoot : ${X2}.nodes = setAll ${X0}.nodes (freshOf ${X2}.nodes ${X0}.nnext ${X2}.nnext)${NL}`,
  `kernel_rfl ${name}.itemsFoot : ${X2}.items = setAll ${X0}.items ((${name}.wi.filterMap fun i => (${X2}.items.get i).map (i, ·)) ++${NL}`,
  `    freshOf ${X2}.items ${X0}.nnext ${X2}.nnext)${NL}`,
  `kernel_rfl ${name}.counters : (Nat.ble ${X0}.next ${X2}.next && Nat.ble ${X0}.nnext ${X2}.nnext) = true${NL}${NL}`, end]);
if (closed) {
  write("Keys.lean", [header(mod("H0"), "host.sim.template.RestartCmd"), `open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template${NL}${NL}`,
    `tpl_keys ${name}${NL}${NL}`, end]);
  write("Closed.lean", [header(mod("Keys"), "host.sim.template.Check", "host.sim.template.NShiftGen"),
    `open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template${NL}${NL}`,
    `/-! Closedness of stage \`${name}\`'s site template start \`${s(0)}\` (as base/Closed.lean): every heap entry, the${NL}`,
    `roots and the native start mention only present addresses and its ${meta.tab0} number references. -/${NL}${NL}`,
    `abbrev ${name}.n : Nat := ${meta.tab0}${NL}`,
    `kernel_rfl ${name}.tab_len : ${S(0)}.tab.length = ${name}.n${NL}`,
    `noncomputable def ${name}.suppAt (a : Nat) : Bool :=${NL}  match ${s(0)}.heap.get a with${NL}`,
    `  | some h => bHobj (presentB ${s(0)}) ${name}.n h${NL}  | none => true${NL}`,
    `noncomputable def ${name}.boundAt (a : Nat) : Bool := Nat.blt a ${s(0)}.next${NL}${NL}`,
    `tpl_all_blocks ${name}.HS from ${name} : ${name}.suppAt${NL}`,
    `kernel_rfl ${name}.suppFramed : ${name}.frames.all ${name}.suppAt = true${NL}`,
    `tpl_all_blocks ${name}.BD from ${name} : ${name}.boundAt${NL}`,
    `kernel_rfl ${name}.boundFramed : ${name}.frames.all ${name}.boundAt = true${NL}`,
    `kernel_rfl ${name}.rootsSupp_check : checkRootsSupp ${s(0)} ${name}.n = true${NL}`,
    `kernel_rfl ${name}.ssT : checkSSt ${name}.n ${X0} = true${NL}${NL}`, end]);
}
console.log(`${name}: ${hCount} state modules, ${cCount} chunk modules (chunks 0..${n - 2} with ${name}.okL, chunk ${n - 1} the return step), Ok, Run, Tpl, Foot${closed ? ", Keys, Closed" : ""}`);
