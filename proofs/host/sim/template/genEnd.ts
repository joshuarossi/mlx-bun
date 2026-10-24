// Write the end modules of a prompt-route decode chain (`tpl_chain` from the decode template T, compacting at its calls)
// and, with --template, T's own facts.
// usage: bun proofs/host/sim/template/genEnd.ts <chain-dir> <Name> --base <T> --tdir <template-dir> [--template]
//          [--grow true|false] [--chunk n]
//   Reads $HOST_STREAM_DIR/Host.Load.Run.Tpl.<Name>/{chain.json,seg.json} (T1, endArrs, loadP) and, with --template,
//   Host.Load.Run.Tpl.<T>/template.json (start counters, frames).
// Template modules in <template-dir> (T's heap blocks, closedness, fresh range, counters; `EndGen`'s frames):
//   Keys (`tpl_keys T`), Closed (`T.cover`, `T.heapSupp`, `T.rootsSupp`, `T.presentBound` over `T.frames`), Fresh
//   (`T.noBigFresh`), Facts (`T.next_val` …, `T.noVar17`).
// Chain-end modules in <chain-dir> (the iteration's end at `<Name>.s<T1>` against `T.s0`, at `addrPrompt`):
//   ERestart (`tpl_restart <Name>.R : T, <Name> T1 (world := full)`, `σ`, `θ`, `S1'`), EHeap (`tpl_heap_blocks`), EShift
//   (`<Name>.shiftJS`: `ShiftJS` under `Ctx.unW wideP` for a context framed by `frA addrPrompt T.s0 (framesP T.s0 q).X`),
//   ENa/ENc_<j>/ENb (`<Name>.nshift : NShift P …`, `nshift_of` with the per-key checks in chunks), EFull
//   (`<Name>.fullShift : Full.FullShift P …`), EFacts (token reference, counters, `noVar 17`, θ, arrays, fixed
//   addresses, the frames' arrays kept), EEnd (`<Name>.iterEnd NB : Prefill.IterEndW (Full.fullWorld NB) addrPrompt P T.s0
//   T.S0.tab fixP`, its `ShiftFW (framesP T.s0 q) wideP`, `KeepsAtW`, and the hypothesis form `<Name>.endB`).
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const argv = process.argv.slice(2);
const take = (f: string): string | undefined => {
  const i = argv.indexOf(f);
  if (i < 0) return undefined;
  const v = argv[i + 1];
  if (v === undefined) throw new Error(`${f} needs a value`);
  argv.splice(i, 2);
  return v;
};
const flag = (f: string): boolean => {
  const i = argv.indexOf(f);
  if (i >= 0) argv.splice(i, 1);
  return i >= 0;
};
const T = take("--base") ?? "DT";
const tdir = take("--tdir") ?? "a4dec";
const grow = take("--grow") ?? "false";
const chunk = Number(take("--chunk") ?? 2000);
const withTemplate = flag("--template");
// the template's token queue (Lean term) and the banded relation's NL its recorded traces lie below
const tokens = take("--tokens") ?? "[.ref 79]";
const handNL = Number(take("--handNL") ?? 20000);
const [dir, X] = argv;
if (!dir || !X) throw new Error("usage: genEnd.ts <chain-dir> <Name> --base <T> --tdir <template-dir> [--template] [--grow b]");
const here = import.meta.dir;
const streams = process.env.HOST_STREAM_DIR ?? join(here, "..", "..", "..", ".host-stream");
const chain = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${X}`, "chain.json"), "utf8"));
const seg = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${X}`, "seg.json"), "utf8"));
const T1: number = chain.T1;
const lp: number[] = seg.loadP ?? chain.loadP ?? (() => { throw new Error("seg.json: no loadP"); })();
const NL = "\n";
const mod = (d: string, f: string) => `host.sim.template.${d.replaceAll("/", ".")}.${f}`;
const head = (...imps: string[]) => [...imps.map(i => `import ${i}${NL}`),
  `set_option Elab.async false${NL}namespace Host.Load.Run.Tpl${NL}open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template${NL}`,
  `set_option maxRecDepth 1000000${NL}set_option maxHeartbeats 0${NL}${NL}`];
const put = (d: string, file: string, lines: string[]) =>
  writeFileSync(join(here, d, `${file}.lean`), [...lines, `end Host.Load.Run.Tpl${NL}`].join(""));
