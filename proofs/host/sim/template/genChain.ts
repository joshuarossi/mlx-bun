// Write the modules of a route chain (`tpl_chain`): the chain's stream, its stage instances and the call sites' facts.
// usage: bun proofs/host/sim/template/genChain.ts <case-dir> <Name> [--world <w>] [--ok <ok> <ok-module>] [--loadP <term>]
//   Reads $HOST_STREAM_DIR (default <proofs>/.host-stream)/Host.Load.Run.Tpl.<Name>/{chain.json,seg.json} and each
//   instance's stage.json; <case-dir>/States.lean is the module running `tpl_chain`.
// Writes, through gen.ts and genStage.ts:
// * the chain: <case-dir>/H<j>, K<j>, OkB, Run (`<Name>.runSeg<k>`: glue piece k checked with the world's acceptance;
//   each call's step into its call state `<Name>.stepA<k>`; no chunk at the call, a zero-step conversion);
// * each instance `<Name>.st<k>` in <case-dir>/st<k>/ (genStage.ts: H<j>, Ok, K<j>, Run, Tpl `<Name>.st<k>.tpl`, Foot;
//   no closedness: `Conv.site_closed` takes it from the caller's relation at the call), its H0 importing the chain's
//   state module holding the call (its page constants);
// * <case-dir>/Site<k>.lean, the call site's facts (`host.sim.conv` at the instance's own site: σ = Map.id, θ the
//   identity): `<Name>.iso<k> : <Name>.st<k>.s0 = { <Name>.s<ia> with stack := [] }` (the site template is the call
//   state without the caller's frames `<Name>.rs<k> := <Name>.s<ia>.stack`); `<Name>.n0_<k>` (the call's table length);
//   `Conv.site_merge`'s footprint facts `<Name>.wrNodup<k>`, `<Name>.wrBound<k>`, `<Name>.trace<k>` (the stage's trace extends the
//   call's); the fresh variables `<Name>.ws<k>` with `<Name>.fresh<k>` (`noVar` of every caller table entry and oracle answer)
//   and `<Name>.mergeTab<k> : <Name>.S<ia+1>.tab = <Name>.S<ia>.tab ++ Conv.resTab <Name>.ws<k>`; the merged state
//   `<Name>.merge<k> : <Name>.s<ia+1> = Conv.mergeSt Map.id (Map.id.res n0 n0) <Name>.rs<k> <Name>.st<k>.wr <Name>.s<ia>
//   <Name>.st<k>.s<T1> <Name>.st<k>.s0 <Name>.st<k>.s<T1>.ffi`; with the compaction (tpl_chain's default) the canonical state
//   <Name>.s<ia+2>, the map `<Name>.kappa<k> := Conv.Map.compact n0 n1 nS <Name>.pl<k> (<Name>.nr<k>.map .ref) …` (its native
//   part `<Name>.kd<k> : RData`), the canonical result variables `<Name>.cws<k>` with `<Name>.ctheta<k> := Conv.compactθ …`,
//   and the checks `ctab`, `ctrace`, `cnext`, `ccounters`, `cclean` (`Conv.cleanListB` of the written and the result
//   entries) and `cbigs` (`bigsOutB` of the canonical native state); the readback queue carried (`cqueue`, `ctokSupp`); the
//   canonical state's closedness from the call's over the changed entries `<Name>.cl<k>` (`Conv.closed_of_callB`: `ckeepP`,
//   `csupp`, `cbound`, `cnextLe`, `cheap`; `Conv.sst_of_callB`: `csst`, `cnodesK`, `cobjsK`, `citemsK`); in the full world the
//   compaction's native shift `<Name>.cshift<k> : Conv.FullShiftQ <Name>.P<k> n <Name>.kappa<k> c.ffi m.ffi` (`Conv.full_compactQ`:
//   `NShift` at the token-cleared states by `nshift_of` over the checks `c…<k>`, the bridge, the observers by `FullShiftGen`),
//   `<Name>.P<k>` the load parameters (--loadP, default the chain start's counters: `⟨mnext, 131072, 2 ^ 40, nnext, nnext, []⟩`);
// * the native bookkeeping (`Conv.NClean` of the model states): NCl0 (with NCl0c_<j>, the start's full check
//   `<Name>.ncl0`), GlueN<k> (glue piece k to its call, `<Name>.gncl<k>`), SiteCl<k> (the compaction, `<Name>.cncl<k>`),
//   NClAll (`<Name>.nclEnd`, at the chain's end); a piece that removes native entries gets none (reported).
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { type Meta, worlds } from "./bridgeFacts.ts";

