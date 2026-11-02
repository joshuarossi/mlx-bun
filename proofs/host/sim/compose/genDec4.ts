// bun genDec4.ts <spec.json> <kind>: decode case <kind>'s fill from the chain `DEC4_<kind>` (host/sim/template/a4dec4_<kind>):
// `a4b/Fill_DEC4_<kind>.lean`, the chain's facts; `a4b/Fill_DEC4_<kind>_Fixed.lean`, `DEC4_<kind>.endFixed`, `piecesFixed`, `caseFixed`, `tailS`.
// `gen.ts fill` at `DecOk.decJ`, the valuations `DecOk.VP`, the frames `framesG`, `wideG`, the fixed addresses `Dec4.fix4`, over
// `host.sim.compose.a4b.Dec4Link`. The pieces' structure is `gen.ts decode --out a4b/DecBundle4_<kind>.lean`'s.
import { readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const fail = (m: string): never => { throw new Error(m); };
const HERE = import.meta.dir;
const [specFile, kind] = process.argv.slice(2);
if (!specFile || !kind) fail("usage: genDec4.ts <spec.json> <kind>");
const X = `DEC4_${kind}`, dir = `a4dec4_${kind}`;
const spec = JSON.parse(readFileSync(specFile!, "utf8"));
const streams = process.env.HOST_STREAM_DIR ?? fail("HOST_STREAM_DIR");
const sdir = join(streams as string, `Host.Load.Run.Tpl.${X}`);
const chain = JSON.parse(readFileSync(join(sdir, "chain.json"), "utf8"));
const seg = JSON.parse(readFileSync(join(sdir, "seg.json"), "utf8"));
const C = `Host.Load.Run.Tpl.${X}`;
const c = (n: string) => `${C}.${n}`;
const tdir = join(HERE, "../template", dir);
const t0 = c("s0"), T0 = c("S0");
const mod = `host.sim.template.${dir}`;
if (chain.row !== `dec_${kind}.r0`) fail(`${X}: row ${chain.row} is not case ${kind}'s`);
const varsOfP = new Map<string, [number, string][]>(spec.pieces.map((p: any) => [p.id, p.vars]));
const pieces: any[] = chain.pieces;
const pname = (p: any) => "glue" in p ? p.glue as string : p.stage.name as string;
const varsOf = (p: any) => varsOfP.get(`${X}.${pname(p)}`) ?? fail(`${X}: ${pname(p)} is not in the spec`);
const maps: string[] = [];
const mapOf = (p: any) => {
  const l = `[${(varsOf(p) as [number, string][]).map(([v, q]) => `(${v}, Q.${q})`).join(", ")}]`;
  if (!maps.includes(l)) maps.push(l);
  return `${X}.m${maps.indexOf(l)}`;
};
if (!("glue" in pieces[0]) || pieces[0].glue !== "start" || pieces[0].steps !== 0) fail(`${X}: a chain from a call (glue 0 \`start\`)`);
if (pieces.length % 2 !== 1 || pieces.some((p, k) => ("glue" in p) !== (k % 2 === 0))) fail(`${X}: glue, call, …, glue`);
const nCalls = (pieces.length - 1) / 2;
// the acceptance parameters (every okB<k> the same)
const okb = readFileSync(join(tdir, "OkB.lean"), "utf8");
const jsps = [...okb.matchAll(/:= Disp\.okJSK \(Host\.Load\.Run\.Tpl\.DecOk\.decJ (⟨[^⟩]*⟩) (\[[^\]]*\]) (\[\]|\[\(.*?\)\])\) \(fun _ _ => false\)\s*$/gm)].map(m => [m[1]!, m[2]!, m[3]!]);
if (jsps.length === 0) fail(`${X}: okB not \`Disp.okJSK (DecOk.decJ …) (fun _ _ => false)\``);
if (jsps.some(j => JSON.stringify(j) !== JSON.stringify(jsps[0]))) fail(`${X}: the okB's acceptance parameters differ`);
const fr = jsps[0]![1]!, wd = jsps[0]![2]!;
const frs = JSON.parse(fr) as number[];
const stages = (seg.bridges as any[]).filter(b => b.kind === "stage");
const eNs: string[][] = stages.map(b => {
  const e = (b.arrs as { a: number; prefix: boolean; els: string[] }[] | undefined)?.find(x => x.a === frs[1]) ?? fail(`${X}: bridge ${b.ia}: no emitted array`);
  if (!(e as any).prefix) fail(`${X}: bridge ${b.ia}: no emitted array past the chain start's`);
  return (e as any).els;
});
const runs = new Map<string, { ok: string; a: number; b: number }>();
for (const m of readFileSync(join(tdir, "Run.lean"), "utf8").matchAll(/^sim_chain_range \S+ \S+\.(okB\d+) (\d+) (\d+) (\S+)$/gm))
  runs.set(m[4]!, { ok: m[1]!, a: +m[2]!, b: +m[3]! });
