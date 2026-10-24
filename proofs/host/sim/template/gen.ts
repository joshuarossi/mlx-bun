// Write the state and chunk modules of a template case stream.
// usage: bun proofs/host/sim/template/gen.ts <case-dir> <Name> <T1> [<ok> <ok-module> [<ia> <aN>]] [--meta <seg.json>] [--addr <addr.json>]
//   <case-dir>: e.g. ordinary; <Name>: the stream (e.g. ORDINARY); <T1>: its last boundary.
// H<j>.lean loads boundaries 32j … 32j+31 (`host_stream_state`). With an acceptance function
// `<ok>` (defined in `<ok-module>`), K<j>.lean checks chunks 4j … 4j+3 as checked runs
// (`sim_chunk`, `runOk`) and Run.lean composes them (`sim_chain_run`, `<Name>.okRun`).
// A final case split at the epilogue spread (boundary <ia>, new array <aN>) gets
// OkB.lean (`<Name>.okB`, framing <aN>), chunks before <ia> - 1 checked with <ok>, chunks <ia> - 1
// and <ia> as plain steps into and out of the spread's state (`<Name>.stepA`, `<Name>.stepB`), the
// rest with `<Name>.okB`; Run.lean composes `<Name>.runA` (chunks 0 … ia-2) and `<Name>.runB`
// (ia+1 … T1-1).
// --meta: the case's seg.json (`tpl_case`, `tpl_case_split`). The acceptance functions frame its
// `frames` (instead of 2673447, 12502) and, when it lists bridges, they replace <ia> <aN>: N bridges
// give N + 1 segments; segment k ≥ 1 is checked with `<Name>.okB` (N = 1) or `<Name>.okB<k>`, framing
// the frames and the new arrays of the spread bridges before it; bridge k's two chunks are plain steps
// (`stepA`/`stepB`, or `stepA<k>`/`stepB<k>` for N > 1); Run.lean composes `runA`/`runB` (N = 1) or
// `runSeg0` … `runSeg<N>` (empty segments are skipped).
// --addr <addr.json>: the driver's template constants (`Host.Ts.Sim.Addr`, as for `genFinal.ts`); without
// `--meta` the acceptance functions frame its `fwd` and `emit` arrays.
// --world <lf|full>: the world of the stream (`tpl_* (world := full)`; default seg.json's "world", else lf): the
// acceptance functions' state type and parameters (`bridgeFacts.ts` `worlds`); with no <ok>, the world's default.
// --out <dir>: write the modules to <dir> (absolute) instead of the case directory (their names are unchanged).
// seg.json v2 bridges (`bridgeFacts.ts`): a spread's transition is the machine's step (`stepB`), a patched kind's
// (len, slice, typed, ptr, newdata) is the bridge lemma's patched template (`patchB`, kernel evaluation of
// `Host.Ts.Sim.Template.Bridge.*Patch`), a stage entry's none (a zero-step conversion: no chunk); segment k's
// acceptance frames the addresses every bridge before it frames; Bridge.lean states each bridge's facts
// (`bridgeFacts.ts` `kindFacts`) when a bridge is not a spread.
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { type Bridge, type Meta, framesAdded, kindFacts, transitionLine, worlds } from "./bridgeFacts.ts";

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
const wi = argv.indexOf("--world");
let worldArg: string | undefined;
if (wi >= 0) {
  worldArg = argv[wi + 1];
  if (!worldArg || !worlds[worldArg]) throw new Error(`--world: one of ${Object.keys(worlds).join(", ")}`);
  argv.splice(wi, 2);
}
// --okMeta: segment 0's acceptance from seg.json's frames and wide frames (`<Name>.okB0` in OkB.lean), as the
// later segments' (a route chain's: its start's frames, not the decode loop's)
const okMetaI = argv.indexOf("--okMeta");
const okMeta = okMetaI >= 0;
if (okMeta) argv.splice(okMetaI, 1);
const oi = argv.indexOf("--out");
let outArg: string | undefined;
if (oi >= 0) {
  outArg = argv[oi + 1];
  if (!outArg) throw new Error("--out needs a directory");
  argv.splice(oi, 2);
}
const world = worlds[worldArg ?? meta?.world ?? "lf"]!;
const [dir, name, last, okArg, okModuleArg, iaArg, aNArg] = argv;
// another world's checked runs default to its acceptance function
const okMod0 = okModuleArg ?? (worldArg && worldArg !== "lf" ? world.okModule : undefined);
const ok = okMeta ? `${name}.okB0` : okArg ?? (worldArg && worldArg !== "lf" ? world.ok : undefined);
const okModule = okMeta ? `host.sim.template.${dir.replaceAll("/", ".")}.OkB` : okMod0;
if (!dir || !name || !last) {
  throw new Error("usage: gen.ts <case-dir> <Name> <T1> [<ok> <ok-module> [<ia> <aN>]] [--meta <seg.json>] [--addr <addr.json>] [--world <w>] [--out <dir>]");
}
const n = Number(last);
if (!Number.isSafeInteger(n) || n < 1) throw new Error("T1 must be a positive integer");
if (meta && meta.T1 !== n) throw new Error(`--meta: T1 ${meta.T1} ≠ ${n}`);
const frames0 = meta?.frames ?? (addr ? [addr.fwd, addr.emit] : [2673447, 12502]);
const bridges: Bridge[] = meta && meta.bridges.length > 0 ? meta.bridges
  : iaArg !== undefined ? [{ kind: "spread", ia: Number(iaArg), aN: Number(aNArg), nA: 0 }] : [];