const fail = (m: string): never => { throw new Error(m); };
const argv = process.argv.slice(2);
const flag = (f: string): boolean => {
  const i = argv.indexOf(f);
  if (i >= 0) argv.splice(i, 1);
  return i >= 0;
};
const take = (f: string, k = 1): string[] | undefined => {
  const i = argv.indexOf(f);
  if (i < 0) return undefined;
  const v = argv.slice(i + 1, i + 1 + k);
  if (v.length < k) throw new Error(`${f} needs ${k} value(s)`);
  argv.splice(i, k + 1);
  return v;
};
const worldArg = take("--world")?.[0];
const loadPArg = take("--loadP")?.[0];
const okArg = take("--ok", 2);
// the generated checks' acceptance (`--accept js|jsk|jsj [--D0 n]`, else seg.json's): gen.ts and genStage.ts read it from the environment
const acceptArg = take("--accept")?.[0], d0Arg = take("--D0")?.[0];
// the JS bookkeeping at the chain start (`--jstart <module> <term>`: `Conv.JClean c0 <Name>.s0`, e.g. a template's `T.jclean` with the
// chain start its template's), composed with the pieces' steps into JClAll
const jstart = take("--jstart", 2);
if (acceptArg) process.env.CHAIN_ACCEPT = acceptArg;
if (d0Arg) process.env.CHAIN_D0 = d0Arg;
// the compaction's native shift by the full checks in chunks (SiteNa, SiteNc<k>_<j>, SiteNb) instead of its footprint (SiteS)
const chunksArg = flag("--chunks");
const [dir, name] = argv;
if (!dir || !name) throw new Error("usage: genChain.ts <case-dir> <Name> [--world <w>] [--ok <ok> <ok-module>] [--loadP <term>]");
const here = import.meta.dir;
const streams = process.env.HOST_STREAM_DIR ?? join(here, "..", "..", "..", ".host-stream");
const sdir = join(streams, `Host.Load.Run.Tpl.${name}`);
const chain = JSON.parse(readFileSync(join(sdir, "chain.json"), "utf8"));
const metaPath = join(sdir, "seg.json");
const meta = JSON.parse(readFileSync(metaPath, "utf8")) as Meta;
const w = worldArg ?? chain.world ?? "lf";
const world = worlds[w] ?? (() => { throw new Error(`unknown world ${w}`); })();
const run = (args: string[]) => {
  const p = Bun.spawnSync(["bun", ...args], { cwd: here, env: process.env, stdout: "pipe", stderr: "pipe" });
  if (p.exitCode !== 0) throw new Error(`${args.join(" ")}:\n${p.stdout}${p.stderr}`);
  process.stdout.write(p.stdout);
};
const [ok, okModule] = okArg ?? [world.ok, world.okModule];
run(["gen.ts", dir, name, String(meta.T1), ok!, okModule!, "--meta", metaPath, "--world", w, "--okMeta"]);
const mod = (file: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${file}`;
const per = 32;
const stages = meta.bridges.filter(b => b.kind === "stage");
const NL = "\n";
type Comp = {
  n0: number; n1: number; nS: number; pl: number[]; nr: number[]; plh: number[]; pln: number[]; xn0: number; xn1: number;
  nn0: number; nn1: number; ws: number[]; wrB: number[]; whB: number[]; wiB: number[]; counts?: number[];
  fwd: { n0: number; n1: number; nh0: number; nh1: number; nn0: number; nn1: number; heap: [number, number][];
    hnd: [number, number][]; node: [number, number][] };
};
const pairs = (l: [number, number][]) => `[${l.map(([a, c]) => `(${a}, ${c})`).join(", ")}]`;
const range = (a: number, n: number) => Array.from({ length: n }, (_, j) => a + j);
// the canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`) over the changed entries
function closedFacts(k: number, cp: Comp, call: string, c: string, nC: number, xC: string, mC: string): string[] {
  const l = [...cp.wrB, ...range(cp.n0, cp.pl.length)];
  cp.whB ??= []; cp.wiB ??= [];
  const lo = [...cp.whB, ...range(cp.xn0, cp.plh.length)], ln = range(cp.nn0, cp.pln.length), li = [...cp.wiB, ...ln];
  const keep = (field: string, xs: string) =>
    `${mC}.${field} = Stage.setAll ${xC}.${field} (${xs}.filterMap fun i => (${mC}.${field}.get i).map (i, ·))`;
  return [
    `/-! The canonical state's closedness from the call's (\`Conv.closed_of_callB\`, \`Conv.sst_of_callB\`): it keeps the call's entries${NL}`,
    `off the written and the result ones (\`${name}.cl${k}\`; natively the written and result handles, the result nodes, the written${NL}`,
    `and result items), and those are checked. -/${NL}${NL}`,
    `def ${name}.cl${k} : List Nat := [${l.join(", ")}]${NL}`,
    `def ${name}.clo${k} : List Nat := [${lo.join(", ")}]${NL}`,
    `def ${name}.cln${k} : List Nat := [${ln.join(", ")}]${NL}`,
    `def ${name}.cli${k} : List Nat := [${li.join(", ")}]${NL}`,
    `kernel_rfl ${name}.cheap${k} : ${c}.heap = Stage.setAll ${call}.heap (${name}.cl${k}.filterMap fun a => (${c}.heap.get a).map (a, ·))${NL}`,
    `kernel_rfl ${name}.cnextLe${k} : Nat.ble ${call}.next ${c}.next = true${NL}`,
    `kernel_rfl ${name}.ckeepP${k} : Conv.keptPresentB ${call} ${c} ${name}.cl${k} = true${NL}`,
    `kernel_rfl ${name}.csupp${k} : Conv.suppListB ${c} ${nC} ${name}.cl${k} = true${NL}`,
    `kernel_rfl ${name}.cbound${k} : Conv.boundListB ${c} ${name}.cl${k} = true${NL}`,
    `kernel_rfl ${name}.cnodesK${k} : ${keep("nodes", `${name}.cln${k}`)}${NL}`,
    `kernel_rfl ${name}.cobjsK${k} : ${keep("objs", `${name}.clo${k}`)}${NL}`,
    `kernel_rfl ${name}.citemsK${k} : ${keep("items", `${name}.cli${k}`)}${NL}`,
    `kernel_rfl ${name}.csst${k} : Conv.sstListB ${nC} ${mC} ${name}.cln${k} ${name}.clo${k} ${name}.cli${k} = true${NL}${NL}`,
  ];
}
// the compaction's native shift in the full world (`Conv.FullShiftQ`): `NShift` at the token-cleared states from its checks
// a check over a long list in chunks of `chunk` elements (`all_take_drop`, `map_take_drop`): one module per chunk
const chunk = Number(take("--chunk")?.[0] ?? 2000);
function chunked(nm: string, k: number, list: string, n: number, kind: "all" | "map", stmt: (l: string) => string):
    { chunks: string[][]; assemble: string[] } {
  const m = Math.max(1, Math.ceil(n / chunk));
  let l = list;
  const ls: string[] = [];
  for (let j = 0; j <= m; j++) { ls.push(l); l = `(${l}).drop ${chunk}`; }
  const chunks = Array.from({ length: m }, (_, j) => [`kernel_rfl ${name}.${nm}${k}_${j} : ${stmt(`(${ls[j]}).take ${chunk}`)}${NL}`]);
  const last = `kernel_rfl ${name}.${nm}${k}_end : ${ls[m]} = []${NL}`;
  const step = kind === "all" ? "all_take_drop" : "map_take_drop", nil = kind === "all" ? "all_of_nil" : "map_of_nil";
  let proof = `${nil} ${name}.${nm}${k}_end`;
  for (let j = m - 1; j >= 0; j--) proof = `${step} ${chunk} ${name}.${nm}${k}_${j} (${proof})`;
  return { chunks, assemble: [last, `theorem ${name}.${nm}${k} : ${stmt(list)} :=${NL}  ${proof}${NL}`] };
}
// the compaction's native shift from its footprint (`Conv.nshift_of_foot`, `Conv.MFoot`; A3's host.sim.conv.NShiftFoot): the
// small checks, the compaction map fixing the call's names (`Conv.fixOld_compact`), the canonical state's keep facts over
// the changed lists (SiteK, SiteCl), the merged state's over the stage's footprint (its `wh`, fresh nodes, `wi` and fresh
// items), the checks over the changed lists; the observers by `liveShift_foot`, `kernShift_foot` (FootGen). The call's
// bookkeeping (`Conv.NClean`, its `gncl` chain), its relation's facts and the canonical closedness are parameters.
function footFacts(k: number, cp: Comp, cC: number[], c: string, m: string, call: string, nC: number, mC: string, mM: string,
    wh: number[], wi: number[]): string[] {
  const kap = `${name}.kappa${k}`, D = `${name}.kd${k}`, P = `${name}.P${k}`;
  const y0 = `${name}.cx0_${k}`, y1 = `${name}.cx1_${k}`, x0 = `${y0}.mlx`, x1 = `${y1}.mlx`, xC = world.mlx(call);
  const lp: number[] | undefined = (meta as { loadP?: number[] }).loadP;
  const st0 = loadPArg || lp ? undefined : chain.start ?? fail("chain.json: no start counters (give --loadP)");
  const ck = (nm: string, stmt: string) => `kernel_rfl ${name}.${nm}${k} : ${stmt}${NL}`;
  const N = (nm: string) => `${name}.${nm}${k}`;
  const cCL = `(⟨${cC.join(", ")}⟩ : Conv.Cnt)`;
  const lh = N("clo"), ln = N("cln"), li = N("cli"), wS = N("cwS"), nS = N("cnS"), iS = N("ciS");
  const fresh = `List.range' ${cC[1]} ${cp.nn1 - cC[1]!}`;
  const keep = (y: string, field: string, xs: string) =>
    `${y}.${field} = Stage.setAll ${xC}.${field} (${xs}.filterMap fun i => (${y}.${field}.get i).map (i, ·))`;
  const le = (nm: string, a: string, b: string) => ck(nm, `Nat.ble ${a} ${b} = true`);
  const L = (nm: string) => `(Nat.le_of_ble_eq_true ${N(nm)})`;
  const fr = (s: string) => `(Host.Ts.Sim.Full.freedOf ${s}.ffi)`, kr = (s: string) => `(Host.Ts.Sim.Full.krecOf ${s}.ffi)`;
  const params = [`(clean : Conv.NClean ${cCL} ${xC})`, `(hltC : ∀ h, PH ${xC} h → h < ${xC}.next)`,
    `(nltC : ∀ i, PN ${xC} i → i < ${xC}.nnext)`, `(itemsC : ∀ k v, ${xC}.items.get k = some v → PN ${xC} k)`,
    `(tracedC : ∀ h o, ${xC}.objs.get h = some o → ∀ i ∈ objTraces o, i < ${P}.NL)`, `(cl : SSt (· < ${nC}) ${x0})`];
  const args = "clean hltC nltC itemsC tracedC cl";
  const fields = ["rfl", "rfl", "rfl", N("cnh0"), N("cnh1"), N("cnn0"), N("cnn1"), N("cplo"), N("ccnt"), N("cnband"), N("chbelow"),
    N("chren"), N("cband"), N("cnh1pos"), N("cnren"), N("cnlow"), N("cabs0a"), N("cabs0b"), N("ctok1"), N("cpend"), N("cerrh"),
    N("cfiles"), N("carch"), N("csizes"), N("cwired"),
    N("cfix"),
    "clean", N("fcxn"), N("fcnn"), "hltC", "nltC", "itemsC", "tracedC", "cl", N("fle0"), N("fnk"),
    N("ckA"), N("cobjsK"), N("cnodesK"), N("citemsK"), N("f1A"), N("f1O"), N("f1N"), N("f1I"), N("fbd"), N("fincW"), N("fincI"),
    N("fincN"), N("flnF"), N("fh"), N("fo"), N("fok"), N("fnd"), N("fp"), N("fnord"), N("fi"), N("fii")];
  return [
    `/-! The compaction's native shift at call site ${k} from its footprint (\`Conv.nshift_of_foot\`), and the observers'${NL}`,
    `(\`liveShift_foot\`, \`kernShift_foot\`): \`Conv.FullShiftQ\` for \`Conv.full_compactQ\`, given the call's bookkeeping and its${NL}`,
    `relation's facts. -/${NL}${NL}`,
    `/-- The load parameters of the chain (its start's node counter as \`NL\` and \`N0\`). -/${NL}`,
    `def ${P} : LoadP := ${loadPArg ?? (lp ? `⟨${lp.join(", ")}, []⟩` : `⟨${st0.mnext}, 131072, 2 ^ 40, ${st0.nnext}, ${st0.nnext}, []⟩`)}${NL}`,
    `noncomputable abbrev ${y0} : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad ${c}.ffi)${NL}`,
    `noncomputable abbrev ${y1} : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad ${m}.ffi)${NL}`,
    `def ${name}.khinv${k} : PTrie Nat := Stage.setAll PTrie.nil ${pairs(cp.plh.map((h, j) => [h, cp.xn0 + j] as [number, number]))}${NL}`,
    `def ${name}.kninv${k} : PTrie Nat := Stage.setAll PTrie.nil ${pairs(cp.pln.map((n, j) => [n, cp.nn0 + j] as [number, number]))}${NL}`,
    `/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/${NL}`,
    `def ${wS} : List Nat := [${wh.join(", ")}]${NL}`,
    `def ${nS} : List Nat := ${fresh}${NL}`,
    `def ${iS} : List Nat := [${wi.join(", ")}] ++ ${fresh}${NL}${NL}`,
    `-- the small checks (\`MChecks\`'s)${NL}`,
    ck("cnh0", `${D}.nh0 = ${x0}.next`), ck("cnh1", `${D}.nh1 = ${x1}.next`), ck("cnn0", `${D}.nn0 = ${x0}.nnext`),
    ck("cnn1", `${D}.nn1 = ${x1}.nnext`),
    ck("cplo", `(Nat.blt 0 ${P}.lo && Nat.ble ${P}.lo ${x0}.next && Nat.ble ${P}.lo RData.bigHi && Nat.ble RData.bigHi ${P}.E) = true`),
    ck("ccnt", `(Nat.ble ${x0}.next ${x1}.next && Nat.ble ${x0}.nnext ${x1}.nnext) = true`),
    ck("cnband", `(Nat.blt 0 ${P}.NL && Nat.ble ${P}.NL ${P}.N0 && Nat.ble ${P}.N0 ${x0}.nnext) = true`),
    ck("chbelow", `${D}.checkHndBelow = true`), ck("chren", `checkRenG ${D}.hnd ${name}.khinv${k} (phB ${x0}) = true`),
    ck("cband", `${D}.checkBand ${P}.lo = true`), ck("cnh1pos", `Nat.blt 0 ${D}.nh1 = true`),
    ck("cnren", `checkRenG ${D}.node ${name}.kninv${k} (pnB ${x0}) = true`),
    ck("cnlow", `(PTrie.keysA ${D}.node).all (fun j => Nat.ble ${P}.NL j && Nat.blt (${D}.nodeF j) ${x1}.nnext) = true`),
    ck("cabs0a", `${x0}.arrs.get 0 = none`), ck("cabs0b", `${x0}.objs.get 0 = none`), ck("ctok1", `${x1}.tokens = []`),
    ck("cpend", `${x1}.pending = ${x0}.pending.map ${kap}.pend`), ck("cerrh", `${x1}.errh = ${x0}.errh.map ${kap}.arg`),
    ck("cfiles", `${x1}.files = ${x0}.files`), ck("carch", `${x1}.arch = ${x0}.arch`),
    ck("csizes", `${x1}.deviceSizes = ${x0}.deviceSizes`), ck("cwired", `${x1}.wired = ${x0}.wired`),
    ck("chost", `${y1}.host = ${y0}.host`),
    `-- the compaction map's addresses are \`${D}\`'s${NL}`,
    ck("ckn0", `${D}.n0 = ${cp.n0 + cp.pl.length}`), ck("ckn1", `${D}.n1 = ${cp.n1}`),
    ck("ckheap", `(PTrie.keysA ${D}.heap).all (fun x => Nat.ble ${cp.n0} x) = true`),
    ck("ckpl", `(List.range ${cp.pl.length}).all (fun j => decide (${D}.heap.get (${cp.n0} + j) = nth? ${name}.pl${k} j)) = true`),
    `-- the map fixes the call's names (\`Conv.fixOld_compact\`), the call's counters${NL}`,
    le("fja", String(cC[2]), String(cp.n0)), le("fn", String(cC[3]), String(cp.nS)), le("fjaD", String(cC[2]), `${D}.n0`),
    le("fxn", String(cC[0]), `${D}.nh0`), le("fnn", String(cC[1]), `${D}.nn0`), le("fxb", String(cC[0]), "RData.bigHi"),
    ck("fheap", `(PTrie.keysA ${D}.heap).all (Nat.ble ${cCL}.ja) = true`),
    ck("fhnd", `(PTrie.keysA ${D}.hnd).all (Nat.ble ${cCL}.xn) = true`),
    ck("fnode", `(PTrie.keysA ${D}.node).all (Nat.ble ${cCL}.nn) = true`),
    `/-- The compaction map fixes the call's names. -/${NL}`,
    `theorem ${N("cfix")} : Conv.FixOld ${cCL} ${kap} :=${NL}`,
    `  Conv.fixOld_compact ${L("fja")} ${L("fn")} ${L("fjaD")} ${L("fxn")} ${L("fnn")} ${L("fxb")} ${N("fheap")} ${N("fhnd")} ${N("fnode")}${NL}`,
    ck("fcxn", `${cCL}.xn = ${xC}.next`), ck("fcnn", `${cCL}.nn = ${xC}.nnext`),
    ck("fle0", `(Nat.ble ${xC}.next ${x0}.next && Nat.ble ${xC}.nnext ${x0}.nnext && Nat.ble ${xC}.next RData.bigHi) = true`),
    ck("fnk", `(PTrie.keysA ${D}.node).all (Nat.ble ${xC}.nnext) = true`),
    `-- the merged state keeps the call's entries off the stage's footprint${NL}`,
    ck("f1A", keep(x1, "arrs", wS)), ck("f1O", keep(x1, "objs", wS)), ck("f1N", keep(x1, "nodes", nS)), ck("f1I", keep(x1, "items", iS)),
    ck("fbd", `(${lh} ++ ${ln} ++ ${li} ++ ${wS} ++ ${nS} ++ ${iS}).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true`),
    ck("fincW", `${wS}.all (fun h => !Nat.blt h ${xC}.next || ${lh}.contains h) = true`),
    ck("fincI", `${iS}.all (fun k => !Nat.blt k ${xC}.nnext || ${li}.contains k) = true`),
    ck("fincN", `${nS}.all (Nat.ble ${xC}.nnext) = true`), ck("flnF", `${ln}.all (Nat.ble ${xC}.nnext) = true`),
    `-- the checks over the changed lists${NL}`,
    ck("fh", `${lh}.all (handleOK ${kap} ${P}.lo ${x0} ${x1}) = true`),
    ck("fo", `${lh}.map (fun h => ${x1}.objs.get (${kap}.handle h)) = ${lh}.map (fun h => (${x0}.objs.get h).map ${kap}.nobj)`),
    ck("fok", `${lh}.all (objOK ${kap} ${P}.NL ${x0}) = true`),
    ck("fnd", `${ln}.all (nodeOKF ${kap} ${P} ${x0} ${x1}) = true`),
    ck("fp", `(${ln}.filter (fullB ${P})).map (fun i => (${x1}.nodes.get (${kap}.node i)).map Host.Mlx.Ffi.Node.prim) =${NL}  (${ln}.filter (fullB ${P})).map (fun i => (${x0}.nodes.get i).map fun nd => ${kap}.prim nd.prim)`),
    ck("fnord", `(${ln}.filter (Nat.ble ${P}.N0)).all (fun i => Nat.ble i (${D}.nodeF i) &&${NL}  (PTrie.keysA ${D}.node).all fun j => !Nat.blt j i || Nat.blt (${D}.nodeF j) (${D}.nodeF i)) = true`),
    ck("fi", `${li}.all (pnB ${x0}) = true`),
    ck("fii", `${li}.all (fun k => decide (${x1}.items.get (${kap}.node k) = (${x0}.items.get k).map ${kap}.nv)) = true`),
    `/-- **The compaction's footprint.** -/${NL}`,
    `theorem ${name}.cfoot${k} ${params.join(" ")} :${NL}`,
    `    Conv.MFoot ${P} ${nC} ${kap} ${D} ${name}.khinv${k} ${name}.kninv${k} ${xC} ${x0} ${x1} ${cCL} ${lh} ${ln} ${li} ${wS} ${nS} ${iS} :=${NL}`,
    `  ⟨${fields.join(", ")}⟩${NL}`,
    `theorem ${name}.cnshift${k} ${params.join(" ")} : NShift ${P} ${nC} ${kap} ${y0} ${y1} :=${NL}`,
    `  Conv.nshift_of_foot (${name}.cfoot${k} ${args}) ${name}.chost${k} (compact_a_eq ${name}.ckn0${k} ${name}.ckn1${k} ${name}.ckheap${k} ${name}.ckpl${k})${NL}${NL}`,
    `-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks${NL}`,
    ...[["C", call], ["0", c], ["1", m]].flatMap(([j, s]) => [
      `noncomputable def ${name}.fx${j}_${k} : PTrie Unit := ${fr(s!)}.getD PTrie.nil${NL}`,
      `noncomputable def ${name}.kr${j}_${k} : Host.Load.Layers.KRec := ${kr(s!)}.getD Host.Load.Layers.KRec.empty${NL}`,
      ck(`ofx${j}_`, `${fr(s!)} = some ${name}.fx${j}_${k}`), ck(`okr${j}_`, `${kr(s!)} = some ${name}.kr${j}_${k}`)]),
    ck("ff0", `${name}.fx0_${k} = Stage.setAll ${name}.fxC_${k} (${lh}.filterMap fun i => (${name}.fx0_${k}.get i).map (i, ·))`),
    ck("ff1", `${name}.fx1_${k} = Stage.setAll ${name}.fxC_${k} (${wS}.filterMap fun i => (${name}.fx1_${k}.get i).map (i, ·))`),
    ck("ffck", `freedLB ${kap} ${x0} ${name}.fx0_${k} ${name}.fx1_${k} ${lh} = true`),
    ...([["fkf0", "0", "flags", lh], ["fkt0", "0", "targs", lh], ["fkf1", "1", "flags", wS], ["fkt1", "1", "targs", wS]] as const).map(([nm, j, fl, xs]) =>
      ck(nm, `${name}.kr${j}_${k}.${fl} = Stage.setAll ${name}.krC_${k}.${fl} (${xs}.filterMap fun i => (${name}.kr${j}_${k}.${fl}.get i).map (i, ·))`)),
    ck("fkck", `krecLB ${kap} ${nC} ${x0} ${name}.kr0_${k} ${name}.kr1_${k} ${lh} = true`),
    le("fkn", String(cC[3]), String(nC)),
    `-- the bridge and the pending traces' regions${NL}`,
    ck("cbridge", `Host.Ts.Sim.Full.bridgeOf ${m}.ffi = Host.Ts.Sim.Full.bridgeOf ${c}.ffi`),
    ck("cpendR", `pendRegB ${kap} ${mC} = true`), ck("cpendLe", `Nat.ble ${mC}.next ${mM}.next = true`),
    `/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the${NL}`,
    `observers') and the canonical closedness. -/${NL}`,
    `theorem ${name}.cshift${k} ${params.join(" ")}${NL}`,
    `    (hobjC : ∀ h, ${name}.fxC_${k}.get h = some () → (${xC}.objs.get h).isSome = true)${NL}`,
    `    (hfC : ∀ h, (${name}.krC_${k}.flags.get h).isSome = true → (${xC}.objs.get h).isSome = true)${NL}`,
    `    (htC : ∀ h, (${name}.krC_${k}.targs.get h).isSome = true → (${xC}.objs.get h).isSome = true)${NL}`,
    `    (hclC : ∀ h l, ${name}.krC_${k}.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < ${cCL}.n) l) :${NL}`,
    `    Conv.FullShiftQ ${P} ${nC} ${kap} ${c}.ffi ${m}.ffi :=${NL}`,
    `  ⟨${name}.cnshift${k} ${args}, ${name}.cqueue${k}, fun t ht => bSN_sound (List.all_eq_true.mp ${name}.ctokSupp${k} t ht),${NL}`,
    `    ${name}.cbridge${k},${NL}`,
    `    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf ${c}.ffi) (x1' := Host.Ts.Sim.Full.mlxOf ${m}.ffi) (${name}.cfoot${k} ${args}) rfl ${name}.ofx0_${k} ${name}.ofx1_${k} hobjC ${name}.ff0${k} ${name}.ff1${k} ${name}.ffck${k},${NL}`,
    `    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf ${c}.ffi) (x1' := Host.Ts.Sim.Full.mlxOf ${m}.ffi) (${name}.cfoot${k} ${args}) rfl ${name}.okr0_${k} ${name}.okr1_${k} ${L("fkn")} hfC htC hclC${NL}`,
    `      ${name}.fkf0${k} ${name}.fkt0${k} ${name}.fkf1${k} ${name}.fkt1${k} ${name}.fkck${k},${NL}`,
    `    pendReg_of rfl ${name}.cnh0${k} ${name}.cnh1${k} (Nat.le_of_ble_eq_true ${name}.cpendLe${k}) ${name}.cpendR${k}⟩${NL}${NL}`,
  ];
}
// the compaction's state shift (`Conv.compact_shift`, A3's host.sim.conv.CompactShift) at call site `k`: the map's places and
// counters, the tables, the frames (`Fd` the chain's framed addresses, `Xs` those without a wide frame), the heap off the
// changed list `cl<k>` (its image on the canonical side), the roots and their supports, the JS bookkeeping's step
// (`Conv.JClean.step`, `jcleanListB` at the canonical counters) and the canonical roots' bigint freedom (`jclean_noBigSt`)
function shiftDFacts(k: number, cp: Comp, cC: number[], cK: number[], sa: string, sm: string, sc: string, Sa: string,
    Sm: string, nC: number, inst: string): string[] {
  const ck = (nm: string, stmt: string) => `kernel_rfl ${name}.${nm}${k} : ${stmt}${NL}`;
  const kap = `${name}.kappa${k}`, cl = `${name}.cl${k}`;
  const cCL = `(⟨${cC.join(", ")}⟩ : Conv.Cnt)`, cKL = `(⟨${cK.join(", ")}⟩ : Conv.Cnt)`;
  const fd: number[] = meta.frames ?? [];
  const wideA = ((meta as { wide?: [number, string][] }).wide ?? []).map(([a]) => a);
  const xs = fd.filter(a => !wideA.includes(a));
  return [
    `/-! The compaction's state shift at call site ${k} of chain \`${name}\` (\`Conv.compact_shift\`): the call \`${sa}\`, the merged${NL}`,
    `state \`${sm}\`, the canonical state \`${sc}\`; its frames ${JSON.stringify(fd)} (kept arrays ${JSON.stringify(xs)}). -/${NL}${NL}`,
    `-- the map's places and counters${NL}`,
    ck("zpl", `${name}.pl${k}.all (Nat.ble ${sa}.next) = true`), ck("zplnd", `nodupT ${name}.pl${k} PTrie.nil = true`),
    ck("zn1", `Nat.ble ${sa}.next ${cp.n1} = true`), ck("zfirst", `Nat.ble aFirst ${sa}.next = true`),
    ck("zscn", `${sc}.next = ${sa}.next + ${name}.pl${k}.length`), ck("zsmn", `${sm}.next = ${cp.n1}`),
    ck("zgrow", `Nat.ble ${sc}.next ${sm}.next = true`),
    `-- the tables${NL}`,
    ck("zfresh", `${Sa}.tab.all (fun e => ${name}.cws${k}.all fun v => e.noVar v) = true`),
    ck("zcnd", `nodupT ${name}.cws${k} PTrie.nil = true`),
    ck("znrHi", `${name}.nr${k}.all (fun r => Nat.blt r ${Sm}.tab.length) = true`),
    `-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state${NL}`,
    ck("zfrlt", `[${fd.join(", ")}].all (fun a => Nat.blt a ${sa}.next) = true`),
    ...xs.flatMap(a => [
      `kernel_rfl ${name}.zg${k}_${a} : ${sc}.heap.get ${a} = some (.obj (objOf ${sc} ${a}))${NL}`,
      `kernel_rfl ${name}.zk${k}_${a} : (objOf ${sc} ${a}).kind = .array (arrOf ${name}.s0 ${a})${NL}`,
      `kernel_rfl ${name}.zm${k}_${a} : ${sm}.heap.get ${a} = some (.obj { ${kap}.obj (objOf ${sc} ${a}) with${NL}`,
      `  kind := .array (arrOf ${name}.s0 ${a} ++ (arrOf ${sm} ${a}).drop (arrOf ${name}.s0 ${a}).length) })${NL}`]),
    ...wideA.map(a => `kernel_rfl ${name}.zw${k}_${a} : (${sc}.heap.get ${a}).isSome = true${NL}`),
    `-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image${NL}`,
    ck("zclbd", `${cl}.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true`),
    ck("zwr", `${inst}.wr.all (fun b => !Nat.blt b ${sa}.next || ${cl}.contains b) = true`),
    `def ${name}.zl${k} : List Nat := ${cl}.filter fun a => !(List.contains [${xs.join(", ")}] a)${NL}`,
    ck("zimgE", `${name}.zl${k}.map (fun a => ${sm}.heap.get (${kap}.a a)) = ${name}.zl${k}.map (fun a => (${sc}.heap.get a).map ${kap}.hobj)`),
    `theorem ${name}.zimg${k} : HeapImg ${kap} ${sc} ${sm} ${name}.zl${k} := ${name}.zimgE${k}${NL}`,
    `-- the roots and their supports${NL}`,
    ck("zctl", `${sm}.ctl = ${kap}.ctl ${sc}.ctl`), ck("zstack", `${sm}.stack = ${sc}.stack.map ${kap}.frame`),
    ck("zjobs", `${sm}.jobs = ${sc}.jobs.map ${kap}.job`), ck("zstores", `${sm}.stores = ${kap}.stores ${sc}.stores`),
    ck("zroots", `checkRootsSupp ${sc} ${nC} = true`),
    ck("znC", `${Sa}.tab.length + ${name}.cws${k}.length = ${nC}`),
    `-- the map as \`Conv.compact_shift\` states it (the call's counters for the literals)${NL}`,
    ck("zkap", `${kap} = Conv.Map.compact ${sa}.next ${cp.n1} ${Sa}.tab.length ${name}.pl${k} (${name}.nr${k}.map NumV.ref) ${name}.kd${k}.big${NL}  ${name}.kd${k}.region ${name}.kd${k}.nodeF`),
    `-- the bridge inactive at the canonical state (\`Conv.FullShiftQ.toX\`; the merged state's bridge is the canonical's: cbridge)${NL}`,
    ck("zbin", `(Host.Ts.Sim.Full.bridgeOf ${sc}.ffi).active = false`),
    `-- the JS bookkeeping's step (\`Conv.JClean.step\` over the changed list) and the canonical roots' bigint freedom${NL}`,
    ck("zjc", `Conv.jcleanListB ${cKL} ${sc} ${cl} = true`),
    ck("zroots2", `noBigRootsP (fun i => !Conv.oldBigB ${cKL} i) ${sc}.trace ${sc} = true`),
    ck("zhm", `Nat.ble ${world.mlx(`${name}.s0`)}.nnext ${cC[1]} = true`),
    `theorem ${name}.cjcl${k} (h : Conv.JClean ${cCL} ${sa}) : Conv.JClean ${cKL} ${sc} :=${NL}`,
    `  Conv.JClean.step h (Conv.Cnt.le_of_leB ${name}.cle${k})${NL}`,
    `    (Conv.heap_off_setAll ${name}.cheap${k} fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp ${name}.zclbd${k} a ha)) ${name}.zjc${k}${NL}${NL}`];
}
function shiftFacts(k: number, cp: Comp, c: string, m: string, nC: number, mC: string, mM: string):
    { a: string[]; chunks: string[][]; b: string[] } {
  const kap = `${name}.kappa${k}`, D = `${name}.kd${k}`, P = `${name}.P${k}`;
  const x0 = `${name}.cx0_${k}.mlx`, x1 = `${name}.cx1_${k}.mlx`;
  const lp: number[] | undefined = (meta as { loadP?: number[] }).loadP;
  const st0 = loadPArg || lp ? undefined : chain.start ?? fail("chain.json: no start counters (give --loadP)");
  const ck = (nm: string, stmt: string) => `kernel_rfl ${name}.${nm}${k} : ${stmt}${NL}`;
  const fields = ["nh0", "nh1", "nn0", "nn1", "lo", "cnt", "nband", "hbelow", "handles", "hren", "band", "nh1pos", "objs", "objok",
    "nodes", "prims", "nren", "nlow", "nord", "items", "ssT", "abs0a", "abs0b", "tok1", "pend", "errh", "files", "arch", "sizes", "wired"];
  const [nArrs, nObjs, nNodes] = cp.counts ?? [20000, 4000, 20000];
  const hs = chunked("chandles", k, `handlesOfA ${x0}`, nArrs! + nObjs!, "all", l => `(${l}).all (handleOK ${kap} ${P}.lo ${x0} ${x1}) = true`);
  const ns = chunked("cnodes", k, `PTrie.keysA ${x0}.nodes`, nNodes!, "all", l => `(${l}).all (nodeOKF ${kap} ${P} ${x0} ${x1}) = true`);
  const ps = chunked("cprims", k, `fullKeysF ${P} ${x0}`, nNodes!, "map", l =>
    `(${l}).map (fun i => (${x1}.nodes.get (${kap}.node i)).map Host.Mlx.Ffi.Node.prim) =${NL}  (${l}).map (fun i => (${x0}.nodes.get i).map fun nd => ${kap}.prim nd.prim)`);
  const all = [
    `/-! The compaction's native shift (\`Conv.FullShiftQ\`, for \`Conv.full_compactQ\`): the load world's shift between the${NL}`,
    `token-cleared states (\`nshift_of\` over the checks below; \`${kap}\`'s native parts are \`${D}\`'s, its addresses by${NL}`,
    `\`compact_a_eq\`), the queue (\`cqueue\`, \`ctokSupp\`), the bridge and the observers (\`FullShiftGen\`). -/${NL}${NL}`,
    `/-- The load parameters of the chain (its start's node counter as \`N0\`). -/${NL}`,
    `def ${P} : LoadP := ${loadPArg ?? (lp ? `⟨${lp.join(", ")}, []⟩` : `⟨${st0.mnext}, 131072, 2 ^ 40, ${st0.nnext}, ${st0.nnext}, []⟩`)}${NL}`,
    `noncomputable abbrev ${name}.cx0_${k} : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad ${c}.ffi)${NL}`,
    `noncomputable abbrev ${name}.cx1_${k} : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad ${m}.ffi)${NL}`,
    `def ${name}.khinv${k} : PTrie Nat := Stage.setAll PTrie.nil ${pairs(cp.plh.map((h, j) => [h, cp.xn0 + j] as [number, number]))}${NL}`,
    `def ${name}.kninv${k} : PTrie Nat := Stage.setAll PTrie.nil ${pairs(cp.pln.map((n, j) => [n, cp.nn0 + j] as [number, number]))}${NL}`,
    ck("cnh0", `${D}.nh0 = ${x0}.next`), ck("cnh1", `${D}.nh1 = ${x1}.next`), ck("cnn0", `${D}.nn0 = ${x0}.nnext`),
    ck("cnn1", `${D}.nn1 = ${x1}.nnext`),
    ck("clo", `(Nat.blt 0 ${P}.lo && Nat.ble ${P}.lo ${x0}.next && Nat.ble ${P}.lo RData.bigHi && Nat.ble RData.bigHi ${P}.E) = true`),
    ck("ccnt", `(Nat.ble ${x0}.next ${x1}.next && Nat.ble ${x0}.nnext ${x1}.nnext) = true`),
    ck("cnband", `(Nat.blt 0 ${P}.NL && Nat.ble ${P}.NL ${P}.N0 && Nat.ble ${P}.N0 ${x0}.nnext) = true`),
    ck("chbelow", `${D}.checkHndBelow = true`),

    ck("chren", `checkRenG ${D}.hnd ${name}.khinv${k} (phB ${x0}) = true`),
    ck("cband", `${D}.checkBand ${P}.lo = true`), ck("cnh1pos", `Nat.blt 0 ${D}.nh1 = true`),
    ck("cobjs", `(PTrie.keysA ${x0}.objs).map (fun h => ${x1}.objs.get (${kap}.handle h)) =${NL}  (PTrie.keysA ${x0}.objs).map (fun h => (${x0}.objs.get h).map ${kap}.nobj)`),
    ck("cobjok", `(PTrie.keysA ${x0}.objs).all (objOK ${kap} ${P}.NL ${x0}) = true`),
    "-- (the handle, node and primitive checks in chunks, assembled below)${NL}",
    ck("cnren", `checkRenG ${D}.node ${name}.kninv${k} (pnB ${x0}) = true`),
    ck("cnlow", `(PTrie.keysA ${D}.node).all (fun j => Nat.ble ${P}.NL j && Nat.blt (${D}.nodeF j) ${x1}.nnext) = true`),
    ck("cnord", `(fullAbove ${P} ${x0}).all (fun i => Nat.ble i (${D}.nodeF i) &&${NL}  (PTrie.keysA ${D}.node).all fun j => !Nat.blt j i || Nat.blt (${D}.nodeF j) (${D}.nodeF i)) = true`),
    ck("citems", `(PTrie.keysA ${x0}.items).all (pnB ${x0}) = true`), ck("cssT", `checkSSt ${nC} ${x0} = true`),
    ck("cabs0a", `${x0}.arrs.get 0 = none`), ck("cabs0b", `${x0}.objs.get 0 = none`), ck("ctok1", `${x1}.tokens = []`),
    ck("cpend", `${x1}.pending = ${x0}.pending.map ${kap}.pend`), ck("cerrh", `${x1}.errh = ${x0}.errh.map ${kap}.arg`),
    ck("cfiles", `${x1}.files = ${x0}.files`), ck("carch", `${x1}.arch = ${x0}.arch`),
    ck("csizes", `${x1}.deviceSizes = ${x0}.deviceSizes`), ck("cwired", `${x1}.wired = ${x0}.wired`),
    ck("chost", `${name}.cx1_${k}.host = ${name}.cx0_${k}.host`),
    `-- the compaction map's addresses are \`${D}\`'s${NL}`,
    ck("ckn0", `${D}.n0 = ${cp.n0 + cp.pl.length}`), ck("ckn1", `${D}.n1 = ${cp.n1}`),
    ck("ckheap", `(PTrie.keysA ${D}.heap).all (fun x => Nat.ble ${cp.n0} x) = true`),
    ck("ckpl", `(List.range ${cp.pl.length}).all (fun j => decide (${D}.heap.get (${cp.n0} + j) = nth? ${name}.pl${k} j)) = true`),
    ...hs.assemble, ...ns.assemble, ...ps.assemble,
    `theorem ${name}.cnshift${k} : NShift ${P} ${nC} ${kap} ${name}.cx0_${k} ${name}.cx1_${k} :=${NL}`,
    `  nshift_of ⟨rfl, rfl, rfl, ${fields.map(f => `${name}.c${f}${k}`).join(", ")}⟩${NL}`,
    `    ${name}.chost${k} (compact_a_eq ${name}.ckn0${k} ${name}.ckn1${k} ${name}.ckheap${k} ${name}.ckpl${k})${NL}`,
    `-- the bridge and the observers${NL}`,
    ck("cbridge", `Host.Ts.Sim.Full.bridgeOf ${m}.ffi = Host.Ts.Sim.Full.bridgeOf ${c}.ffi`),
    ck("clive", `liveShiftB ${kap} ${mC} (Host.Ts.Sim.Full.freedOf ${c}.ffi) (Host.Ts.Sim.Full.freedOf ${m}.ffi) = true`),
    ck("ckern", `kernShiftB ${kap} ${nC} ${mC} (Host.Ts.Sim.Full.krecOf ${c}.ffi) (Host.Ts.Sim.Full.krecOf ${m}.ffi) = true`),
    ck("cpendR", `pendRegB ${kap} ${mC} = true`), ck("cpendLe", `Nat.ble ${mC}.next ${mM}.next = true`),
    `/-- **The compaction's native shift.** -/${NL}`,
    `theorem ${name}.cshift${k} : Conv.FullShiftQ ${P} ${nC} ${kap} ${c}.ffi ${m}.ffi :=${NL}`,
    `  ⟨${name}.cnshift${k}, ${name}.cqueue${k}, fun t ht => bSN_sound (List.all_eq_true.mp ${name}.ctokSupp${k} t ht), ${name}.cbridge${k},${NL}`,
    `    liveShift_of ${name}.clive${k}, kernShift_of ${name}.ckern${k},${NL}`,
    `    pendReg_of rfl ${name}.cnh0${k} ${name}.cnh1${k} (Nat.le_of_ble_eq_true ${name}.cpendLe${k}) ${name}.cpendR${k}⟩${NL}${NL}`,
  ];
  // the defs and the small checks (a); the chunks; the assemblies, the shift and the observers (b)
  const cut = all.findIndex(l => l.startsWith("-- (the handle, node and primitive checks"));
  // the object checks in a module of their own (beside the chunks)
  const isObj = (l: string) => l.startsWith(`kernel_rfl ${name}.cobjs${k}`) || l.startsWith(`kernel_rfl ${name}.cobjok${k}`) ||
    l.startsWith("  (PTrie.keysA");
  const a = all.slice(0, cut);
  return { a: a.filter(l => !isObj(l)), chunks: [a.filter(isObj), ...hs.chunks, ...ns.chunks, ...ps.chunks], b: all.slice(cut + 1) };
}
// the native bookkeeping (`Conv.NClean`, A3's `host.sim.conv.NClean`): the start's full check (`<Name>.ncl0`), then
// every piece checks the native entries it changes or creates against its end's counters (`Conv.NClean.stepKeep`: keep
// facts and the check of the model states): glue piece `k` from its start to its call (`<Name>.gncl<k>`,
// module GlueN<k>), the compaction at site `k` from the call to the canonical state (`<Name>.cncl<k>`, SiteCl<k>);
// `<Name>.nclEnd` (NClAll) composes them to the chain's end
const cntL = (c: number[]) => `(⟨${c.join(", ")}⟩ : Conv.Cnt)`;
function nclStep(p: string, k: number, xa: string, xb: string, ca: number[], cb: number[], lh: string, ln: string, li: string,
    arrsOnly: boolean): string[] {
  const keep = (field: string, xs: string) =>
    `${xb}.${field} = Stage.setAll ${xa}.${field} (${xs}.filterMap fun i => (${xb}.${field}.get i).map (i, ·))`;
  const K = (fl: string) => `${name}.${p}k${fl}${k}`;
  // a compaction's objects, nodes and items keep facts are its closedness facts' (SiteK)
  const kO = arrsOnly ? `${name}.cobjsK${k}` : K("O"), kN = arrsOnly ? `${name}.cnodesK${k}` : K("N"), kI = arrsOnly ? `${name}.citemsK${k}` : K("I");
  return [
    `kernel_rfl ${K("A")} : ${keep("arrs", lh)}${NL}`,
    ...(arrsOnly ? [] : [`kernel_rfl ${kO} : ${keep("objs", lh)}${NL}`, `kernel_rfl ${kN} : ${keep("nodes", ln)}${NL}`,
      `kernel_rfl ${kI} : ${keep("items", li)}${NL}`]),
    `kernel_rfl ${name}.${p}bd${k} : (${lh} ++ ${ln} ++ ${li}).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true${NL}`,
    `kernel_rfl ${name}.${p}le${k} : Conv.Cnt.leB ${cntL(ca)} ${cntL(cb)} = true${NL}`,
    `kernel_rfl ${name}.${p}ck${k} : Conv.ncleanListB ${cntL(cb)} ${xb} ${lh} ${ln} ${li} = true${NL}`,
    `theorem ${name}.${p}ncl${k} (h : Conv.NClean ${cntL(ca)} ${xa}) : Conv.NClean ${cntL(cb)} ${xb} :=${NL}`,
    `  Conv.NClean.stepKeep h ${name}.${p}le${k} ${K("A")} ${kO} ${kN} ${kI} ${name}.${p}bd${k} ${name}.${p}ck${k}${NL}${NL}`];
}
// the framed arrays at `st` past the chain start's: the elements, the array's shape, `NumRefs` where all are references
function arrFacts(tag: string, st: string, arrs: { a: number; prefix: boolean; els: string[] }[] | undefined): string[] {
  if (!arrs) return [];
  const wideA = ((meta as { wide?: [number, string][] }).wide ?? []).map(([w]) => w);
  return arrs.filter(({ a }) => !wideA.includes(a)).flatMap(({ a, prefix, els }) => {
    if (!prefix || els.includes("none")) return [`-- ${a}: not the chain start's array extended${NL}`];
    const E = `${name}.arrEl${tag}_${a}`;
    const refs = els.every(e => e.startsWith("(Val.num (NumV.ref "));
    return [
      `def ${E} : List Val := [${els.join(", ")}]${NL}`,
      `kernel_rfl ${name}.arrE${tag}_${a} : arrOf ${st} ${a} = arrOf ${name}.s0 ${a} ++ ${E}${NL}`,
      `kernel_rfl ${name}.arrA${tag}_${a} : isArrB ${st} ${a} = true${NL}`,
      `theorem ${name}.arr${tag}_${a} : ∃ o, ${st}.heap.get ${a} = some (.obj o) ∧ o.kind = .array (arrOf ${name}.s0 ${a} ++ ${E}) :=${NL}`,
      `  arrExt_of ${name}.arrE${tag}_${a} ${name}.arrA${tag}_${a}${NL}`,
      ...(refs ? [`kernel_rfl ${name}.arrN${tag}_${a} : numRefsB ${name}.S0.tab.length ${E} = true${NL}`,
        `theorem ${name}.arrR${tag}_${a} : Prefill.NumRefs ${name}.S0.tab.length ${E} := numRefs_of ${name}.arrN${tag}_${a}${NL}`] : []),
      NL];
  });
}
// a glue piece's JS bookkeeping step (`Conv.JClean.step`): its JS heap off the changed and removed entries `jh`, checked
function jclStep(k: number, sa: string, sb: string, ca: number[], cb: number[], jh: number[]): string[] {
  const L = `${name}.gjh${k}`;
  const caL = `(⟨${ca.join(", ")}⟩ : Conv.Cnt)`, cbL = `(⟨${cb.join(", ")}⟩ : Conv.Cnt)`;
  return [
    `-- the JS bookkeeping's step${NL}`,
    `def ${L} : List Nat := [${jh.join(", ")}]${NL}`,
    `kernel_rfl ${name}.gjk${k} : ${sb}.heap = Stage.setAll ${sa}.heap (${L}.filterMap fun a => (${sb}.heap.get a).map (a, ·))${NL}`,
    `kernel_rfl ${name}.gjbd${k} : ${L}.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true${NL}`,
    `kernel_rfl ${name}.gjc${k} : Conv.jcleanListB ${cbL} ${sb} ${L} = true${NL}`,
    `theorem ${name}.gjcl${k} (h : Conv.JClean ${caL} ${sa}) : Conv.JClean ${cbL} ${sb} :=${NL}`,
    `  Conv.JClean.step h (Conv.Cnt.le_of_leB ${name}.gle${k})${NL}`,
    `    (Conv.heap_off_setAll ${name}.gjk${k} fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp ${name}.gjbd${k} a ha)) ${name}.gjc${k}${NL}${NL}`];
}
// a decode result's quantity by its form (`Conv.decQ 9`), from its Lean term
function decQOf(e: string): string | undefined {
  const one = "(SymE.lit (F64.fin false 1 (0)))";
  if (e === `(SymE.bin .add (SymE.var 9) ${one})`) return "e";
  if (e === "(SymE.un .int32 (SymE.var 9))") return "o";
  if (e === `(SymE.un .int32 (SymE.bin .add (SymE.var 9) ${one}))`) return "e";
  return undefined;
}
const headT = (...imps: string[]) => [...imps.map(i => `import ${i}${NL}`),
  `set_option Elab.async false${NL}namespace Host.Load.Run.Tpl${NL}set_option maxRecDepth 1000000${NL}set_option maxHeartbeats 0${NL}`,
  `open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template${NL}${NL}`];
