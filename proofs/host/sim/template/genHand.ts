// POST's hand-off: the modules of `Host.Route.PrefGraph.HandWalk` from the decode template into POST's end.
// usage: bun genHand.ts <dir> <T> <tdir> <X> <end> [--pd lo,E,NE,NL,N0]
//   Walk (`tpl_restart_hand`, chosen natively), Base (the end as the hand-off uses it), Keys, Closed, Fresh, Heap, Na, Nc_<j>, Nb, Full, K<j>, Hand (`Hand.walk`).
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const argv = process.argv.slice(2);
const pdAt = argv.indexOf("--pd");
const pd = pdAt >= 0 ? argv.splice(pdAt, 2)[1]!.split(",") : ["18151", "131072", "2 ^ 40", "20000", "22539"];
const [dir, T, tdir, X, Ti] = argv as [string, string, string, string, string];
if (!Ti) throw new Error("usage: genHand.ts <dir> <T> <tdir> <X> <end>");
const here = import.meta.dir, NL = "\n", streams = process.env.HOST_STREAM_DIR!;
const tm = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${T}`, "template.json"), "utf8"));
const st = tm.start as { n: number; next: number; mnext: number; nnext: number };
const seg = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${X}`, "seg.json"), "utf8"));
const xdir = process.env.HAND_XDIR ?? (() => { throw new Error("HAND_XDIR: the end's chain directory"); })();
if (seg.T1 !== +Ti) throw new Error(`${X}: T1 ${seg.T1}, not ${Ti}`);
mkdirSync(join(here, dir), { recursive: true });
const mod = (f: string) => `host.sim.template.${dir}.${f}`;
const head = (...imps: string[]) => imps.map(i => `import ${i}${NL}`).join("") +
  `set_option Elab.async false${NL}namespace Host.Load.Run.Tpl${NL}open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Route${NL}` +
  `set_option maxRecDepth 1000000${NL}set_option maxHeartbeats 0${NL}${NL}`;
const put = (file: string, body: string) => writeFileSync(join(here, dir, file + ".lean"), body + NL + "end Host.Load.Run.Tpl" + NL);
const s0 = `${T}.s0`, S0 = `${T}.S0`, sE = `${X}.s${Ti}`, SE = `${X}.S${Ti}`, s1 = "Hand.t";
const R = "HandP.R", D = `${R}.data`, sg = "Hand.κ", P = "Hand.Pd", x0 = "Hand.x0n", x1 = "Hand.x1n";
const fq = (a: string) => `(mlxOf ${a}.ffi)`;
const W = "Host.Load.Run.Tpl.wideG", WL = "Host.Load.Run.Tpl.wideList";

put("Walk", head(`host.sim.template.${tdir}.S`, `host.sim.template.${xdir}.H${Math.floor(+Ti / 32)}`, "host.sim.template.RestartHand",
  "host.sim.template.BridgeLiteral", "host.sim.template.ServerData", "host.sim.template.Ghosts", "host.sim.template.a4pre_first_tail_x15_r0.States") + [
  `/-! The map from the decode template into POST's end, chosen natively on the bridge-free views of both states. -/`,
  `bridge_empty HandP.s0 from ${s0}`,
  `server_data HandP.S0 := ${S0}`,
  `bridge_empty HandP.s${Ti} from ${sE}`,
  `server_data HandP.S${Ti} := ${SE}`,
  `def HandP.frames : List Nat := [2665]`,
  `def HandP.ghosts : List Nat := ghostAddrs`,
  `def HandP.maps : List Nat := [4910]`,
  `set_option interpreter.prefer_native true in`,
  `tpl_restart_hand ${R} : HandP, HandP ${Ti} tok 79 emit 12504 («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)`,
  ""].join(NL));