const split = bridges.length > 0;
if (split && (!ok || !okModule || (!meta && !aNArg))) {
  throw new Error("split: need <ok> <ok-module> and the bridge points (<ia> <aN>, or --meta)");
}
// the last chunk of a bridge's transition: ia, or ia + 1 for a compacted stage call (the merge, then the compaction)
const lastOf = (b: Bridge) => b.ia + (b.kind === "stage" && b.compaction ? 1 : 0);
for (const [k, b] of bridges.entries()) {
  // a chain's first call may be its start state (ia = 0, no step into it) or its first step (ia = 1): an empty segment 0
  const min = k === 0 ? (b.kind === "stage" ? 0 : 2) : lastOf(bridges[k - 1]!) + 2;
  if (!Number.isSafeInteger(b.ia) || !Number.isSafeInteger(b.aN) || b.ia < min) {
    throw new Error(`split: bridge ${k} at ${b.ia} must be an integer ≥ ${min}`);
  }
  if (!["spread", "len", "slice", "typed", "ptr", "newdata", "size", "stage"].includes(b.kind)) throw new Error(`bridge kind ${b.kind}`);
}
if (split && lastOf(bridges[bridges.length - 1]!) + 1 >= n) throw new Error("split: the last bridge needs ia + 1 < T1");
// one bridge: the names `runA`/`runB`, `stepA`/`stepB`, `okB` (a chain's calls keep the per-bridge names)
const one = bridges.length === 1 && bridges[0]!.kind !== "stage";
// the arrays framed in segment k: the frames and the addresses the bridges before it frame
const framesOf = (k: number) => [...frames0, ...bridges.slice(0, k).flatMap(framesAdded)];
const okOf = (k: number) => (k === 0 ? ok! : one ? `${name}.okB` : `${name}.okB${k}`);
// the acceptance parameters at the framed arrays `fr` (with seg.json's wide frames, if any)
const wide = meta?.wide ?? [];
const loadP = meta?.loadP;
// a band-free P: the calls also at the raise (`fullJSPPD`, A1's `Full.okCallFSD`)
const bandFree = !!loadP && loadP[3] === loadP[4];
const jspOf = (fr: number[]) => loadP && world.jspP
  ? `${bandFree && world.jspPD ? world.jspPD : world.jspP} ⟨${loadP.join(", ")}, []⟩ [${fr.join(", ")}] [${wide.map(([a, t]) => `(${a}, ${t})`).join(", ")}]`
  : wide.length > 0 && world.jspW
  ? `${world.jspW} [${fr.join(", ")}] [${wide.map(([a, t]) => `(${a}, ${t})`).join(", ")}]`
  : `${world.jsp} [${fr.join(", ")}]`;
