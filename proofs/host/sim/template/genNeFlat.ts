// Write the checked modules of a flat Neural Engine forward body (`tpl_chain` with no stage cuts, the bridge literal).
// usage: bun genNeFlat.ts <dir under template/> <Name> [--group <chunks per K module>] [--ok <module> <term>] [--only-chunks a-b]
//   [--source <state> <server> <module> <the prefix's canonical row variable>]
// The acceptance is parameterized (`<term> bytes rows`); states never hold the `Boot.replay` thunk, so every check is a
// plain kernel evaluation of literal states (no `boot_rfl`).
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { syncRowMetadata } from "./syncRowMeta";
import { kindFacts } from "./bridgeFacts.ts";

const argv = process.argv.slice(2);
const take = (f: string, k = 1) => {
  const i = argv.indexOf(f);
  if (i < 0) return undefined;
  const v = argv.slice(i + 1, i + 1 + k);
  argv.splice(i, k + 1);
  return v;
};
const group = Number(take("--group")?.[0] ?? 4);
const okArg = take("--ok", 2) ?? ["host.sim.compose.a4b.VWFramesDefs", "Host.Ts.Sim.Compose.VWFrames.bodyOk"];
const only = take("--only-chunks")?.[0]?.split("-").map(Number);
// the chain's source state and server (its prefix's end, `bridge_literal` of it): the start seam
const src = take("--source", 4);
// the value bound of the size bridges' numeric premise
const sizeVb = take("--size-vb")?.[0] ?? "(Host.Ts.Sim.Full.rowVB 2048)";
// the class table rows whose oracle check the body's oracle passes once, at L and n (`bodyGoodAll`)
const rows = take("--rows")?.[0]?.split(",");
const [dir, name] = argv;
if (!dir || !name) throw Error("usage: genNeFlat.ts dir Name [--group n] [--ok module term] [--only-chunks a-b]");
const streams = process.env.HOST_STREAM_DIR ?? join(import.meta.dir, "../../../.host-stream");
const pre = `Host.Load.Run.Tpl.${name}`;
syncRowMetadata(streams, pre);
const seg = JSON.parse(readFileSync(join(streams, pre, "seg.json"), "utf8"));
const T1 = Number(seg.T1), bridges: any[] = seg.bridges ?? [];
const root = join(import.meta.dir, dir), mod = (f: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${f}`;
const per = 32;
const H = (i: number) => mod(`H${Math.floor(i / per)}`);
const head = (imports: string[], open = "Host.Ts Host.Ts.Sim") => [...new Set(imports)].map(i => `import ${i}\n`).join("") +
  `set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen ${open}\n\n`;
const put = (file: string, text: string) => writeFileSync(join(root, file + ".lean"), text + "\nend Host.Load.Run.Tpl\n");
const s = (i: number) => `${name}.s${i}`, S = (i: number) => `${name}.S${i}`;
const fuel = (k: number) => `((nth? ${name}.ks ${k}).getD 0)`;

put("Rebind", `import ${mod("States")}\nimport host.sim.template.StreamRows\nimport host.sim.template.StreamTokens\n` +
  `set_option Elab.async false\nnamespace Host.Load.Run.Tpl\n` +
  `tpl_stream_keep_lookahead ${name} through ${T1}\ntpl_stream_bind_rows ${name} through ${T1}\n`);
for (let j = 0; j <= Math.floor(T1 / per); j++) {
  const lines = [head([j === 0 ? mod("Rebind") : mod(`H${j - 1}`)], "Host.Ts")];
  for (let i = j * per; i < Math.min((j + 1) * per, T1 + 1); i++) lines.push(`host_stream_state ${name} ${i}\n`);
  put(`H${j}`, lines.join(""));
}
put("TypedOk", head([okArg[0]!], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Template") +
  `noncomputable def ${name}.bodyOkB (bytes : List Byte) (rows : Nat) : St Host.Load.Layers.full.S → SSrv → Bool :=\n  ${okArg[1]} bytes rows\n`);

if (src) {
  const [srcS, srcSrv, srcMod, rowVar] = src as [string, string, string, string];
  put("S0State", head([mod("H0"), srcMod, "host.sim.full.DropTokens"]) +
    `kernel_rfl ${name}.s0_noFfi : ${s(0)}.setFfi ${srcS}.ffi = ${srcS}\n`);
  put("S0Table", head([mod("H0"), srcMod]) +
    `kernel_rfl ${name}.s0_tab : ${S(0)}.tab = ${srcSrv}.tab.map (·.subst (fun v => if v = ${rowVar} then .var 10 else .var v))\n`);
  put("S0Tokens", head([H(T1), "host.sim.full.Raise"]) +
    `kernel_rfl ${name}.tokens0 : (Full.mlxOf ${s(0)}.ffi).tokens = [.ref 1, .ref 2]\n` +
    `kernel_rfl ${name}.tokensEnd : (Full.mlxOf ${s(T1)}.ffi).tokens = [.ref 1, .ref 2]\n`);
  put("S0Eq", head([mod("S0State"), mod("S0Table"), "host.sim.full.StateFields", "host.sim.template.a4pre_setup_native32.Origin"], "Host.Ts Host.Ts.Sim Host.Load") +
    `state_fields ${name}.newFields from ${s(0)}\nstate_fields ${name}.oldFields from ${srcS}\n` +
    `kernel_rfl ${name}.new_bridge : ${name}.newFields.bridge = PRENative32.s0.ffi.1.1.bridge\n` +
    `kernel_rfl ${name}.old_bridge : ${name}.oldFields.bridge = Boot.replay Host.Load.Run.Prompt.P.oblog2818\n` +
    `kernel_rfl ${name}.s0_load : ${name}.newFields.load =\n  { ${name}.oldFields.load with mlx := { ${name}.oldFields.load.mlx with tokens := [.ref 1, .ref 2] } }\n` +
    `kernel_rfl ${name}.s0_live : ${name}.newFields.live = ${name}.oldFields.live\n` +
    `kernel_rfl ${name}.s0_krec : ${name}.newFields.krec = ${name}.oldFields.krec\n` +
    `theorem ${name}.s0_tok : ${s(0)} = ${srcS}.setFfi (Full.fullSetTokens ${srcS}.ffi [.ref 1, .ref 2]) :=\n` +
    `  Full.start_of_fields ${name}.newFields.ffi_eq ${name}.oldFields.ffi_eq ${name}.s0_noFfi ${name}.s0_load\n` +
    `    (${name}.new_bridge.trans (PRENative32.bridge_exact.symm.trans ${name}.old_bridge.symm))\n` +
    `    ${name}.s0_live ${name}.s0_krec\n`);
}

// a chunk entered or left by a size bridge is the bridge's facts, not glue
const bridgeChunks = new Set<number>();
for (const b of bridges) { bridgeChunks.add(b.ia - 1); bridgeChunks.add(b.ia); }
const glue = Array.from({ length: T1 }, (_, i) => i).filter(i => !bridgeChunks.has(i));
const stretches: number[][] = [];
for (const k of glue) {
  const last = stretches[stretches.length - 1];
  if (last && last[last.length - 1] === k - 1 && last.length < group) last.push(k);
  else stretches.push([k]);
}
const emitted: string[] = [];
for (const [j, ks] of stretches.entries()) {
  if (only && (ks[0]! < only[0]! || ks[ks.length - 1]! > only[1]!)) continue;
  const lines = ks.map(k => `kernel_rfl ${name}.bodyK${k} :\n` +
    `  (fun (bytes : List Byte) (rows : Nat) => runOk ${name}.F (${name}.bodyOkB bytes rows) ${fuel(k)} ${s(k)} ${S(k)}) =\n` +
    `    fun _ _ => some (${s(k + 1)}, ${S(k + 1)})\n`);
  put(`K${j}`, head([H(ks[ks.length - 1]! + 1), mod("TypedOk"), "host.sim.Chunk"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Template") + lines.join(""));
  emitted.push(`K${j}`);
}
// The composition's facts per stretch (`bodyRunSeg<j>` between the size bridges; bridge n, 1-based: `bodyStepA<n>` into its state,
// `bodyPatchB<n>` its block, `sizeA<n>` … `sizePreA<n>`), the acceptance at the stretches' ends (`bodyOkAt<i>`) and the oracle once.
if (!only) {
  const kMod = new Map<number, string>();
  stretches.forEach((ks, j) => ks.forEach(k => kMod.set(k, mod(`K${j}`))));
  const ranges: { a: number; b: number }[] = [];
  let a0 = 0;
  for (const b of bridges) { ranges.push({ a: a0, b: Number(b.ia) - 1 }); a0 = Number(b.ia) + 1; }
  ranges.push({ a: a0, b: T1 });
  const O = "Host.Ts Host.Ts.Sim Host.Ts.Sim.Template";
  for (const [j, r] of ranges.entries()) {
    const applied = (k: number) => `(congrFun (congrFun ${name}.bodyK${k} bytes) rows)`;
    let proof = r.a < r.b ? applied(r.a) : "rfl", sum = r.a < r.b ? fuel(r.a) : "0";
    for (let k = r.a + 1; k < r.b; k++) {
      proof = `runOk_trans ${name}.F (${name}.bodyOkB bytes rows) ${sum} ${fuel(k)} ${s(r.a)} ${s(k)} ${s(k + 1)} ${S(r.a)} ${S(k)} ${S(k + 1)} (${proof}) ${applied(k)}`;
      sum = `(${sum} + ${fuel(k)})`;
    }
    put(`Seg${j}`, head(["host.sim.Chunk", H(r.b), mod("TypedOk"), ...Array.from({ length: r.b - r.a }, (_, i) => kMod.get(r.a + i)!)], O) +
      `theorem ${name}.bodyRunSeg${j} (bytes : List Byte) (rows : Nat) :\n    runOk ${name}.F (${name}.bodyOkB bytes rows) ${sum} ${s(r.a)} ${S(r.a)} = some (${s(r.b)}, ${S(r.b)}) :=\n  ${proof}\n`);
  }
  writeFileSync(join(root, "Run.lean"), ranges.map((_, j) => `import ${mod(`Seg${j}`)}\n`).join(""));
  const ends = [...new Set(ranges.flatMap(r => [r.a, r.b]))].sort((x, y) => x - y), width = 32;
  const endMods: string[] = [];
  for (let g = 0; g * width < ends.length; g++) {
    const xs = ends.slice(g * width, (g + 1) * width);
    put(`Ends${g}`, head([H(xs[xs.length - 1]!), mod("TypedOk")], O) + xs.map(i =>
      `kernel_rfl ${name}.bodyOkAt${i} :\n  (fun (bytes : List Byte) (rows : Nat) => ${name}.bodyOkB bytes rows ${s(i)} ${S(i)}) = fun _ _ => true\n`).join(""));
    endMods.push(mod(`Ends${g}`));
  }
  if (rows) put("Good", head([mod("H0"), "host.sim.lin.Table"], "Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls") +
    `def ${name}.bodyM : List (Nat × Q) := [(9, Q.L), (10, Q.n)]\n` +
    `kernel_rfl ${name}.bodyGoodAll : ([${rows.join(", ")}].all fun r => goodLin r.ps (varsOf r.V ${name}.bodyM) ${name}.OR) = true\n`);
  const per8 = 8, bridgeMods: string[] = [];
  for (let g = 0; g * per8 < bridges.length; g++) {
    const xs = bridges.slice(g * per8, (g + 1) * per8), base = g * per8, last = Number(xs[xs.length - 1].ia) + 1;
    put(`Steps${g}`, head([H(last), "host.sim.template.Bridges", "host.sim.compose.Glue", "host.sim.full.Rel"], O) + xs.map((b, i) => {
      const n = base + i + 1, ia = Number(b.ia);
      return `kernel_rfl ${name}.bodyStepA${n} : interpS (step ${name}.F ${s(ia - 1)}).run ${S(ia - 1)} = some (${s(ia)}, ${S(ia)})\n` +
        `kernel_rfl ${name}.bodyPatchB${n} : interpS (Host.Ts.Sim.Disp.sizeS ${name}.F ${s(ia)}).run ${S(ia)} = some (${s(ia + 1)}, ${S(ia + 1)})\n` +
        `kernel_rfl ${name}.bodyTop${n} : Host.Ts.Sim.Compose.noRetBlock ${s(ia)} = true\n` +
        `kernel_rfl ${name}.bodyLive${n} : isHalt ${s(ia - 1)}.ctl = false\n` +
        `kernel_rfl ${name}.bodyBridge${n} : Host.Ts.Sim.Full.bridgeOf ${s(ia + 1)}.ffi = Host.Ts.Sim.Full.bridgeOf ${s(ia)}.ffi\n`;
    }).join(""));
    put(`Bridge${g}`, head([H(last), "host.sim.template.Bridges", "host.sim.LoopFinal", "host.sim.full.SizeSim", okArg[0]!], O) +
      xs.map((b, i) => kindFacts(name, b, base + i + 1, seg.frames, sizeVb)).join(""));
    bridgeMods.push(mod(`Steps${g}`), mod(`Bridge${g}`));
  }
  writeFileSync(join(root, "Facts.lean"), [...endMods, ...bridgeMods].map(m => `import ${m}\n`).join(""));
}
console.log(`${dir}: T1 ${T1}, ${seg.steps} steps, ${bridges.length} bridges, ${glue.length} glue chunks in ${stretches.length} K modules; emitted ${emitted.length}`);