put("Base", head(mod("Walk"), "host.route.PostReframe", "host.sim.full.DropTokens", "host.sim.template.SetupP", "host.sim.template.NShiftOf", "host.sim.template.Check") + [
  `/-! POST's end as the hand-off uses it: the prompt array holding the template's elements, its queue the token. -/`,
  `noncomputable def Hand.o : Obj := Template.objOf ${sE} 2665`,
  `noncomputable def Hand.x0 : List Val := arrOf ${s0} 2665`,
  `noncomputable def ${s1} : St FF.S :=`,
  `  (withArr ${sE} 2665 Hand.o Hand.x0).setFfi (fullSetTokens (withArr ${sE} 2665 Hand.o Hand.x0).ffi [.ref 2])`,
  `noncomputable abbrev ${sg} : Map := ${D}.map`,
  `noncomputable def Hand.θ : Nat → SymE := thetaOf ${R}.theta`,
  `noncomputable def Hand.SE : SSrv := ⟨${SE}.tab, []⟩`,
  `def ${P} : LoadP := ⟨${pd.join(", ")}, []⟩`,
  `noncomputable abbrev Hand.y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad ${s0}.ffi)`,
  `noncomputable abbrev Hand.y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad ${s1}.ffi)`,
  `noncomputable abbrev ${x0} : NSt := Hand.y0.mlx`,
  `noncomputable abbrev ${x1} : NSt := Hand.y1.mlx`,
  ""].join(NL));
put("Keys", head(`host.sim.template.${tdir}.S`, "host.sim.template.RestartCmd", "host.sim.template.BridgeLiteral", "host.sim.template.ServerData") + [
  `/-! The template's address groups, on its bridge-free view: all but the prompt array. -/`,
  `bridge_empty HandV.s0 from ${s0}`,
  `server_data HandV.S0 := ${S0}`,
  `def HandV.frames : List Nat := [2665]`,
  `tpl_keys HandV`,
  `theorem Hand.cover : ∀ a x, ${s0}.heap.get a = some x → a ∉ [2665] → ∃ q ∈ HandV.gks, a ∈ q.2 :=`,
  `  HandV.cover`,
  ""].join(NL));
put("Closed", head(mod("Keys"), "host.sim.template.Check", "host.sim.template.NShiftGen") + [
  `abbrev Hand.n : Nat := ${st.n}`,
  `kernel_rfl Hand.tab_len : ${S0}.tab.length = Hand.n`,
  `noncomputable def Hand.suppAt (a : Nat) : Bool :=`,
  `  match ${s0}.heap.get a with`,
  `  | some h => bHobj (presentB ${s0}) Hand.n h`,
  `  | none => true`,
  `noncomputable def Hand.boundAt (a : Nat) : Bool := Nat.blt a ${s0}.next`,
  "",
  `tpl_all_blocks Hand.HS from HandV : Hand.suppAt`,
  `kernel_rfl Hand.suppFramed : [2665].all Hand.suppAt = true`,
  `tpl_all_blocks Hand.BD from HandV : Hand.boundAt`,
  `kernel_rfl Hand.boundFramed : [2665].all Hand.boundAt = true`,
  `kernel_rfl Hand.rootsSupp_check : checkRootsSupp ${s0} Hand.n = true`,
  "",
  `theorem Hand.allPresent {p : Nat → Bool} (hb : ∀ q ∈ HandV.gks, ∀ a ∈ q.2, p a = true) (hf : [2665].all p = true) :`,
  `    ∀ a, Present ${s0} a → p a = true := by`,
  `  intro a ha`,
  `  obtain ⟨h, hg⟩ := Present.get ha`,
  `  by_cases hm : a ∈ [2665]`,
  `  · exact List.all_eq_true.mp hf a hm`,
  `  · obtain ⟨q, hq, haq⟩ := Hand.cover a h hg hm`,
  `    exact hb q hq a haq`,
  "",
  `theorem Hand.heapSupp : ∀ a h, ${s0}.heap.get a = some h → Supp.hobj (Present ${s0}) Hand.n h := by`,
  `  intro a h ha`,
  `  have hp := Hand.allPresent Hand.HS.all Hand.suppFramed a (Present.of_get ha)`,
  `  unfold Hand.suppAt at hp`,
  `  rw [ha] at hp`,
  `  exact bHobj_sound hp`,
  "",
  `theorem Hand.rootsSupp : Supp.ctl (Present ${s0}) Hand.n ${s0}.ctl ∧`,
  `    (∀ f ∈ ${s0}.stack, Supp.frame (Present ${s0}) Hand.n f) ∧`,
  `    (∀ j ∈ ${s0}.jobs, Supp.job (Present ${s0}) Hand.n j) ∧ Supp.stores (Present ${s0}) Hand.n ${s0}.stores :=`,
  `  checkRootsSupp_sound Hand.rootsSupp_check`,
  "",
  `theorem Hand.presentBound : ∀ a, Present ${s0} a → a < ${s0}.next := by`,
  `  intro a ha`,
  `  have := Hand.allPresent Hand.BD.all Hand.boundFramed a ha`,
  `  unfold Hand.boundAt at this`,
  `  simpa [Nat.blt_eq] using this`,
  ""].join(NL));
