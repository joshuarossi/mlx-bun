// bun gen.ts <Tag> <fd chain> <end> <tok> <post chain> <L> [<inputs> <nnextF> <nnextH>]
// A literal-row class's final forward (Fin/<Tag>) and sampled cut (Head/<Tag>) certificates. Without the counts it writes the
// two choosers; with them (from the choosers' logs) the checks, split so each kernel check stays bounded, and the certificates.
import { mkdirSync } from "fs";
import { dirname, join } from "path";
const [Tag, fd, end, tok, post, Ls, nIns, nF, nH] = process.argv.slice(2);
if (!Tag || !fd || !end || !tok || !post || !Ls) throw new Error("usage");
const L = Number(Ls);
const root = dirname(dirname(import.meta.path));
const T = `PRE_${fd}`, Pc = `PRE_${post}`;
const opts = `set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false`;
const NSF = `Host.Route.Cert.Fin.${Tag}`, NSH = `Host.Route.Cert.Head.${Tag}`;
const op = `open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl`;
const hdr = (ns: string, imports: string[], extra = "") => `${imports.map(i => `import ${i}`).join("\n")}\n${opts}\nnamespace ${ns}\n${op}\nopen Host.Route.Cert.Fin${extra}\n`;
const files: string[] = [];
const write = async (dir: string, n: string, s: string) => {
  mkdirSync(join(root, dir), { recursive: true });
  files.push(`host/route/cert/${dir}/${n}.lean`);
  await Bun.write(join(root, dir, `${n}.lean`), s);
};
const load = (s: string) => `⟨${s}.heap, ${s}.next, ${s}.ctl, ${s}.stack,
    ⟨${s}.aux.jobs, Host.Load.Layers.toLoad ${s}.aux.ffi, ${s}.aux.trace, ${s}.aux.stores⟩⟩`;