// a band-free load parameter (a prompt-route chain's): the glue's acceptance with the trace-back continuations
// (`Disp.okJSK` at `Full.okBackF`, A1's host.sim.full.BackSim), where a compiled closure's first application returns
// from its JavaScript trace callback
const backP = loadP && world.jspP && loadP[3] === loadP[4] ? `⟨${loadP.join(", ")}, []⟩` : undefined;
// seg.json "accept": `js`, `jsk`, `jsj` (`Disp.okJSJ`, kernel-creating chains, its counter offset bound "D0"), `auto` (`jsk` at a band-free P)
const accept = process.env.CHAIN_ACCEPT ?? (meta as { accept?: string })?.accept ?? "auto", D0 = Number(process.env.CHAIN_D0 ?? (meta as { D0?: number })?.D0 ?? 4096);
const okE = (fr: number[]) => accept === "jskx" && backP ? `Disp.okJSK (${jspOf(fr).replace("Template.fullJSPPD ", "Template.fullJSPPX ")}) (Host.Ts.Sim.Full.okBackFX ${backP})`
  : accept === "jsj" && backP ? `Disp.okJSJ (${jspOf(fr)}) (Host.Ts.Sim.Full.okBackF ${backP}) ${D0}`
  : (accept === "jsk" || accept === "auto") && backP ? `Disp.okJSK (${jspOf(fr)}) (Host.Ts.Sim.Full.okBackF ${backP})`
  // a banded P (a decode loop's): `okJSK` without continuations (its JS-level disjunct, `Full.fullStepSimXBK`)
  : accept === "js" ? `Disp.okJS (${jspOf(fr)})` : `Disp.okJSK (${jspOf(fr)}) (fun _ _ => false)`;
