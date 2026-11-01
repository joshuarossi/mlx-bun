import host.route.FamFwd
import host.route.GpuLoad
import host.route.cert.X1.Cert
import host.route.cert.X1.Tab
import host.sim.compose.a4b.x1.sfx.VWForward
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem rowN {r : Row} {i : Cls.Inst} (hr : r ∈ fwdClassRows) (hi : InRow r i) :
    (2 ≤ i.n ∧ i.n ≤ 3) := by
  simp only [fwdClassRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [first_tail_x1.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

end Host.Ts.Sim.Compose.VWFirst.X1

namespace Host.Route.Cert.X1
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Lin.Cls (Row InRow)
open Host.Mlx.SimGraph.Ref (gpuFamily refRows downPlan)
open Host.Ts.Sim.Compose.VWFirst (firstTailFacts firstTailRows)
open Host.Ts.Sim.Compose.VWFirst.X1 (fwdClassRows)
open Host.Ts.Sim.Compose.VWFirst.X1.Sfx (startCore)
open Host.Load.Run.Tpl
open Host.Route.PrefGraph

/-! # The x1 group's forward at the bookkeeping -/

theorem plan {n : Nat} (h : (2 ≤ n ∧ n ≤ 3)) :
    gpuFamily .tail n = some (rowTpl refRows .rows .codebook .causal) := by
  have h3 : n ≤ 3 := by omega
  dsimp only [gpuFamily]
  rw [if_pos h3]
  rfl

theorem rowFacts {r : Row} {i : Host.Ts.Sim.Lin.Cls.Inst} (hr : r ∈ fwdClassRows) (hi : InRow r i) :
    2 ≤ i.n ∧ i.n ≤ 3 ∧ gpuFamily .tail i.n = some (rowTpl refRows .rows .codebook .causal) := by
  have key := Host.Ts.Sim.Compose.VWFirst.X1.rowN hr hi
  exact ⟨by omega, by omega, plan key⟩

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The x1 group's `hfwd`.** -/
theorem hfwd (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (Cr : Nat → List (Option Nat × Option Nat)) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (hCr : ∀ r ∈ fwdClassRows, ∀ i, InRow r i → Cr i.L = cert.carriers) (T : Nat) (tk : Nat → Nat)
    (htail : ∀ r ∈ fwdClassRows, r ∈ firstTailRows) :
    ∀ r ∈ fwdClassRows, ∀ i, InRow r i → ∀ x y : SegInst FF,
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
    (tk := tk) (Nat.le_refl _) (s := PRE_first_tail_x1_r0_suffix.s0) (S := PRE_first_tail_x1_r0_suffix.S0)
    rfl tab_eq rfl rfl hparam (hCr r hr i hi) (by omega) (by omega) (by omega) (by omega) (by omega) hf hy hle hg ht hm

end Host.Route.Cert.X1