const steps = new Map<number, { name: string; b: number }>();
for (const f of readdirSync(tdir).filter(f => /^K\d+\.lean$/.test(f)))
  for (const m of readFileSync(join(tdir, f), "utf8").matchAll(/kernel_rfl \S+\.(stepA\d+) : interpS \(step \S+ \S+\.s(\d+)\)\.run \S+ = some \(\S+\.s(\d+), /g))
    steps.set(+m[2]!, { name: m[1]!, b: +m[3]! });
const ia: number[] = stages.map(b => b.ia);
if (ia.length !== nCalls) fail(`${X}: ${ia.length} stage bridges, ${nCalls} calls`);
const glues = pieces.filter((_, k) => k % 2 === 0);
const answers = glues.map(g => g.glue === "start" ? 0 : JSON.parse(readFileSync(join(sdir, g.meta), "utf8")).answers as number);
const AP = "Host.Load.Run.Prompt.addrPrompt", WP = "Host.Load.Run.Tpl.wideG", FP = `(framesG ${t0} q)`, XP = "Dec4.fix4";
const P = `b0 NB ${X}.Pw ${X}.fr ${X}.wd ${WP} ${AP} ${FP} ${t0} ${T0}.tab ${XP} toks ΔJ ΔH ΔN`;
const [fwdA, emitA] = [frs[0]!, frs[1]!];
const srcOf = (f: string) => readFileSync(join(tdir, `${f}.lean`), "utf8");
const ghost = (j: number, nb = "NB", en = `${X}.eN`, bb = "b0") =>
  j === 0 ? `(GhostP.init (fullWorldFb ${bb} ${nb}) ${t0})` : `(${X}.g${j} ${bb} ${nb} ${en})`;
const ghostK = (j: number) => ghost(j, "0", "fun _ => []", "Host.Mlx.FfiAne.St.empty");
const cut = (b: number, j: number, m: string, cm: string) => `(fun i x0 => Dec4.bdCut ${P} θ ${ghost(j)} ${m} ${cm} ${c(`s${b}`)} ${c(`S${b}`)} i x0)`;
const rows = `dec_${kind}.rows`;
const sub = (m2: string, m1: string) => m2 === m1 ? "(fun _ h => h)" : "(by decide +kernel)";
const DJ = `(Dec4.J ${X}.Pw ${X}.fr ${X}.wd)`;
const cutB: [number, number, string, string][] = [];
for (let j = 0; j < nCalls; j++) {
  cutB.push([ia[j]!, j, mapOf(pieces[2 * j]), `${X}.cm${j}`]);
  cutB.push([ia[j]! + 2, j + 1, mapOf(pieces[2 * j + 2]), `${X}.cm${j + 1}`]);
}
// the ghost's counters (`GhostP.compact` at each compaction), Lean's truncated subtraction
const sub0 = (x: number, y: number) => Math.max(0, x - y);
const start = chain.start as { next: number; mnext: number; nnext: number };
let [vJ, vH, vN, gJ, gH, gN] = [start.next, start.mnext, start.nnext, 0, 0, 0] as number[];
for (const b of stages) {
  const k = b.compaction;
  [gJ, gH, gN] = [gJ! + sub0(k.n1, vJ!), gH! + sub0(k.xn1, vH!), gN! + sub0(k.nn1, vN!)];
  [vJ, vH, vN] = [k.n0, k.xn0, k.nn0];
}
const dJ = gJ! + sub0(start.next + seg.counters.dJ, vJ!), dH = gH! + sub0(start.mnext + seg.counters.dH, vH!),
  dN = gN! + sub0(start.nnext + seg.counters.dN, vN!);
let dec: { vs: number[]; m: string } | undefined;
const grows = kind === "grow";
const dQ = grows ? "(Conv.decQC 9 16)" : "(Conv.decQ 9)";
let facts = "", runsS = "", runsV: string[] = [], growV: string[] = [], grow = "", links = "";
links += `  start := Dec4.startLink [] (by decide +kernel) rfl rfl (${X}.hfr q) hVP
    (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb\n`;
let cms = `noncomputable def ${X}.cm0 : List (Nat × Nat) := []\n`;
for (let j = 0; j < nCalls; j++) {
  const cl = pieces[2 * j + 1].stage, gl = pieces[2 * j + 2], last = j === nCalls - 1;
  const a = ia[j]!, k = cl.site as number;
  if (k !== j) fail(`${X}: call ${j} at site ${k}`);
  const m = mapOf(pieces[2 * j + 1]), R = cutB[2 * j]![2], R2 = cutB[2 * j + 1]![2];
  const sa = c(`s${a}`), Sa = c(`S${a}`), sm = c(`s${a + 1}`), sc = c(`s${a + 2}`), Sc = c(`S${a + 2}`), g0 = ghostK(j);
  const st = c(`st${k}`), tpl = `${st}.tpl`, cn = (n: string) => c(`${n}${k}`), θ = c("θ");
  facts += `-- call \`${cl.name}\` (\`${cl.fn}\`): the call state \`s${a}\`, merged \`s${a + 1}\`, canonical \`s${a + 2}\`
kernel_rfl ${X}.len${a} : Nat.ble ${T0}.tab.length ${Sa}.tab.length = true
kernel_rfl ${X}.cJm${j} : Nat.ble ${g0}.vJ ${sm}.next = true
kernel_rfl ${X}.cJc${j} : Nat.ble ${sc}.next ${sm}.next = true
kernel_rfl ${X}.cHm${j} : Nat.ble ${g0}.vH (mlxOf ${sm}.ffi).next = true
kernel_rfl ${X}.cHE${j} : Nat.blt (mlxOf ${sm}.ffi).next ${X}.Pw.E = true
kernel_rfl ${X}.cNm${j} : Nat.ble ${g0}.vN (mlxOf ${sm}.ffi).nnext = true
kernel_rfl ${X}.bandLo${j} : Nat.ble ${DJ}.lo (mlxOf ${sc}.ffi).next = true
kernel_rfl ${X}.cRJ${j} : Nat.ble (${sm}.next + ${t0}.next + ${g0}.dJ) (${dJ} + ${g0}.vJ + ${sc}.next) = true
kernel_rfl ${X}.cRH${j} : Nat.ble (${g0}.dH + (mlxOf ${sm}.ffi).next + (mlxOf ${t0}.ffi).next) (${dH} + ${g0}.vH + (mlxOf ${sc}.ffi).next) = true
kernel_rfl ${X}.cRN${j} : Nat.ble (${g0}.dN + (mlxOf ${sm}.ffi).nnext + (mlxOf ${t0}.ffi).nnext) (${dN} + ${g0}.vN + (mlxOf ${sc}.ffi).nnext) = true
kernel_rfl ${X}.scE${j} : Nat.ble (mlxOf ${sc}.ffi).next ${X}.Pw.E = true
kernel_rfl ${X}.scN${j} : Nat.ble (mlxOf ${sc}.ffi).nnext ${X}.Pw.NE = true

`;
  const kap = srcOf(`SiteC${k}`).match(new RegExp(`def ${X}\\.kappa${k} : Map :=\\s*Conv\\.Map\\.compact (\\d+) (\\d+) (\\d+) `)) ??
    fail(`${X}: SiteC${k}: kappa${k} is not \`Conv.Map.compact n0 n1 nS …\``);
  const [kn0, , knS] = [+kap[1]!, +kap[2]!, +kap[3]!];
  if (!new RegExp(`^theorem ${X}\\.cshiftR${k} `, "m").test(srcOf(`SiteR${k}`))) fail(`${X}: no cshiftR${k}`);
  const jclC = srcOf(`SiteZ${k}`).match(new RegExp(`kernel_rfl ${X}\\.zroots2${k} : noBigRootsP \\(fun i => !Conv\\.oldBigB \\(⟨(\\d+), `)) ??
    fail(`${X}: SiteZ${k}: zroots2${k}`);
  facts += `-- call \`${cl.name}\`'s data (site ${k}) in \`Dec4.callLink\`'s forms
kernel_rfl ${X}.wsl${j} : ${cn("ws")}.length = ${tpl}.S2.tab.length - ${Sa}.tab.length
kernel_rfl ${X}.wsnd${j} : Template.nodupT ${cn("ws")} PTrie.nil = true
kernel_rfl ${X}.fresh${j} : (${Sa}.tab.all fun e => ${cn("ws")}.all fun w => e.noVar w) = true
kernel_rfl ${X}.gtab${j} : (${T0}.tab.all fun e => (${cn("cws")} ++ ${cn("ws")}).all fun w => e.noVar w) = true
kernel_rfl ${X}.gth${j} : (${T0}.tab.all fun e => (${cn("cws")} ++ ${cn("ws")}).all fun w => w == 17 || (e.subst ${θ}).noVar w) = true
kernel_rfl ${X}.big${j} : bigsOutB (mlxOf ${sc}.ffi).next ${X}.Pw.E (mlxOf ${sc}.ffi) = true
kernel_rfl ${X}.kn${j} : Nat.ble ${T0}.tab.length ${knS} = true
kernel_rfl ${X}.ka${j} : (${XP}.all fun a => Nat.blt a ${kn0}) = true
kernel_rfl ${X}.m0_${j} : (${R}.all fun p => (Conv.idx? p.1 ${cn("cws")}).isNone && !${cn("ws")}.contains p.1) = true
kernel_rfl ${X}.dv${j} : ((${cn("cws")} ++ ${cn("ws")}).all fun v => (Host.Load.Run.Tpl.decVal v).isNone) = true
kernel_rfl ${X}.ndc${j} : Template.nodupT ${cn("cws")} PTrie.nil = true
kernel_rfl ${X}.lenc${j} : ${cn("cws")}.length = ${cn("nr")}.length
kernel_rfl ${X}.nrLo${j} : ${cn("nr")}.all (Nat.ble ${Sa}.tab.length) = true
kernel_rfl ${X}.xn${j} : Nat.ble ${jclC[1]} (mlxOf ${sc}.ffi).next = true
kernel_rfl ${X}.wa${j} : ((4910 :: Host.Load.Run.Tpl.ghostAddrs).all fun a => !isArrB ${sm} a) = true
kernel_rfl ${X}.zwa${j} : ((4910 :: Host.Load.Run.Tpl.ghostAddrs).all fun a => (${sc}.heap.get a).isSome) = true
theorem ${X}.keepG${j} (q : List Val) : KeepsAtW ${FP} ${sm} := keepsG ${c(`arr${k}_2665`)} ${X}.wa${j}
theorem ${X}.chk${j} : ∀ r ∈ ${rows}, goodLin r.ps (varsOf r.V ${m}) ${st}.O = true := by
  decide +kernel
/-- Call ${j}'s results' entries and their values. -/
noncomputable def ${X}.Es${j} : List (Option SymE) := ${cn("nr")}.map fun r => nth? ${tpl}.S2.tab r
noncomputable def ${X}.qs${j} : List Dec4.RV := ${X}.Es${j}.map fun o => (o.bind (Dec4.decC ${dQ})).getD (.inl .o)
kernel_rfl ${X}.dq${j} : ${X}.Es${j}.all (fun o => (o.bind (Dec4.decC ${dQ})).isSome) = true
kernel_rfl ${X}.lq${j} : ${X}.qs${j}.length = ${cn("cws")}.length
kernel_rfl ${X}.qsOk${j} : ${X}.qs${j}.all (Dec4.rvLe ${grows}) = true
kernel_rfl ${X}.R'${j} : (${R2}.all fun p => (${R} ++ Dec4.qzip ${cn("cws")} ${X}.qs${j}).contains p) = true
kernel_rfl ${X}.c0_${j} : (${X}.cm${j}.all fun p => (Conv.idx? p.1 ${cn("cws")}).isNone && !${cn("ws")}.contains p.1) = true

`;
  cms += `noncomputable def ${X}.cm${j + 1} : List (Nat × Nat) := ${X}.cm${j} ++ Dec4.kzip ${cn("cws")} ${X}.qs${j}\n`;
  links += `  ${cl.name} := Dec4.callLink ${tpl} ${st}.O hW ${X}.chk${j} ${cn("srvO")} ${sub(m, R)}
    (hs0 := ${cn("iso")}) (htab := ${c(`tab0_${k}`)}) (hfoot := ${cn("stFoot")}) (hnd := ${cn("wrNodup")})
    (hbd := ${cn("wrBound")}) (htr := ${cn("trace")}) (hmer := fun _ => ${cn("merged")}) (hmtab := ${cn("mergeTab")})
    (hwsl := ${X}.wsl${j}) (hwsnd := (Template.nodupT_sound ${X}.wsnd${j}).2) (hfresh := noVar_of_all ${X}.fresh${j})
    (hlen := Nat.le_of_ble_eq_true ${X}.len${a}) (hgtab := noVar_nth_of_all ${X}.gtab${j})
    (hgθ := noVarθ_nth_of_all ${X}.gth${j})
    (hgrow := Dec4.call_ngrow hW ${tpl} ${cn("iso")} ${cn("stFoot")} ${cn("wrNodup")} ${cn("wrBound")} ${cn("trace")})
    (hctab := ${cn("ctab")}) (hdis := disj_of_all ${cn("cwsDisj")}) (hshift := fun x0 x hcf hfq hK hB => ${cn("ctab")} ▸ Conv.callShift ${cn("zkap")}
      (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) ${X}.jcl${a}) ${cn("cfix")} hfq
      rfl rfl ${cn("zpl")} ${cn("zplnd")} ${cn("zn1")} ${cn("zfirst")} ${cn("zscn")} ${cn("zsmn")} ${cn("zgrow")} ${cn("mergeTab")}
      ${cn("zfresh")} ${cn("zcnd")} ${X}.lenc${j} ${cn("znrHi")} ${cn("znC")} ${cn("zfrlt")} Dec4.xs_wideG Dec4.wfr_wideG (Dec4.hX_framesG ${X}.arrG ${X}.arr4910)
      (kept_of fun a ha => by
        simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
        rcases ha with rfl | rfl | rfl
        ${frs.slice(0, 3).map(fa => `· exact ⟨${c(`zg${k}_${fa}`)}, ${c(`zk${k}_${fa}`)}, ${c(`zm${k}_${fa}`)}⟩`).join("\n        ")})
      (Dec4.wg_present ${X}.zwa${j}) Dec4.wf_wideG ${cn("zclbd")} ${cn("cheap")}
      (hoff_of ${cn("mheap")} ${cn("stFoot")} ${cn("iso")} ${cn("zwr")}) ${cn("ckeepP")} ${cn("csupp")} ${cn("cbound")} ${cn("zimg")}
      ${cn("zctl")} ${cn("zstack")} ${cn("zjobs")} ${cn("zstores")} ${cn("zroots")} x0 x hcf hK hB.ofFb)
    (hffi := fun _ _ _ h => ${cn("cshiftR")} h rfl)
    (hbig := ${X}.big${j}) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) ${X}.jcl${a + 2})
      (Nat.le_of_ble_eq_true ${X}.xn${j}) (by decide) ${cn("zroots2")})
    (hband := band_of (Nat.le_of_ble_eq_true ${X}.bandLo${j}) (Nat.le_of_ble_eq_true ${X}.bandHi) (by decide))
    (hκn := compact_num_of ${X}.kn${j}) (hκa := compact_fix_of ${X}.ka${j}) (hκv := Conv.node_of_fixOld ${cn("cfix")} (Nat.le_of_ble_eq_true ${cn("zhm")}))
    (hfwd := ${c(`arr${k}_${fwdA}`)}) (hemit := ${c(`arr${k}_${emitA}`)}) (hkeep := ${X}.keepG${j} q)
    (heN := ${c(`arrR${k}_${emitA}`)})
    (hJ := Nat.le_of_ble_eq_true ${X}.cJm${j}) (hJc := Nat.le_of_ble_eq_true ${X}.cJc${j})
    (hH := Nat.le_of_ble_eq_true ${X}.cHm${j}) (hHE := Nat.blt_eq.mp ${X}.cHE${j})
    (hN := Nat.le_of_ble_eq_true ${X}.cNm${j}) (hm0 := m0_of_all ${X}.m0_${j}) (hc0 := Dec4.cm0_of_all ${X}.c0_${j})
    (hdv := Dec4.dv_of_all ${X}.dv${j}) (hndc := (Template.nodupT_sound ${X}.ndc${j}).2)
    (hlenc := ${X}.lenc${j}) (hnrLo := ${X}.nrLo${j}) (hder := rfl)
    (qs := ${X}.qs${j}) (hlq := ${X}.lq${j}) (hEs := ${grows ? `Dec4.hEs_decC dec_${kind}.capRow (by decide) (by decide)` : "Dec4.hEs_dec (by decide)"} ${X}.dq${j})
    (hq := ${grows ? `Dec4.qs_leVC dec_${kind}.capRow` : "Dec4.qs_leV"} ${X}.qsOk${j}) (hR' := sub_of_all ${X}.R'${j}) (hC' := fun _ h => h)
    (dJ := ${dJ}) (dH := ${dH}) (dN := ${dN}) (hdJ := hdJ) (hdH := hdH)
    (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true ${X}.cRJ${j}) (hcH := Nat.le_of_ble_eq_true ${X}.cRH${j})
    (hcN := Nat.le_of_ble_eq_true ${X}.cRN${j}) (hs0E := Nat.le_of_ble_eq_true ${X}.s0E)
    (hscE := Nat.le_of_ble_eq_true ${X}.scE${j}) (hs0N := Nat.le_of_ble_eq_true ${X}.s0N)
    (hscN := Nat.le_of_ble_eq_true ${X}.scN${j})\n`;
  // the glue piece after the call
  const lean = gl.lean;
  if (typeof lean !== "string") fail(`${X}: glue ${gl.glue}: one run segment expected`);
  const rn = (lean as string).split(".").pop()!, run = runs.get(rn) ?? fail(`${X}: ${rn} not in Run.lean`);
  if ((run as any).a !== gl.from || (run as any).b !== gl.to) fail(`${X}: ${rn}: chain.json ${gl.from} → ${gl.to}`);
  if (gl.from !== a + 2) fail(`${X}: glue ${gl.glue} from ${gl.from}, the canonical state ${a + 2}`);
  if (answers.slice(j + 2).some(n => n > 0)) fail(`${X}: glue ${gl.glue}: a later glue piece consumes answers`);
  const meta = JSON.parse(readFileSync(join(sdir, gl.meta), "utf8"));
  const o0 = +((String(meta.oracle).match(/List\.drop (\d+) /) ?? fail(`${X}: ${gl.meta}: oracle`))[1]!);
  const O = `(List.drop ${o0} ${c("O")})`, f = gl.from as number, t = gl.to as number, n = gl.steps as number;
  const mA = mapOf(gl);
  const okR = (run as any).ok as string;
  facts += `-- glue \`${gl.glue}\`: \`${X}.${rn}\` (${n} steps) from \`s${f}\`${last ? ", the chain's end" : `, then \`${X}.${steps.get(t)?.name}\` into the call at \`s${t + 1}\``}
kernel_rfl ${X}.ok${f} : ${c(okR)} ${c(`s${f}`)} ${c(`S${f}`)} = true
kernel_rfl ${X}.srv${f} : ${c(`S${f}`)}.oracle = List.drop ${o0} ${c("O")}
kernel_rfl ${X}.len${f} : Nat.ble ${T0}.tab.length ${c(`S${f}`)}.tab.length = true
theorem ${X}.chk_${gl.glue} : ∀ r ∈ ${rows}, goodLin r.ps (varsOf r.V ${mA}) ${O} = true := by
  decide +kernel
`;
  runsS += `  ${rn} : runOk ${c("F")} ${c(okR)} ${n} ${c(`s${f}`)} ${c(`S${f}`)} = some (${c(`s${t}`)}, ${c(`S${t}`)})\n`;
  runsV.push(`${c(rn)}`);
  grow += `  ${gl.glue} : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), DecOk.VP c.ν →
    Disp.Kp ${DJ} c.K → RelB FF (FLRb b0 ${X}.Pw NB r) W [] c.M c.ν c.K ${c(`s${f}`)} ${c(`S${f}`)} c.t c.C →
    runC FF ${last ? n : `(${n} + 1)`} c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi)\n`;
  if (!last) {
    const st2 = steps.get(t) ?? fail(`${X}: no entry step from s${t}`);
    const stn = (st2 as any).name as string;
    if ((st2 as any).b !== t + 1 || ia[j + 1] !== t + 1) fail(`${X}: ${stn}: the next call at ${ia[j + 1]}`);
    facts += `kernel_rfl ${X}.halt${t} : isHalt ${c(`s${t}`)}.ctl = false