const s1 = `${X}.s${T1}`, S1 = `${X}.S${T1}`, P = `${X}.PE`, sg = `${X}.σ`, S0s = `${X}.s0`;
// the end table de-canonicalized (chain.json "dtheta": the canonical result variables to their defining terms): the end
// facts' server `<Name>.S1D` (A3's host.sim.conv.Decanon relates it to the end cut's)
const dth = chain.dtheta as { ws: number[]; rs: string[]; endTab: string[] } | undefined;
const decanon = !!dth && dth.ws.length > 0;
const S1E = decanon ? `${X}.S1D` : S1;
const mlx = (s: string) => `(Host.Load.Layers.toLoad ${s}.ffi).mlx`;
const AP = "Host.Load.Run.Prompt.addrPrompt";
const frames = [2673448, 12504, 2665];
// the template start's counters (the bookkeeping's at the chain start)
const tstart = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${T}`, "template.json"), "utf8")).start as
  { n: number; next: number; mnext: number; nnext: number };
const c0L = `(⟨${tstart.mnext}, ${tstart.nnext}, ${tstart.next}, ${tstart.n}⟩ : Conv.Cnt)`;

// ---------- the template's facts ----------
if (withTemplate) {
  const tm = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${T}`, "template.json"), "utf8"));
  const st = tm.start as { n: number; next: number; mnext: number; nnext: number };
  if (JSON.stringify(tm.frames) !== JSON.stringify(frames)) throw new Error(`${T}: frames ${tm.frames}, expected ${frames}`);
  put(tdir, "Keys", [...head(mod(tdir, "S"), "host.sim.template.RestartCmd"),
    `/-! The template's unframed present addresses as explicit group chunks (\`${T}.gc<j>\`, \`${T}.gks\`); \`${T}.cover\`. -/${NL}${NL}`,
    `tpl_keys ${T}${NL}${NL}`]);
  put(tdir, "Closed", [...head(mod(tdir, "Keys"), "host.sim.template.Check", "host.sim.template.NShiftGen"),
    `/-! Closedness of the template \`${T}.s0\` (as \`base/Closed\`, its frames \`${T}.frames\`): every heap entry and the roots mention${NL}`,
    `only present addresses and the first \`${T}.n\` number references; present addresses lie below the counter. -/${NL}${NL}`,
    `abbrev ${T}.n : Nat := ${st.n}${NL}`,
    `kernel_rfl ${T}.tab_len : ${T}.S0.tab.length = ${T}.n${NL}`,
    `kernel_rfl ${T}.frames_eq : ${T}.frames = [${frames.join(", ")}]${NL}`,
    `noncomputable def ${T}.suppAt (a : Nat) : Bool :=${NL}  match ${T}.s0.heap.get a with${NL}`,
    `  | some h => bHobj (presentB ${T}.s0) ${T}.n h${NL}  | none => true${NL}`,
    `noncomputable def ${T}.boundAt (a : Nat) : Bool := Nat.blt a ${T}.s0.next${NL}${NL}`,
    `tpl_all_blocks ${T}.HS from ${T} : ${T}.suppAt${NL}`,
    `kernel_rfl ${T}.suppFramed : ${T}.frames.all ${T}.suppAt = true${NL}`,
    `tpl_all_blocks ${T}.BD from ${T} : ${T}.boundAt${NL}`,
    `kernel_rfl ${T}.boundFramed : ${T}.frames.all ${T}.boundAt = true${NL}`,
    `kernel_rfl ${T}.rootsSupp_check : checkRootsSupp ${T}.s0 ${T}.n = true${NL}${NL}`,
    `theorem ${T}.allPresent {p : Nat → Bool} (hb : ∀ q ∈ ${T}.gks, ∀ a ∈ q.2, p a = true) (hf : ${T}.frames.all p = true) :${NL}`,
    `    ∀ a, Present ${T}.s0 a → p a = true := by${NL}`,
    `  intro a ha${NL}  obtain ⟨h, hg⟩ := Present.get ha${NL}  by_cases hm : a ∈ ${T}.frames${NL}`,
    `  · exact List.all_eq_true.mp hf a hm${NL}  · obtain ⟨q, hq, haq⟩ := ${T}.cover a h hg hm${NL}    exact hb q hq a haq${NL}${NL}`,
    `theorem ${T}.heapSupp : ∀ a h, ${T}.s0.heap.get a = some h → Supp.hobj (Present ${T}.s0) ${T}.n h := by${NL}`,
    `  intro a h ha${NL}  have hp := ${T}.allPresent ${T}.HS.all ${T}.suppFramed a (Present.of_get ha)${NL}`,
    `  unfold ${T}.suppAt at hp${NL}  rw [ha] at hp${NL}  exact bHobj_sound hp${NL}${NL}`,
    `theorem ${T}.rootsSupp : Supp.ctl (Present ${T}.s0) ${T}.n ${T}.s0.ctl ∧${NL}`,
    `    (∀ f ∈ ${T}.s0.stack, Supp.frame (Present ${T}.s0) ${T}.n f) ∧${NL}`,
    `    (∀ j ∈ ${T}.s0.jobs, Supp.job (Present ${T}.s0) ${T}.n j) ∧ Supp.stores (Present ${T}.s0) ${T}.n ${T}.s0.stores :=${NL}`,
    `  checkRootsSupp_sound ${T}.rootsSupp_check${NL}${NL}`,
    `theorem ${T}.presentBound : ∀ a, Present ${T}.s0 a → a < ${T}.s0.next := by${NL}`,
    `  intro a ha${NL}  have := ${T}.allPresent ${T}.BD.all ${T}.boundFramed a ha${NL}  unfold ${T}.boundAt at this${NL}`,
    `  simpa [Nat.blt_eq] using this${NL}${NL}`]);
  put(tdir, "Fresh", [...head(mod(tdir, "Closed"), "host.sim.BigFree", "host.sim.native.RebigR"),
    `/-! The template start mentions no bigint in its fresh handle range \`[${st.mnext}, ${lp[1]})\` (\`Rel.rebig\`). -/${NL}${NL}`,
    `kernel_rfl ${T}.hnext : ${mlx(`${T}.s0`)}.next = ${st.mnext}${NL}`,
    `noncomputable def ${T}.freshAt (a : Nat) : Bool := noBigAtB ${st.mnext} ${lp[1]} ${T}.s0 a${NL}`,
    `tpl_all_blocks ${T}.FB from ${T} : ${T}.freshAt${NL}`,
    `kernel_rfl ${T}.freshFramed : ${T}.frames.all ${T}.freshAt = true${NL}`,
    `kernel_rfl ${T}.freshRoots : noBigRootsB ${st.mnext} ${lp[1]} ${T}.s0.trace ${T}.s0 = true${NL}`,
    `kernel_rfl ${T}.nativeFresh : bigsOutB ${st.mnext} ${lp[1]} ${mlx(`${T}.s0`)} = true${NL}`,
    `theorem ${T}.noBigFresh : NoBigSt (fun i => (${st.mnext} : Int) ≤ i ∧ i < ${lp[1]}) ${T}.s0.trace ${T}.s0 :=${NL}`,
    `  NoBigSt.of_checks (fun a ha => ${T}.allPresent ${T}.FB.all ${T}.freshFramed a ha) ${T}.freshRoots${NL}${NL}`]);
  put(tdir, "Facts", [...head(mod(tdir, "S"), "host.sim.Upd", "host.sim.template.NShiftOf"),
    `/-! The template's counters and its token reference; its table does not mention the look-ahead variable \`var 17\`. -/${NL}${NL}`,
    `kernel_rfl ${T}.next_val : ${T}.s0.next = ${st.next}${NL}`,
    `kernel_rfl ${T}.mnext_val : ${mlx(`${T}.s0`)}.next = ${st.mnext}${NL}`,
    `kernel_rfl ${T}.mnnext_val : ${mlx(`${T}.s0`)}.nnext = ${st.nnext}${NL}`,
    `kernel_rfl ${T}.tokens_val : ${mlx(`${T}.s0`)}.tokens = ${tokens}${NL}`,
    `-- the hand-off to the banded decode relation: every recorded trace node below its NL (${handNL})${NL}`,
    `kernel_rfl ${T}.handoff_check : (PTrie.keysA ${mlx(`${T}.s0`)}.objs).all (fun h => match ${mlx(`${T}.s0`)}.objs.get h with${NL}`,
    `  | some o => (objTraces o).all (fun i => Nat.blt i ${handNL}) | none => true) = true${NL}`,
    `theorem ${T}.handoff : ∀ h o, ${mlx(`${T}.s0`)}.objs.get h = some o → ∀ i ∈ objTraces o, i < ${handNL} := by${NL}`,
    `  intro h o ho i hi${NL}  have := List.all_eq_true.mp ${T}.handoff_check h (PTrie.mem_keysA _ _ _ ho)${NL}`,
    `  rw [ho] at this${NL}  exact Nat.blt_eq.mp (List.all_eq_true.mp this i hi)${NL}`,
    `kernel_rfl ${T}.noVar17_check : ${T}.S0.tab.all (SymE.noVar 17) = true${NL}`,
    `theorem ${T}.noVar17 : ∀ e ∈ ${T}.S0.tab, e.noVar 17 = true := List.all_eq_true.mp ${T}.noVar17_check${NL}${NL}`]);
  const c0 = `(⟨${st.mnext}, ${st.nnext}, ${st.next}, ${st.n}⟩ : Conv.Cnt)`;
  put(tdir, "JClean", [...head(mod(tdir, "Closed"), "host.sim.template.CallGen"),
    `/-! The JS bookkeeping at the template start (\`Conv.JClean\` at its counters): every present address checked, block by block. -/${NL}${NL}`,
    `noncomputable def ${T}.jcAt (a : Nat) : Bool := Conv.jcleanAtB ${c0} ${T}.s0 a${NL}`,
    `tpl_all_blocks ${T}.JC from ${T} : ${T}.jcAt${NL}`,
    `kernel_rfl ${T}.jcFramed : ${T}.frames.all ${T}.jcAt = true${NL}`,
    `theorem ${T}.jclean : Conv.JClean ${c0} ${T}.s0 :=${NL}`,
    `  jclean_of_present fun a ha => ${T}.allPresent ${T}.JC.all ${T}.jcFramed a ha${NL}${NL}`]);
  console.log(`${T}: Keys, Closed, Fresh, Facts, JClean written in ${tdir}`);
}

