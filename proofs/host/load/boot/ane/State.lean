import host.load.boot.ane.Ld
import host.load.boot.ane.Frame
namespace Host.Load.Run.Prompt
open Host.Ts Host.Mlx Host.Mlx.FfiAneEval Host.Mlx.SimGraph.Ref Host.Load Host.Load.Boot Host.Load.Extract

/-! # The Neural Engine side read off the boot's end state

`aneNetSt t c init`: the Neural Engine side of a full-world state `t` — the buckets its load state's model
object holds (`aneX`: each array an `Extract.tensor` of that state, its handle's graph node,
`tensor_live`), on `t`'s bridge, the arrays' values `headerValues c` (contents `c t.node`), the
surfaces `init`. At `loadDone` (`ldStT fw τ`, every prompt `fw` and readback suffix `τ`) it is
`aneNetLd c init` (`aneNetLd_state`), and the bridge's memory there holds `init` (`aneNetSt_mem`):
whatever contents the loaded graph gives its arrays (`c`) and whatever the surfaces hold when the bridge
starts (`init`), the route's Neural Engine side is the one the boot's end state holds. -/

/-- A full-world state's Neural Engine buckets (its load state's). -/
noncomputable def aneOf (t : St Layers.full.S) : List ABucket := (aneX (t.reFfi t.ffi.1.1.base) aneModel).getD []

/-- **The Neural Engine side read off a full-world state.** -/
noncomputable def aneNetSt (t : St Layers.full.S) (c : Nat → Nat → Nat) (init : Nat → Surface) : AneNet :=
  aneNetOf (aneOf t) t.ffi.1.1.bridge c init

/-- An extracted array is the state's: its handle names its graph node, which holds its node. -/
theorem tensor_live {s : St LSt} {v : Val} {x : Tensor} (h : tensor s v = some x) :
    s.ffi.mlx.nodeId? x.handle = some x.node ∧ s.ffi.mlx.nodes.get x.node = some x.value := by
  unfold tensor at h
  obtain ⟨hd, _, h⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨i, hi, h⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨nd, hn, h⟩ := Option.bind_eq_some_iff.mp h
  cases h
  exact ⟨hi, hn⟩

theorem reFfi_reFfi {S T U : Type} (s : St S) (x : T) (y : U) : (s.reFfi x).reFfi y = s.reFfi y := rfl

theorem reFfi_self {S : Type} (s : St S) : s.reFfi s.ffi = s := by
  cases s
  rfl

theorem ldStT_load (fw : List Val) (τ : List NumV) :
    (ldStT fw τ).reFfi (ldStT fw τ).ffi.1.1.base = P.at2818 fw τ := by
  unfold ldStT
  rw [reFfi_reFfi]
  exact reFfi_self _

/-- **At `loadDone`, the Neural Engine side the end state holds is `aneNetLd`**, every prompt and readback
suffix. -/
theorem aneNetLd_state (fw : List Val) (τ : List NumV) (c : Nat → Nat → Nat) (init : Nat → Surface) :
    aneNetSt (ldStT fw τ) c init = aneNetLd c init := by
  unfold aneNetSt aneOf aneNetLd aneLd
  rw [ldStT_load, aneX_any, aneNetLd_bridge]

/-- **The bridge's memory at `loadDone` holds the side's surfaces**: the bridge has run nothing. -/
theorem aneNetSt_mem {C : Inference.Contracts.Mlx.M1Max.Contract} (Pm : MlxPrefillContract C)
    (K : RouteKernelContract C) (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
    (NE : NeuralEngine) (IP : InPlace) (G : Graph) (fw : List Val) (τ : List NumV) (c : Nat → Nat → Nat)
    (init : Nat → Surface) :
    final Pm K weights kind NE IP G init (ldStT fw τ).ffi.1.1.bridge =
      some ⟨(aneNetSt (ldStT fw τ) c init).surfaces, fun _ => none, fun _ => none⟩ := by
  rw [aneNetLd_state, aneNetLd_bridge]
  exact aneNetLd_surfaces Pm K weights kind NE IP G c init

end Host.Load.Run.Prompt
