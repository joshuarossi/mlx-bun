import host.mlx.NativeBufferInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

/-- The heap effects of accepted native writes. Every object retains its
complete header; only buffer kinds/bytes may change. Cells, arrays and native
function objects keep their original contents, and no stack/address is added. -/
structure NativeHeapFrame {S : Type} (source target : St S) : Prop where
  cells : ∀ a, cellValueAt target a = cellValueAt source a
  headers : ∀ a object, source.heap.get a = some (.obj object) →
    ∃ kind, target.heap.get a = some (.obj {object with kind := kind})
  nonBuffers : ∀ a object, source.heap.get a = some (.obj object) →
    (∀ bytes, object.kind ≠ .buf bytes) → target.heap.get a = some (.obj object)
  stack : target.stack = source.stack
  next : target.next = source.next

theorem NativeHeapFrame.refl {S : Type} (s : St S) : NativeHeapFrame s s :=
  ⟨fun _ => rfl,fun _ o h => ⟨o.kind,h⟩,fun _ _ h _ => h,rfl,rfl⟩

theorem NativeHeapFrame.trans {S : Type} {s t u : St S}
    (first : NativeHeapFrame s t) (second : NativeHeapFrame t u) : NativeHeapFrame s u := by
  constructor
  · intro a; exact (second.cells a).trans (first.cells a)
  · intro a object read
    obtain ⟨kind,intermediate⟩ := first.headers a object read
    obtain ⟨finalKind,final⟩ := second.headers a {object with kind := kind} intermediate
    exact ⟨finalKind,final⟩
  · intro a object read nonBuffer
    exact second.nonBuffers a object (first.nonBuffers a object read nonBuffer) nonBuffer
  · exact second.stack.trans first.stack
  · exact second.next.trans first.next

theorem NativeHeapFrame.heap_eq {S : Type} {s t : St S}
    (heap : t.heap = s.heap) (stack : t.stack = s.stack) (next : t.next = s.next) : NativeHeapFrame s t := by
  constructor
  · intro a; simp only [cellValueAt,heap]
  · intro a object read; exact ⟨object.kind,heap ▸ read⟩
  · intro a object read _; exact heap ▸ read
  · exact stack
  · exact next

theorem NativeHeapFrame.setBuffer {S : Type} (s : St S) (address : Nat) (object : Obj)
    (oldBytes newBytes : List Host.Ts.Byte) (read : s.heap.get address = some (.obj object))
    (buffer : object.kind = .buf oldBytes) (bound : address < 2^64) :
    NativeHeapFrame s (s.setObj address {object with kind := .buf newBytes}) := by
  constructor
  · intro a
    by_cases same : a = address
    · subst a
      simp only [cellValueAt,St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true,read]
    · simp only [cellValueAt,St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right same]
  · intro a prior priorRead
    by_cases same : a = address
    · subst a
      have equal := HObj.obj.inj (Option.some.inj (priorRead.symm.trans read))
      subst prior
      exact ⟨.buf newBytes,by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]⟩
    · exact ⟨prior.kind,by simpa only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right same] using priorRead⟩
  · intro a prior priorRead nonBuffer
    by_cases same : a = address
    · subst a
      have equal := HObj.obj.inj (Option.some.inj (priorRead.symm.trans read))
      subst prior
      exact False.elim (nonBuffer oldBytes buffer)
    · simpa only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right same] using priorRead
  · rfl
  · rfl

theorem NativeHeapFrame.finishBuffer {S : Type} (s : St S) (native : S) (address off : Nat)
    (object : Obj) (oldBytes writes : List Host.Ts.Byte) (name : Name) (args : List Arg)
    (read : s.heap.get address = some (.obj object)) (buffer : object.kind = .buf oldBytes)
    (bound : address < 2^64) :
    NativeHeapFrame s (finishBuffer s native address off object oldBytes writes name args) := by
  exact (NativeHeapFrame.setBuffer s address object oldBytes
    (oldBytes.take off ++ writes ++ oldBytes.drop (off + len writes)) read buffer bound).trans
    (NativeHeapFrame.heap_eq rfl rfl rfl)

def NativeWriteBounds : List (Nat × Nat × List Host.Ts.Byte) → Prop :=
  listSupport (fun write => write.1 < 2^64)

