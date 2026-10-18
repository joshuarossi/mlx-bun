import host.ts.RenameRetainedRebase
import host.ts.RenameAnnotatedLoop
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Reusing a checked source template keeps its source meanings and live keys.
Only the target side is replaced, using annotations already proved at that
target. A whole-state relation and execution are separate obligations. -/
theorem RetainedInventory.with_target {S : Type} {notes : RetainedNotes}
    {ν₀ μ ν : Nat → F64} {C₀ B C : CSrv} {Q R : Ren} {live : Nat → Prop}
    {s₀ u s : St S} (template : RetainedInventory notes ν₀ μ C₀ B Q live s₀ u)
    (target : notes.Holds ν C R s) : RetainedInventory notes ν₀ ν C₀ C R live s₀ s :=
  ⟨⟨template.runtime.keyLive,template.runtime.source,target.runtime⟩,
    ⟨template.privates.keyLive,template.privates.source,target.privates⟩,
    ⟨template.captures.keyLive,template.captures.source,target.captures⟩,
    ⟨template.arrays.keyLive,template.arrays.source,target.arrays,template.arrays.sourceClosed⟩,
    ⟨template.publicFields.keyLive,template.publicFields.source,target.publicFields⟩,
    ⟨template.buffers.keyLive,template.buffers.source,target.buffers⟩⟩

/-- Reset all six annotation families from a reached inventory, using one
resource composition and one numeric substitution. Covers must be established
for the actual reached notes; no new operand meaning is chosen here. -/
theorem RetainedInventory.rebase_target {S : Type} {notes renamed : RetainedNotes}
    {ν₀ μ η ν : Nat → F64} {C₀ B D C : CSrv} {Q R : Ren}
    {live reachedLive : Nat → Prop} {s₀ u t₀ s : St S}
    (template : RetainedInventory notes ν₀ μ C₀ B Q live s₀ u)
    (K : Ren) (θ : Nat → SymE) (covers : notes.RenameCovers renamed K)
    (reached : RetainedInventory (renamed.subst θ) η ν D C R reachedLive t₀ s) :
    RetainedInventory notes ν₀ (nextValuation θ ν) C₀ C (composeResources R K) live s₀ s :=
  template.with_target (RetainedNotes.Holds.rebase K θ covers reached.targetHolds)

/-- The loop's retained control, cells, fields, captures, arrays and bytes
advance the counter and, on growth, the capacity. The template's source side
is unchanged; the reached target supplies the next iteration's fixed roles. -/
theorem RetainedInventory.loop_restart {S : Type} {notes renamed : RetainedNotes}
    {ν₀ μ η : Nat → F64} {C₀ B D C : CSrv} {Q R : Ren}
    {live reachedLive : Nat → Prop} {s₀ u t₀ s : St S}
    (template : RetainedInventory notes ν₀ μ C₀ B Q live s₀ u)
    (K : Ren) (prompt index limit capacity : Nat) (growth : Bool)
    (counterBound : index+1 < 2^53) (capacityBound : capacity+256 < 2^53)
    (covers : notes.RenameCovers renamed K)
    (reached : RetainedInventory (renamed.subst (advanceRoles growth)) η
      (loopValuation prompt index limit capacity) D C R reachedLive t₀ s) :
    RetainedInventory notes ν₀
      (loopValuation prompt (index+1) limit (if growth then capacity+256 else capacity))
      C₀ C (composeResources R K) live s₀ s := by
  have reset := template.rebase_target K (advanceRoles growth) covers reached
  rw [advanceRoles_eval prompt index limit capacity growth counterBound capacityBound] at reset
  exact reset

end Host.Ts.Owned.Annotated
