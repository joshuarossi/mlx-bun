// Write the restart modules (Restart, Heap, Shift, NShift, Facts, Case) of a loop case from the ORDINARY ones.
// usage: bun proofs/host/sim/template/genRestart.ts <case-dir> <Name> <T1> <dJ> <dH> <dN> <grow> [--out <dir>]
//        bun proofs/host/sim/template/genRestart.ts <case-dir> <Name> --meta <seg.json> [--out <dir>]
//        … --world full --base <T> --tdir <template-dir> [--template]
//   --world full: the case and its template `T` (default Base, modules host.sim.template.<template-dir>) are full-world
//   streams (`tpl_template`/`tpl_case … (world := full)`) of the decode loop at `addr0`: Restart (`tpl_restart … (world :=
//   full)`), Heap, Shift (`ShiftJS Layers.full`), NShift (the load world's shift on `toLoad`, by `nshift_of` over its
//   checks), FullShift (`<Name>.fullShift : Full.FullShift loadP0 n σ T.s0.ffi <Name>.s<T1>.ffi`: the bridge kept,
//   `LiveShift`/`KernShift` by `FullShiftGen`), Facts, Case (`<Name>.loopRun NB : LoopRunW (Full.fullWorld NB) addr0 okFull0
//   loadP0 T.s0 T.S0.tab loopFix`); with --template also the template's Keys, Closed, Fresh, Facts and Start
//   (`T.start : Full.fullStart loadP0 79 T.s0`, `T.loopStart NB : LoopStartW …`) in <template-dir>, the numbers from
//   <template-dir>'s template.json `start` if given (--tmeta), else Base's (a lift of `Base.s0`).
//   e.g. growth GROWTH 153 151053 3738 2445 true
//   T1: the last boundary; dJ/dH/dN: heap, native handle and node counter deltas; grow: capacity growth.
//   --meta: read them from the case's seg.json v2 (`tpl_case`: "T1", "counters" {dJ, dH, dN}, "grow").
//   --out <dir>: write to <dir> (absolute) instead of the case directory.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import type { Meta } from "./bridgeFacts.ts";

const argv = process.argv.slice(2);
const take = (flag: string): string | undefined => {
  const i = argv.indexOf(flag);
  if (i < 0) return undefined;
  const v = argv[i + 1];
  if (!v) throw new Error(`${flag} needs a value`);
  argv.splice(i, 2);
  return v;
};
const metaPath = take("--meta");
const out = take("--out");
const world = take("--world") ?? "lf";
const base = take("--base") ?? "Base";
const tdir = take("--tdir") ?? "base";
const tmetaPath = take("--tmeta");
const tmplI = argv.indexOf("--template");
const withTemplate = tmplI >= 0;
if (withTemplate) argv.splice(tmplI, 1);
let [dir, name, last, dJ, dH, dN, grow] = argv;
if (metaPath) {
  const meta = JSON.parse(readFileSync(metaPath, "utf8")) as Meta;
  if (!meta.counters || meta.grow === undefined) throw new Error("--meta: seg.json v2 (counters and grow) needed");
  if (last !== undefined) throw new Error("--meta replaces <T1> <dJ> <dH> <dN> <grow>");
  [last, dJ, dH, dN, grow] = [meta.T1, meta.counters.dJ, meta.counters.dH, meta.counters.dN, meta.grow].map(String);
}
if (!dir || !name || !last || !dJ || !dH || !dN || !grow) {
  throw new Error("usage: genRestart.ts <case-dir> <Name> (<T1> <dJ> <dH> <dN> <grow> | --meta <seg.json>) [--out <dir>]");
}
const here = import.meta.dir;
const lastH = `H${Math.floor(Number(last) / 32)}`;
if (world === "full") {
  full();
  process.exit(0);
}
for (const file of ["Restart", "Heap", "Shift", "NShift", "Facts", "Case"]) {
  const src = readFileSync(join(here, "ordinary", `${file}.lean`), "utf8");
  let text = src
    .replaceAll("ordinary.H4", `ordinary.${lastH}`)
    .replaceAll("ORDINARY 150", `${name} ${last}`)
    .replaceAll("ORDINARY", name)
    .replaceAll("ordinary", dir)
    .replaceAll("s150", `s${last}`)
    .replaceAll("S150", `S${last}`);
  if (file === "Case") text = text.replace("grow := false", `grow := ${grow}`);
  if (file === "Facts") {
    text = text
      .replace(`- Base.s0.next = 147917`, `- Base.s0.next = ${dJ}`)
      .replace(`- Base.s0.ffi.mlx.next = 3642`, `- Base.s0.ffi.mlx.next = ${dH}`)
      .replace(`- Base.s0.ffi.mlx.nnext = 2381`, `- Base.s0.ffi.mlx.nnext = ${dN}`)
      .replaceAll("loopTheta false", `loopTheta ${grow}`);
  }
  writeFileSync(join(out ?? join(here, dir), `${file}.lean`), text);
}
console.log(`${name}: Restart, Heap, Shift, NShift, Facts, Case written (T1 = ${name}.s${last})`);

