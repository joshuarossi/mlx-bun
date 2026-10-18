import host.ts.renameOrdinary.RankOriginSourceFrame
import host.ts.renameOrdinary.RuntimeRetainedSeed
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem initial_rank_uninitialized : input.heap.get Variable5.address = some (.cell none) := by host_kernel_rfl
theorem initial_pointer_uninitialized : input.heap.get PointerBinding48.sourceAddress = some (.cell none) := by host_kernel_rfl

section
variable {FR : Ren → LSt → LSt → Prop} {R : Ren} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
  {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s result : St LSt}
  {notes : RetainedNotes}

/-- Source object ownership proves that none of the retained object families
can alias either lexical cell written by the rank/shape prefix. -/
theorem object_heap_frames
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (frame : ∀ a, a < s.next → a ≠ R.a Variable5.address → a ≠ R.a PointerBinding48.sourceAddress →
      result.heap.get a = s.heap.get a)
    (a : Nat) (o : Obj) (object : input.heap.get a = some (.obj o)) (alive : live a) :
    Prefix.input.heap.get a = input.heap.get a ∧ result.heap.get (R.a a) = s.heap.get (R.a a) := by
  have notRank : a ≠ Variable5.address := by
    intro same
    rw [same,initial_rank_uninitialized] at object
    cases object
  have notPointer : a ≠ PointerBinding48.sourceAddress := by
    intro same
    rw [same,initial_pointer_uninitialized] at object
    cases object
  obtain ⟨rankLive,_⟩ := initial_owned_addresses _ _ _ _ _ _ _ _ _ _ h
  have pointerLive := initial_pointer_live _ _ _ _ _ _ _ _ _ _ h
  exact ⟨source_heap_frame a (h.heap.sourceBound a alive) notRank notPointer,
    frame (R.a a) (h.heap.targetBound a alive)
      (fun same => notRank (h.heap.inj a Variable5.address alive rankLive same))
      (fun same => notPointer (h.heap.inj a PointerBinding48.sourceAddress alive pointerLive same))⟩

/-- Existing annotations survive the actual prefix. The two previously
uninitialized lexical cells are annotated from its checked result afterwards. -/
theorem inventories_frame
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (rankAbsent : notes.runtime.cells.cells Variable5.address = none)
    (pointerAbsent : notes.runtime.cells.cells PointerBinding48.sourceAddress = none)
    (frame : ∀ a, a < s.next → a ≠ R.a Variable5.address → a ≠ R.a PointerBinding48.sourceAddress →
      result.heap.get a = s.heap.get a) :
    CellInventory notes.runtime.cells ν₀ ν C₀ C R (GetterLive live) Prefix.input result ∧
    PrivateInventory notes.privates ν₀ ν C₀ C R (GetterLive live) Prefix.input result ∧
    NativeCaptureInventory notes.captures ν₀ ν C₀ C R (GetterLive live) Prefix.input result ∧
    ArrayInventory notes.arrays ν₀ ν C₀ C R (GetterLive live) Prefix.input result ∧
    PublicInventory notes.publicFields ν₀ ν C₀ C R (GetterLive live) Prefix.input result ∧
    BufferInventory notes.buffers ν₀ ν C₀ C R (GetterLive live) Prefix.input result := by
  have grow : ∀ a, live a → GetterLive live a := ClosureLive.grow live EnterGetter28.input.next
    EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceFunction
  have objects := object_heap_frames h frame
  have cells := inventory.runtime.cellInventory
  have cellFrames : ∀ a role, notes.runtime.cells.cells a = some role →
      Prefix.input.heap.get a = input.heap.get a ∧ result.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a role entry
    have alive := cells.keyLive a role entry
    have notRank : a ≠ Variable5.address := by intro same; rw [same,rankAbsent] at entry; cases entry
    have notPointer : a ≠ PointerBinding48.sourceAddress := by intro same; rw [same,pointerAbsent] at entry; cases entry
    obtain ⟨rankLive,_⟩ := initial_owned_addresses _ _ _ _ _ _ _ _ _ _ h
    have pointerLive := initial_pointer_live _ _ _ _ _ _ _ _ _ _ h
    exact ⟨source_heap_frame a (h.heap.sourceBound a alive) notRank notPointer,
      frame (R.a a) (h.heap.targetBound a alive)
        (fun same => notRank (h.heap.inj a Variable5.address alive rankLive same))
        (fun same => notPointer (h.heap.inj a PointerBinding48.sourceAddress alive pointerLive same))⟩
  have privateFrames : ∀ a note, notes.privates.owners a = some note →
      Prefix.input.heap.get a = input.heap.get a ∧ result.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a note entry
    obtain ⟨_,⟨o,_,_,object,_⟩,_⟩ := inventory.privates.source a note entry
    exact objects a o object (inventory.privates.keyLive a note entry).1
  have captureFrames : ∀ a note, notes.captures.owners a = some note →
      Prefix.input.heap.get a = input.heap.get a ∧ result.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a note entry
    obtain ⟨o,_,object,_,_⟩ := inventory.captures.source a note entry
    exact objects a o object (inventory.captures.keyLive a note entry)
  have arrayFrames : ∀ a roles, notes.arrays.owners a = some roles →
      Prefix.input.heap.get a = input.heap.get a ∧ result.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a roles entry
    obtain ⟨o,_,object,_,_⟩ := inventory.arrays.source a roles entry
    exact objects a o object (inventory.arrays.keyLive a roles entry)
  have publicFrames : ∀ a name role, notes.publicFields.fields a name = some role →
      Prefix.input.heap.get a = input.heap.get a ∧ result.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a name role entry
    obtain ⟨_,⟨o,_,_,object,_⟩,_⟩ := inventory.publicFields.source a name role entry
    exact objects a o object (inventory.publicFields.keyLive a name role entry)
  have bufferFrames : ∀ a roles, notes.buffers.owners a = some roles →
      Prefix.input.heap.get a = input.heap.get a ∧ result.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a roles entry
    obtain ⟨o,_,object,_,_⟩ := inventory.buffers.source a roles entry
    exact objects a o object (inventory.buffers.keyLive a roles entry)
  exact ⟨cells.frame grow (fun a role entry => (cellFrames a role entry).1) (fun a role entry => (cellFrames a role entry).2),
    inventory.privates.frame grow (fun a note entry => (privateFrames a note entry).1) (fun a note entry => (privateFrames a note entry).2),
    inventory.captures.frame grow (fun a note entry => (captureFrames a note entry).1) (fun a note entry => (captureFrames a note entry).2),
    inventory.arrays.frame grow (fun a roles entry => (arrayFrames a roles entry).1) (fun a roles entry => (arrayFrames a roles entry).2),
    inventory.publicFields.frame grow (fun a name role entry => (publicFrames a name role entry).1) (fun a name role entry => (publicFrames a name role entry).2),
    inventory.buffers.frame grow (fun a roles entry => (bufferFrames a roles entry).1) (fun a roles entry => (bufferFrames a roles entry).2)⟩