const mlx = (s: string) => `(Host.Load.Layers.toLoad ${s}.ffi).mlx`;
put("Fresh", head(mod("Closed"), "host.sim.BigFree", "host.sim.native.RebigR") + [
  `kernel_rfl Hand.hnext : ${mlx(s0)}.next = ${st.mnext}`,
  `noncomputable def Hand.freshAt (a : Nat) : Bool := noBigAtB ${st.mnext} 131072 ${s0} a`,
  `tpl_all_blocks Hand.FB from HandV : Hand.freshAt`,
  `kernel_rfl Hand.freshFramed : [2665].all Hand.freshAt = true`,
  `kernel_rfl Hand.freshRoots : noBigRootsB ${st.mnext} 131072 ${s0}.trace ${s0} = true`,
  `kernel_rfl Hand.nativeFresh : bigsOutB ${st.mnext} 131072 ${mlx(s0)} = true`,
  `theorem Hand.noBigFresh : NoBigSt (fun i => (${st.mnext} : Int) ≤ i ∧ i < 131072) ${s0}.trace ${s0} :=`,
  `  NoBigSt.of_checks (fun a ha => Hand.allPresent Hand.FB.all Hand.freshFramed a ha) Hand.freshRoots`,
  ""].join(NL));
put("Heap", head(mod("Base"), mod("Keys")) + `tpl_heap_blocks ${R} from HandV : ${sg}, ${s0}, ${s1}${NL}`);

const ck = (nm: string, stmt: string) => `kernel_rfl Hand.n${nm} : ${stmt}${NL}`;
const chunked = (nm: string, list: string, n: number, kind: "all" | "map", stmt: (l: string) => string, chunk = 2000) => {
  const m = Math.max(1, Math.ceil(n / chunk));
  let l = list;
  const ls: string[] = [];
  for (let j = 0; j <= m; j++) { ls.push(l); l = `(${l}).drop ${chunk}`; }
  const chunks = Array.from({ length: m }, (_, j) => `kernel_rfl Hand.n${nm}_${j} : ${stmt(`(${ls[j]}).take ${chunk}`)}${NL}`);
  const step = kind === "all" ? "all_take_drop" : "map_take_drop", nil = kind === "all" ? "all_of_nil" : "map_of_nil";
  let proof = `${nil} Hand.n${nm}_end`;
  for (let j = m - 1; j >= 0; j--) proof = `${step} ${chunk} Hand.n${nm}_${j} (${proof})`;
  return { chunks, assemble: `kernel_rfl Hand.n${nm}_end : ${ls[m]} = []${NL}theorem Hand.n${nm} : ${stmt(list)} :=${NL}  ${proof}${NL}` };
};
const hs = chunked("handles", `handlesOfA ${x0}`, st.mnext + 4000, "all", l => `(${l}).all (handleOK ${sg} ${P}.lo ${x0} ${x1}) = true`);
const ns = chunked("nodes", `PTrie.keysA ${x0}.nodes`, st.nnext, "all", l => `(${l}).all (nodeOKF ${sg} ${P} ${x0} ${x1}) = true`);
const ps = chunked("prims", `fullKeysF ${P} ${x0}`, st.nnext, "map", l =>
  `(${l}).map (fun i => (${x1}.nodes.get (${sg}.node i)).map Host.Mlx.Ffi.Node.prim) =${NL}  (${l}).map (fun i => (${x0}.nodes.get i).map fun nd => ${sg}.prim nd.prim)`);