kernel_rfl ${X}.top${t + 1} : noRetBlock ${c(`s${t + 1}`)} = true\n\n`;
    runsS += `  ${stn} : interpS (step ${c("F")} ${c(`s${t}`)}).run ${c(`S${t}`)} = some (${c(`s${t + 1}`)}, ${c(`S${t + 1}`)})\n`;
    runsV.push(`${c(stn)}`);
    links += `  ${gl.glue} := Dec4.glueLinkCall ${O} hW ${X}.chk_${gl.glue} ${X}.srv${f} ${X}.ok${f} ${X}.runs.${rn}
    (runOk_ok_end ${n - 1} ${X}.runs.${rn} ${X}.halt${t}) ${X}.halt${t} ${X}.runs.${stn} ${X}.top${t + 1}
    (Nat.le_of_ble_eq_true ${X}.len${f}) ${sub(cutB[2 * j + 2]![2], mA)} Gw.${gl.glue}\n`;
    growV.push(`fun r _ _ _ hν hK hr ht => Full.glueCall_ngrow (Dec4.simQ b0 NB ${X}.Pw ${X}.fr ${X}.wd W hW r []) ${X}.ok${f} R.${rn}
    (runOk_ok_end ${n - 1} R.${rn} ${X}.halt${t}) ${X}.halt${t} R.${stn} hν hK hr ht`);
  } else {
    facts += `kernel_rfl ${X}.top${t} : noRetBlock ${c(`s${t}`)} = true\n\n`;
    const der = (meta.derived as [number, string, string][]);
    dec = der.length ? { vs: der.map(([v]) => v), m: mA } : undefined;
    links += dec
      ? `  ${gl.glue} := Dec4.glueLinkEndD ${O} hW ${X}.chk_${gl.glue} ${X}.srv${f} ${X}.ok${f} ${X}.runs.${rn}
    ${X}.top${t} ${c("dvs")} ${c("des")} (e := ${X}.endFixed b0 NB) rfl ${X}.hS1D
    ${grows ? `(Dec4.hde_decC dec_${kind}.capRow ${X}.hvsB (by decide) (by decide))` : `(Dec4.hde_dec ${X}.hvsB (by decide))`}
    (Nat.le_of_ble_eq_true ${X}.len${f}) Gw.${gl.glue}\n`
      : `  ${gl.glue} := Dec4.glueLinkEnd ${O} hW ${X}.chk_${gl.glue} ${X}.srv${f} ${X}.ok${f} ${X}.runs.${rn}
    ${X}.top${t} (e := ${X}.endFixed b0 NB) rfl rfl (Nat.le_of_ble_eq_true ${X}.len${f}) Gw.${gl.glue}\n`;
    growV.push(`fun r _ _ _ hν hK hr ht => Full.glue_ngrow (Dec4.simQ b0 NB ${X}.Pw ${X}.fr ${X}.wd W hW r []) ${X}.ok${f} R.${rn}
    hν hK hr ht`);
  }
}
const end = pieces[pieces.length - 1].to as number;
const gE = ghostK(nCalls), sE = c(`s${end}`);
const ghosts = ia.map((a, j) => `/-- The ghost's data after call ${j}'s compaction (merged \`s${a + 1}\`, canonical \`s${a + 2}\`). -/
noncomputable def ${X}.g${j + 1} (b0 : BSt) (NB : Nat) (eN : Nat → List Val) : GhostP :=
  GhostP.compact (fullWorldFb b0 NB) ${ghost(j)} ${c(`s${a + 1}`)} ${c(`s${a + 2}`)} (eN ${j})\n`).join("\n");