const stepOf = (k: number, ab: "A" | "B") => (one ? `step${ab}` : `step${ab}${k + 1}`);
const root = outArg ?? join(import.meta.dir, dir);
mkdirSync(root, { recursive: true });
const mod = (file: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${file}`;
const header = (...imps: string[]) =>
  `${imps.map(i => `import ${i}\n`).join("")}set_option Elab.async false\nnamespace Host.Load.Run.Tpl\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n`;
const per = 32;
const hCount = Math.floor(n / per) + 1;
for (let j = 0; j < hCount; j++) {
  const lines = [header(j === 0 ? mod("States") : mod(`H${j - 1}`))];
  for (let i = j * per; i < Math.min((j + 1) * per, n + 1); i++) lines.push(`host_stream_state ${name} ${i}\n`);
  lines.push("end Host.Load.Run.Tpl\n");
  writeFileSync(join(root, `H${j}.lean`), lines.join(""));
}
if (split || okMeta) {
  const def0 = okMeta ? [`/-- The acceptance function of \`${name}\`'s first segment (seg.json's frames). -/\n`,
    `noncomputable def ${name}.okB0 : St ${world.S} → SSrv → Bool := ${okE(framesOf(0))}\n\n`] : [];
  const defs = bridges.map((b, k) => one
    ? [`/-- The acceptance function of \`${name}\` after the epilogue spread: \`ok\` with the spread's\n`,
      `new array \`${b.aN}\` (\`${name}.aN\`) framed as well. -/\n`,
      `noncomputable def ${okOf(1)} : St ${world.S} → SSrv → Bool := ${okE(framesOf(1))}\n\n`]
    : [`/-- The acceptance function of \`${name}\` after bridge ${k + 1} (${b.kind} at boundary ${b.ia}). -/\n`,
      `noncomputable def ${okOf(k + 1)} : St ${world.S} → SSrv → Bool := ${okE(framesOf(k + 1))}\n\n`]);
  writeFileSync(join(root, "OkB.lean"), [
    `import ${okMod0}\n`, backP ? `import host.sim.full.BackSim\n${accept === "jsj" ? "import host.sim.dispatch.OkJs\n" : ""}` : "", "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim\n\n", ...def0, ...defs.flat(),
    "end Host.Load.Run.Tpl\n"].join(""));
}
// chunk i's role: a bridge's step into (i = ia - 1) or out of (i = ia) its state, or segment k's chunk
const role = (i: number): { step: "A" | "B"; k: number } | { seg: number } => {
  for (const [k, b] of bridges.entries()) {
    if (i === b.ia - 1) return { step: "A", k };
    if (i >= b.ia && i <= lastOf(b)) return { step: "B", k };
  }
  return { seg: bridges.filter(b => b.ia < i).length };
};
const cPer = 4;
const cCount = Math.ceil(n / cPer);
for (let j = 0; j < cCount; j++) {
  const lastChunk = Math.min((j + 1) * cPer, n) - 1;
  const states = mod(`H${Math.floor((lastChunk + 1) / per)}`);
  if (ok && okModule) {
    const k = [header(states, split || okMeta ? mod("OkB") : okModule, "host.sim.Chunk",
      ...(bridges.some(b => b.kind !== "spread" && b.kind !== "stage") ? ["host.sim.template.Bridges"] : [])), "open Host.Ts Host.Ts.Sim\n"];
    for (let i = j * cPer; i <= lastChunk; i++) {
      const r = role(i);
      if ("seg" in r) k.push(`sim_chunk ${name} ${okOf(r.seg)} ${i}\n`);
      else if (r.step === "A") {
        k.push(`kernel_rfl ${name}.${stepOf(r.k, r.step)} : interpS (step ${name}.F ${name}.s${i}).run ${name}.S${i} = some (${name}.s${i + 1}, ${name}.S${i + 1})\n`);
      } else {
        // the bridge's transition: the machine's step, the lemma's patched template, or none (a stage conversion)
        const line = i === bridges[r.k]!.ia ? transitionLine(name, bridges[r.k]!, one ? "" : String(r.k + 1)) : undefined;
        if (line) k.push(line);
      }
    }
    k.push("end Host.Load.Run.Tpl\n");
    writeFileSync(join(root, `K${j}.lean`), k.join(""));
  }
}
if (ok && okModule) {
  const imps = Array.from({ length: cCount }, (_, j) => mod(`K${j}`));
  // segment k runs from boundary (k = 0 ? 0 : ia_k + 1) to (k = N ? T1 : ia_{k+1} - 1)
  const segs = Array.from({ length: bridges.length + 1 }, (_, k) =>
    [k === 0 ? 0 : lastOf(bridges[k - 1]!) + 1, k === bridges.length ? n : bridges[k]!.ia - 1] as const);
  const body = !split ? [`sim_chain_run ${name} ${ok}\n`]
    : one ? [`sim_chain_range ${name} ${ok} 0 ${segs[0]![1]} runA\n`, `sim_chain_range ${name} ${okOf(1)} ${segs[1]![0]} ${n} runB\n`]
    : segs.flatMap(([a, b], k) => (a < b ? [`sim_chain_range ${name} ${okOf(k)} ${a} ${b} runSeg${k}\n`] : []));
  writeFileSync(join(root, "Run.lean"),
    [header(...imps, ...(split ? ["host.sim.template.ChainRange"] : [])), "open Host.Ts.Sim Host.Ts.Sim.Template\n", ...body,
      "end Host.Load.Run.Tpl\n"].join(""));
}
if (bridges.some(b => b.kind !== "spread")) {
  const lastH = mod(`H${hCount - 1}`);
  writeFileSync(join(root, "Bridge.lean"), [header(lastH, "host.sim.template.Bridges", "host.sim.LoopFinal",
    ...(bridges.some(b => b.kind === "size" && b.patched) ? ["host.sim.full.SizeSim"] : [])),
    "open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n\n",
    `/-! The bridge points of \`${name}\` (seg.json): at each bridge state, the facts its bridge lemma needs. -/\n\n`,
    ...bridges.map((b, k) => kindFacts(name, b, k + 1, framesOf(k), world.vb)), "end Host.Load.Run.Tpl\n"].join(""));
}
const splitLog = !meta && one ? `${bridges[0]!.ia} (aN = ${bridges[0]!.aN})`
  : bridges.map(b => `${b.ia} (${b.kind}, aN = ${b.aN})`).join(", ");
console.log(`${name}: ${hCount} state modules, ${cCount} chunk modules, chunks 0..${n - 1}${ok ? `, checked runs with ${ok}` : ""}${split ? `, split at ${splitLog}` : ""}`);