const fields = ["nh0", "nh1", "nn0", "nn1", "lo", "cnt", "nband", "hbelow", "handles", "hren", "band", "nh1pos", "objs", "objok",
  "nodes", "prims", "nren", "nlow", "nord", "items", "ssT", "abs0a", "abs0b", "tok1", "pend", "errh", "files", "arch", "sizes", "wired"];
put("Na", head(mod("Base"), mod("Closed")) + [
  ck("nh0", `${D}.nh0 = ${x0}.next`), ck("nh1", `${D}.nh1 = ${x1}.next`), ck("nn0", `${D}.nn0 = ${x0}.nnext`), ck("nn1", `${D}.nn1 = ${x1}.nnext`),
  ck("lo", `(Nat.blt 0 ${P}.lo && Nat.ble ${P}.lo ${x0}.next && Nat.ble ${P}.lo RData.bigHi && Nat.ble RData.bigHi ${P}.E) = true`),
  ck("cnt", `(Nat.ble ${x0}.next ${x1}.next && Nat.ble ${x0}.nnext ${x1}.nnext) = true`),
  ck("nband", `(Nat.blt 0 ${P}.NL && Nat.ble ${P}.NL ${P}.N0 && Nat.ble ${P}.N0 ${x0}.nnext) = true`),
  ck("hbelow", `${D}.checkHndBelow = true`),
  ck("hren", `checkRenG ${D}.hnd ${R}.hinv (phB ${x0}) = true`),
  ck("band", `${D}.checkBand ${P}.lo = true`), ck("nh1pos", `Nat.blt 0 ${D}.nh1 = true`),
  ck("nren", `checkRenG ${D}.node ${R}.ninv (pnB ${x0}) = true`),
  ck("nlow", `(PTrie.keysA ${D}.node).all (fun j => Nat.ble ${P}.NL j && Nat.blt (${D}.nodeF j) ${x1}.nnext) = true`),
  ck("nord", `(fullAbove ${P} ${x0}).all (fun i => Nat.ble i (${D}.nodeF i) &&${NL}  (PTrie.keysA ${D}.node).all fun j => !Nat.blt j i || Nat.blt (${D}.nodeF j) (${D}.nodeF i)) = true`),
  ck("items", `(PTrie.keysA ${x0}.items).all (pnB ${x0}) = true`), ck("ssT", `checkSSt Hand.n ${x0} = true`),
  ck("abs0a", `${x0}.arrs.get 0 = none`), ck("abs0b", `${x0}.objs.get 0 = none`), ck("tok1", `${x1}.tokens = []`),
  ck("pend", `${x1}.pending = ${x0}.pending.map ${sg}.pend`), ck("errh", `${x1}.errh = ${x0}.errh.map ${sg}.arg`),
  ck("files", `${x1}.files = ${x0}.files`), ck("arch", `${x1}.arch = ${x0}.arch`),
  ck("sizes", `${x1}.deviceSizes = ${x0}.deviceSizes`), ck("wired", `${x1}.wired = ${x0}.wired`),
  ck("host", `Hand.y1.host = Hand.y0.host`)].join(""));
const cks = [ck("objs", `(PTrie.keysA ${x0}.objs).map (fun h => ${x1}.objs.get (${sg}.handle h)) =${NL}  (PTrie.keysA ${x0}.objs).map (fun h => (${x0}.objs.get h).map ${sg}.nobj)`) +
  ck("objok", `(PTrie.keysA ${x0}.objs).all (objOK ${sg} ${P}.NL ${x0}) = true`), ...hs.chunks, ...ns.chunks, ...ps.chunks];
