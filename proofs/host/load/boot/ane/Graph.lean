import host.load.boot.ld.Full
import host.load.ProgramValues
namespace Host.Load.Run.Prompt
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Load Host.Load.Boot
open Host.Ts.Sim.Full (mlxOf)

/-! # The loaded graph is the same for every prompt and readback suffix

`loadDone`'s graph state for the prompt `fw` and the unread readbacks `τ` is the template's with the
readback tokens `.ref 1, .ref 2, τ` (`ldStT_mlx`: the prompt is a heap array, `Ld.frameT`; the readbacks
are the load state's token list, `Ld.Y_mlx`), and the FFI graph reads only its nodes and objects
(`ffiGraph`, `kernelName?`), so the loaded graph — and every value read off it, as `Program.contents` —
is the template's (`ldGraph_any`). -/

theorem ldStT_mlx (fw : List Val) (τ : List NumV) : mlxOf (ldStT fw τ).ffi = Ld.Yn τ := by
  show (P.at2818 fw τ).ffi.mlx = Ld.Yn τ
  rw [Ld.frameT fw τ]
  exact Ld.Y_mlx τ

/-- **The loaded graph at `loadDone` is the template's**, every prompt and readback suffix. -/
theorem ldGraph_any {δ κ : Type} (N : Nums δ) (S : KernelSources) (fw : List Val) (τ : List NumV) :
    (ffiGraph N S (mlxOf (ldStT fw τ).ffi) : Nat → Option (RNode δ κ)) = ffiGraph N S (mlxOf (ldStT [] []).ffi) := by
  rw [ldStT_mlx, ldStT_mlx]
  rfl

/-- The loaded arrays' contents (`Program.contents` of the loaded graph) are the template's. -/
theorem ldContents_any {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (N : Nums Int) (S : KernelSources) (fw : List Val) (τ : List NumV) :
    Program.contents M K env (ffiGraph N S (mlxOf (ldStT fw τ).ffi)) =
      Program.contents M K env (ffiGraph N S (mlxOf (ldStT [] []).ffi)) := by
  rw [ldGraph_any]

end Host.Load.Run.Prompt