/-- This proves the effects of the original applyWrites recursion, including
repeated writes and aliased buffer owners. Each write is checked as a buffer;
no assumed post-state annotation or target write relation is used. -/
theorem native_applyWrites_frame (F : Ffi) : ∀ writes (s t : St F.S), NativeWriteBounds writes →
    applyWrites F s writes = some t → NativeHeapFrame s t := by
  intro writes
  induction writes with
  | nil => intro s t _ run; cases run; exact NativeHeapFrame.refl s
  | cons write writes ih =>
    intro s t bounds run
    obtain ⟨address,off,bytes⟩ := write
    cases objectRead : s.obj? address with
    | none => simp only [applyWrites,objectRead] at run; cases run
    | some object =>
      have heapRead : s.heap.get address = some (.obj object) := by
        cases entry : s.heap.get address with
        | none => simp only [St.obj?,entry] at objectRead; cases objectRead
        | some value =>
          cases value with
          | cell value => simp only [St.obj?,entry] at objectRead; cases objectRead
          | obj found => simp only [St.obj?,entry] at objectRead; cases objectRead; rfl
      cases kind : object.kind <;> simp only [applyWrites,objectRead,kind] at run
      case buf oldBytes =>
        have first := NativeHeapFrame.setBuffer s address object oldBytes
          (oldBytes.take off ++ bytes ++ oldBytes.drop (off + len bytes)) heapRead kind bounds.1
        exact first.trans (ih _ t bounds.2 run)
      all_goals cases run

theorem NativeHeapFrame.privateData {S : Type} {s t : St S} (frame : NativeHeapFrame s t)
    {owner brand : Nat} {name : Name} {value : Val} (field : PrivateData s owner brand name value) :
    PrivateData t owner brand name value := by
  obtain ⟨object,w,e,read,descriptor⟩ := field
  obtain ⟨kind,target⟩ := frame.headers owner object read
  exact ⟨{object with kind := kind},w,e,target,descriptor⟩

theorem NativeHeapFrame.cellNotes {S : Type} {s t : St S} (frame : NativeHeapFrame s t)
    {notes : Notes} {ν : Nat → F64} {C : CSrv} {R : Ren} (held : notes.Holds ν C R s) : notes.Holds ν C R t := by
  intro a role selected
  rw [frame.cells]
  exact held a role selected

theorem NativeHeapFrame.privateNotes {S : Type} {s t : St S} (frame : NativeHeapFrame s t)
    {notes : PrivateNotes} {ν : Nat → F64} {C : CSrv} {R : Ren} (held : notes.Holds ν C R s) : notes.Holds ν C R t := by
  intro a note selected
  obtain ⟨value,field,role⟩ := held a note selected
  exact ⟨value,frame.privateData field,role⟩

theorem NativeHeapFrame.captureNotes {S : Type} {s t : St S} (frame : NativeHeapFrame s t)
    {notes : NativeCaptureNotes} {ν : Nat → F64} {C : CSrv} {R : Ren} (held : notes.Holds ν C R s) : notes.Holds ν C R t := by
  intro a note selected
  obtain ⟨object,data,read,kind,roles⟩ := held a note selected
  refine ⟨object,data,frame.nonBuffers _ object read ?_,kind,roles⟩
  intro bytes impossible
  rw [kind] at impossible
  cases impossible

theorem NativeHeapFrame.arrayNotes {S : Type} {s t : St S} (frame : NativeHeapFrame s t)
    {notes : ArrayNotes} {ν : Nat → F64} {C : CSrv} {R : Ren} (held : notes.Holds ν C R s) : notes.Holds ν C R t := by
  intro a roles selected
  obtain ⟨object,values,read,kind,annotations⟩ := held a roles selected
  refine ⟨object,values,frame.nonBuffers _ object read ?_,kind,annotations⟩
  intro bytes impossible
  rw [kind] at impossible
  cases impossible

/-- The original normal-return path has only accepted buffer writes, a trace
event and a return control. Callbacks are a separate source transition. -/
theorem native_ffiDone_frame (F : Ffi) (s : St F.S) (name : Name) (args : List Arg)
    (native : F.S) (ret : Ret) (writes : List (Nat × Nat × List Host.Ts.Byte))
    (C D : CSrv) (t : St F.S) (bounds : NativeWriteBounds writes)
    (normal : ∀ r callbackArgs, ret ≠ .callback r callbackArgs)
    (run : interpC (ffiDone F s name args (some (native,ret,writes))).run C = some (t,D)) :
    NativeHeapFrame s t ∧ t.ctl = .ret (retVal ret) ∧ D = C := by
  cases write : applyWrites F (s.setFfi native) writes with
  | none => simp only [ffiDone,write,M.run,M.fail,interpC_fail] at run; cases run
  | some u =>
    have done : ffiDone F s name args (some (native,ret,writes)) =
        M.pure ((u.setTrace (⟨name,args,ret⟩ :: u.trace)).ret (retVal ret)) := by
      cases ret <;> simp only [ffiDone,write,retS]
      case callback r callbackArgs => exact False.elim (normal r callbackArgs rfl)
      all_goals rfl
    rw [done] at run
    have equal : ((u.setTrace (⟨name,args,ret⟩ :: u.trace)).ret (retVal ret),C) = (t,D) :=
      Option.some.inj run
    cases equal
    refine ⟨?_,rfl,rfl⟩
    exact (NativeHeapFrame.heap_eq (s := s) (t := s.setFfi native) rfl rfl rfl).trans
      ((native_applyWrites_frame F writes _ u bounds write).trans
        (NativeHeapFrame.heap_eq rfl rfl rfl))