cks.forEach((body, j) => put(`Nc_${j}`, head(mod("Na")) + body));
put("Nb", head(...cks.map((_, j) => mod(`Nc_${j}`))) + hs.assemble + ns.assemble + ps.assemble + NL +
  `theorem Hand.nshift : NShift ${P} Hand.n ${sg} Hand.y0 Hand.y1 :=${NL}` +
  `  nshift_of ⟨rfl, rfl, rfl, ${fields.map(f => `Hand.n${f}`).join(", ")}⟩ Hand.nhost fun _ => rfl${NL}`);
put("Full", head(mod("Nb"), "host.sim.template.FullShiftGen", "host.sim.conv.HandOff", "host.load.boot.World") + [
  `kernel_rfl Hand.tokens : ${fq(s1)}.tokens = ${fq(s0)}.tokens.map ${sg}.nv`,
  `kernel_rfl Hand.tokSupp : ${fq(s0)}.tokens.all (bSN Hand.n) = true`,
  `theorem Hand.inactive : (bridgeOf ${s0}.ffi).active = false := Host.Load.Boot.replay_active _`,
  `kernel_rfl Hand.bridge : bridgeOf ${s1}.ffi = bridgeOf ${s0}.ffi`,
  `kernel_rfl Hand.live : liveShiftB ${sg} ${fq(s0)} (freedOf ${s0}.ffi) (freedOf ${s1}.ffi) = true`,
  `kernel_rfl Hand.kern : kernShiftB ${sg} Hand.n ${fq(s0)} (krecOf ${s0}.ffi) (krecOf ${s1}.ffi) = true`,
  `kernel_rfl Hand.pendR : pendRegB ${sg} ${fq(s0)} = true`,
  `kernel_rfl Hand.pendLe : Nat.ble ${fq(s0)}.next ${fq(s1)}.next = true`,
  "",
  `theorem Hand.fullShift : Conv.FullShiftH ${P} Hand.n ${sg} ${s0}.ffi ${s1}.ffi :=`,
  `  ⟨Hand.nshift, Hand.tokens, fun t ht => bSN_sound (List.all_eq_true.mp Hand.tokSupp t ht), ⟨Hand.inactive, .inl Hand.bridge⟩,`,
  `    liveShift_of Hand.live, kernShift_of Hand.kern,`,
  `    pendReg_of rfl Hand.nnh0 Hand.nnh1 (Nat.le_of_ble_eq_true Hand.pendLe) Hand.pendR⟩`,
  ""].join(NL));
