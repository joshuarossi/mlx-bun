import host.mlx.NativeWritesFrame
import host.ts.RenamePublicInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Accepted native writes retain public descriptors even at the written
buffer owner. This follows from the original object-header update. -/
theorem NativeHeapFrame.publicData {S : Type} {s t : St S} (frame : NativeHeapFrame s t)
    {owner : Nat} {name : Name} {value : Val} (field : PublicData s owner name value) :
    PublicData t owner name value := by
  obtain ⟨object,w,e,read,descriptor⟩ := field
  obtain ⟨kind,target⟩ := frame.headers owner object read
  exact ⟨{object with kind := kind},w,e,target,descriptor⟩

theorem NativeHeapFrame.publicNotes {S : Type} {s t : St S} (frame : NativeHeapFrame s t)
    {notes : PublicNotes} {ν : Nat → F64} {C : CSrv} {R : Ren} (held : notes.Holds ν C R s) : notes.Holds ν C R t := by
  intro a name role selected
  obtain ⟨value,field,role⟩ := held a name role selected
  exact ⟨value,frame.publicData field,role⟩

theorem PublicInventory.nativeFrame {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : NativeHeapFrame s₀ t₀) (target : NativeHeapFrame s t) :
    PublicInventory notes ν₀ ν C₀ C R live t₀ t :=
  ⟨inventory.keyLive,source.publicNotes inventory.source,target.publicNotes inventory.target⟩

theorem PublicInventory.nativeFrame_mono {S : Type} {notes : PublicNotes} {ν₀ ν : Nat → F64}
    {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : PublicInventory notes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D)
    (source : NativeHeapFrame s₀ t₀) (target : NativeHeapFrame s t) :
    PublicInventory notes ν₀ ν D₀ D R live t₀ t :=
  (inventory.mono sourceExtension targetExtension).nativeFrame source target

theorem native_status_frame_inventories {S : Type} {notes : RuntimeNotes}
    {privates : PrivateNotes} {captures : NativeCaptureNotes} {arrayNotes : ArrayNotes} {publicNotes : PublicNotes}
    {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (runtime : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (publicInventory : PublicInventory publicNotes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D)
    (source : NativeHeapFrame s₀ t₀) (target : NativeHeapFrame s t)
    (sourceControl : t₀.ctl = .ret (.num zeroN)) (targetControl : t.ctl = .ret (.num zeroN)) :
    RuntimeInventory {notes with control := returnNote nativeStatusRole} ν₀ ν D₀ D R live t₀ t ∧
    HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν D₀ D R live t₀ t ∧
    ArrayInventory arrayNotes ν₀ ν D₀ D R live t₀ t ∧
    PublicInventory publicNotes ν₀ ν D₀ D R live t₀ t :=
  ⟨(runtime.mono sourceExtension targetExtension).nativeFrame_return source target nativeStatusRole _ _
      sourceControl targetControl (nativeStatusRole_holds _ _ _) (nativeStatusRole_holds _ _ _),
    (heapInventory.mono sourceExtension targetExtension).nativeFrame source target,
    (arrayInventory.mono sourceExtension targetExtension).nativeFrame source target,
    publicInventory.nativeFrame_mono sourceExtension targetExtension source target⟩

end Host.Ts.Owned.Annotated