theorem HeapInventory.nativeFrame {S : Type} {notes : HeapNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : HeapInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : NativeHeapFrame s₀ t₀) (target : NativeHeapFrame s t) :
    HeapInventory notes ν₀ ν C₀ C R live t₀ t :=
  ⟨⟨inventory.cells.keyLive,source.cellNotes inventory.cells.source,target.cellNotes inventory.cells.target⟩,
    ⟨inventory.privates.keyLive,source.privateNotes inventory.privates.source,target.privateNotes inventory.privates.target⟩,
    ⟨inventory.captures.keyLive,source.captureNotes inventory.captures.source,target.captureNotes inventory.captures.target⟩⟩

theorem ArrayInventory.nativeFrame {S : Type} {notes : ArrayNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : ArrayInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : NativeHeapFrame s₀ t₀) (target : NativeHeapFrame s t) :
    ArrayInventory notes ν₀ ν C₀ C R live t₀ t := by
  apply inventory.frame (fun _ alive => alive)
  · intro a roles selected
    obtain ⟨object,values,read,kind,_⟩ := inventory.source a roles selected
    exact (source.nonBuffers a object read (by intro bytes equal; rw [kind] at equal; cases equal)).trans read.symm
  · intro a roles selected
    obtain ⟨object,values,read,kind,_⟩ := inventory.target a roles selected
    exact (target.nonBuffers (R.a a) object read (by intro bytes equal; rw [kind] at equal; cases equal)).trans read.symm

theorem RuntimeInventory.nativeFrame_return {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (source : NativeHeapFrame s₀ t₀) (target : NativeHeapFrame s t)
    (role : Value) (value₀ value : Val) (sourceControl : t₀.ctl = .ret value₀) (targetControl : t.ctl = .ret value)
    (sourceRole : role.Holds ν₀ C₀ identity value₀) (targetRole : role.Holds ν C R value) :
    RuntimeInventory {notes with control := returnNote role} ν₀ ν C₀ C R live t₀ t := by
  refine ⟨inventory.keyLive,⟨?_,?_,source.cellNotes inventory.source.cells⟩,
    ⟨?_,?_,target.cellNotes inventory.target.cells⟩⟩
  · rw [sourceControl]; exact returnNote_holds sourceRole
  · rw [source.stack]; exact inventory.source.stack
  · rw [targetControl]; exact returnNote_holds targetRole
  · rw [target.stack]; exact inventory.target.stack

/-- The source/target execution equations are the conclusions of the native
family's dispatch proof. This adapter extracts the original write effects
and retains every existing inventory at independently extended number tables. -/
theorem native_ffiDone_inventories (F : Ffi) {notes : RuntimeNotes}
    {privates : PrivateNotes} {captures : NativeCaptureNotes} {arrayNotes : ArrayNotes}
    {ν₀ ν : Nat → F64} {C₀ C D₀ D : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s t₀ t : St F.S}
    (runtime : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrayNotes ν₀ ν C₀ C R live s₀ s)
    (sourceExtension : TableExtends C₀ D₀) (targetExtension : TableExtends C D)
    (name : Name) (args₀ args : List Arg) (native₀ native : F.S) (ret₀ ret : Ret)
    (writes₀ writes : List (Nat × Nat × List Host.Ts.Byte))
    (sourceBounds : NativeWriteBounds writes₀) (targetBounds : NativeWriteBounds writes)
    (sourceNormal : ∀ r callbackArgs, ret₀ ≠ .callback r callbackArgs)
    (targetNormal : ∀ r callbackArgs, ret ≠ .callback r callbackArgs)
    (sourceRun : interpC (ffiDone F s₀ name args₀ (some (native₀,ret₀,writes₀))).run D₀ = some (t₀,D₀))
    (targetRun : interpC (ffiDone F s name args (some (native,ret,writes))).run D = some (t,D))
    (role : Value) (sourceRole : role.Holds ν₀ D₀ identity (retVal ret₀)) (targetRole : role.Holds ν D R (retVal ret)) :
    RuntimeInventory {notes with control := returnNote role} ν₀ ν D₀ D R live t₀ t ∧
    HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν D₀ D R live t₀ t ∧
    ArrayInventory arrayNotes ν₀ ν D₀ D R live t₀ t := by
  obtain ⟨sourceFrame,sourceControl,_⟩ := native_ffiDone_frame F s₀ name args₀ native₀ ret₀ writes₀ D₀ D₀ t₀
    sourceBounds sourceNormal sourceRun
  obtain ⟨targetFrame,targetControl,_⟩ := native_ffiDone_frame F s name args native ret writes D D t
    targetBounds targetNormal targetRun
  exact ⟨(runtime.mono sourceExtension targetExtension).nativeFrame_return sourceFrame targetFrame
      role _ _ sourceControl targetControl sourceRole targetRole,
    (heapInventory.mono sourceExtension targetExtension).nativeFrame sourceFrame targetFrame,
    (arrayInventory.mono sourceExtension targetExtension).nativeFrame sourceFrame targetFrame⟩

end Host.Ts.Owned.Annotated
