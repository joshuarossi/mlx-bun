import host.ts.RenameRetainedDisposeFlag
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric Host.Load.Run.Full.Ordinary Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

def freeArgs : List Elem := [.expr (.priv .this handle false)]
def freeCaller (env : Env) (frames : List Frame) : List Frame := .s (.block [] env)::frames
def freeNotes (notes : RetainedNotes) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote nativeStatusRole,blockFrameNote [] env::tail,notes.runtime.cells⟩
def freeOutput (source : Host.Ts.St Host.Load.LSt) (env : Env) (frames : List Frame) (h : Nat) : Host.Ts.St Host.Load.LSt :=
  finishStatus {source with stack := freeCaller env frames} (Host.Load.Owned.freeArray source.ffi h) free [.big (Int.ofNat h)]

/-- The whole original free statement derives its ABI arguments from current
source lookups and the retained handle. The indexed native relation, all six
inventories and both producer-closure facts survive removal of that handle. -/
theorem free_block {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {nodes : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {roots H N : Nat → Prop} {tailTokens : List NumV} {host : Host.Load.HostSt → Host.Load.HostSt → Prop}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : Host.Ts.St Host.Load.LSt}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host)
      R live framed before after old old' source target)
    (policy : ProducerAnnotations roots H N nodes objects)
    (env : Env) (frames : List Frame) (head : Tree) (tail : List Tree) (value : Val)
    (moduleCell moduleAddress callee types thisCell owner brand arrayHandle : Nat)
    (object calleeObject signatureObject : Host.Ts.Obj) (returns : Name) (w e hw he : Bool)
    (control : source.ctl = .ret value)
    (stack : source.stack = .s (.block [freeStmt] env)::frames)
    (stackNotes : notes.runtime.stack = head::tail)
    (moduleLookup : lookupEnv nativeModule env = some moduleCell)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (brandLookup : lookupEnv (privName handle) env = some brand)
    (moduleRead : source.heap.get moduleCell = some (.cell (some (.obj moduleAddress))))
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (handleDescriptor : findPriv brand handle object.priv = some (.data (.big (Int.ofNat arrayHandle)) hw he))
    (path : OrdinaryLookup source free 16 moduleAddress (some (.data (.obj callee) w e)))
    (calleeRead : source.heap.get callee = some (.obj calleeObject))
    (calleeKind : calleeObject.kind = .fn (.native (.ffi .symbol) [.str free,.obj types,.str returns]))
    (signatureRead : source.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array [.str chars!"u64"])
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (handleNote : notes.privates.owners owner = some ⟨brand,handle,.handle arrayHandle⟩)
    (signatureFrame : ¬ framed types) (handleLive : H arrayHandle) (nonzero : arrayHandle ≠ 0)
    (sourceBound : arrayHandle < 2^64) (targetBound : target.ffi.mlx.next < 2^64) :
    ∃ result,
      runC Host.Load.ffi 11 source C₀ = some (freeOutput source env frames arrayHandle,C₀) ∧
      runC Host.Load.ffi 11 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects (fun i => H i ∧ i ≠ arrayHandle) N tailTokens host)
        R live framed before after old old' (freeOutput source env frames arrayHandle) result ∧
      RetainedInventory (freeNotes notes env tail) ν₀ ν C₀ C R live
        (freeOutput source env frames arrayHandle) result ∧
      ProducerAnnotations roots (fun i => H i ∧ i ≠ arrayHandle) N nodes objects ∧
      ProducerSupport roots (fun i => H i ∧ i ≠ arrayHandle) N (freeOutput source env frames arrayHandle).ffi.mlx ∧
      ProducerSupport (resourceImage R.node (fun i => N i ∧ roots i))
        (resourceImage R.handle (fun i => H i ∧ i ≠ arrayHandle)) (resourceImage R.node N) result.ffi.mlx := by
  let F := Host.Load.ffi
  let FR := VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tailTokens host
  obtain ⟨s1,left1,right1,h1,runtime1⟩ := inventory.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    source target state value freeStmt [] env frames head tail control stack stackNotes
  have pure1 := PureRuntimeCase.blockNext (F:=F) state value freeStmt [] env frames control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨left2,right2,h2,runtime2⟩ := inv1.runtime.statement_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 (.expression (.call (.member (.id nativeModule) free false) freeArgs false)) env rfl
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h2, inv2
  obtain ⟨left3,right3,h3,runtime3⟩ := inv2.runtime.call_entry_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 (.method (.id nativeModule) free false) freeArgs false env rfl
  have inv3 := inv2.heap_step runtime3 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h3, inv3
  obtain ⟨left4,right4,h4,inv4⟩ := inv3.variable_object_step h3 nativeModule env moduleCell moduleAddress
    rfl moduleLookup moduleRead
  host_normalize_retained h4, inv4
  have moduleAlive : live moduleAddress := h4.controlLive.1
  let source4 : Host.Ts.St Host.Load.LSt := { source with
    ctl := .ret (.obj moduleAddress)
    stack := .c (.member (.str free) freeArgs env false false)::freeCaller env frames }
  obtain ⟨_,left5,right5,h5,runtime5,_,_,_⟩ := inv4.runtime.method_object_path_step F FR _ notes.publicFields ν₀ ν C₀ C R
    live framed before after old old' _ _ h4 inv4.publicFields moduleAddress callee free freeArgs env false false
    w e (freeCaller env frames) (CallEntry.frameNote freeArgs false env (.method (.id nativeModule) free false))
    (blockFrameNote [] env::tail) rfl rfl
    (path.frame_live (reached:=source4) state.heap (fun _ _ => rfl) moduleAlive) rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h5, inv5
  obtain ⟨_,_,left6,right6,h6,runtime6⟩ := inv5.runtime.call_start_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h5 (.method false) callee (.obj moduleAddress) (.obj moduleAddress) freeArgs env (freeCaller env frames)
    (blockFrameNote [] env::tail) rfl rfl rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h6, inv6
  obtain ⟨s9,left9,right9,h9,inv9,heap9,native9,next9⟩ := inv6.this_private_block h6 env thisCell owner brand handle
    (.handle arrayHandle) object (.big (Int.ofNat arrayHandle)) hw he rfl thisLookup brandLookup thisRead objectRead
    ordinary handleDescriptor thisNote handleNote
  host_normalize_retained h9, inv9
  obtain ⟨_,_,_,_,_,left10,right10,h10,runtime10⟩ := inv9.runtime.argument_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h9 (.big (Int.ofNat arrayHandle)) (.handle arrayHandle) (.obj callee) (.obj moduleAddress) [] 0 (.obj callee) (.obj moduleAddress)
    [] [] env (freeCaller env frames) (blockFrameNote [] env::tail) rfl rfl (by decide) rfl rfl
  have inv10 := inv9.heap_step runtime10 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h10, inv10
  obtain ⟨left11,right11,h11,inv11,policy11,support11,targetSupport11⟩ :=
    ArrayFreeInventory.retained_from_source ν₀ ν C₀ C R nodes boundary objects roots H N tailTokens host
      live framed before after old old' _ _ h10 inv10 policy callee types arrayHandle calleeObject signatureObject
      returns (.obj moduleAddress) rfl calleeRead calleeKind signatureRead signatureKind signatureFrame handleLive nonzero
      sourceBound (by change s9.ffi.mlx.next < 2^64; rw [native9]; change s1.ffi.mlx.next < 2^64; rw [effects1.2.native]; exact targetBound)
      (.obj callee) (.obj moduleAddress) rfl
  have l1 := one_step F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := one_step F _ _ C (state.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have l2 := one_step F _ _ C₀ rfl left2
  have r2 := one_step F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have l3 := one_step F _ _ C₀ rfl left3
  have r3 := one_step F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have l4 := one_step F _ _ C₀ rfl left4
  have r4 := one_step F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  have l5 := one_step F _ _ C₀ rfl left5
  have r5 := one_step F _ _ C (h4.control.isHalt_eq.trans rfl) right5
  have l6 := one_step F _ _ C₀ rfl left6
  have r6 := one_step F _ _ C (h5.control.isHalt_eq.trans rfl) right6
  have l10 := one_step F _ _ C₀ rfl left10
  have r10 := one_step F _ _ C (h9.control.isHalt_eq.trans rfl) right10
  have l11 := one_step F _ _ C₀ rfl left11
  have r11 := one_step F _ _ C (h10.control.isHalt_eq.trans rfl) right11
  have l6 := runC_join F (runC_join F (runC_join F (runC_join F (runC_join F l1 l2) l3) l4) l5) l6
  have r6 := runC_join F (runC_join F (runC_join F (runC_join F (runC_join F r1 r2) r3) r4) r5) r6
  exact ⟨_,runC_join F (runC_join F (runC_join F l6 left9) l10) l11,
    runC_join F (runC_join F (runC_join F r6 right9) r10) r11,
    h11,inv11,policy11,support11,targetSupport11⟩
end Host.Ts.Owned.Annotated.Dispose
