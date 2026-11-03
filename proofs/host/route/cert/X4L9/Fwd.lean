import host.route.FamFwd
import host.route.GpuLoad
import host.route.cert.X4L9.Cert
import host.route.cert.X4L9.Tab
import host.sim.compose.a4b.x4_L9.sfx.VWForward
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.Cert.X4L9
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Lin.Cls (Row InRow)
open Host.Mlx.SimGraph.Ref (gpuFamily refRows)
open Host.Ts.Sim.Compose.VWFirst (firstTailFacts firstTailRows)
open Host.Ts.Sim.Compose.VWFirst.X4_L9 (fwdRows)
open Host.Ts.Sim.Compose.VWFirst.X4_L9.Sfx (startCore)
open Host.Load.Run.Tpl
open Host.Route.PrefGraph

/-! # The x4_L9 group's forward at the bookkeeping: the prompts of 9 tokens -/

theorem plan : gpuFamily .tail 8 = some (rowTpl refRows .split .codebook (.folded 8)) := rfl

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The x4_L9 group's `hfwd`.** -/
theorem hfwd (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (Cr : Nat → List (Option Nat × Option Nat)) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (hCr : Cr 9 = cert.carriers) (hL : π.length = 9) (T : Nat) (tk : Nat → Nat)
    (htail : ∀ r ∈ fwdRows, r ∈ firstTailRows) :
    ∀ r ∈ fwdRows, ∀ i, InRow r i → ∀ x y : SegInst FF,
      (startCore 15235 T tk π i).R y (startCore 15235 T tk π i).s0 ⟨(startCore 15235 T tk π i).tab0, []⟩ →
      Host.Ts.Sim.CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens →
      memCold P KR net env π i.L x → memPre P KR NE net env π Cr i.L y := by
  intro r hr i hi x y hy hle hg ht hm
  obtain ⟨_, _, hn, _⟩ := firstTailFacts (htail r hr) hi
  have hparam : ∀ p ∈ parameterTensors parameterChoice, p.node < 15235 := fun p hp =>
    of_decide_eq_true (List.all_eq_true.mp ld_params_below p hp)
  have hiL : i.L = 9 := by
    obtain ⟨_, _, hb, _⟩ := hy
    rw [← hb.length, hL]
  exact bodyFwdL (P := P) (KR := KR) (NE := NE) (net := net) (env := env) (π := π) cert leaves typed Cr hlt (NB := 15235) (T := T)
    (tk := tk) (Nat.le_refl _) (s := PRE_first_tail_x4_L9_r0_suffix.s0) (S := PRE_first_tail_x4_L9_r0_suffix.S0) 8
    rfl tab_eq rfl rfl hparam hL (by decide) (by decide) (by rw [hiL]; exact hCr) (by omega) plan hy hle hg ht hm

end Host.Route.Cert.X4L9