end

/-- Execute the original native rank/shape prefix and establish the retained
ordinary-body entry from its result. Every annotation premise belongs to the
initial state; the pointer, rank and saved caller notes are derived here. -/
theorem initialize_retained_entry (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (notes : RetainedNotes) (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (rankAbsent : notes.runtime.cells.cells Variable5.address = none)
    (pointerAbsent : notes.runtime.cells.cells PointerBinding48.sourceAddress = none)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R NodeRel ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (shape : ∀ i n n', NodeRel i n n' → Host.Mlx.Ffi.Parametric.ShapeR (NumberRoles ν₀ ν C₀ C) n.shape n'.shape)
    (rankSignature : ¬ framed signature) (shapeSignature : ¬ framed ShapeNative.signature) (handleLive : H 29363)
    (handleRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0))
    (field : PrivateData s (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
      Handle40.sourceName (.big (Int.ofNat (R.handle 29363))))
    (region : R.region (4*29363) = 4*R.handle 29363)
    (bound : s.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ (result : St LSt) (nextNotes : RetainedNotes) (fnRole thisRole : Annotated.Value)
        (tailNotes : List Annotated.Tree),
      runC P.F 58 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (GetterLive live) framed before after old old'
        RetainedSeed.input result ∧
      RetainedInventory nextNotes ν₀ ν C₀ C R (GetterLive live) RetainedSeed.input result ∧
      nextNotes.runtime.cells = RetainedSeed.seededCells notes.runtime.cells ∧
      nextNotes.captures = notes.captures ∧
      nextNotes.runtime.cells.cells RetainedPrefix.Source0.address = some RetainedSeed.pointerRole ∧
      nextNotes.runtime.cells.cells RetainedPrefix.Source5.address = some RetainedSeed.rankRole ∧
      nextNotes.runtime.stack = argumentFrameNote false RetainedPrefix.Source1.sourceKind fnRole thisRole []
        RetainedPrefix.Source1.sourceRest RetainedPrefix.Source1.sourceEnv::tailNotes := by
  obtain ⟨result,run,related,rank,_,frame⟩ := initialize_shape_entry FR R ν₀ ν C₀ C live framed before after old old' s h
    NodeRel ObjRel H N tail native shape rankSignature shapeSignature handleLive handleRole field region bound globalLive globalFixed
  obtain ⟨cells,privates,captures,arrayContents,publics,buffers⟩ := inventories_frame h inventory rankAbsent pointerAbsent frame
  have related' : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (GetterLive live) framed before after old old'
      RetainedSeed.input result := by exact related
  obtain ⟨nextNotes,fnRole,thisRole,tailNotes,retained,cellNotes,captureNotes,pointerEntry,rankEntry,stackNotes⟩ :=
    RetainedSeed.initial_seed FR R ν₀ ν C₀ C (GetterLive live) framed before after old old' result related'
      notes.runtime.cells notes.privates notes.captures notes.arrays notes.publicFields notes.buffers
      cells privates captures arrayContents publics buffers rank
  exact ⟨result,nextNotes,fnRole,thisRole,tailNotes,run,related',retained,cellNotes,captureNotes,pointerEntry,rankEntry,stackNotes⟩
end Host.Load.Run.Full.Ordinary.RankOrigin
