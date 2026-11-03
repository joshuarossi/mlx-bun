// bun genD1.ts <Tag> <first tail chain> <tok> <L> [<inputs> <nnext>]
// A two-token class's first forward (the cold one-row step) certificate `D1Cert` on the chain's suffix start, as Fin/gen.ts does a
// final forward's: without the counts the chooser, with them the bounded checks and the certificate.
import { mkdirSync } from "fs";
import { dirname, join } from "path";
const [Tag, chain, tok, Ls, nIns, nF] = process.argv.slice(2);
if (!Tag || !chain || !tok || !Ls) throw new Error("usage");
const L = Number(Ls);
const root = dirname(dirname(import.meta.path));
const S = `PRE_${chain}_suffix`, Bd = `PRE_${chain}_body`;
const opts = `set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false`;
const NS = `Host.Route.Cert.Fin.${Tag}`, m = `host.route.cert.Fin.${Tag}`;
const hdr = (imports: string[], extra = "") => `${imports.map(i => `import ${i}`).join("\n")}\n${opts}\nnamespace ${NS}\nopen Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl\nopen Host.Route.Cert.Fin${extra}\n`;
const end = `\nend ${NS}\n`;
const files: string[] = [];
const write = async (n: string, s: string) => { mkdirSync(join(root, "Fin", Tag), { recursive: true }); files.push(`host/route/cert/Fin/${Tag}/${n}.lean`); await Bun.write(join(root, "Fin", Tag, `${n}.lean`), s); };
const load = (s: string) => `⟨${s}.heap, ${s}.next, ${s}.ctl, ${s}.stack,
    ⟨${s}.aux.jobs, Host.Load.Layers.toLoad ${s}.aux.ffi, ${s}.aux.trace, ${s}.aux.stores⟩⟩`;