// ---------- the chain's end ----------
const lastH = mod(dir, `H${Math.floor(T1 / 32)}`);
put(dir, "ERestart", [...head(lastH, mod(tdir, "S"), "host.sim.template.RestartCmd", "host.sim.conv.Compact"),
  `/-! The restart map of chain \`${X}\`'s end (its start \`${S0s}\`, the template \`${T}\`'s with its readback suffix dropped, to${NL}`,
  `\`${s1}\`, the next readback cut), chosen natively. -/${NL}${NL}`,
  `def ${X}.frames : List Nat := ${T}.frames${NL}def ${X}.ghosts : List Nat := ${T}.ghosts${NL}def ${X}.maps : List Nat := ${T}.maps${NL}`,
  `kernel_rfl ${X}.S0_len : ${X}.S0.tab.length = ${tstart.n}${NL}`,
  ...(decanon ? [
    `/-- The canonical result variables and their defining terms; the end table with them substituted. -/${NL}`,
    `def ${X}.dvs : List Nat := [${dth!.ws.join(", ")}]${NL}`,
    `def ${X}.des : List SymE := [${dth!.rs.join(",\n  ")}]${NL}`,
    `def ${X}.dθ : Nat → SymE := Conv.compactθ ${X}.dvs ${X}.des${NL}`,
    `noncomputable def ${X}.S1D : SSrv := ⟨[${dth!.endTab.join(",\n  ")}], ${S1}.oracle⟩${NL}`,
    `kernel_rfl ${X}.dtab : ${S1}.tab.map (·.subst (Conv.compactθ ${X}.dvs ${X}.des)) = ${X}.S1D.tab${NL}${NL}`,
    `set_option maxRecDepth 1000000 in${NL}set_option maxHeartbeats 0 in${NL}`,
    `tpl_restart ${X}.R : ${X}, ${X} ${T1} (world := full, subst := ${X}.dθ)${NL}${NL}`] :
    [`set_option maxRecDepth 1000000 in${NL}set_option maxHeartbeats 0 in${NL}`, `tpl_restart ${X}.R : ${X}, ${X} ${T1} (world := full)${NL}${NL}`]),
  `noncomputable abbrev ${sg} : Map := ${X}.R.data.map${NL}`,
  `noncomputable def ${X}.θ : Nat → SymE := thetaOf ${X}.R.theta${NL}`,
  `/-- The end server with the next iteration's token reference appended (\`var 17\`). -/${NL}`,
  `noncomputable def ${X}.S1' : SSrv := ⟨${S1E}.tab ++ [.var 17], ${S1E}.oracle⟩${NL}`,
  `/-- The chain's load parameters (seg.json). -/${NL}`,
  `def ${P} : LoadP := ⟨${lp.join(", ")}, []⟩${NL}${NL}`]);