// ---------- the full world ----------

/** The LF text of an ORDINARY or base module, renamed to the case, the template and the full world. */
function fullText(src: string): string {
  return src
    .replaceAll("ordinary.H4", `ordinary.${lastH}`)
    .replaceAll("ORDINARY 150", `${name} ${last}`)
    .replaceAll("ORDINARY", name)
    .replaceAll("host.sim.template.ordinary", `host.sim.template.${dir.replaceAll("/", ".")}`)
    .replaceAll("host.sim.template.base", `host.sim.template.${tdir.replaceAll("/", ".")}`)
    .replaceAll("s150", `s${last}`)
    .replaceAll("S150", `S${last}`)
    .replaceAll("Base.", `${base}.`)
    .replaceAll("from Base", `from ${base}`)
    .replaceAll(": Base,", `: ${base},`)
    .replaceAll("tpl_keys Base", `tpl_keys ${base}`)
    .replaceAll("ShiftJS Host.Load.ffi", "ShiftJS Host.Load.Layers.full")
    // the load world's native state of a full-world state
    .replace(/([A-Za-z_][\w.]*?)\.ffi\.(mlx|host)/g, "(Host.Load.Layers.toLoad $1.ffi).$2");
}

function full() {
  const outDir = out ?? join(here, dir);
  const tOut = join(here, tdir);
  const T = base, X = name, s1 = `${X}.s${last}`, S1 = `${X}.S${last}`;
  const tm = tmetaPath ? JSON.parse(readFileSync(tmetaPath, "utf8")).start : undefined;
  const tnum = { n: tm?.n ?? 112, next: tm?.next ?? 3123579, mnext: tm?.mnext ?? 29302, nnext: tm?.nnext ?? 22539 };
  const ord = (file: string) => readFileSync(join(here, "ordinary", `${file}.lean`), "utf8");
  const write = (file: string, text: string) => writeFileSync(join(outDir, `${file}.lean`), text);
  // Restart: the full world's walk
  write("Restart", fullText(ord("Restart")).replace(`tpl_restart ${X}.R : ${T}, ${X} ${last}`,
    `tpl_restart ${X}.R : ${T}, ${X} ${last} (world := full)`));
  write("Heap", fullText(ord("Heap")));
  write("Shift", fullText(ord("Shift")));
  // NShift: the checks of `nshift_of` on the load-world projections
  const x0 = `${X}.X0`, x1 = `${X}.X1`, sg = `${X}.σ`, D = `${X}.R.data`;
  const ck = (nm: string, stmt: string) => `kernel_rfl ${X}.n${nm} : ${stmt}\n`;
  const fields = ["nh0", "nh1", "nn0", "nn1", "lo", "cnt", "nband", "hbelow", "handles", "hren", "band", "nh1pos", "objs", "objok",
    "nodes", "prims", "nren", "nlow", "nord", "items", "ssT", "abs0a", "abs0b", "tok1", "pend", "errh", "files", "arch", "sizes", "wired"];
  write("NShift", [
    `import host.sim.template.${dir.replaceAll("/", ".")}.Shift\nimport host.sim.template.NShiftOf\nimport host.sim.template.FullOk\n`,
    `import host.sim.template.${tdir.replaceAll("/", ".")}.Closed\n`,
    "set_option Elab.async false\nnamespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n",
    "set_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n\n",
    `/-! The native part of the shift of case \`${X}\` in the full world: the load world's shift on the projections (\`NShift loadP0\`\n`,
    `on \`toLoad\`), from its kernel checks (\`nshift_of\`). -/\n\n`,
    `noncomputable abbrev ${x0} : NSt := (Host.Load.Layers.toLoad ${T}.s0.ffi).mlx\n`,
    `noncomputable abbrev ${x1} : NSt := (Host.Load.Layers.toLoad ${s1}.ffi).mlx\n\n`,
    ck("nh0", `${D}.nh0 = ${x0}.next`), ck("nh1", `${D}.nh1 = ${x1}.next`), ck("nn0", `${D}.nn0 = ${x0}.nnext`),
    ck("nn1", `${D}.nn1 = ${x1}.nnext`),
    ck("lo", `(Nat.blt 0 loadP0.lo && Nat.ble loadP0.lo ${x0}.next && Nat.ble loadP0.lo RData.bigHi && Nat.ble RData.bigHi loadP0.E) = true`),
    ck("cnt", `(Nat.ble ${x0}.next ${x1}.next && Nat.ble ${x0}.nnext ${x1}.nnext) = true`),
    ck("nband", `(Nat.blt 0 loadP0.NL && Nat.ble loadP0.NL loadP0.N0 && Nat.ble loadP0.N0 ${x0}.nnext) = true`),
    ck("hbelow", `${D}.checkHndBelow = true`),
    ck("handles", `(handlesOfA ${x0}).all (handleOK ${sg} loadP0.lo ${x0} ${x1}) = true`),
    ck("hren", `checkRenG ${D}.hnd ${X}.R.hinv (phB ${x0}) = true`),
    ck("band", `${D}.checkBand loadP0.lo = true`), ck("nh1pos", `Nat.blt 0 ${D}.nh1 = true`),
    ck("objs", `(PTrie.keysA ${x0}.objs).map (fun h => ${x1}.objs.get (${sg}.handle h)) =\n  (PTrie.keysA ${x0}.objs).map (fun h => (${x0}.objs.get h).map ${sg}.nobj)`),
    ck("objok", `(PTrie.keysA ${x0}.objs).all (objOK ${sg} loadP0.NL ${x0}) = true`),
    ck("nodes", `(PTrie.keysA ${x0}.nodes).all (nodeOKF ${sg} loadP0 ${x0} ${x1}) = true`),
    ck("prims", `(fullKeysF loadP0 ${x0}).map (fun i => (${x1}.nodes.get (${sg}.node i)).map Host.Mlx.Ffi.Node.prim) =\n  (fullKeysF loadP0 ${x0}).map (fun i => (${x0}.nodes.get i).map fun nd => ${sg}.prim nd.prim)`),
    ck("nren", `checkRenG ${D}.node ${X}.R.ninv (pnB ${x0}) = true`),
    ck("nlow", `(PTrie.keysA ${D}.node).all (fun j => Nat.ble loadP0.NL j && Nat.blt (${D}.nodeF j) ${x1}.nnext) = true`),
    ck("nord", `(fullAbove loadP0 ${x0}).all (fun i => Nat.ble i (${D}.nodeF i) &&\n  (PTrie.keysA ${D}.node).all fun j => !Nat.blt j i || Nat.blt (${D}.nodeF j) (${D}.nodeF i)) = true`),
    ck("items", `(PTrie.keysA ${x0}.items).all (pnB ${x0}) = true`), ck("ssT", `checkSSt ${T}.n ${x0} = true`),
    ck("abs0a", `${x0}.arrs.get 0 = none`), ck("abs0b", `${x0}.objs.get 0 = none`), ck("tok1", `${x1}.tokens = []`),
    ck("pend", `${x1}.pending = ${x0}.pending.map ${sg}.pend`), ck("errh", `${x1}.errh = ${x0}.errh.map ${sg}.arg`),
    ck("files", `${x1}.files = ${x0}.files`), ck("arch", `${x1}.arch = ${x0}.arch`),
    ck("sizes", `${x1}.deviceSizes = ${x0}.deviceSizes`), ck("wired", `${x1}.wired = ${x0}.wired`),
    ck("host", `(Host.Load.Layers.toLoad ${s1}.ffi).host = (Host.Load.Layers.toLoad ${T}.s0.ffi).host`),
    `\n/-- **The native shift of case \`${X}\`** on the load-world projections. -/\n`,
    `theorem ${X}.nshift : NShift loadP0 ${T}.S0.tab.length ${sg} (Host.Load.Layers.toLoad ${T}.s0.ffi)\n`,
    `    (Host.Load.Layers.toLoad ${s1}.ffi) := by\n`,
    `  rw [${T}.tab_len]\n`,
    `  exact nshift_of ⟨rfl, rfl, rfl, ${fields.map(f => `${X}.n${f}`).join(", ")}⟩ ${X}.nhost fun _ => rfl\n\n`,
    "end Host.Load.Run.Tpl\n"].join(""));
  // FullShift: the bridge and the observers
  write("FullShift", [
    `import host.sim.template.${dir.replaceAll("/", ".")}.NShift\nimport host.sim.template.FullShiftGen\n`,
    "set_option Elab.async false\nnamespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n",
    "set_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n\n",
    `/-! The full world's shift of case \`${X}\` (\`Full.FullShift\`): the load world's (\`${X}.nshift\`), the bridge kept, and the\n`,
    `liveness and kernel-recording layers at the shifted handles (\`LiveShift\`, \`KernShift\`, kernel checks of \`FullShiftGen\`). -/\n\n`,
    `kernel_rfl ${X}.bridge_eq : Host.Ts.Sim.Full.bridgeOf ${s1}.ffi = Host.Ts.Sim.Full.bridgeOf ${T}.s0.ffi\n`,
    `kernel_rfl ${X}.live_check : liveShiftB ${sg} (Host.Ts.Sim.Full.mlxOf ${T}.s0.ffi) (Host.Ts.Sim.Full.freedOf ${T}.s0.ffi)\n`,
    `    (Host.Ts.Sim.Full.freedOf ${s1}.ffi) = true\n`,
    `kernel_rfl ${X}.kern_check : kernShiftB ${sg} ${T}.S0.tab.length (Host.Ts.Sim.Full.mlxOf ${T}.s0.ffi)\n`,
    `    (Host.Ts.Sim.Full.krecOf ${T}.s0.ffi) (Host.Ts.Sim.Full.krecOf ${s1}.ffi) = true\n`,
    `kernel_rfl ${X}.pend_check : pendRegB ${sg} (Host.Ts.Sim.Full.mlxOf ${T}.s0.ffi) = true\n`,
    `kernel_rfl ${X}.pend_le : Nat.ble ${X}.X0.next ${X}.X1.next = true\n\n`,
    `/-- **The full world's shift of case \`${X}\`.** -/\n`,
    `theorem ${X}.fullShift : Host.Ts.Sim.Full.FullShift loadP0 ${T}.S0.tab.length ${sg} ${T}.s0.ffi ${s1}.ffi :=\n`,
    `  fullShift_of ${X}.nshift ${X}.bridge_eq ${X}.live_check ${X}.kern_check\n`,
    `    (pendReg_of rfl ${X}.nnh0 ${X}.nnh1 (Nat.le_of_ble_eq_true ${X}.pend_le) ${X}.pend_check)\n\n`,
    "end Host.Load.Run.Tpl\n"].join(""));
  // Facts: the LF facts over the projections
  let facts = fullText(ord("Facts"))
    .replace(`- ${T}.s0.next = 147917`, `- ${T}.s0.next = ${dJ}`)
    .replace(`- (Host.Load.Layers.toLoad ${T}.s0.ffi).mlx.next = 3642`, `- (Host.Load.Layers.toLoad ${T}.s0.ffi).mlx.next = ${dH}`)
    .replace(`- (Host.Load.Layers.toLoad ${T}.s0.ffi).mlx.nnext = 2381`, `- (Host.Load.Layers.toLoad ${T}.s0.ffi).mlx.nnext = ${dN}`)
    .replaceAll("loopTheta false", `loopTheta ${grow}`);
  write("Facts", facts);
  // Case: the loop case over the full world
  write("Case", [
    `import host.sim.template.${dir.replaceAll("/", ".")}.Run\nimport host.sim.template.${dir.replaceAll("/", ".")}.FullShift\n`,
    `import host.sim.template.${dir.replaceAll("/", ".")}.Facts\nimport host.sim.world.Loop\nimport host.sim.full.World\n`,
    "set_option Elab.async false\nnamespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n",
    "set_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n\n",
    `/-! Case \`${X}\` as a checked loop case of the full world (\`LoopRunW (Full.fullWorld NB)\` at \`addr0\`): the checked run\n`,
    `(\`${X}.okRun\`), the shift (\`${X}.fullShift\`) and the facts. The JavaScript shift is \`${X}.shiftJS\`. -/\n\n`,
    `kernel_rfl ${X}.ok0 : okFull0 ${T}.s0 ${X}.S0 = true\n`,
    `kernel_rfl ${X}.tlen_check : Nat.ble ${X}.S0.tab.length ${S1}.tab.length = true\n\n`,
    `noncomputable def ${X}.loopRun (NB : Nat) :\n`,
    `    LoopRunW (Host.Ts.Sim.Full.fullWorld NB) addr0 okFull0 loadP0 ${T}.s0 ${T}.S0.tab loopFix where\n`,
    `  S0 := ${X}.S0\n  n := ${X}.steps\n  s1 := ${s1}\n  S1 := ${S1}\n  σ := ${sg}\n  θ := ${X}.θ\n  grow := ${grow}\n  xs := ${X}.xs\n`,
    `  tab := ${X}.S0_tab\n  tlen := Nat.le_of_ble_eq_true ${X}.tlen_check\n  noVarTab := ${X}.noVarTab\n  noVarOr := ${X}.noVarOr\n`,
    `  nshift := ${X}.fullShift\n  num := ${X}.num79\n  hE := ${X}.hE\n  theta := ${X}.theta\n  fwd := ${X}.fwd\n  emit := ${X}.emit\n`,
    `  fix := ${X}.fix\n  ok0 := ${X}.ok0\n  run := ${X}.okRun\n  ctl := ${X}.ctl_notRet\n\n`,
    "end Host.Load.Run.Tpl\n"].join(""));
  console.log(`${X} (full): Restart, Heap, Shift, NShift, FullShift, Facts, Case written (T1 = ${X}.s${last}, template ${T})`);
  if (!withTemplate) return;
  const b = (file: string) => readFileSync(join(here, "base", `${file}.lean`), "utf8");
  const tw = (file: string, text: string) => writeFileSync(join(tOut, `${file}.lean`), text);
  tw("Keys", fullText(b("Keys")).replace("import host.sim.template.base.S", `import host.sim.template.${tdir.replaceAll("/", ".")}.S`));
  tw("Closed", fullText(b("Closed")).replace(`abbrev ${T}.n : Nat := 112`, `abbrev ${T}.n : Nat := ${tnum.n}`));
  tw("Fresh", fullText(b("Fresh")).replaceAll("29302", String(tnum.mnext)));
  tw("Facts", fullText(b("Facts"))
    .replace("= 3123579", `= ${tnum.next}`).replace("mlx.next = 29302", `mlx.next = ${tnum.mnext}`)
    .replace("mlx.nnext = 22539", `mlx.nnext = ${tnum.nnext}`));
  tw("Start", [
    `import host.sim.template.${tdir.replaceAll("/", ".")}.Fresh\nimport host.sim.template.${tdir.replaceAll("/", ".")}.Facts\n`,
    "import host.sim.world.Loop\nimport host.sim.full.World\n",
    "set_option Elab.async false\nnamespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n",
    "set_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n\n",
    `/-! The full-world template \`${T}\`'s start facts (\`Full.fullStart\`, \`LoopStartW\` at \`addr0\`). -/\n\n`,
    `theorem ${T}.start : Host.Ts.Sim.Full.fullStart loadP0 79 ${T}.s0 :=\n`,
    `  ⟨${T}.tokens_val, ${T}.nativeFresh, ${T}.noBigFresh${"⟩"}\n\n`,
    `kernel_rfl ${T}.htok_check : Nat.blt 79 ${T}.S0.tab.length = true\n`,
    `theorem ${T}.loopStart (NB : Nat) : LoopStartW (Host.Ts.Sim.Full.fullWorld NB) addr0 loadP0 ${T}.s0 ${T}.S0.tab where\n`,
    `  htok := Nat.blt_eq.mp ${T}.htok_check\n  start := ${T}.start\n`,
    `  lo := by show 25000 ≤ (Host.Load.Layers.toLoad ${T}.s0.ffi).mlx.next; rw [${T}.mnext_val]; decide\n`,
    `  hi := by show (131072 : Nat) ≤ 2 ^ 56; decide\n\n`,
    "end Host.Load.Run.Tpl\n"].join(""));
  console.log(`${T} (full): Keys, Closed, Fresh, Facts, Start written in ${tdir}`);
}