if (!nIns) {
  await write("Choose", hdr(["host.route.cert.Fin.Choose", "host.load.run.full.expected.Join", `host.sim.template.a4pre_${chain}_suffix.States`, `host.sim.template.a4pre_${chain}_body.m.B00`]) + `
/-! # The ${Tag} class's first forward: its choice of carriers -/

noncomputable def endLoad : St Host.Load.LSt :=
  ${load(`${S}.s0`)}
noncomputable def startLoad : St Host.Load.LSt :=
  ${load(`${Bd}.s0`)}

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(\`endSrv, \`\`${S}.S0), (\`startSrv, \`\`${Bd}.S0), (\`envSrv, \`\`Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst \`\`SSrv, value := value, hints := .regular 0, safety := .safe })

def box : Box := [(9, ${L}, ${L})]
def vars : VarV := [(9, 0, 1)]

/-- The cold step's forward part, as the certificate reads it. -/
def Ed : List (RNode SDim InKey) := (Host.Load.Run.Full.Expected.graph.map (SimGraph.mapN SDim.lit)).take 4010

set_option interpreter.prefer_native false in
simgraph_choose_fin choice : (endLoad, endSrv), (startLoad, startSrv), (Host.Load.Run.Prompt.P.s0, envSrv),
  box, vars, -2, ${tok}, ${tok}, Ed
` + end);
} else {
  const P = 4000, N = Number(nF);
  await write("Data", hdr([`${m}.Choose`, "host.route.cert.Seg", "host.simgraph.prompt.ChooseRoute"], "\nopen Host.Ts.Sim.Full (mlxOf)") + `
/-! # The ${Tag} class's first forward: what its certificate reads -/

noncomputable def native : Ffi.St := mlxOf ${S}.s0.ffi
noncomputable abbrev Gs := gsV native ${S}.S0 box vars (-2)
def insT : InKey → Option Nat := inputsOf choice.inputs
` + end);
  await write("Check", hdr([`${m}.Data`]) + `
/-! # The ${Tag} class's first forward: every node of the cold step's forward part, at its carrier -/

simgraph_check_template check : Gs, Ed, choice.cert, insT choosing Ed
` + end);
  const ps: [number, number][] = []; for (let s = 0; s < N; s += P) ps.push([s, Math.min(P, N - s)]);
  for (const [i, [s, n]] of ps.entries()) await write(`Down${i}`, hdr([`${m}.Data`]) + `
kernel_rfl down${i} : (List.range' ${s} ${n}).all (downB (exactTplDom 15235 15235 [5554869888] native) native) = true
` + end);
  let d = hdr(["host.route.cert.Fin.VW.Down", ...ps.map((_, i) => `${m}.Down${i}`)]) + `
kernel_rfl nnext_eq : native.nnext = ${N}

theorem down : (List.range native.nnext).all (downB (exactTplDom 15235 15235 [5554869888] native) native) = true := by
  rw [nnext_eq, List.range_eq_range']
`;
  let acc = "down0", len = ps[0]![1];
  for (let i = 1; i < ps.length; i++) { d += `  have h${i} := Fin.VW.all_range'_append _ 0 ${len} ${ps[i]![1]} ${acc} down${i}\n`; acc = `h${i}`; len += ps[i]![1]; }
  await write("Down", d + `  exact ${acc}\n` + end);
  await write("Below", hdr([`${m}.Data`]) + `
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
` + end);
  const n = Number(nIns), ch = Math.ceil(n / 64);
  let ins = hdr([`${m}.Data`, "host.simgraph.iter.InputsPrefix"], "\nopen Host.Mlx.SimGraph.Iter") + `
def ps : List (Option Nat × Option Nat) :=
  (List.range 64).map fun p => (inputsOf choice.inputs (.stage p (.cache 0)), inputsOf choice.inputs (.stage p (.cache 1)))

`;
  for (let i = 0; i < ch - 1; i++) ins += `kernel_rfl inputs_part${i} : InputsOkAt 15235 ((choice.inputs.drop ${i * 64}).take 64) ps ${tok} = true\n`;
  ins += `kernel_rfl inputs_tail${ch - 1} : InputsOkAt 15235 (choice.inputs.drop ${(ch - 1) * 64}) ps ${tok} = true\n`;
  for (let i = ch - 2; i >= 0; i--) ins += `
theorem inputs_tail${i} : InputsOkAt 15235 (choice.inputs.drop ${i * 64}) ps ${tok} = true := by
  apply inputsOkAt_of_take_drop 15235 64
  · exact inputs_part${i}
  · simpa only [List.drop_drop] using inputs_tail${i + 1}
`;
  ins += `
theorem inputs_ok : InputsOkAt 15235 choice.inputs ps ${tok} = true := by
  simpa only [List.drop_zero] using inputs_tail0
`;
  await write("Ins", ins + end);
  await write("Cert", hdr([`${m}.Check`, `${m}.Down`, `${m}.Below`, `${m}.Ins`, "host.route.cert.Fin.D1Fwd"], "\nopen Host.Mlx.SimGraph.Iter") + `
/-! # The ${Tag} class's first forward: its certificate -/

/-- **The ${Tag} class's first forward, checked.** -/
noncomputable def d1Cert : D1Cert native ${S}.S0 box vars where
  cert := choice.cert
  insT := insT
  tok := ${tok}
  ps := ps
  hm := check.matches
  hlen := Nat.le_of_ble_eq_true cert_len
  hinp := check.inputs
  hins := fun σ hfix => inputs_at_bound 15235 choice.inputs ps ${tok} inputs_ok σ hfix
  hbelow := fun _ hk => below_at hk
  hdown := down
` + end);
}
const ck = join(root, "../../../check.ts");
let c = await Bun.file(ck).text();
const add = files.filter(f => !c.includes(`"${f}"`));
c = c.replace(`  "host/route/PostTail.lean",\n`, `  "host/route/PostTail.lean",\n` + add.map(f => `  "${f}",\n`).join(""));
await Bun.write(ck, c);
console.log(files.join("\n"));