put(dir, "EHeap", [...head(mod(dir, "ERestart"), mod(tdir, "Keys")),
  `/-! The heap clause of chain \`${X}\`'s end shift, block by block. -/${NL}${NL}`,
  `tpl_heap_blocks ${X}.R from ${T} : ${sg}, ${S0s}, ${s1}${NL}${NL}`]);
const fr = frames.map((a, i) => ({ a, i: i + 1 }));
put(dir, "EShift", [...head(mod(dir, "EHeap"), mod(tdir, "Closed"), "host.sim.template.EndGen"),
  `/-! The JavaScript part of chain \`${X}\`'s end shift: \`${s1}\` holds a copy of \`${S0s}\` under \`${sg}\`, its numbers the template's${NL}`,
  `substituted by \`${X}.θ\`, the frames \`addrPrompt\`'s and \`framesP\`'s without the wide one. -/${NL}${NL}`,
  `kernel_rfl ${X}.num_check : checkNum ${sg} ${X}.θ ⟨${X}.S0.tab, []⟩ ${X}.S1' = true${NL}`,
  `kernel_rfl ${X}.nh0_check : Nat.ble ${lp[0]} ${X}.R.data.nh0 = true${NL}`,
  `kernel_rfl ${X}.ren_check : checkRen ${S0s} ${X}.R.data ${X}.R.inv = true${NL}`,
  `kernel_rfl ${X}.band_check : ${X}.R.data.checkBand ${lp[0]} = true${NL}`,
  `kernel_rfl ${X}.n0_eq : ${X}.R.data.n0 = ${S0s}.next${NL}`,
  `kernel_rfl ${X}.n1_eq : ${X}.R.data.n1 = ${s1}.next${NL}`,
  `kernel_rfl ${X}.grows_check : Nat.ble ${S0s}.next ${s1}.next = true${NL}`,
  `kernel_rfl ${X}.ctl_eq : ${s1}.ctl = ${sg}.ctl ${S0s}.ctl${NL}`,
  `kernel_rfl ${X}.stack_eq : ${s1}.stack = ${S0s}.stack.map ${sg}.frame${NL}`,
  `kernel_rfl ${X}.jobs_eq : ${s1}.jobs = ${S0s}.jobs.map ${sg}.job${NL}`,
  `kernel_rfl ${X}.stores_eq : ${s1}.stores = ${sg}.stores ${S0s}.stores${NL}`,
  `kernel_rfl ${X}.intr_check : (List.range 40).all (fun a => Nat.beq (${sg}.a a) a) = true${NL}`,
  ...fr.flatMap(({ a, i }) => [
    `kernel_rfl ${X}.f${i}a : ${sg}.a ${a} = ${a}${NL}`,
    `kernel_rfl ${X}.f${i}g0 : ${S0s}.heap.get ${a} = some (.obj (objOf ${S0s} ${a}))${NL}`,
    `kernel_rfl ${X}.f${i}k : (objOf ${S0s} ${a}).kind = .array (arrOf ${S0s} ${a})${NL}`,
    `kernel_rfl ${X}.f${i}g1 : ${s1}.heap.get ${a} = some (.obj { ${sg}.obj (objOf ${S0s} ${a}) with${NL}`,
    `  kind := .array (arrOf ${S0s} ${a} ++ (arrOf ${s1} ${a}).drop (arrOf ${S0s} ${a}).length) })${NL}`]),
  `${NL}/-- **The JavaScript part of the end shift**, for every context framed by \`frA addrPrompt\` with the prompt route's${NL}`,
  `further frames (any target prefixes) and the band \`[${lp[0]}, ${lp[1]})\`, its wide frame dropped. -/${NL}`,
  `theorem ${X}.shiftJS (q p1 p2 : List Val) (K : Host.Ts.Sim.Ctx)${NL}`,
  `    (hfr : K.fr = frA ${AP} ${S0s} (framesP ${S0s} q).X p1 p2) (hlo : K.lo = ${lp[0]}) (hhi : K.hi = ${lp[1]}) :${NL}`,
  `    ShiftJS Host.Load.Layers.full ${sg} ${X}.θ (K.unW wideP) ${S0s} ⟨${X}.S0.tab, []⟩ ${s1} ${X}.S1' where${NL}`,
  `  num := checkNum_sound ${X}.num_check${NL}`,
  `  heap := by${NL}    intro a h ha hk${NL}    have hm := frP_none hfr hk${NL}`,
  `    rw [← ${T}.frames_eq] at hm${NL}    obtain ⟨q', hq, haq⟩ := ${T}.cover a h ha hm${NL}`,
  `    rw [${X}.R.heapAt q' hq a haq, ha]${NL}    rfl${NL}`,
  `  framed := by${NL}    intro a pre pre' hk${NL}`,
  `    rcases frP_some hfr hk with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩${NL}`,
  ...fr.map(({ a, i }) => `    · exact ⟨${X}.f${i}a, objOf ${S0s} ${a}, _, ${X}.f${i}g0, ${X}.f${i}k, ${X}.f${i}g1⟩${NL}`),
  `  next := by${NL}    intro k${NL}    show ${X}.R.data.a (${S0s}.next + k) = _${NL}`,
  `    rw [← ${X}.n0_eq, RData.a_fresh, ${X}.n1_eq]${NL}`,
  `  grows := Nat.le_of_ble_eq_true ${X}.grows_check${NL}`,
  `  present := by${NL}    intro a hp${NL}    obtain ⟨h, ha⟩ := Present.get hp${NL}`,
  `    by_cases hf : a ∈ [${frames.join(", ")}]${NL}`,
  `    · simp only [List.mem_cons, List.not_mem_nil, or_false] at hf${NL}`,
  `      rcases hf with rfl | rfl | rfl${NL}`,
  ...fr.map(({ i }) => `      · rw [${X}.f${i}a]; exact Present.of_get ${X}.f${i}g1${NL}`),
  `    · rw [← ${T}.frames_eq] at hf${NL}      obtain ⟨q', hq, haq⟩ := ${T}.cover a h ha hf${NL}`,
  `      have := ${X}.R.heapAt q' hq a haq${NL}      rw [ha] at this${NL}      exact Present.of_get this${NL}`,
  `  inj := a_inj (fun x hx => by rw [${X}.n0_eq]; exact ${T}.presentBound x hx) ${X}.ren_check${NL}`,
  `  presentBound := ${T}.presentBound${NL}`,
  `  framedPresent := by${NL}    intro a p hk${NL}    obtain ⟨pre, pre'⟩ := p${NL}`,
  `    rcases frP_some hfr hk with ⟨rfl, _⟩ | ⟨rfl, _⟩ | ⟨rfl, _⟩${NL}`,
  ...fr.map(({ i }) => `    · exact Present.of_get ${X}.f${i}g0${NL}`),
  `  ctl := ${X}.ctl_eq${NL}  stack := ${X}.stack_eq${NL}  jobs := ${X}.jobs_eq${NL}  stores := ${X}.stores_eq${NL}`,
  `  heapSupp := by rw [show (⟨${X}.S0.tab, []⟩ : SSrv).tab.length = ${T}.n from ${X}.S0_len]; exact ${T}.heapSupp${NL}`,
  `  ctlSupp := by rw [show (⟨${X}.S0.tab, []⟩ : SSrv).tab.length = ${T}.n from ${X}.S0_len]; exact ${T}.rootsSupp.1${NL}`,
  `  stackSupp := by rw [show (⟨${X}.S0.tab, []⟩ : SSrv).tab.length = ${T}.n from ${X}.S0_len]; exact ${T}.rootsSupp.2.1${NL}`,
  `  jobsSupp := by rw [show (⟨${X}.S0.tab, []⟩ : SSrv).tab.length = ${T}.n from ${X}.S0_len]; exact ${T}.rootsSupp.2.2.1${NL}`,
  `  storesSupp := by rw [show (⟨${X}.S0.tab, []⟩ : SSrv).tab.length = ${T}.n from ${X}.S0_len]; exact ${T}.rootsSupp.2.2.2${NL}`,
  `  bigFixed := by${NL}    show ∀ i, BigFixed K.lo K.hi i → _${NL}    rw [hlo, hhi]${NL}`,
  `    exact RData.big_fixed _ ${X}.band_check (Nat.le_of_ble_eq_true ${X}.nh0_check) (by decide)${NL}`,
  `  bigExt := RData.big_ext _${NL}`,
  `  intr := by${NL}    intro a ha${NL}    have := ${X}.intr_check${NL}`,
  `    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this${NL}    exact this a ha${NL}${NL}`]);

