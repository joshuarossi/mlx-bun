import host.route.GpuLoad
import host.route.GpuMem
import host.route.Gpu
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Ts Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Load.Run.Prompt (ldStT)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF)

/-! # The load cut's bookkeeping

`ld_mem`: at the boot's end, the prefill's cold bookkeeping, and the emitted array at its own address (the load cut's map is the
identity). -/

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The load entry's bookkeeping**, for every length. -/
theorem ld_mem (leaves : Leaves code env.weights) (fw : List Val) (τ : List NumV) {NB : Nat} {Pw : Host.Ts.Sim.LoadP}
    {W : Nat → Option Host.Ts.Sim.WFrame} {s0 : St FF.S} {T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hb : (ldPromptCutAt NB Pw W s0 T tk π (ldStT fw τ)).B x) (L : Nat) :
    memCold P KR net env π L x ∧ x.M.a 12504 = 12504 := by
  refine ⟨fun _ kind => coldG_ld P KR net env kind leaves fw τ hb.2, ?_⟩
  have hM : x.M = Host.Ts.Sim.Map.id := hb.1.1.1
  rw [hM]
  rfl

end Host.Route.PrefGraph
