import host.route.FamFwd
import host.route.GpuLoad
import host.route.cert.VW6.Cert
import host.route.cert.VW6.Tab
import host.sim.compose.a4b.vw6.sfx.VWForward
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.VWFirst.VW6
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem rowN {r : Row} {i : Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) :
    (17 ≤ i.n ∧ i.n ≤ 24) := by
  simp only [fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [first_tail_x6.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

end Host.Ts.Sim.Compose.VWFirst.VW6

namespace Host.Route.Cert.VW6
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Lin.Cls (Row InRow)
open Host.Mlx.SimGraph.Ref (gpuFamily refRows downPlan)
open Host.Ts.Sim.Compose.VWFirst (firstTailFacts firstTailRows)
open Host.Ts.Sim.Compose.VWFirst.VW6 (fwdRows)
open Host.Ts.Sim.Compose.VWFirst.VW6.Sfx (startCore)
open Host.Load.Run.Tpl
open Host.Route.PrefGraph

/-! # The x6 group's forward at the bookkeeping -/

theorem plan {n : Nat} (h : (17 ≤ n ∧ n ≤ 24)) :
    gpuFamily .tail n = some (rowTpl refRows .split (.wide 3 ⟨8, 3⟩) .causal) := by
  have h9 : ¬ n ≤ 8 := by omega
  have h3 : ¬ n ≤ 3 := by omega
  have h4 : ¬ n = 4 := by omega
  have h5 : ¬ n = 5 := by omega
  have h223 : n ≤ 223 := by omega
  have hb : Metal.Kernels.GateUpMmaWide.rowBlocks n = 3 := by
    unfold Metal.Kernels.GateUpMmaWide.rowBlocks
    rw [if_pos]
    unfold Metal.ceilDiv
    omega
  have hd : downPlan n = ⟨8, 3⟩ := by
    have key : ∀ m, m < 224 → ((decide (17 ≤ m) && decide (m ≤ 24))) = true → downPlan m = ⟨8, 3⟩ := by decide
    refine key n (by omega) ?_
    simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]
    omega
  dsimp only [gpuFamily]
  rw [if_neg h3, if_neg h4, if_neg h5, if_neg h9, if_pos h223, hb, hd]
  rfl

theorem rowFacts {r : Row} {i : Host.Ts.Sim.Lin.Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) :
    9 ≤ i.n ∧ i.n ≤ 223 ∧ gpuFamily .tail i.n = some (rowTpl refRows .split (.wide 3 ⟨8, 3⟩) .causal) := by
  have key := Host.Ts.Sim.Compose.VWFirst.VW6.rowN hr hi
  exact ⟨by omega, by omega, plan key⟩

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The x6 group's `hfwd`.** -/
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
    (tk := tk) (Nat.le_refl _) (s := PRE_first_tail_x6_r0_suffix.s0) (S := PRE_first_tail_x6_r0_suffix.S0)
    rfl tab_eq rfl rfl hparam (hCr r hr i hi) (by omega) h223 (by omega) (by omega) (by omega) hf hy hle hg ht hm

end Host.Route.Cert.VW6