const kchecks: string[][] = [[
  `kernel_rfl Hand.num : checkNum ${sg} Hand.θ ⟨${S0}.tab, []⟩ Hand.SE = true`,
  `kernel_rfl Hand.fixP : ${D}.a 2665 = 2665`,
  `kernel_rfl Hand.numT : ${sg}.num 79 = .ref 2`,
  `kernel_rfl Hand.numM : ${sg}.num ${R}.iE = .ref 1`,
  `kernel_rfl Hand.arrM : arrOf ${s0} 12504 = [.num (.ref ${R}.iE)]`,
  `kernel_rfl Hand.fixS : [2586, 2589, 12504, 2590].all (fun a => Nat.beq (${D}.a a) a) = true`], [
  `kernel_rfl Hand.getP : ${s0}.heap.get 2665 = some (.obj (Template.objOf ${s0} 2665))`,
  `kernel_rfl Hand.kindP : (Template.objOf ${s0} 2665).kind = .array Hand.x0`,
  `kernel_rfl Hand.imgP : ${s1}.heap.get 2665 = some (.obj { ${sg}.obj (Template.objOf ${s0} 2665) with kind := .array (Hand.x0 ++ []) })`,
  `kernel_rfl Hand.getE : ${sE}.heap.get 2665 = some (.obj Hand.o)`,
  `kernel_rfl Hand.kindE : Hand.o.kind = .array []`,
  `kernel_rfl Hand.suppE : bKind (presentB ${sE}) Hand.SE.tab.length (.array Hand.x0) = true`,
  `kernel_rfl Hand.getF : ${s0}.heap.get 2673448 = some (.obj (Template.objOf ${s0} 2673448))`,
  `kernel_rfl Hand.kindF : (Template.objOf ${s0} 2673448).kind = .array (arrOf ${s0} 2673448)`,
  `kernel_rfl Hand.getM : ${s0}.heap.get 12504 = some (.obj (Template.objOf ${s0} 12504))`,
  `kernel_rfl Hand.kindM : (Template.objOf ${s0} 12504).kind = .array (arrOf ${s0} 12504)`,
  `kernel_rfl Hand.wideOK : ${WL}.all (fun p => Nat.beq (${D}.a p.1) p.1 && presentB ${s0} p.1 && wfixB ${sg} (presentB ${s0}) p.2 && presentB ${sE} p.1) = true`], [
  `kernel_rfl Hand.n0 : ${D}.n0 = ${s0}.next`,
  `kernel_rfl Hand.n1 : ${D}.n1 = ${s1}.next`,
  `kernel_rfl Hand.nextLo : Nat.ble ${sE}.next ${s0}.next = true`,
  `kernel_rfl Hand.nextHi : Nat.ble ${s0}.next (${sE}.next + 13) = true`,
  `kernel_rfl Hand.ren : checkRen ${s0} ${D} ${R}.inv = true`], [
  `kernel_rfl Hand.ctl : ${s1}.ctl = ${sg}.ctl ${s0}.ctl`,
  `kernel_rfl Hand.stack : ${s1}.stack = ${s0}.stack.map ${sg}.frame`,
  `kernel_rfl Hand.jobs : ${s1}.jobs = ${s0}.jobs.map ${sg}.job`,
  `kernel_rfl Hand.stores : ${s1}.stores = ${sg}.stores ${s0}.stores`], [
  `kernel_rfl Hand.band : ${D}.checkBand 18151 = true`,
  `kernel_rfl Hand.nh0le : Nat.ble 18151 ${D}.nh0 = true`,
  `kernel_rfl Hand.intr : (List.range 40).all (fun a => Nat.beq (${D}.a a) a) = true`,
  `kernel_rfl Hand.tokE : ${fq(sE)}.tokens = [.ref 2]`,
  `kernel_rfl Hand.itemE : ${fq(sE)}.items.get 17776 = some (.ref 1)`,
  `kernel_rfl Hand.nodeE : (${fq(sE)}.nodes.get 17776).isSome = true`,
  `kernel_rfl Hand.tab1E : nth? Hand.SE.tab 1 = some (.var 1)`,
  `kernel_rfl Hand.tab2E : nth? Hand.SE.tab 2 = some (.var 2)`,
  `kernel_rfl Hand.tok0 : ${fq(s0)}.tokens = [.ref 79]`,
  `kernel_rfl Hand.lo0 : Nat.ble ${P}.lo ${fq(s0)}.next = true`,
  `kernel_rfl Hand.nE : Nat.ble ${fq(sE)}.next (2 ^ 40) = true`,
  `kernel_rfl Hand.nnE : Nat.ble ${fq(sE)}.nnext (2 ^ 40) = true`]];
