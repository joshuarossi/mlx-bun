import host.ts.RenameRuntimePureCases
import host.ts.RenameBufferPureEffects
import host.ts.RenameRuntimeNotes
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- One invariant for the actual source dispatcher. Cell notes are shared with
the runtime inventory so a store cannot update one copy and leave another stale. -/
structure RetainedNotes where
  runtime : RuntimeNotes
  privates : PrivateNotes
  captures : NativeCaptureNotes
  arrays : ArrayNotes
  publicFields : PublicNotes
  buffers : BufferNotes
def RetainedNotes.heap (notes : RetainedNotes) : HeapNotes :=
  ⟨notes.runtime.cells,notes.privates,notes.captures⟩
def RetainedNotes.withRuntime (notes : RetainedNotes) (runtime : RuntimeNotes) : RetainedNotes :=
  {notes with runtime := runtime}

structure RetainedInventory {S : Type} (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (live : Nat → Prop) (source target : St S) : Prop where
  runtime : RuntimeInventory notes.runtime ν₀ ν C₀ C R live source target
  privates : PrivateInventory notes.privates ν₀ ν C₀ C R live source target
  captures : NativeCaptureInventory notes.captures ν₀ ν C₀ C R live source target
  arrays : ArrayInventory notes.arrays ν₀ ν C₀ C R live source target
  publicFields : PublicInventory notes.publicFields ν₀ ν C₀ C R live source target
  buffers : BufferInventory notes.buffers ν₀ ν C₀ C R live source target

theorem RetainedInventory.heapInventory {S : Type} {notes : RetainedNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {source target : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target) :
    HeapInventory notes.heap ν₀ ν C₀ C R live source target :=
  ⟨inventory.runtime.cellInventory,inventory.privates,inventory.captures⟩

/-- The checked runtime primitive supplies its new control/stack/cell notes.
The original source/target effect certificates frame all other retained data. -/
theorem RetainedInventory.pure_step {F : Ffi} {notes : RetainedNotes} {nextRuntime : RuntimeNotes}
    {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop}
    {source target nextSource nextTarget : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (runtime : RuntimeInventory nextRuntime ν₀ ν D₀ D R live nextSource nextTarget)
    (effects : PureRuntimeCase F source target)
    (sourceRun : interpC (step F source).run C₀ = some (nextSource,D₀))
    (targetRun : interpC (step F target).run C = some (nextTarget,D))
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    RetainedInventory (notes.withRuntime nextRuntime) ν₀ ν D₀ D R live nextSource nextTarget := by
  obtain ⟨sourceEffects,targetEffects⟩ := effects.effects sourceRun targetRun
  have heap := inventory.heapInventory.pure_effects sourceEffects targetEffects sourceExtension targetExtension
  exact ⟨runtime,heap.privates,heap.captures,
    inventory.arrays.pure_effects sourceEffects targetEffects sourceExtension targetExtension,
    inventory.publicFields.pure_effects sourceEffects targetEffects sourceExtension targetExtension,
    inventory.buffers.pure_effects sourceEffects targetEffects sourceExtension targetExtension⟩
end Host.Ts.Owned.Annotated
