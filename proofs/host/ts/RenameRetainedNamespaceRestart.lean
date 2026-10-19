import host.ts.RenameRetainedRestart
import host.ts.RenameLoopNamespaceAdvance

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Rebase the six reached inventories using the separate oracle and loop
namespaces. The oracle valuation stays fixed while the loop counters advance.
Execution and the reached inventory must still be supplied by the body proof. -/
theorem RetainedInventory.loop_restart_namespaced {S : Type} {notes renamed : RetainedNotes}
    {ν₀ μ η oracle : Nat → F64} {C₀ B D C : CSrv} {Q R : Ren}
    {live reachedLive : Nat → Prop} {s₀ u t₀ s : St S}
    (template : RetainedInventory notes ν₀ μ C₀ B Q live s₀ u)
    (K : Ren) (prompt index limit capacity : Nat) (growth : Bool)
    (counterBound : index+1 < 2^53) (capacityBound : capacity+256 < 2^53)
    (covers : notes.RenameCovers renamed K)
    (reached : RetainedInventory (renamed.subst (LoopVariables.advance growth)) η
      (LoopVariables.valuation oracle (loopValuation prompt index limit capacity))
      D C R reachedLive t₀ s) :
    RetainedInventory notes ν₀
      (LoopVariables.valuation oracle
        (loopValuation prompt (index+1) limit (if growth then capacity+256 else capacity)))
      C₀ C (composeResources R K) live s₀ s := by
  have reset := template.rebase_target K (LoopVariables.advance growth) covers reached
  rw [LoopVariables.advance_valuation oracle prompt index limit capacity growth counterBound capacityBound] at reset
  exact reset

/-- The supported context bound supplies binary64 exactness for the same
restart. No independent numeric-bound assumptions are needed at this layer. -/
theorem RetainedInventory.loop_restart_supported {S : Type} {notes renamed : RetainedNotes}
    {ν₀ μ η oracle : Nat → F64} {C₀ B D C : CSrv} {Q R : Ren}
    {live reachedLive : Nat → Prop} {s₀ u t₀ s : St S}
    (template : RetainedInventory notes ν₀ μ C₀ B Q live s₀ u)
    (K : Ren) (prompt index limit capacity : Nat) (growth : Bool)
    (supported : prompt+limit ≤ 262144) (continuing : index < limit) (capacitySupported : capacity ≤ 262144)
    (covers : notes.RenameCovers renamed K)
    (reached : RetainedInventory (renamed.subst (LoopVariables.advance growth)) η
      (LoopVariables.valuation oracle (loopValuation prompt index limit capacity))
      D C R reachedLive t₀ s) :
    RetainedInventory notes ν₀
      (LoopVariables.valuation oracle
        (loopValuation prompt (index+1) limit (if growth then capacity+256 else capacity)))
      C₀ C (composeResources R K) live s₀ s := by
  exact template.loop_restart_namespaced K prompt index limit capacity growth
    (by omega) (by omega) covers reached

end Host.Ts.Owned.Annotated