// the native shift: the per-key checks in chunks (as genChain's)
const x0 = `${X}.X0`, x1 = `${X}.X1`, D = `${X}.R.data`;
const ck = (nm: string, stmt: string) => `kernel_rfl ${X}.n${nm} : ${stmt}${NL}`;
function chunked(nm: string, list: string, n: number, kind: "all" | "map", stmt: (l: string) => string) {
  const m = Math.max(1, Math.ceil(n / chunk));
  let l = list;
  const ls: string[] = [];
  for (let j = 0; j <= m; j++) { ls.push(l); l = `(${l}).drop ${chunk}`; }
  const chunks = Array.from({ length: m }, (_, j) => [`kernel_rfl ${X}.n${nm}_${j} : ${stmt(`(${ls[j]}).take ${chunk}`)}${NL}`]);
  const step = kind === "all" ? "all_take_drop" : "map_take_drop", nil = kind === "all" ? "all_of_nil" : "map_of_nil";
  let proof = `${nil} ${X}.n${nm}_end`;
  for (let j = m - 1; j >= 0; j--) proof = `${step} ${chunk} ${X}.n${nm}_${j} (${proof})`;
  return { chunks, assemble: [`kernel_rfl ${X}.n${nm}_end : ${ls[m]} = []${NL}`, `theorem ${X}.n${nm} : ${stmt(list)} :=${NL}  ${proof}${NL}`] };
}
// the template start is the chain start (boundary 0): its key counts are the bookkeeping start check's
const counts: number[] = chain.ncl0?.counts ?? [32000, 4000, 25000];
const hs = chunked("handles", `handlesOfA ${x0}`, counts[0]! + counts[1]!, "all", l => `(${l}).all (handleOK ${sg} ${P}.lo ${x0} ${x1}) = true`);
const ns = chunked("nodes", `PTrie.keysA ${x0}.nodes`, counts[2]!, "all", l => `(${l}).all (nodeOKF ${sg} ${P} ${x0} ${x1}) = true`);
const ps = chunked("prims", `fullKeysF ${P} ${x0}`, counts[2]!, "map", l =>
  `(${l}).map (fun i => (${x1}.nodes.get (${sg}.node i)).map Host.Mlx.Ffi.Node.prim) =${NL}  (${l}).map (fun i => (${x0}.nodes.get i).map fun nd => ${sg}.prim nd.prim)`);