kchecks.forEach((c, j) => put(`K${j}`, head(mod("Na"), "host.sim.template.FullShiftGen", "host.sim.template.Ghosts") + c.join(NL) + NL));
put("Hand", head(mod("Heap"), mod("Full"), mod("Fresh"), ...kchecks.map((_, j) => mod(`K${j}`)), "host.route.PostHandoff", "host.sim.template.HandGen", "host.sim.template.SetupP") + [
  `open Host.Route.PrefGraph Host.Load.Run.Prompt`,
  "",
  `/-- The variables the template's table reads. -/`,
  `kernel_rfl Hand.reads : ${S0}.tab.all (readsOnly (fun v => ${R}.used.contains v)) = true`,
  "",
  `/-- **The template's shift into POST's end.** -/`,
  `theorem Hand.shift (q : List Val) (K : Sim.Ctx) (hfr : K.fr = frH Hand.x0 q) (hlo : K.lo = setupP.lo) (hhi : K.hi = setupP.E) :`,
  `    ShiftH FF ${sg} Hand.θ K ${s0} ⟨${S0}.tab, []⟩ ${s1} Hand.SE where`,
  `  num := checkNum_sound Hand.num`,
  `  heap := by`,
  `    intro a h ha hk`,
  `    have hm : a ∉ [2665] := by`,
  `      intro hm`,
  `      have e : a = 2665 := by simpa using hm`,
  `      subst e`,
  `      rw [hfr] at hk`,
  `      cases hk`,
  `    obtain ⟨q', hq, haq⟩ := Hand.cover a h ha hm`,
  `    have he := ${R}.heapAt q' hq a haq`,
  `    rw [ha] at he`,
  `    exact he`,
  `  framed := by`,
  `    intro a pre pre' hk`,
  `    rw [hfr] at hk`,
  `    unfold frH at hk`,
  `    cases h : Nat.beq a 2665 with`,
  `    | false => rw [h] at hk; cases hk`,
  `    | true =>`,
  `      have e := Nat.eq_of_beq_eq_true h`,
  `      subst e`,
  `      rw [h] at hk`,
  `      simp only [Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at hk`,
  `      obtain ⟨rfl, rfl⟩ := hk`,
  `      exact ⟨Hand.fixP, _, [], Hand.getP, Hand.kindP, Hand.imgP⟩`,
  `  next := by`,
  `    intro k`,
  `    show ${D}.a (${s0}.next + k) = _`,
  `    rw [← Hand.n0, RData.a_fresh, Hand.n1]`,
  `  present := by`,
  `    intro a hp`,
  `    obtain ⟨h, ha⟩ := Present.get hp`,
  `    by_cases hm : a ∈ [2665]`,
  `    · have e : a = 2665 := by simpa using hm`,
  `      subst e`,
  `      rw [Hand.fixP]`,
  `      exact Present.of_get Hand.imgP`,
  `    · obtain ⟨q', hq, haq⟩ := Hand.cover a h ha hm`,
  `      have he := ${R}.heapAt q' hq a haq`,
  `      rw [ha] at he`,
  `      exact Present.of_get he`,
  `  inj := a_inj (fun x hx => by rw [Hand.n0]; exact Hand.presentBound x hx) Hand.ren`,
  `  presentBound := Hand.presentBound`,
  `  framedPresent := by`,
  `    intro a p hk`,
  `    obtain ⟨pre, pre'⟩ := p`,
  `    rw [hfr] at hk`,
  `    unfold frH at hk`,
  `    cases h : Nat.beq a 2665 with`,
  `    | false => rw [h] at hk; cases hk`,
  `    | true =>`,
  `      have e := Nat.eq_of_beq_eq_true h`,
  `      subst e`,
  `      exact Present.of_get Hand.getP`,
  `  ctl := Hand.ctl`,
  `  stack := Hand.stack`,
  `  jobs := Hand.jobs`,
  `  stores := Hand.stores`,
  `  heapSupp := by rw [show (⟨${S0}.tab, []⟩ : SSrv).tab.length = Hand.n from Hand.tab_len]; exact Hand.heapSupp`,
  `  ctlSupp := by rw [show (⟨${S0}.tab, []⟩ : SSrv).tab.length = Hand.n from Hand.tab_len]; exact Hand.rootsSupp.1`,
  `  stackSupp := by rw [show (⟨${S0}.tab, []⟩ : SSrv).tab.length = Hand.n from Hand.tab_len]; exact Hand.rootsSupp.2.1`,
  `  jobsSupp := by rw [show (⟨${S0}.tab, []⟩ : SSrv).tab.length = Hand.n from Hand.tab_len]; exact Hand.rootsSupp.2.2.1`,
  `  storesSupp := by rw [show (⟨${S0}.tab, []⟩ : SSrv).tab.length = Hand.n from Hand.tab_len]; exact Hand.rootsSupp.2.2.2`,
  `  bigFixed := by`,
  `    show ∀ i, BigFixed K.lo K.hi i → _`,
  `    rw [hlo, hhi]`,
  `    exact RData.big_fixed _ Hand.band (Nat.le_of_ble_eq_true Hand.nh0le) (by decide)`,
  `  bigExt := RData.big_ext _`,
  `  intr := by`,
  `    intro a ha`,
  `    have := Hand.intr`,
  `    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this`,
  `    exact this a ha`,
  "",
  `theorem Hand.wideAt {a : Nat} {w : WFrame} (hw : ${W} a = some w) :`,
  `    ${D}.a a = a ∧ Present ${s0} a ∧ WFix ${sg} (Present ${s0}) w ∧ Present ${sE} a := by`,
  `  have hm : (a, w) ∈ ${WL} := lookupW_mem hw`,
  `  have h := List.all_eq_true.mp Hand.wideOK (a, w) hm`,
  `  simp only [Bool.and_eq_true] at h`,
  `  exact ⟨Nat.eq_of_beq_eq_true h.1.1.1, h.1.1.2, wfix_of h.1.2, h.2⟩`,
  "",
  `/-- **POST's hand-off walk** (\`Host.Route.PrefGraph.postHandoff\`). -/`,
  `theorem Hand.walk : HandWalk ${P} ${W} ${sE} Hand.SE Hand.o ${s0} ${S0}.tab ${sg} Hand.θ`,
  `    (Template.objOf ${s0} 2673448) (Template.objOf ${s0} 12504) ${R}.iE where`,
  `  getE := Hand.getE`,
  `  kindE := Hand.kindE`,
  `  suppE := bKind_sound Hand.suppE`,
  `  tokE := Hand.tokE`,
  `  itemE := Hand.itemE`,
  `  nodeE := Hand.nodeE`,
  `  tab1E := Hand.tab1E`,
  `  tab2E := Hand.tab2E`,
  `  ne := by`,
  `    intro h`,
  `    have h1 : ${fq(s1)}.tokens = [.ref 2] := rfl`,
  `    have h0 := Hand.tok0`,
  `    change ${s1}.ffi = ${s0}.ffi at h`,
  `    rw [h, h0] at h1`,
  `    cases h1`,
  `  shift := fun q K hfr hlo hhi => Hand.shift q K hfr hlo hhi`,
  `  shiftFfi := by rw [Hand.tab_len]; exact Hand.fullShift`,
  `  wide := fun a w hw => ⟨(Hand.wideAt hw).1, (Hand.wideAt hw).2.1, (Hand.wideAt hw).2.2.1⟩`,
  `  w2665 := rfl`,
  `  wPresent := by`,
  `    intro a ha`,
  `    cases hw : ${W} a with`,
  `    | none => exact absurd hw ha`,
  `    | some w => exact (Hand.wideAt hw).2.2.2`,
  `  big := by`,
  `    change bigsOutB ${mlx(s0)}.next 131072 ${mlx(s0)} = true`,
  `    rw [Hand.hnext]`,
  `    exact Hand.nativeFresh`,
  `  free := by`,
  `    change NoBigSt (fun i => (${mlx(s0)}.next : Int) ≤ i ∧ i < 131072) ${s0}.trace ${s0}`,
  `    rw [Hand.hnext]`,
  `    exact Hand.noBigFresh`,
  `  nextLo := Nat.le_of_ble_eq_true Hand.nextLo`,
  `  nextHi := Nat.le_of_ble_eq_true Hand.nextHi`,
  `  hLo := rfl`,
  `  hE := rfl`,
  `  hNE := rfl`,
  `  lo0 := Nat.le_of_ble_eq_true Hand.lo0`,
  `  nE := Nat.le_of_ble_eq_true Hand.nE`,
  `  nnE := Nat.le_of_ble_eq_true Hand.nnE`,
  `  getF := Hand.getF`,
  `  kindF := Hand.kindF`,
  `  getM := Hand.getM`,
  `  kindM := Hand.kindM`,
  `  wF := rfl`,
  `  wM := rfl`,
  `  arrM := Hand.arrM`,
  `  numM := Hand.numM`,
  `  numT := Hand.numT`,
  ""].join(NL));
console.log(`Hand: modules written in ${dir}, ${cks.length} native check modules`);
