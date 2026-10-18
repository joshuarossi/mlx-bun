import host.ts.BuiltinCaptureInitialization
import host.ts.InitCaptureConstruction
import host.ts.renameOrdinary.RankOriginOwnership

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- This is the real source constructor, selected before rank initialization,
with the same metadata later used at the actual typed-buffer construction. -/
theorem initial_int32_heap : input.heap.get 90 = some (.obj TypedBuffer.constructorObject) := by host_kernel_rfl

theorem initial_int32_capture (ν : Nat → F64) (C : CSrv) (R : Ren) (fixed : R.a 90 = 90) :
    (NativeCaptureNote.typedConstructor 4 21).Holds ν C R 90 input := by
  apply NativeCaptureNote.typedConstructor_holds ν C R input 90 4 21 TypedBuffer.constructorObject _ TypedBuffer.source_kind
  simpa only [fixed] using initial_int32_heap

def initialTypedCaptures : NativeCaptureNotes :=
  NativeCaptureNotes.empty.write 90 (NativeCaptureNote.typedConstructor 4 21)

theorem initialTypedCaptures_selected : initialTypedCaptures.owners 90 = some (NativeCaptureNote.typedConstructor 4 21) := rfl

/-- The actual entry state has these initialized literals for every valuation
and numeric table. This lemma does not reinterpret an arbitrary related heap. -/
theorem initial_int32_inventory (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live : Nat → Prop)
    (alive : live 90) (fixed : R.a 90 = 90) :
    NativeCaptureInventory initialTypedCaptures ν₀ ν C₀ C R live input input :=
  NativeCaptureInventory.empty.annotate 90 (NativeCaptureNote.typedConstructor 4 21) alive
    (initial_int32_capture ν₀ C₀ identity rfl) (initial_int32_capture ν C R fixed)

/-- Numeric specialization of the reached source state preserves both literal
metadata positions, independently of how its native world is specialized. -/
theorem materialized_int32_inventory (ffiMap : CSrv → LSt → LSt) (table : CSrv)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live : Nat → Prop)
    (alive : live 90) (fixed : R.a 90 = 90) :
    NativeCaptureInventory initialTypedCaptures ν₀ ν C₀ C R live input (materializeStateWith ffiMap table input) := by
  apply NativeCaptureInventory.empty.annotate 90 (NativeCaptureNote.typedConstructor 4 21) alive
    (initial_int32_capture ν₀ C₀ identity rfl)
  apply NativeCaptureNote.typedConstructor_materialized ffiMap table C ν R input 90 4 21 TypedBuffer.constructorObject _ TypedBuffer.source_kind
  simpa only [fixed] using initial_int32_heap

end Host.Load.Run.Full.Ordinary.RankOrigin
