// bun gen.ts <Tag> <chain tag> <family tag> <blocks> <down.mt> <lo-hi,...> <row x,...>
// Writes host/route/cert/<Tag>/: a first tail's forward certificate on the template at its return, split so that the
// long kernel check imports only definitions, and its `hfwd`. Example: bun gen.ts VW8 x8 VW83 2 3 33-48,65-72 8,10
import { mkdirSync } from "fs";
import { dirname, join } from "path";
const [Tag, chain, fam, blocks, mt, spans, xs] = process.argv.slice(2);
if (!Tag || !chain || !fam || !blocks || !mt || !spans || !xs) throw new Error("usage");
const dir = join(dirname(import.meta.path), Tag);
mkdirSync(dir, { recursive: true });
const ivs = spans.split(",").map(s => s.split("-").map(Number) as [number, number]);
const rows = xs.split(",");
const T = `PRE_first_tail_${chain}_r0_suffix`, B = `PRE_first_tail_${chain}_r0_body`;
const NS = `Host.Route.Cert.${Tag}`;
const opts = `set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false`;
const head = (imports: string[], extraOpen = "") => `${imports.map(i => `import ${i}`).join("\n")}
${opts}
namespace ${NS}
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam${extraOpen}
`;
const end = `\nend ${NS}\n`;
const m = `host.route.cert.${Tag}`;
const write = (n: string, s: string) => Bun.write(join(dir, `${n}.lean`), s);
await write("Choose", head(["host.simgraph.prompt.ChooseRoute", `host.simgraph.tpl.fam.${fam}.Join`, `host.sim.template.a4pre_first_tail_${chain}_r0_suffix.States`]) + `
/-! # The ${chain} forward's choice of carriers -/

/-- The template at the forward's return, for restoring its stream. -/
noncomputable def endLoad : St Host.Load.LSt :=
  ⟨${T}.input.heap, ${T}.input.next, ${T}.input.ctl, ${T}.input.stack,
    ⟨${T}.input.aux.jobs, Host.Load.Layers.toLoad ${T}.input.aux.ffi, ${T}.input.aux.trace, ${T}.input.aux.stores⟩⟩

def box : Box := [(9, 10, 224), (10, 9, 223)]

/-- The expected graph, built natively. -/
def Ecn : List (RNode PDim SimGraph.PKey) :=
  (familyGraph ${fam}.F id 0 124 Host.Load.Run.Full.Expected.stages).1.map (Host.Mlx.SimGraph.mapN (rowsAt 10))

set_option interpreter.prefer_native true in
simgraph_choose_route choice : (endLoad, ${T}.inputSrv), box, 15235, 15235, [5554869888], Ecn, 15235
` + end);
await write("Data", head([`${m}.Choose`, `host.sim.template.a4pre_first_tail_${chain}_r0_suffix.m.B0`], "\nopen Host.Ts.Sim.Full (mlxOf)") + `
/-! # The ${chain} forward's certificate: what it reads -/

noncomputable def native : Ffi.St := mlxOf ${T}.s0.ffi
noncomputable abbrev Gs := famGs native ${T}.inputSrv box [5554869888]
noncomputable abbrev ins := insOf 15235 choice.cells

/-- The expected graph, as the chain reads it at its rows' variable. -/
noncomputable def Ec : List (RNode PDim SimGraph.PKey) := ${fam}.graph.map (Host.Mlx.SimGraph.mapN (rowsAt 10))
` + end);
const NODES = process.argv[9] ?? "NODES";
await write("Check", head([`${m}.Data`]) + `
/-! # The ${chain} forward's certificate: every node of the family's graph at its carrier -/

simgraph_check_segment check : Gs, kindOf choice.kind, Ec, .promptIds, 0, ${NODES}, choice.cert, ins choosing Ecn
` + end);
await write("Extra", head([`${m}.Data`]) + `
/-! # The ${chain} forward's certificate: each kernel node plain, each dimension input held -/

simgraph_check_nodes extra : extraOk Gs choice.cert 10 ${T}.inputSrv box [5554869888] native ins, Ec choosing Ecn
` + end);
await write("Facts", head([`${m}.Data`]) + `
/-! # The ${chain} forward's certificate: its small facts -/

kernel_rfl kinds_ok : choice.kind.all (fun e => (native.objs.get e.1).isSome) = true
kernel_rfl outs_ok : ${fam}.cacheNodes.all (fun q => Nat.blt q.1 choice.cert.length && Nat.blt q.2 choice.cert.length &&
  Nat.blt (certAt choice.cert q.1) native.nnext && Nat.blt (certAt choice.cert q.2) native.nnext) = true
kernel_rfl outs_len : ${fam}.cacheNodes.length = 64
kernel_rfl graph_len : ${fam}.graph.length = ${NODES}
kernel_rfl cert_len : choice.cert.length = ${NODES}
` + end);
await write("Tab", head([`${m}.Data`, `host.sim.template.a4pre_first_tail_${chain}_r0_suffix.m.B3`]) + `
kernel_rfl input_tab : ${T}.inputSrv.tab = ${B}.endSrv.tab

theorem tab_eq : ${T}.inputSrv.tab = ${T}.S0.tab :=
  input_tab.trans ${T}.s0_tab.symm
` + end);
await write("Cert", head(["host.route.FamCert", `${m}.Check`, `${m}.Extra`, `${m}.Facts`]) + `open Host.Route.PrefGraph

/-! # The ${chain} forward's certificate -/

theorem Ec_len : Ec.length = ${NODES} := by
  unfold Ec
  rw [List.length_map]
  exact graph_len

/-- **The certificate of the ${chain} group's forward.** -/
noncomputable def cert : FamCert .split (.wide ${blocks} ⟨8, ${mt}⟩) .causal Host.Load.Run.Full.Expected.stages where
  n₀ := 124
  x := 10
  s := native
  S := ${T}.inputSrv
  B := box
  fixed := [5554869888]
  cert := choice.cert
  kinds := choice.kind
  cells := choice.cells
  E := ${fam}.graph
  Ec := Ec
  tok := ${fam}.outNode
  outs := ${fam}.cacheNodes
  family := ${fam}.family_eq
  hEc := rfl
  hn₀ := ⟨by decide, by decide⟩
  fixedHi := by
    intro i hi
    obtain rfl := List.mem_singleton.mp hi
    exact ⟨by decide, by decide⟩
  hlen := by rw [graph_len, cert_len]
  hm := by rw [Ec_len]; exact check.matches
  inputs := by rw [Ec_len]; exact check.inputs
  extra := extra.all
  kindsPresent := fun e he => List.all_eq_true.mp kinds_ok e he
  outsLt := fun q hq => by
    have h := List.all_eq_true.mp outs_ok q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact ⟨h.1.1.1, h.1.1.2, h.1.2, h.2⟩
  outs64 := outs_len
` + end);
const disj = (v: string) => ivs.map(([a, b]) => `(${a} ≤ ${v} ∧ ${v} ≤ ${b})`).join(" ∨ ");
const dec = ivs.map(([a, b]) => `(decide (${a} ≤ m) && decide (m ≤ ${b}))`).join(" || ");
const hb = blocks === "3" ? "rw [if_pos]\n    unfold Metal.ceilDiv\n    omega" : "rw [if_neg]\n    unfold Metal.ceilDiv\n    omega";
const VW = Tag;
await write("Fwd", `import host.route.FamFwd
import host.route.GpuLoad
import ${m}.Cert
import ${m}.Tab
import host.sim.compose.a4b.${VW.toLowerCase()}.sfx.VWForward
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.VWFirst.${VW}
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem rowN {r : Row} {i : Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) :
    ${disj("i.n")} := by
  simp only [fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with ${rows.map(() => "rfl").join(" | ")}
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [${rows.map(x => `first_tail_x${x}.r0`).join(", ")}, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

end Host.Ts.Sim.Compose.VWFirst.${VW}

namespace ${NS}
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Lin.Cls (Row InRow)
open Host.Mlx.SimGraph.Ref (gpuFamily refRows downPlan)
open Host.Ts.Sim.Compose.VWFirst (firstTailFacts firstTailRows)
open Host.Ts.Sim.Compose.VWFirst.${VW} (fwdRows)
open Host.Ts.Sim.Compose.VWFirst.${VW}.Sfx (startCore)
open Host.Load.Run.Tpl
open Host.Route.PrefGraph

/-! # The ${chain} group's forward at the bookkeeping -/

theorem plan {n : Nat} (h : ${disj("n")}) :
    gpuFamily .tail n = some (rowTpl refRows .split (.wide ${blocks} ⟨8, ${mt}⟩) .causal) := by
  have h9 : ¬ n ≤ 8 := by omega
  have h3 : ¬ n ≤ 3 := by omega
  have h4 : ¬ n = 4 := by omega
  have h5 : ¬ n = 5 := by omega
  have h223 : n ≤ 223 := by omega
  have hb : Metal.Kernels.GateUpMmaWide.rowBlocks n = ${blocks} := by
    unfold Metal.Kernels.GateUpMmaWide.rowBlocks
    ${hb}
  have hd : downPlan n = ⟨8, ${mt}⟩ := by
    have key : ∀ m, m < 224 → (${dec}) = true → downPlan m = ⟨8, ${mt}⟩ := by decide
    refine key n (by omega) ?_
    simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]
    omega
  dsimp only [gpuFamily]
  rw [if_neg h3, if_neg h4, if_neg h5, if_neg h9, if_pos h223, hb, hd]
  rfl

theorem rowFacts {r : Row} {i : Host.Ts.Sim.Lin.Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) :
    9 ≤ i.n ∧ i.n ≤ 223 ∧ gpuFamily .tail i.n = some (rowTpl refRows .split (.wide ${blocks} ⟨8, ${mt}⟩) .causal) := by
  have key := Host.Ts.Sim.Compose.VWFirst.${VW}.rowN hr hi
  exact ⟨by omega, by omega, plan key⟩

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The ${chain} group's \`hfwd\`.** -/
theorem hfwd (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (Cr : Nat → List (Option Nat × Option Nat)) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (hCr : ∀ r ∈ fwdRows, ∀ i, InRow r i → Cr i.L = cert.carriers) (T : Nat) (tk : Nat → Nat)
    (htail : ∀ r ∈ fwdRows, r ∈ firstTailRows) :
    ∀ r ∈ fwdRows, ∀ i, InRow r i → ∀ x y : SegInst FF,
      (startCore 15235 T tk π i).R y (startCore 15235 T tk π i).s0 ⟨(startCore 15235 T tk π i).tab0, []⟩ →
      Host.Ts.Sim.CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens →
      memCold P KR net env π i.L x → memPre P KR NE net env π Cr i.L y := by
  intro r hr i hi x y hy hle hg ht hm
  obtain ⟨h9, h223, hf⟩ := rowFacts hr hi
  obtain ⟨_, _, hn, _⟩ := firstTailFacts (htail r hr) hi
  have hparam : ∀ p ∈ parameterTensors parameterChoice, p.node < 15235 := fun p hp =>
    of_decide_eq_true (List.all_eq_true.mp ld_params_below p hp)
  exact bodyFwd (P := P) (KR := KR) (NE := NE) (net := net) (env := env) (π := π) cert leaves typed Cr hlt (NB := 15235) (T := T)
    (tk := tk) (Nat.le_refl _) (s := ${T}.s0) (S := ${T}.S0)
    rfl tab_eq rfl rfl hparam (hCr r hr i hi) h9 h223 (by omega) hf hy hle hg ht hm

end ${NS}
`);