const fields = ["nh0", "nh1", "nn0", "nn1", "lo", "cnt", "nband", "hbelow", "handles", "hren", "band", "nh1pos", "objs", "objok",
  "nodes", "prims", "nren", "nlow", "nord", "items", "ssT", "abs0a", "abs0b", "tok1", "pend", "errh", "files", "arch", "sizes", "wired"];
put(dir, "ENa", [...head(mod(dir, "ERestart"), mod(tdir, "Closed"), "host.sim.template.NShiftOf"),
  `/-! The native part of chain \`${X}\`'s end shift (\`NShift ${P}\` on \`toLoad\`, \`nshift_of\`): the small checks. -/${NL}${NL}`,
  `noncomputable abbrev ${x0} : NSt := ${mlx(`${S0s}`)}${NL}`,
  `noncomputable abbrev ${x1} : NSt := ${mlx(s1)}${NL}${NL}`,
  ck("nh0", `${D}.nh0 = ${x0}.next`), ck("nh1", `${D}.nh1 = ${x1}.next`), ck("nn0", `${D}.nn0 = ${x0}.nnext`),
  ck("nn1", `${D}.nn1 = ${x1}.nnext`),
  ck("lo", `(Nat.blt 0 ${P}.lo && Nat.ble ${P}.lo ${x0}.next && Nat.ble ${P}.lo RData.bigHi && Nat.ble RData.bigHi ${P}.E) = true`),
  ck("cnt", `(Nat.ble ${x0}.next ${x1}.next && Nat.ble ${x0}.nnext ${x1}.nnext) = true`),
  ck("nband", `(Nat.blt 0 ${P}.NL && Nat.ble ${P}.NL ${P}.N0 && Nat.ble ${P}.N0 ${x0}.nnext) = true`),
  ck("hbelow", `${D}.checkHndBelow = true`),
  ck("hren", `checkRenG ${D}.hnd ${X}.R.hinv (phB ${x0}) = true`),
  ck("band", `${D}.checkBand ${P}.lo = true`), ck("nh1pos", `Nat.blt 0 ${D}.nh1 = true`),
  ck("nren", `checkRenG ${D}.node ${X}.R.ninv (pnB ${x0}) = true`),
  ck("nlow", `(PTrie.keysA ${D}.node).all (fun j => Nat.ble ${P}.NL j && Nat.blt (${D}.nodeF j) ${x1}.nnext) = true`),
  ck("nord", `(fullAbove ${P} ${x0}).all (fun i => Nat.ble i (${D}.nodeF i) &&${NL}  (PTrie.keysA ${D}.node).all fun j => !Nat.blt j i || Nat.blt (${D}.nodeF j) (${D}.nodeF i)) = true`),
  ck("items", `(PTrie.keysA ${x0}.items).all (pnB ${x0}) = true`), ck("ssT", `checkSSt ${T}.n ${x0} = true`),
  ck("abs0a", `${x0}.arrs.get 0 = none`), ck("abs0b", `${x0}.objs.get 0 = none`), ck("tok1", `${x1}.tokens = []`),
  ck("pend", `${x1}.pending = ${x0}.pending.map ${sg}.pend`), ck("errh", `${x1}.errh = ${x0}.errh.map ${sg}.arg`),
  ck("files", `${x1}.files = ${x0}.files`), ck("arch", `${x1}.arch = ${x0}.arch`),
  ck("sizes", `${x1}.deviceSizes = ${x0}.deviceSizes`), ck("wired", `${x1}.wired = ${x0}.wired`),
  ck("host", `(Host.Load.Layers.toLoad ${s1}.ffi).host = (Host.Load.Layers.toLoad ${S0s}.ffi).host`), NL]);
const cks = [[ck("objs", `(PTrie.keysA ${x0}.objs).map (fun h => ${x1}.objs.get (${sg}.handle h)) =${NL}  (PTrie.keysA ${x0}.objs).map (fun h => (${x0}.objs.get h).map ${sg}.nobj)`),
  ck("objok", `(PTrie.keysA ${x0}.objs).all (objOK ${sg} ${P}.NL ${x0}) = true`)], ...hs.chunks, ...ns.chunks, ...ps.chunks];
cks.forEach((lines, j) => put(dir, `ENc_${j}`, [...head(mod(dir, "ENa")), ...lines]));
put(dir, "ENb", [...head(...cks.map((_, j) => mod(dir, `ENc_${j}`))),
  ...hs.assemble, ...ns.assemble, ...ps.assemble,
  `${NL}/-- **The native shift of chain \`${X}\`'s end** on the load-world projections. -/${NL}`,
  `theorem ${X}.nshift : NShift ${P} ${X}.S0.tab.length ${sg} (Host.Load.Layers.toLoad ${S0s}.ffi)${NL}`,
  `    (Host.Load.Layers.toLoad ${s1}.ffi) := by${NL}  rw [${X}.S0_len]${NL}`,
  `  exact nshift_of ⟨rfl, rfl, rfl, ${fields.map(f => `${X}.n${f}`).join(", ")}⟩ ${X}.nhost fun _ => rfl${NL}${NL}`]);