// the JS bookkeeping (the template's `JClAll`, from its native twin's boundaries and counters)
const ncl = srcOf("NClAll");
const nclSteps = [...ncl.matchAll(new RegExp(`theorem ${X}\\.ncl(\\d+) : Conv\\.NClean \\((⟨[^⟩]*⟩) : Conv\\.Cnt\\) [^\\n]* := ${X}\\.([cg])ncl(\\d+) ${X}\\.ncl(\\d+)`, "g"))]
  .map(m => ({ to: +m[1]!, cnt: m[2]!, kind: m[3]!, k: +m[4]!, from: +m[5]! }));
if (nclSteps.length === 0) fail(`${X}: NClAll: no steps`);
const jclean = srcOf("EFacts").match(new RegExp(`${X}\\.jclean0 : Conv\\.JClean \\((⟨[^⟩]*⟩) : Conv\\.Cnt\\) `)) ?? fail(`${X}: EFacts: jclean0`);
const jcl = `theorem ${X}.jcl0 : Conv.JClean (${(jclean as any)[1]} : Conv.Cnt) ${t0} := ${c("jclean0")}\n` + nclSteps.map(s =>
  `theorem ${X}.jcl${s.to} : Conv.JClean (${s.cnt} : Conv.Cnt) ${c(`s${s.to}`)} := ${c(`${s.kind}jcl${s.k}`)} ${X}.jcl${s.from}\n`).join("");
