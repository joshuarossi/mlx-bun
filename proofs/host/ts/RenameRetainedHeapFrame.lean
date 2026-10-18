import host.ts.RenameRetainedInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- A checked rule's exact heap equations frame the remaining inventories.
The new runtime notes and original executions are supplied by that rule. -/
theorem RetainedInventory.heap_step {S : Type} {notes : RetainedNotes} {nextRuntime : RuntimeNotes}
    {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop}
    {source target nextSource nextTarget : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (runtime : RuntimeInventory nextRuntime ν₀ ν D₀ D R live nextSource nextTarget)
    (sourceHeap : nextSource.heap = source.heap) (targetHeap : nextTarget.heap = target.heap)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D) :
    RetainedInventory (notes.withRuntime nextRuntime) ν₀ ν D₀ D R live nextSource nextTarget :=
  ⟨runtime,
    (inventory.privates.mono sourceExtension targetExtension).frame (fun _ h => h)
      (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap]),
    (inventory.captures.mono sourceExtension targetExtension).frame (fun _ h => h)
      (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap]),
    (inventory.arrays.mono sourceExtension targetExtension).frame (fun _ h => h)
      (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap]),
    (inventory.publicFields.mono sourceExtension targetExtension).frame (fun _ h => h)
      (fun _ _ _ _ => by rw [sourceHeap]) (fun _ _ _ _ => by rw [targetHeap]),
    (inventory.buffers.mono sourceExtension targetExtension).frame (fun _ h => h)
      (fun _ _ _ => by rw [sourceHeap]) (fun _ _ _ => by rw [targetHeap])⟩

end Host.Ts.Owned.Annotated