put(dir, "EFull", [...head(mod(dir, "ENb"), "host.sim.template.FullShiftGen"),
  `/-! The full world's shift of chain \`${X}\`'s end (\`Full.FullShift\`): the load world's, the bridge kept, the observers. -/${NL}${NL}`,
  `kernel_rfl ${X}.bridge_eq : Host.Ts.Sim.Full.bridgeOf ${s1}.ffi = Host.Ts.Sim.Full.bridgeOf ${S0s}.ffi${NL}`,
  `kernel_rfl ${X}.live_check : liveShiftB ${sg} (Host.Ts.Sim.Full.mlxOf ${S0s}.ffi) (Host.Ts.Sim.Full.freedOf ${S0s}.ffi)${NL}`,
  `    (Host.Ts.Sim.Full.freedOf ${s1}.ffi) = true${NL}`,
  `kernel_rfl ${X}.kern_check : kernShiftB ${sg} ${X}.S0.tab.length (Host.Ts.Sim.Full.mlxOf ${S0s}.ffi)${NL}`,
  `    (Host.Ts.Sim.Full.krecOf ${S0s}.ffi) (Host.Ts.Sim.Full.krecOf ${s1}.ffi) = true${NL}`,
  `kernel_rfl ${X}.pend_check : pendRegB ${sg} (Host.Ts.Sim.Full.mlxOf ${S0s}.ffi) = true${NL}`,
  `kernel_rfl ${X}.pend_le : Nat.ble ${x0}.next ${x1}.next = true${NL}${NL}`,
  `theorem ${X}.fullShift : Host.Ts.Sim.Full.FullShift ${P} ${X}.S0.tab.length ${sg} ${S0s}.ffi ${s1}.ffi :=${NL}`,
  `  fullShift_of ${X}.nshift ${X}.bridge_eq ${X}.live_check ${X}.kern_check${NL}`,
  `    (pendReg_of rfl ${X}.nnh0 ${X}.nnh1 (Nat.le_of_ble_eq_true ${X}.pend_le) ${X}.pend_check)${NL}${NL}`]);
// the facts: arrays from chain.json's endArrs
const ea = chain.endArrs as { a: number; prefix: boolean; els: string[] }[];
const el = (a: number) => {
  const e = ea.find(x => x.a === a);
  if (!e || !e.prefix || e.els.includes("none")) throw new Error(`${X}: array ${a} at the end is not the template's extended`);
  return `[${e.els.join(", ")}]`;
};
put(dir, "EFacts", [...head(mod(dir, "ERestart"), mod(dir, "S0Eq"), mod(tdir, "Facts"), mod(tdir, "JClean"), "host.sim.template.FactsGen",
    "host.sim.template.CallGen", "host.sim.template.EndGen"),
  `/-! The facts of chain \`${X}\`'s end the iteration consumes (\`Prefill.IterEndW\` apart from its shift): the token reference,${NL}`,
  `the end counter, freshness of \`var 17\`, the substitution, the framed arrays past the template's, the fixed addresses. -/${NL}${NL}`,
  `-- the chain's start: the template's with its readback suffix dropped (genChain's S0Eq: \`${X}.s0_tok\`), its token the live one${NL}`,
  `kernel_rfl ${X}.tokens_val : ${mlx(S0s)}.tokens = [.ref 79]${NL}`,
  `kernel_rfl ${X}.S0_tab : ${X}.S0.tab = ${T}.S0.tab${NL}`,
  `/-- The JS bookkeeping at the chain start (genChain --jstart). -/${NL}`,
  `theorem ${X}.jclean0 : Conv.JClean ${c0L} ${S0s} := by rw [${X}.s0_tok]; exact ${T}.jclean${NL}`,
  `kernel_rfl ${X}.num79 : ${sg}.num 79 = .ref ${S1E}.tab.length${NL}`,
  `kernel_rfl ${X}.hE_check : Nat.blt ${mlx(s1)}.next ${lp[1]} = true${NL}`,
  `theorem ${X}.hE : ${mlx(s1)}.next < ${lp[1]} := Nat.le_of_ble_eq_true ${X}.hE_check${NL}`,
  `kernel_rfl ${X}.tlen_check : Nat.ble ${X}.S0.tab.length ${S1E}.tab.length = true${NL}`,
  `kernel_rfl ${X}.noVarTab_check : ${S1E}.tab.all (SymE.noVar 17) = true${NL}`,
  `kernel_rfl ${X}.noVarOr_check : ${S1E}.oracle.all (Ans.noVar 17) = true${NL}`,
  `theorem ${X}.noVarTab : ∀ e ∈ ${S1E}.tab, e.noVar 17 = true := List.all_eq_true.mp ${X}.noVarTab_check${NL}`,
  `theorem ${X}.noVarOr : ∀ q ∈ ${S1E}.oracle, q.noVar 17 = true := List.all_eq_true.mp ${X}.noVarOr_check${NL}`,
  `kernel_rfl ${X}.theta_low : (List.range 18).all (fun j => decide (${X}.θ j = loopTheta ${grow} 17 j)) = true${NL}`,
  `kernel_rfl ${X}.theta_keys : ${X}.R.theta.all (fun p => Nat.blt p.1 18) = true${NL}`,
  `theorem ${X}.theta : ∀ j, ${X}.θ j = loopTheta ${grow} 17 j := theta_eq ${X}.theta_low ${X}.theta_keys${NL}`,
  `/-- The forwarded and emitted arrays' elements past the template's. -/${NL}`,
  `def ${X}.xs : List Val := ${el(2673448)}${NL}def ${X}.eR : List Val := ${el(12504)}${NL}`,
  ...[[2673448, `${X}.xs`, "fwd"], [12504, `${X}.eR`, "emit"], [2665, "[]", "prompt"]].flatMap(([a, e, nm]) => [
    `kernel_rfl ${X}.${nm}E : arrOf ${s1} ${a} = arrOf ${S0s} ${a} ++ ${e}${NL}`,
    `kernel_rfl ${X}.${nm}A : isArrB ${s1} ${a} = true${NL}`,
    `theorem ${X}.${nm} : ∃ o, ${s1}.heap.get ${a} = some (.obj o) ∧ o.kind = .array (arrOf ${S0s} ${a} ++ ${e}) :=${NL}`,
    `  arrExt_of ${X}.${nm}E ${X}.${nm}A${NL}`]),
  `kernel_rfl ${X}.fix_check : fixP.all (fun a => Nat.beq (${sg}.a a) a) = true${NL}`,
  `theorem ${X}.fix : ∀ a ∈ fixP, ${sg}.a a = a := fun a ha => by${NL}`,
  `  have := List.all_eq_true.mp ${X}.fix_check a ha${NL}  simpa using this${NL}`,
  `-- the wide frame's address fixed and present`,
  `${NL}kernel_rfl ${X}.w4910a : ${sg}.a 4910 = 4910${NL}`,
  `kernel_rfl ${X}.w4910p : (${S0s}.heap.get 4910).isSome = true${NL}`,
  `kernel_rfl ${X}.w4910f : wfixB ${sg} (presentB ${S0s}) (WFrame.memo []) = true${NL}`,
  `-- the wide frame holds no array at the end (its frame keeps no prefix)${NL}`,
  `kernel_rfl ${X}.w4910k : isArrB ${s1} 4910 = false${NL}${NL}`]);