const headOpen = `set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers
  Host.Ts.Sim.Template
open Host.Load.Run.Tpl (DecOk)
`;
const pad = (n: string) => n;
const hfp = (hv: string) => `(${hv} : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → DecOk.VP (valL ρ T tk L i nx))`;
const bounds = `(hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf ${t0}.ffi).next + T * ΔH + B.H + (${X}.Pw.E - (mlxOf ${t0}.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf ${t0}.ffi).nnext + T * ΔN + B.N + (${X}.Pw.NE - (mlxOf ${t0}.ffi).nnext) < 2 ^ 62)`;
const dDefs = `def ${X}.dJ : Nat := ${dJ}\ndef ${X}.dH : Nat := ${dH}\ndef ${X}.dN : Nat := ${dN}\n`;
const fill = `import host.sim.compose.a4b.Dec4Link
import host.sim.compose.a4b.DecBundle4_${kind}
import host.load.run.prompt.Addr
import ${mod}.H0
import ${mod}.OkB
import ${mod}.EEnd
import ${mod}.Run
${ia.map((_, k) => `import ${mod}.st${k}.Tpl\nimport ${mod}.SiteL${k}\nimport ${mod}.SiteD${k}\nimport ${mod}.SiteZ${k}\nimport ${mod}.SiteR${k}\n`).join("")}${headOpen}
/-! # Decode case \`${kind}\`'s facts from chain \`${X}\` (generated by \`host/sim/compose/genDec4.ts\`)

The kernel checks of \`Dec4.callLink\` and the glue links at the chain's boundaries, the ghost, the runs and their growth, the counters
(the ghost's \`dJ ${dJ}\`, \`dH ${dH}\`, \`dN ${dN}\`). -/

abbrev ${X}.Pw : LoadP := ${c("PE")}
abbrev ${X}.fr : List Nat := ${fr}
abbrev ${X}.wd : List (Nat × WFrame) := ${wd}
${dDefs}/-- The \`emitted\` elements each call's compaction absorbs. -/
def ${X}.eN : Nat → List Val
${eNs.map((_, j) => `  | ${j} => ${c(`arrEl${j}_${emitA}`)}`).join("\n")}
  | _ => []

/-- The pieces' variable maps (the chains' spec). -/
${maps.map((l, k) => `def ${X}.m${k} : List (Nat × Q) := ${l}`).join("\n")}

/-! ## The JS bookkeeping -/

${jcl}
/-! ## The ghost -/

${ghosts}
/-! ## The boundary facts -/

kernel_rfl ${X}.bandHi : Nat.ble ${X}.Pw.E ${DJ}.hi = true
kernel_rfl ${X}.arr4910 : arrOf ${t0} 4910 = []
kernel_rfl ${X}.arrG : (Host.Load.Run.Tpl.ghostAddrs.all fun a => (arrOf ${t0} a).isEmpty) = true
kernel_rfl ${X}.s0E : Nat.ble (mlxOf ${t0}.ffi).next ${X}.Pw.E = true
kernel_rfl ${X}.s0N : Nat.ble (mlxOf ${t0}.ffi).nnext ${X}.Pw.NE = true
kernel_rfl ${X}.sig2586 : ${c("σ")}.a 2586 = 2586
kernel_rfl ${X}.sig2589 : ${c("σ")}.a 2589 = 2589

${facts}/-- The results' constants at each cut. -/
${cms}
${dec ? `-- the end results and terms, each a quantity or a constant the last glue piece's cut holds it at
kernel_rfl ${X}.hvsB : (${c("dvs")}.zip ${c("des")}).all (Dec4.endOk ${dQ} ${(dec as any).m} ${X}.cm${nCalls}) = true
kernel_rfl ${X}.hS1D : ${c("S1D")} = ⟨${c(`S${end}`)}.tab.map (·.subst (Conv.compactθ ${c("dvs")} ${c("des")})), ${c(`S${end}`)}.oracle⟩