const srvs = (pairs: [string, string][]) => `open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [${pairs.map(([n, s]) => `(\`${n}, \`\`${s})`).join(", ")}] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst \`\`SSrv, value := value, hints := .regular 0, safety := .safe })`;
const mF = `host.route.cert.Fin.${Tag}`, mH = `host.route.cert.Head.${Tag}`;
const endF = `\nend ${NSF}\n`, endH = `\nend ${NSH}\n`;
if (!nIns) {
  await write(`Fin/${Tag}`, "Choose", hdr(NSF, ["host.route.cert.Fin.Choose", "host.simgraph.tpl.ordinary.Join", `host.sim.template.a4pre_${fd}.m.B00`]) + `
/-! # The ${Tag} class's final forward: its choice of carriers -/

noncomputable def endLoad : St Host.Load.LSt :=
  ${load(`${T}.s${end}`)}
noncomputable def startLoad : St Host.Load.LSt :=
  ${load(`${T}.s0`)}

${srvs([["endSrv", `${T}.S${end}`], ["startSrv", `${T}.S0`], ["envSrv", "Host.Load.Run.Prompt.P.S0"]])}

def box : Box := [(9, ${L}, ${L}), (10, 1, 1), (11, ${L - 1}, ${L - 1}), (16, 256, 256)]
def vars : VarV := [(9, 0, 1), (10, 1, 0), (11, -1, 1), (16, 256, 0)]

/-- The forward's part of the ordinary step. -/
def Eh : List (RNode SDim InKey) := Tpl.Ordinary.graph.take 4010

set_option interpreter.prefer_native false in
simgraph_choose_fin choice : (endLoad, endSrv), (startLoad, startSrv), (Host.Load.Run.Prompt.P.s0, envSrv),
  box, vars, -1, ${tok}, ${tok}, Eh
` + endF);
  await write(`Head/${Tag}`, "Choose", hdr(NSH, ["host.route.cert.Fin.ChooseHead", "host.simgraph.prompt.ChooseRoute", `${mF}.Choose`, "host.simgraph.tpl.ordinary.Join", `host.sim.template.a4pre_${post}.H0`]) + `
/-! # The ${Tag} class's sampled cut: its choice of carriers -/

noncomputable def loadH : St Host.Load.LSt :=
  ${load(`${Pc}.s1`)}

${srvs([["srvH", `${Pc}.S1`]])}

def boxH : Box := [(9, ${L}, ${L}), (10, 1, 1), (11, ${L}, ${L}), (16, 256, 256)]
def varsH : VarV := [(9, 0, 1), (10, 1, 0), (11, 0, 1), (16, 256, 0)]

set_option interpreter.prefer_native false in
simgraph_choose_head choiceH : (loadH, srvH), boxH, varsH, -1, ${tok}, 4010, Fin.${Tag}.choice.cert,
  (fun key => (inputsOf Fin.${Tag}.choice.inputs key).orElse fun _ => insOf 0 [] (.base key)), Tpl.Ordinary.graph
` + endH);
} else {
  const P = 4000;
  const pieces = (N: number) => { const r: [number, number][] = []; for (let s = 0; s < N; s += P) r.push([s, Math.min(P, N - s)]); return r; };
  const downs = async (dir: string, ns: string, endS: string, nat: string, N: number, mod: string, thm: string) => {
    const ps = pieces(N);
    for (const [i, [s, n]] of ps.entries()) await write(dir, `Down${i}`, hdr(ns, [`${mod}.Data`]) + `
/-! # Nodes ${s} to ${s + n - 1}'s inputs below them -/

kernel_rfl down${i} : (List.range' ${s} ${n}).all (downB (exactTplDom 15235 15235 [5554869888] ${nat}) ${nat}) = true
` + endS);
    let d = hdr(ns, ["host.route.cert.Fin.VW.Down", ...ps.map((_, i) => `${mod}.Down${i}`)]) + `
/-! # Every node's inputs below it -/

kernel_rfl nnext_eq : ${nat}.nnext = ${N}

theorem ${thm} : (List.range ${nat}.nnext).all (downB (exactTplDom 15235 15235 [5554869888] ${nat}) ${nat}) = true := by
  rw [nnext_eq, List.range_eq_range']
`;
    let acc = "down0", len = ps[0]![1];
    for (let i = 1; i < ps.length; i++) { d += `  have h${i} := Fin.VW.all_range'_append _ 0 ${len} ${ps[i]![1]} ${acc} down${i}\n`; acc = `h${i}`; len += ps[i]![1]; }
    await write(dir, "Down", d + `  exact ${acc}\n` + endS);
  };
  await write(`Fin/${Tag}`, "Data", hdr(NSF, [`${mF}.Choose`, "host.route.cert.Seg", "host.simgraph.prompt.ChooseRoute"], "\nopen Host.Ts.Sim.Full (mlxOf)") + `
/-! # The ${Tag} class's final forward: what its certificate reads -/

noncomputable def native : Ffi.St := mlxOf ${T}.s${end}.ffi
noncomputable abbrev Gs := gsV native ${T}.S${end} box vars (-1)
def insT : InKey → Option Nat := inputsOf choice.inputs
` + endF);
  await write(`Fin/${Tag}`, "Check", hdr(NSF, [`${mF}.Data`]) + `
/-! # The ${Tag} class's final forward: every node of the ordinary step's forward part, at its carrier -/

simgraph_check_template check : Gs, Eh, choice.cert, insT choosing Eh
` + endF);
  await downs(`Fin/${Tag}`, NSF, endF, "native", Number(nF), mF, "down");
  await write(`Fin/${Tag}`, "Below", hdr(NSF, [`${mF}.Data`]) + `
/-! # The ${Tag} class's final forward: its carriers below the end's counter -/

kernel_rfl cert_len : Nat.ble 4010 choice.cert.length = true
kernel_rfl below : ((choice.cert.take 4010).all fun c => Nat.blt c native.nnext) = true

theorem below_at {k : Nat} (hk : k < 4010) : certAt choice.cert k < native.nnext := by
  have hl : 4010 ≤ choice.cert.length := Nat.le_of_ble_eq_true cert_len
  have hm : choice.cert[k]'(by omega) ∈ choice.cert.take 4010 :=
    List.mem_iff_getElem.mpr ⟨k, by simp; omega, by simp⟩
  have h := Nat.blt_eq.mp (List.all_eq_true.mp below _ hm)
  unfold certAt
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega), Option.getD_some]
  exact h
` + endF);
  const N = Number(nIns), chunks = Math.ceil(N / 64);
  let ins = hdr(NSF, [`${mF}.Data`, "host.simgraph.iter.InputsPrefix"], "\nopen Host.Mlx.SimGraph.Iter") + `
/-! # The ${Tag} class's final forward: its input table, in bounded pieces -/

/-- The caches the forward reads, at their carriers. -/
def ps : List (Option Nat × Option Nat) :=
  (List.range 64).map fun p => (inputsOf choice.inputs (.stage p (.cache 0)), inputsOf choice.inputs (.stage p (.cache 1)))

`;
  for (let i = 0; i < chunks - 1; i++) ins += `kernel_rfl inputs_part${i} : InputsOkAt 15235 ((choice.inputs.drop ${i * 64}).take 64) ps ${tok} = true\n`;
  ins += `kernel_rfl inputs_tail${chunks - 1} : InputsOkAt 15235 (choice.inputs.drop ${(chunks - 1) * 64}) ps ${tok} = true\n`;
  for (let i = chunks - 2; i >= 0; i--) ins += `
theorem inputs_tail${i} : InputsOkAt 15235 (choice.inputs.drop ${i * 64}) ps ${tok} = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part${i}
  · simpa only [List.drop_drop] using inputs_tail${i + 1}
`;
  ins += `
theorem inputs_ok : InputsOkAt 15235 choice.inputs ps ${tok} = true := by
  simpa only [List.drop_zero] using inputs_tail0
`;
  await write(`Fin/${Tag}`, "Ins", ins + endF);
  await write(`Fin/${Tag}`, "Cert", hdr(NSF, [`${mF}.Check`, `${mF}.Down`, `${mF}.Below`, `${mF}.Ins`, "host.route.cert.Fin.Step"], "\nopen Host.Mlx.SimGraph.Iter") + `
/-! # The ${Tag} class's final forward: its certificate -/

/-- **The ${Tag} class's final forward, checked.** -/
noncomputable def finCert : FinCert native ${T}.S${end} box vars (-1) 4010 where
  cert := choice.cert
  insT := insT
  tok := ${tok}
  ps := ps
  hm := check.matches
  hlen := Nat.le_of_ble_eq_true cert_len
  hinp := check.inputs
  hins := fun σ hfix => inputs_at_bound 15235 choice.inputs ps ${tok} inputs_ok σ hfix
  hdown := down

theorem finCert_below : ∀ k, k < 4010 → certAt finCert.cert k < native.nnext := fun _ hk => below_at hk
` + endF);
  await write(`Head/${Tag}`, "Data", hdr(NSH, [`${mH}.Choose`, "host.route.cert.Seg"], "\nopen Host.Ts.Sim.Full (mlxOf)") + `
/-! # The ${Tag} class's sampled cut: what its certificate reads -/

noncomputable def nativeH : Ffi.St := mlxOf ${Pc}.s1.ffi
noncomputable abbrev GsH := gsV nativeH ${Pc}.S1 boxH varsH (-1)
` + endH);
  await write(`Head/${Tag}`, "Check", hdr(NSH, [`${mH}.Data`]) + `
/-! # The ${Tag} class's sampled cut: the head and sampler's nodes at their carriers -/

simgraph_check_nodes checkH : tailOk 4010 GsH choiceH.cert, Tpl.Ordinary.graph choosing Tpl.Ordinary.graph
` + endH);
  await downs(`Head/${Tag}`, NSH, endH, "nativeH", Number(nH), mH, "downH");
  await write(`Head/${Tag}`, "Facts", hdr(NSH, [`${mH}.Data`]) + `
/-! # The ${Tag} class's sampled cut: its small facts -/

kernel_rfl cert_len : Nat.ble Tpl.Ordinary.graph.length choiceH.cert.length = true
kernel_rfl tok_below : Nat.blt (certAt choiceH.cert Tpl.Ordinary.tokenNode) nativeH.nnext = true
kernel_rfl outs_below : Tpl.Ordinary.cacheOutputs.all (fun q =>
  Nat.blt (certAt choiceH.cert q.1) nativeH.nnext && Nat.blt (certAt choiceH.cert q.2) nativeH.nnext) = true
` + endH);
  await write(`Head/${Tag}`, "Cert", hdr(NSH, ["host.route.cert.Fin.Head", `${mF}.Cert`, `${mH}.Check`, `${mH}.Down`, `${mH}.Facts`]) + `
/-! # The ${Tag} class's sampled cut: its certificate -/

simgraph_check_nodes inpH : headInputOk choiceH.cert, Tpl.Ordinary.graph choosing Tpl.Ordinary.graph

-- The forward's nodes the sampled cut names, where the final forward left them.
kernel_rfl kept_fin : (keptOf (certAt choiceH.cert)).all (fun q =>
  Nat.blt q.1 Fin.${Tag}.choice.cert.length && Nat.beq (certAt Fin.${Tag}.choice.cert q.1) q.2) = true

/-- **The ${Tag} class's sampled cut, checked.** -/
noncomputable def headCert : HeadCert nativeH ${Pc}.S1 boxH varsH (-1) where
  cert := choiceH.cert
  hm := checkH.all
  hlen := Nat.le_of_ble_eq_true cert_len
  hinp := inpH.all
  toB := Nat.blt_eq.mp tok_below
  outsB := fun q hq => by
    have h := List.all_eq_true.mp outs_below q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact h
  hdown := downH

theorem kept_at : ∀ q ∈ keptOf (certAt headCert.cert), q.1 < Fin.${Tag}.finCert.cert.length ∧
    certAt Fin.${Tag}.finCert.cert q.1 = q.2 := fun q hq => by
  have h := List.all_eq_true.mp kept_fin q hq
  simp only [Bool.and_eq_true, Nat.blt_eq, Nat.beq_eq] at h
  exact h
` + endH);
}
const ck = join(root, "../../../check.ts");
let c = await Bun.file(ck).text();
const add = files.filter(f => !c.includes(`"${f}"`));
c = c.replace(`  "host/route/PostTail.lean",\n`, `  "host/route/PostTail.lean",\n` + add.map(f => `  "${f}",\n`).join(""));
await Bun.write(ck, c);
console.log(files.join("\n"));
