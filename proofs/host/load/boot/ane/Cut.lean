import host.load.boot.ane.Ld
import host.load.boot.ane.Graph
import host.load.boot.Boot
namespace Host.Load.Run.Prompt
open Host.Ts Host.Mlx Host.Mlx.FfiAneEval Host.Load Host.Load.Boot
open Host.Ts.Sim.Full (bridgeOf)

/-! # The loadDone cut's server and Neural Engine memory

The boot's server at `loadDone` is the load's table with no oracle answers (`P.S2818_eq`); the full world's
bridge there has run nothing, so its Neural Engine memory, from any loaded surfaces `init`, is `init` with no
fixed values and nothing pending (`ldBridge_final`; `SimGraph.aneMem_final` turns it into `aneMem`'s). -/

theorem P.S2818_eq : P.S2818 = ⟨Decode.tab, []⟩ := by
  rw [← P.S2818_tab, ← Ld.S2818_oracle]

theorem ldBridge_final {C : Inference.Contracts.Mlx.M1Max.Contract} (Pm : MlxPrefillContract C)
    (K : RouteKernelContract C) (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
    (NE : NeuralEngine) (IP : InPlace) (G : Graph) (init : Nat → Surface) (fw : List Val) (τ : List NumV) :
    final Pm K weights kind NE IP G init (bridgeOf (ldStT fw τ).ffi) = some ⟨init, fun _ => none, fun _ => none⟩ := by
  show final Pm K weights kind NE IP G init (ldStT fw τ).ffi.1.1.bridge = _
  rw [aneNetLd_bridge]
  unfold final
  rw [replay_log]
  rfl

end Host.Load.Run.Prompt
