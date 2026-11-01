import host.route.FamFwd
import host.route.GpuLoad
import host.route.cert.VW15.Cert
import host.route.cert.VW15.Tab
import host.sim.compose.a4b.vw15.sfx.VWForward
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

theorem rowN {r : Row} {i : Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) :
    (9 ≤ i.n ∧ i.n ≤ 16) ∨ (25 ≤ i.n ∧ i.n ≤ 32) ∨ (49 ≤ i.n ∧ i.n ≤ 64) ∨ (73 ≤ i.n ∧ i.n ≤ 80) ∨
      (97 ≤ i.n ∧ i.n ≤ 112) ∨ (121 ≤ i.n ∧ i.n ≤ 128) ∨ (145 ≤ i.n ∧ i.n ≤ 160) ∨ (169 ≤ i.n ∧ i.n ≤ 176) ∨
      (217 ≤ i.n ∧ i.n ≤ 223) := by
  simp only [fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0,
      first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega

end Host.Ts.Sim.Compose.VWFirst.VW15

namespace Host.Route.Cert.VW15
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Lin.Cls (Row InRow)
open Host.Mlx.SimGraph.Ref (gpuFamily refRows downPlan)
open Host.Ts.Sim.Compose.VWFirst (forwardCut firstTailFacts firstTailRows)
open Host.Ts.Sim.Compose.VWFirst.VW15 (fwdRows bodyN)
open Host.Ts.Sim.Compose.VWFirst.VW15.Sfx (startCore)
open Host.Load.Run.Tpl
open Host.Route.PrefGraph

/-! # The x15 group's forward at the bookkeeping -/

theorem plan82 {n : Nat} (h : (9 ≤ n ∧ n ≤ 16) ∨ (25 ≤ n ∧ n ≤ 32) ∨ (49 ≤ n ∧ n ≤ 64) ∨ (73 ≤ n ∧ n ≤ 80) ∨
    (97 ≤ n ∧ n ≤ 112) ∨ (121 ≤ n ∧ n ≤ 128) ∨ (145 ≤ n ∧ n ≤ 160) ∨ (169 ≤ n ∧ n ≤ 176) ∨ (217 ≤ n ∧ n ≤ 223)) :
    gpuFamily .tail n = some (rowTpl refRows .split (.wide 2 ⟨8, 2⟩) .causal) := by
  have h9 : ¬ n ≤ 8 := by omega
  have h3 : ¬ n ≤ 3 := by omega
  have h4 : ¬ n = 4 := by omega
  have h5 : ¬ n = 5 := by omega
  have h223 : n ≤ 223 := by omega
  have hb : Metal.Kernels.GateUpMmaWide.rowBlocks n = 2 := by
    unfold Metal.Kernels.GateUpMmaWide.rowBlocks
    rw [if_neg]
    unfold Metal.ceilDiv
    omega
  have hd : downPlan n = ⟨8, 2⟩ := by
    have key : ∀ m, m < 224 → ((decide (9 ≤ m) && decide (m ≤ 16)) || (decide (25 ≤ m) && decide (m ≤ 32)) ||
        (decide (49 ≤ m) && decide (m ≤ 64)) || (decide (73 ≤ m) && decide (m ≤ 80)) ||
        (decide (97 ≤ m) && decide (m ≤ 112)) || (decide (121 ≤ m) && decide (m ≤ 128)) ||
        (decide (145 ≤ m) && decide (m ≤ 160)) || (decide (169 ≤ m) && decide (m ≤ 176)) ||
        (decide (217 ≤ m) && decide (m ≤ 223))) = true → downPlan m = ⟨8, 2⟩ := by decide
    refine key n (by omega) ?_
    simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]
    omega
  dsimp only [gpuFamily]
  rw [if_neg h3, if_neg h4, if_neg h5, if_neg h9, if_pos h223, hb, hd]
  rfl

theorem rowFacts {r : Row} {i : Host.Ts.Sim.Lin.Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) :
    9 ≤ i.n ∧ i.n ≤ 223 ∧ gpuFamily .tail i.n = some (rowTpl refRows .split (.wide 2 ⟨8, 2⟩) .causal) := by
  have key := Host.Ts.Sim.Compose.VWFirst.VW15.rowN hr hi
  exact ⟨by omega, by omega, plan82 key⟩

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The x15 group's `hfwd`.** -/
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
    (tk := tk) (Nat.le_refl _) (s := PRE_first_tail_x15_r0_suffix.s0) (S := PRE_first_tail_x15_r0_suffix.S0)
    rfl tab_eq rfl rfl hparam (hCr r hr i hi) h9 h223 (by omega) hf hy hle hg ht hm

end Host.Route.Cert.VW15