const putT = (file: string, lines: string[]) => writeFileSync(join(here, dir, `${file}.lean`), [...lines, `end Host.Load.Run.Tpl${NL}`].join(""));
const sT = (i: number) => `${name}.s${i}`;
const hOf = (i: number) => mod(`H${Math.floor(i / per)}`);
// a chain whose start's token queue was replaced (plan "startTokens"): the start as its source's with the queue set
// (`Full.fullSetTokens`; `Full.RelF.dropTokens` takes the source's queue to the live tokens and the dropped suffix)
const stok = chain.startTokens as number[] | null | undefined;
if (stok && chain.source) {
  const src = chain.source as string;
  putT("S0Eq", [...headT(hOf(0), "host.sim.full.DropTokens"),
    `/-! The start of chain \`${name}\`: its source \`${src}\` with the mlx token queue set to its live tokens. -/${NL}${NL}`,
    `kernel_rfl ${name}.s0_tok : ${sT(0)} = ${src}.setFfi (Host.Ts.Sim.Full.fullSetTokens ${src}.ffi [${stok.map(r => `.ref ${r}`).join(", ")}])${NL}${NL}`]);
}
const nclMods: string[] = [];
let nclProof = "";
let jclProof = "JSTART";
// the bookkeeping at every piece's end: `<Name>.ncl<b>`, `<Name>.jcl<b>` (boundary b), the theorems' lines
const nclAt: string[] = [], jclAt: string[] = [];
const nclStmt = (c: number[], b: number) => `Conv.NClean ${cntL(c)} ${world.mlx(sT(b))}`;
const jclStmt = (c: number[], b: number) => `Conv.JClean ${cntL(c)} ${sT(b)}`;
const ncl0 = chain.ncl0 as { c: number[]; counts: number[] } | undefined;
if (ncl0) {
  const x0 = world.mlx(sT(0)), c0 = cntL(ncl0.c);
  const fs = [["arrs", "arrOldB", "a"], ["objs", "objOldB", "o"], ["nodes", "nodeOldB", "n"], ["items", "itemOldB", "i"]] as const;
  const parts = fs.map(([fl, chk, tag], j) =>
    chunked(`ncl0${tag}`, 0, `PTrie.keysA ${x0}.${fl}`, ncl0.counts[j]!, "all", l => `(${l}).all (Conv.${chk} ${c0} ${x0}) = true`));
  const cks = parts.flatMap(p => p.chunks);
  cks.forEach((lines, j) => putT(`NCl0c_${j}`, [...headT(hOf(0), "host.sim.conv.NClean"), ...lines]));
  putT("NCl0", [...headT(...cks.map((_, j) => caseMod0(`NCl0c_${j}`))),
    `/-! The native bookkeeping at the start of chain \`${name}\`: the full check (\`Conv.ncleanB\`), in chunks. -/${NL}${NL}`,
    ...parts.flatMap(p => p.assemble),
    `theorem ${name}.ncl0B : Conv.ncleanB ${c0} ${x0} = true := by${NL}`,
    `  simp only [Conv.ncleanB, ${fs.map(([, , tag]) => `${name}.ncl0${tag}0`).join(", ")}, Bool.and_self]${NL}`,
    `theorem ${name}.ncl0 : Conv.NClean ${c0} ${x0} := Conv.ncleanB_sound ${name}.ncl0B${NL}${NL}`]);
  nclMods.push("NCl0");
  nclProof = `${name}.ncl0`;
}
function caseMod0(file: string) { return `host.sim.template.${dir.replaceAll("/", ".")}.${file}`; }
for (const b of stages) {
  const ext = b as typeof b & { site: number; instance: string; T1: number; n0: number; ws: number[]; name: string; fn?: string };
  const iwide: [number, string][] = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${name}.st${ext.site}`, "stage.json"), "utf8")).wide ?? [];
  const k = ext.site;
  const inst = `${name}.st${k}`;
  const ipath = join(streams, `Host.Load.Run.Tpl.${inst}`, "stage.json");
  const hCall = mod(`H${Math.floor(b.ia / per)}`);
  run(["genStage.ts", `${dir}/st${k}`, inst, "--meta", ipath, "--world", w, "--states", `${mod("States")},${hCall}`]);
  const ia = b.ia, T = ext.T1;
  const s = (i: number) => `${name}.s${i}`, S = (i: number) => `${name}.S${i}`;
  const cp = (b as { compaction?: Comp | null }).compaction ?? undefined;
  const hAfter = mod(`H${Math.floor((ia + (cp ? 2 : 1)) / per)}`);
  // the site's facts, one module per piece (each a few kernel checks over the states: every module under the slot cap)
  const traceNew = (JSON.parse(readFileSync(ipath, "utf8")) as { traceNew?: number }).traceNew;
  const caseMod = (file: string) => `host.sim.template.${dir.replaceAll("/", ".")}.${file}`;
  const head = (...imps: string[]) => [...imps.map(i => `import ${i}${NL}`),
    `set_option Elab.async false${NL}namespace Host.Load.Run.Tpl${NL}set_option maxRecDepth 1000000${NL}set_option maxHeartbeats 0${NL}`,
    `open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template${NL}${NL}`];
  const put = (file: string, lines: string[]) => writeFileSync(join(here, dir, `${file}.lean`), [...lines, `end Host.Load.Run.Tpl${NL}`].join(""));
  const foot = caseMod(`st${k}.Foot`);
  put(`Site${k}`, [...head(hAfter, foot, "host.sim.conv.MergeSt", "host.sim.conv.Fresh"),
    `/-! Call site ${k} of chain \`${name}\`: \`${ext.name}\` (\`${ext.fn}\`), the call state \`${s(ia)}\`, the merged state \`${s(ia + 1)}\`,${NL}`,
    `the site template \`${inst}\` (σ = \`Map.id\`, θ the identity at its own site)${cp ? `, the canonical state \`${s(ia + 2)}\`` : ""}: the merge.${NL}`,
    `The footprint's facts are in \`SiteF${k}\`${cp ? `, the compaction's in \`SiteC${k}\`, \`SiteK${k}\`${w === "full" ? `, \`SiteNa${k}\`, \`SiteNb${k}\`` : ""}` : ""}. -/${NL}${NL}`,
    `kernel_rfl ${name}.iso${k} : ${inst}.s0 = { ${s(ia)} with stack := [] }${NL}`,
    `/-- The caller's frames at the call. -/${NL}noncomputable def ${name}.rs${k} : List Frame := ${s(ia)}.stack${NL}`,
    `kernel_rfl ${name}.n0_${k} : ${S(ia)}.tab.length = ${ext.n0}${NL}`,
    `kernel_rfl ${name}.tab0_${k} : ${inst}.S0.tab = ${S(ia)}.tab${NL}${NL}`,
    `/-- The fresh variables of the stage's results. -/${NL}def ${name}.ws${k} : List Nat := [${ext.ws.join(", ")}]${NL}`,
    `kernel_rfl ${name}.fresh${k} : (${S(ia)}.tab.all fun e => ${name}.ws${k}.all fun v => e.noVar v) &&${NL}`,
    `    (${S(ia)}.oracle.all fun q => ${name}.ws${k}.all fun v => q.noVar v) = true${NL}`,
    `kernel_rfl ${name}.mergeTab${k} : ${S(ia + 1)}.tab = ${S(ia)}.tab ++ Conv.resTab ${name}.ws${k}${NL}`,
    `kernel_rfl ${name}.mergeLen${k} : ${inst}.S${T}.tab.length - ${inst}.S0.tab.length = ${ext.ws.length}${NL}${NL}`,
    `-- The merged state is \`Conv.mergeSt\` at the instance's own site.${NL}`,
    `kernel_rfl ${name}.merge${k} : ${s(ia + 1)} = Conv.mergeSt Map.id (Map.id.res ${ext.n0} ${ext.n0}) ${name}.rs${k} ${inst}.wr ${s(ia)}${NL}`,
    `    ${inst}.s${T} ${inst}.s0 ${inst}.s${T}.ffi${NL}${NL}`]);
  // the footprint's facts (`Conv.site_merge`): distinct written entries (`nodupT`, linear), in the stores' range, the
  // stage's trace its new events (`traceNew` of them) before the call's
  const trFr = traceNew !== undefined ? `${inst}.s${T}.trace.take ${traceNew}`
    : `${inst}.s${T}.trace.take (${inst}.s${T}.trace.length - ${inst}.s0.trace.length)`;
  put(`SiteF${k}`, [...head(foot, "host.sim.template.NShiftOf", ...(iwide.length > 0 ? ["host.sim.template.FullShiftGen"] : [])),
    `/-! Call site ${k} of chain \`${name}\`: \`Conv.site_merge\`'s footprint facts. -/${NL}${NL}`,
    `kernel_rfl ${name}.wrNodupB${k} : nodupT ${inst}.wr PTrie.nil = true${NL}`,
    `theorem ${name}.wrNodup${k} : ${inst}.wr.Nodup := (nodupT_sound ${name}.wrNodupB${k}).2${NL}`,
    `kernel_rfl ${name}.wrBoundB${k} : ${inst}.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true${NL}`,
    `theorem ${name}.wrBound${k} : ∀ b ∈ ${inst}.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp ${name}.wrBoundB${k} b hb)${NL}`,
    `noncomputable def ${name}.trFr${k} := ${trFr}${NL}`,
    `kernel_rfl ${name}.traceEq${k} : ${inst}.s${T}.trace = ${name}.trFr${k} ++ ${inst}.s0.trace${NL}`,
    `theorem ${name}.trace${k} : ∃ fr, ${inst}.s${T}.trace = fr ++ ${inst}.s0.trace := ⟨_, ${name}.traceEq${k}${"⟩"}${NL}${NL}`,
    ...(iwide.length === 0 ? [] : [
      `-- the caller's wide frames at the instance's start (\`Conv.isolateW\`'s \`W0\` under \`Map.id\`) and their \`WFix\`${NL}`,
      `def ${name}.wide${k} : List (Nat × WFrame) := [${iwide.map(([a, t]) => `(${a}, ${t})`).join(", ")}]${NL}`,
      `kernel_rfl ${name}.wfixB${k} : (${name}.wide${k}.all fun p => wfixB Map.id (presentB ${inst}.s0) p.2) = true${NL}`,
      `theorem ${name}.wfix${k} : ∀ p ∈ ${name}.wide${k}, WFix Map.id (Present ${inst}.s0) p.2 :=${NL}`,
      `  fun p hp => wfix_of (List.all_eq_true.mp ${name}.wfixB${k} p hp)${NL}${NL}`])]);
  if (cp) {
    const c = s(ia + 2), mC = world.mlx(c), mM = world.mlx(s(ia + 1));
    const cnext = cp.xn0 + cp.plh.length;
    const nC = ext.n0 + cp.ws.length;
    put(`SiteC${k}`, [...head(hAfter, "host.sim.conv.Compact", "host.sim.native.RebigR", "host.sim.template.Sigma",
        "host.sim.template.NShiftGen", "host.sim.stage.Mlx"),
      `/-! The compaction after the merge at call site ${k} of chain \`${name}\` (\`Conv.compact\`, \`Conv.full_compactQ\`): the canonical${NL}`,
      `state \`${c}\` (the stage's results at canonical places, its trace the call's) under \`${name}.kappa${k}\` into the merged state${NL}`,
      `\`${s(ia + 1)}\`. -/${NL}${NL}`,
      `def ${name}.pl${k} : List Nat := [${cp.pl.join(", ")}]${NL}`,
      `def ${name}.nr${k} : List Nat := [${cp.nr.join(", ")}]${NL}`,
      `/-- The native part of the compaction map (canonical → merged handles and nodes: its \`big\`, \`region\`, \`nodeF\`). -/${NL}`,
      `def ${name}.kd${k} : RData :=${NL}`,
      `  ⟨${cp.fwd.n0}, ${cp.fwd.n1}, Stage.setAll PTrie.nil ${pairs(cp.fwd.heap)}, Stage.setAll PTrie.nil ${pairs(cp.fwd.hnd)},${NL}`,
      `   ${cp.fwd.nh0}, ${cp.fwd.nh1}, ${cp.fwd.nn0}, ${cp.fwd.nn1}, Stage.setAll PTrie.nil ${pairs(cp.fwd.node)},${NL}`,
      `   Stage.setAll PTrie.nil [${cp.nr.map((r, j) => `(${cp.nS + j}, .ref ${r})`).join(", ")}]⟩${NL}`,
      `/-- **The compaction map.** -/${NL}noncomputable def ${name}.kappa${k} : Map :=${NL}`,
      `  Conv.Map.compact ${cp.n0} ${cp.n1} ${cp.nS} ${name}.pl${k} (${name}.nr${k}.map NumV.ref) ${name}.kd${k}.big${NL}`,
      `    ${name}.kd${k}.region ${name}.kd${k}.nodeF${NL}`,
      `/-- The canonical result variables and their images, the merged state's entries (\`Conv.compactθ\`). -/${NL}`,
      `def ${name}.cws${k} : List Nat := [${cp.ws.join(", ")}]${NL}`,
      `noncomputable def ${name}.crs${k} : List SymE := ${name}.nr${k}.map fun r => (nth? ${S(ia + 1)}.tab r).getD (.var 0)${NL}`,
      `noncomputable def ${name}.ctheta${k} : Nat → SymE := Conv.compactθ ${name}.cws${k} ${name}.crs${k}${NL}`,
      `/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/${NL}`,
      `def ${name}.wrB${k} : List Nat := [${cp.wrB.join(", ")}]${NL}${NL}`,
      `kernel_rfl ${name}.ctab${k} : ${S(ia + 2)}.tab = ${S(ia)}.tab ++ ${name}.cws${k}.map SymE.var${NL}`,
      `kernel_rfl ${name}.ctrace${k} : ${c}.trace = ${s(ia)}.trace${NL}`,
      `kernel_rfl ${name}.cnext${k} : ${c}.next = ${cp.n0 + cp.pl.length}${NL}`,
      `kernel_rfl ${name}.ccounters${k} : (${mC}.next, ${mC}.nnext) = (${cnext}, ${cp.nn0 + cp.pln.length})${NL}`,
      `-- the merged state's readback queue, carried to the canonical state (\`Conv.FullShiftQ.tokens\`, \`tokSupp\`)${NL}`,
      `kernel_rfl ${name}.cqueue${k} : ${mM}.tokens = ${mC}.tokens.map ${name}.kappa${k}.nv${NL}`,
      `kernel_rfl ${name}.ctokSupp${k} : ${mC}.tokens.all (bSN ${nC}) = true${NL}`,
      `-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region${NL}`,
      `kernel_rfl ${name}.cclean${k} : Conv.cleanListB ${cnext} 131072 (fun r => Nat.ble ${4 * cnext} r) ${c}${NL}`,
      `    (${name}.wrB${k} ++ (List.range ${cp.pl.length}).map (${cp.n0} + ·)) = true${NL}`,
      `kernel_rfl ${name}.cbigs${k} : bigsOutB ${cnext} 131072 ${mC} = true${NL}${NL}`]);
    put(`SiteK${k}`, [...head(caseMod(`SiteC${k}`), "host.sim.conv.Closed"),
      ...closedFacts(k, cp, s(ia), c, nC, world.mlx(s(ia)), mC)]);
    const cc = cp as Comp & { cCall?: number[]; cCan?: number[]; removed?: number[] };
    if (cc.cCall && cc.cCan) {
      if (cc.removed?.length) console.log(`${name}: site ${k}: the compaction removes ${cc.removed.length} native entries (${cc.removed.slice(0, 8).join(", ")}…): no SiteCl${k}`);
      else put(`SiteCl${k}`, [...head(caseMod(`SiteK${k}`), "host.sim.conv.NClean"),
        ...nclStep(`c`, k, world.mlx(s(ia)), mC, cc.cCall, cc.cCan, `${name}.clo${k}`, `${name}.cln${k}`, `${name}.cli${k}`, true)]);
    }
    // the canonical results' values (the instance's end table at the result references) and the variables' disjointness
    const rsLean = (cp as { rsLean?: string[] }).rsLean;
    if (rsLean) put(`SiteD${k}`, [...head(caseMod(`Site${k}`), caseMod(`SiteC${k}`), "host.sim.conv.CallPieces"),
      `/-! The canonical results at call site ${k} of chain \`${name}\`: their values in the instance's end table, the references past${NL}`,
      `the call's table, the canonical variables apart from the stage's. -/${NL}${NL}`,
      `kernel_rfl ${name}.cderived${k} : ${name}.nr${k}.map (fun r => nth? ${inst}.S${T}.tab r) =${NL}  [${rsLean.map(e => `some ${e}`).join(`,${NL}   `)}]${NL}`,
      `kernel_rfl ${name}.cnrLo${k} : ${name}.nr${k}.all (Nat.ble ${(cp as { nS: number }).nS}) = true${NL}`,
      `kernel_rfl ${name}.cwsDisj${k} : ${name}.cws${k}.all (fun c => !${name}.ws${k}.contains c) = true${NL}`,
      // the results' quantities (A3's `Conv.decQ` at the decode offset variable 9: v9 + 1 and int32(v9 + 1) the end
      // quantity, int32(v9) the offset), where every result has such a form
      ...(rsLean.length && rsLean.every(e => decQOf(e) !== undefined) ? [
        `def ${name}.cqs${k} : List Host.Ts.Sim.Lin.Cls.Q := [${rsLean.map(e => `.${decQOf(e)}`).join(", ")}]${NL}`,
        `kernel_rfl ${name}.cqsEq${k} : ${name}.cqs${k} = (${name}.nr${k}.map (fun r => nth? ${inst}.S${T}.tab r)).map${NL}`,
        `  fun o => (o.bind (Conv.decQ 9)).getD .o${NL}`,
        `kernel_rfl ${name}.cdq${k} : (${name}.nr${k}.map (fun r => nth? ${inst}.S${T}.tab r)).all${NL}`,
        `  (fun o => (o.bind (Conv.decQ 9)).isSome) = true${NL}`] : []),
      `/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables${NL}`,
      `to \`0\` (\`Conv.compactθZ\`). -/${NL}`,
      `noncomputable def ${name}.cthetaZ${k} : Nat → SymE := Conv.compactθZ ${name}.cws${k} ${name}.crs${k} ${name}.ws${k}${NL}${NL}`]);
    // the call link's facts: the instance's server and footprint, the merged state's framed arrays past the chain start's
    const arrs = (b as { arrs?: { a: number; prefix: boolean; els: string[] }[] }).arrs;
    put(`SiteL${k}`, [...head(caseMod(`SiteF${k}`), "host.sim.template.CallGen"),
      `/-! The call link's facts at call site ${k} of chain \`${name}\`: the instance's start server, its footprint (\`Conv.StageFoot\`), the${NL}`,
      `merged state \`${s(ia + 1)}\`'s framed arrays as the chain start's extended (\`arrExt_of\`, \`numRefs_of\`). -/${NL}${NL}`,
      `kernel_rfl ${name}.srvO${k} : ${inst}.S0.oracle = ${inst}.O${NL}`,
      `kernel_rfl ${name}.wr0B${k} : ${inst}.wr.all (fun b => !Nat.blt b ${inst}.s0.next || (${inst}.s0.heap.get b).isSome) = true${NL}`,
      `theorem ${name}.stFoot${k} : Conv.StageFoot ${inst}.wr ${inst}.s0 ${inst}.s${T} :=${NL}`,
      `  stageFoot_of ${inst}.heapFoot ${name}.wrNodup${k} ${name}.wrBound${k} ${name}.wr0B${k} ${inst}.grows${NL}${NL}`,
      ...arrFacts(`${k}`, s(ia + 1), arrs)]);

    if (w === "full" && !chunksArg && cc.cCall) {
      const st = JSON.parse(readFileSync(ipath, "utf8")) as { wh: number[]; wi: number[] };
      put(`SiteS${k}`, [...head(caseMod(`SiteCl${k}`), "host.sim.conv.CompactFull", "host.sim.template.FootGen"),
        ...footFacts(k, cp, cc.cCall, c, s(ia + 1), s(ia), nC, mC, mM, st.wh, st.wi)]);
      if (cc.cCan) put(`SiteZ${k}`, [...head(caseMod(`SiteS${k}`), caseMod(`SiteK${k}`), caseMod(`SiteF${k}`), "host.sim.conv.CompactShift",
          "host.sim.template.Check", "host.sim.BigFreeP"), ...shiftDFacts(k, cp, cc.cCall, cc.cCan, s(ia), s(ia + 1), c, S(ia), S(ia + 1), nC, inst)]);
    } else if (w === "full") {
      const sf = shiftFacts(k, cp, c, s(ia + 1), nC, mC, mM);
      put(`SiteNa${k}`, [...head(caseMod(`SiteC${k}`), "host.sim.conv.CompactFull", "host.sim.template.NShiftOf"), ...sf.a]);
      sf.chunks.forEach((lines, j) => put(`SiteNc${k}_${j}`, [...head(caseMod(`SiteNa${k}`)), ...lines]));
      put(`SiteNb${k}`, [...head(...sf.chunks.map((_, j) => caseMod(`SiteNc${k}_${j}`)), "host.sim.template.FullShiftGen"), ...sf.b]);
    }
  }
  console.log(`${name}: site ${k} (${ext.name}) at boundary ${ia}: st${k}/, Site${k}, SiteF${k}${cp ? `, SiteC${k}, SiteK${k}, SiteCl${k}${w === "full" ? (chunksArg ? `, SiteNa${k}, SiteNb${k}` : `, SiteS${k}`) : ""}` : ""}`);
}
for (const pc of chain.pieces as { glue?: string; meta?: string; stage?: { site: number } }[]) {
  if (pc.stage) {
    const cb = stages.find(b => (b as unknown as { site: number }).site === pc.stage!.site) as unknown as { ia: number; compaction?: { cCall?: number[]; cCan?: number[]; removed?: number[] } };
    const kk = pc.stage.site, cpk = cb?.compaction;
    if (cpk?.cCall && cpk.cCan && !cpk.removed?.length) {
      nclMods.push(`SiteCl${kk}`); nclProof = `${name}.cncl${kk} (${nclProof})`;
      nclAt.push(`theorem ${name}.ncl${cb.ia + 2} : ${nclStmt(cpk.cCan, cb.ia + 2)} := ${name}.cncl${kk} ${name}.ncl${cb.ia}${NL}`);
    } else nclProof = "";
    if (cpk?.cCan && jclProof) {
      jclProof = `${name}.cjcl${kk} (${jclProof})`;
      jclAt.push(`theorem ${name}.jcl${cb.ia + 2} : ${jclStmt(cpk.cCan, cb.ia + 2)} := ${name}.cjcl${kk} ${name}.jcl${cb.ia}${NL}`);
    } else jclProof = "";
    continue;
  }
  if (!pc.meta) continue;
  const gj = JSON.parse(readFileSync(join(sdir, pc.meta), "utf8")) as { index: number; ncl?: { from: number; to: number; lh: number[];
    ln: number[]; li: number[]; ca: number[]; cb: number[]; removed: Record<string, number[]>; jh?: number[] } };
  const nc = gj.ncl, k = gj.index;
  if (!nc || nc.from === nc.to) continue;
  const rm = Object.entries(nc.removed).filter(([, l]) => l.length);
  if (rm.length) {
    console.log(`${name}: glue ${k}: removes native entries (${rm.map(([f, l]) => `${f} ${l.length}: ${l.slice(0, 6).join(", ")}`).join("; ")}): no GlueN${k}`);
    nclProof = "";
    jclProof = "";
    continue;
  }
  putT(`GlueN${k}`, [...headT(...new Set([hOf(nc.from), hOf(nc.to)]), "host.sim.conv.NClean", "host.sim.conv.CompactShift"),
    `/-! Glue piece ${k} of chain \`${name}\` (boundaries ${nc.from} to ${nc.to}): the native bookkeeping's step. -/${NL}${NL}`,
    `def ${name}.gh${k} : List Nat := [${nc.lh.join(", ")}]${NL}`,
    `def ${name}.gn${k} : List Nat := [${nc.ln.join(", ")}]${NL}`,
    `def ${name}.gi${k} : List Nat := [${nc.li.join(", ")}]${NL}`,
    ...nclStep("g", k, world.mlx(sT(nc.from)), world.mlx(sT(nc.to)), nc.ca, nc.cb, `${name}.gh${k}`, `${name}.gn${k}`, `${name}.gi${k}`, false),
    ...(nc.jh ? jclStep(k, sT(nc.from), sT(nc.to), nc.ca, nc.cb, nc.jh) : [])]);
  nclMods.push(`GlueN${k}`);
  if (nclProof) {
    nclProof = `${name}.gncl${k} (${nclProof})`;
    nclAt.push(`theorem ${name}.ncl${nc.to} : ${nclStmt(nc.cb, nc.to)} := ${name}.gncl${k} ${name}.ncl${nc.from}${NL}`);
  }
  if (jclProof && nc.jh) {
    jclProof = `${name}.gjcl${k} (${jclProof})`;
    jclAt.push(`theorem ${name}.jcl${nc.to} : ${jclStmt(nc.cb, nc.to)} := ${name}.gjcl${k} ${name}.jcl${nc.from}${NL}`);
  } else jclProof = "";
}
if (jstart && jclProof) {
  const T = meta.T1;
  putT("JClAll", [...headT(...nclMods.map(caseMod0), ...stages.map(b => caseMod0(`SiteZ${(b as unknown as { site: number }).site}`)), jstart[0]!),
    `/-! The JS bookkeeping of chain \`${name}\` at its end (boundary ${T}): the start's and every piece's step. -/${NL}${NL}`,
    `theorem ${name}.jcl0 : ${jclStmt(ncl0?.c ?? [], 0)} := ${jstart[1]}${NL}`, ...jclAt,
    `theorem ${name}.jclEnd : ∃ c, Conv.JClean c ${sT(T)} := ⟨_, ${name}.jcl${T}⟩${NL}${NL}`]);
  console.log(`${name}: JS bookkeeping: JClAll`);
}
if (nclProof && nclMods.length) {
  const T = meta.T1;
  putT("NClAll", [...headT(...nclMods.map(caseMod0)),
    `/-! The native bookkeeping of chain \`${name}\` at its end (boundary ${T}): the start's check and every piece's step. -/${NL}${NL}`,
    ...nclAt,
    `theorem ${name}.nclEnd : ∃ c, Conv.NClean c ${world.mlx(sT(T))} := ⟨_, ${name}.ncl${T}⟩${NL}${NL}`]);
  console.log(`${name}: native bookkeeping: ${nclMods.join(", ")}, NClAll`);
} else if (ncl0) console.log(`${name}: native bookkeeping: ${nclMods.join(", ")} (no composition: a piece without its step)`);
writeFileSync(join(sdir, "pieces.json"), JSON.stringify(chain.pieces, null, 1) + NL);