put(dir, "EEnd", [...head(mod(dir, "EShift"), mod(dir, "EFull"), mod(dir, "EFacts"), "host.sim.full.World"),
  `/-! Chain \`${X}\`'s end as a decode iteration's end (\`Prefill.IterEndW\` at \`addrPrompt\`, \`${P}\`, \`fixP\`), its shift under the${NL}`,
  `prompt route's frames (\`framesP\`, \`wideP\`), the frames' arrays kept, and the hypothesis form \`${X}.endB\`. -/${NL}${NL}`,
  `noncomputable def ${X}.iterEnd (NB : Nat) :${NL}`,
  `    Host.Ts.Sim.Prefill.IterEndW (Host.Ts.Sim.Full.fullWorld NB) ${AP} ${P} ${S0s} ${X}.S0.tab fixP where${NL}`,
  `  s1 := ${s1}${NL}  S1 := ${S1E}${NL}  σ := ${sg}${NL}  θ := ${X}.θ${NL}  grow := ${grow}${NL}  xs := ${X}.xs${NL}  eR := ${X}.eR${NL}`,
  `  tlen := Nat.le_of_ble_eq_true ${X}.tlen_check${NL}  noVarTab := ${X}.noVarTab${NL}  noVarOr := ${X}.noVarOr${NL}`,
  `  nshift := ${X}.fullShift${NL}  num := ${X}.num79${NL}  hE := ${X}.hE${NL}  theta := ${X}.theta${NL}`,
  `  fwd := ${X}.fwd${NL}  emit := ${X}.emit${NL}  fix := ${X}.fix${NL}${NL}`,
  `theorem ${X}.shiftFW (NB : Nat) (q : List Val) : (${X}.iterEnd NB).ShiftFW (framesP ${S0s} q) wideP := by${NL}`,
  `  refine ⟨fun p1 p2 K hfr hlo hhi => ${X}.shiftJS q p1 p2 K hfr hlo hhi, fun a w hw => ?_⟩${NL}`,
  `  have ha : a = 4910 := by${NL}    unfold wideP at hw${NL}    cases h : Nat.beq a 4910${NL}`,
  `    · rw [h] at hw; cases hw${NL}    · exact Nat.eq_of_beq_eq_true h${NL}`,
  `  subst ha${NL}  have hw' : w = .memo [] := by simp [wideP] at hw; exact hw.symm${NL}  subst hw'${NL}`,
  `  exact ⟨by show 4910 ∈ [2665, 4910]; decide, ${X}.w4910a, ${X}.w4910p, wfix_of ${X}.w4910f⟩${NL}${NL}`,
  `theorem ${X}.keep (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP ${S0s} q) ${s1} := by${NL}`,
  `  intro a pre pre' hx o es ho hk${NL}  unfold framesP at hx${NL}  simp only at hx${NL}`,
  `  cases h1 : Nat.beq a 2665${NL}  · cases h2 : Nat.beq a 4910${NL}    · rw [h1, h2] at hx; cases hx${NL}`,
  `    · have := Nat.eq_of_beq_eq_true h2; subst this${NL}      rw [h1, h2] at hx; cases hx${NL}`,
  `      exact (notArr_of ${X}.w4910k ho hk).elim${NL}`,
  `  · have := Nat.eq_of_beq_eq_true h1; subst this${NL}    rw [h1] at hx; cases hx${NL}`,
  `    obtain ⟨o', ho', hk'⟩ := ${X}.prompt${NL}    rw [ho] at ho'; cases ho'${NL}    rw [hk'] at hk; cases hk${NL}    simp${NL}${NL}`,
  `/-- **The end in the hypothesis form** (\`A\`, the further frames, the wide frames, the fixed addresses given). -/${NL}`,
  `theorem ${X}.endB {NB : Nat} {A : Addr} {Fr : LoopFramesA A} {W : Nat → Option WFrame} {fixA : List Nat} (q : List Val)${NL}`,
  `    (hA : A = ${AP}) (hfr : HEq Fr (framesP ${S0s} q)) (hW : W = wideP) (hfix : fixA = fixP) :${NL}`,
  `    ∃ e : Host.Ts.Sim.Prefill.IterEndW (Host.Ts.Sim.Full.fullWorld NB) A ${P} ${S0s} ${X}.S0.tab fixA,${NL}`,
  `      e.s1 = ${s1} ∧ e.S1 = ${S1E} ∧ e.eR = ${X}.eR ∧ e.ShiftFW Fr W ∧ Host.Ts.Sim.Prefill.KeepsAtW Fr e.s1 := by${NL}`,
  `  subst hA hW hfix${NL}  cases hfr${NL}`,
  `  exact ⟨${X}.iterEnd NB, rfl, rfl, rfl, ${X}.shiftFW NB q, ${X}.keep q⟩${NL}${NL}`]);
console.log(`${X}: ERestart, EHeap, EShift, ENa, ENc_0..${cks.length - 1}, ENb, EFull, EFacts, EEnd written in ${dir}`);