` : ""}/-- **The glue runs.** -/
structure ${X}.Runs : Prop where
${runsS}
theorem ${X}.runs : ${X}.Runs := ⟨${runsV.join(", ")}⟩

/-- The pinned decode world's mlx growth along the glue runs. -/
structure ${X}.Grow (b0 : BSt) (NB : Nat) (W : Nat → Option WFrame) : Prop where
${grow}
theorem ${X}.grow {b0 : BSt} {NB : Nat} {W : Nat → Option WFrame} (R : ${X}.Runs) (hW : Disp.Wp ${DJ} W) :
    ${X}.Grow b0 NB W :=
  ⟨${growV.join(",\n  ")}⟩

/-! ## The counters -/

kernel_rfl ${X}.cJ0 : Nat.ble ${gE}.vJ ${sE}.next = true
kernel_rfl ${X}.cJ : Nat.ble (${gE}.dJ + (${sE}.next - ${gE}.vJ)) ${dJ} = true
kernel_rfl ${X}.cH0 : Nat.ble ${gE}.vH (mlxOf ${sE}.ffi).next = true
kernel_rfl ${X}.cH : Nat.ble (${gE}.dH + ((mlxOf ${sE}.ffi).next - ${gE}.vH)) ${dH} = true
kernel_rfl ${X}.cN0 : Nat.ble ${gE}.vN (mlxOf ${sE}.ffi).nnext = true
kernel_rfl ${X}.cN : Nat.ble (${gE}.dN + ((mlxOf ${sE}.ffi).nnext - ${gE}.vN)) ${dN} = true

theorem ${X}.within {b0 : BSt} {NB : Nat} {A : Addr} {fixA : List Nat} (eN : Nat → List Val)
    {e : IterEndW (fullWorldFb b0 NB) A ${X}.Pw ${t0} ${T0}.tab fixA} (he1 : e.s1 = ${sE}) {ΔJ ΔH ΔN : Nat}
    (hJ : ${dJ} ≤ ΔJ) (hH : ${dH} ≤ ΔH) (hN : ${dN} ≤ ΔN) : e.Within (${X}.g${nCalls} b0 NB eN) ΔJ ΔH ΔN := by
  unfold IterEndW.Within; rw [he1]
  exact ⟨Nat.le_of_ble_eq_true ${X}.cJ0, Nat.le_trans (Nat.le_of_ble_eq_true ${X}.cJ) hJ,
    Nat.le_of_ble_eq_true ${X}.cH0, Nat.le_trans (Nat.le_of_ble_eq_true ${X}.cH) hH,
    Nat.le_of_ble_eq_true ${X}.cN0, Nat.le_trans (Nat.le_of_ble_eq_true ${X}.cN) hN⟩

/-- **The emitted token** after the compactions' absorbed elements and the end's. -/
theorem ${X}.emitTok (b0 : BSt) (NB : Nat) :
    (${X}.g${nCalls} b0 NB ${X}.eN).eA ++ ${c("eR")} = [.num (.ref ${AP}.tok)] := rfl

/-- The route's wide frames are the acceptance's. -/
theorem ${X}.hW : Disp.Wp ${DJ} ${WP} := fun _ _ h => h

/-- The decode loop's frames at the route's: the chain's acceptance's. -/
theorem ${X}.hfr (q : List Val) : ∀ a, a ∈ ${AP}.fwd :: ${AP}.emit :: ${FP}.xs ↔ a ∈ ${X}.fr := fun _ => Iff.rfl

end Host.Ts.Sim.Compose
`;
writeFileSync(join(HERE, `a4b/Fill_${X}.lean`), fill);
const caseTerm = `(${X}.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVP h1 hctx hJ hH hN hJb hHb hNb)`;
const fixed = `import host.sim.compose.a4b.Fill_${X}
${headOpen}
/-! # Decode case \`${kind}\` at the bounded route's list (generated by \`host/sim/compose/genDec4.ts\`)

\`${X}.endFixed\`: the chain's end at \`Dec4.fix4\`, its \`s1\`, \`S1\`, \`σ\` the generator's. \`${X}.caseFixed\`: the case's \`IterCaseW\`.
\`${X}.tailS\`: \`TailFix\` at \`shortFixP\`. -/

/-- The chain's end at \`Dec4.fix4\`. -/
noncomputable def ${X}.endFixed (b0 : BSt) (NB : Nat) :=
  Dec4.endAt4 ((${c("iterEnd")} NB).toFb b0) ${X}.sig2586 ${X}.sig2589

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

noncomputable def ${X}.piecesFixed (q : List Val)
    ${hfp("hVP")} (hdJ : ${dJ} ≤ ΔJ) (hdH : ${dH} ≤ ΔH) (hdN : ${dN} ≤ ΔN)
    ${bounds} :
    DecPieces_${X} (fullWorldFb b0 NB) ${AP} ${WP} ${X}.Pw ${FP} ${t0} ${T0}.tab ${XP} (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      L T (${X}.endFixed b0 NB) (${X}.g${nCalls} b0 NB ${X}.eN) :=
  let θ := ${c("θ")}
  let hW := ${X}.hW
  let Gw : ${X}.Grow b0 NB ${WP} := ${X}.grow ${X}.runs hW
  { ${cutB.map(([b, j, m, cm], k) => `c${k + 1} := ${cut(b, j, m, cm)}`).join("\n    ")}
${links.replace(/^ {2}/gm, "    ")}  }

/-- **Decode case \`${kind}\`** (\`IterCaseW\`) at the route's instance. -/
noncomputable def ${X}.caseFixed (q : List Val)
    ${hfp("hVP")} (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : ${dJ} ≤ ΔJ) (hH : ${dH} ≤ ΔH) (hN : ${dN} ≤ ΔN) ${bounds} :
    IterCaseW (fullWorldFb b0 NB) ${AP} ${WP} ${X}.Pw ${FP} ${t0} ${T0}.tab ${XP} (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .${kind}) where
  e := ${X}.endFixed b0 NB
  g := ${X}.g${nCalls} b0 NB ${X}.eN
  chain := (${X}.piecesFixed (E0 := E0) (B := B) q hVP hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := ${c("shiftFW")} NB q
  keep := ${c("keep")} q
  emit := ${X}.emitTok b0 NB
  within := ${X}.within (e := ${X}.endFixed b0 NB) ${X}.eN rfl hJ hH hN

/-- **The case's chain from the decode cut at \`shortFixP\`.** -/
theorem ${X}.tailS (q : List Val)
    ${hfp("hVP")} (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : ${dJ} ≤ ΔJ) (hH : ${dH} ≤ ΔH) (hN : ${dN} ≤ ΔN) ${bounds} :
    TailFix (fullWorldFb b0 NB) ${AP} ${WP} ${X}.Pw ${FP} ${t0} ${T0}.tab ${XP} shortFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      ${caseTerm} := by
  have st := Dec4.startLinkS (b0 := b0) (NB := NB) (Pw := ${X}.Pw) (fr := ${X}.fr) (wd := ${X}.wd) (W := ${WP}) (A := ${AP})
    (Fr := ${FP}) (s0 := ${t0}) (tab0 := ${T0}.tab)
    (fixA := ${XP}) (fixS := shortFixP) (toks := toks) (uses := ${rows}) (E0 := E0) (B := B)
    (m := ${X}.m0) (θ := ${c("θ")}) (sst := ${t0}) (Sst := ${T0})
    [] (by decide +kernel) rfl rfl (${X}.hfr q) hVP
    (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
  refine ⟨st.n + (${caseTerm}.chain.lens.drop 1).sum, fun i x0 hs => ?_⟩
  exact (st.link dec_${kind}.cover (fun _ h => h) (fun _ _ _ _ => trivial) h1 hctx i x0 hs).trans
    (CutChain.tail (${caseTerm}.chain.links i x0 hs)).run

end

end Host.Ts.Sim.Compose
`;
writeFileSync(join(HERE, `a4b/Fill_${X}_Fixed.lean`), fixed);
console.log(`${X}: ${nCalls} calls, dJ ${dJ} dH ${dH} dN ${dN}; dec ${!!dec}`);
void pad;
