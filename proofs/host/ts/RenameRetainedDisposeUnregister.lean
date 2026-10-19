import host.ts.RenameRetainedDisposeSource
import host.ts.RenameRetainedNormalize
import host.ts.RenameRuntimeCallEntry
import host.ts.RenameLookupFrame
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric

def unregisterArgs : List Elem := [.expr (.priv .this token false)]
def unregisterCaller (env : Env) (frames : List Frame) : List Frame := .s (.block [freeStmt] env)::frames
def unregisterNotes (notes : RetainedNotes) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.bool false),blockFrameNote [freeStmt] env::tail,notes.runtime.cells⟩
def unregisterOutput {S : Type} (source : St S) (env : Env) (frames : List Frame) : St S :=
  {source with ctl := .ret (.bool false),stack := unregisterCaller env frames}

/-- The complete source unregister statement uses the current token field and
initialized prototype path. The owner's separate handle annotation survives. -/
theorem unregister_block {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (frames : List Frame) (head : Tree) (tail : List Tree) (value : Val)
    (registryCell registryAddress callee thisCell owner brand tokenAddress : Nat)
    (object calleeObject : Obj) (data : List Val) (w e tw te : Bool)
    (control : source.ctl = .ret value)
    (stack : source.stack = .s (.block [unregisterStmt,freeStmt] env)::frames)
    (stackNotes : notes.runtime.stack = head::tail)
    (registryLookup : lookupEnv registry env = some registryCell)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (brandLookup : lookupEnv (privName token) env = some brand)
    (registryRead : source.heap.get registryCell = some (.cell (some (.obj registryAddress))))
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (tokenDescriptor : findPriv brand token object.priv = some (.data (.obj tokenAddress) tw te))
    (path : OrdinaryLookup source unregister 16 registryAddress (some (.data (.obj callee) w e)))
    (calleeRead : source.heap.get callee = some (.obj calleeObject))
    (calleeKind : calleeObject.kind = .fn (.native (.fn .finUnregister) data))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner)) :
    ∃ result,
      runC F 11 source C₀ = some (unregisterOutput source env frames,C₀) ∧
      runC F 11 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (unregisterOutput source env frames) result ∧
      RetainedInventory (unregisterNotes notes env tail) ν₀ ν C₀ C R live (unregisterOutput source env frames) result ∧
      result.heap = target.heap ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨s1,left1,right1,h1,runtime1⟩ := inventory.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    source target h value unregisterStmt [freeStmt] env frames head tail control stack stackNotes
  have pure1 := PureRuntimeCase.blockNext h value unregisterStmt [freeStmt] env frames control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨left2,right2,h2,runtime2⟩ := inv1.runtime.statement_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 (.expression (.call (.member (.id registry) unregister false) unregisterArgs false)) env rfl
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h2, inv2
  obtain ⟨left3,right3,h3,runtime3⟩ := inv2.runtime.call_entry_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 (.method (.id registry) unregister false) unregisterArgs false env rfl
  have inv3 := inv2.heap_step runtime3 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h3, inv3
  obtain ⟨left4,right4,h4,inv4⟩ := inv3.variable_object_step h3 registry env registryCell registryAddress
    rfl registryLookup registryRead
  host_normalize_retained h4, inv4
  have registryAlive : live registryAddress := h4.controlLive.1
  let source4 : St F.S := { source with
    ctl := .ret (.obj registryAddress)
    stack := .c (.member (.str unregister) unregisterArgs env false false)::unregisterCaller env frames }
  obtain ⟨_,left5,right5,h5,runtime5,_,_,_⟩ := inv4.runtime.method_object_path_step F FR _ notes.publicFields ν₀ ν C₀ C R
    live framed before after old old' _ _ h4 inv4.publicFields registryAddress callee unregister unregisterArgs env false false
    w e (unregisterCaller env frames) (CallEntry.frameNote unregisterArgs false env (.method (.id registry) unregister false))
    (blockFrameNote [freeStmt] env::tail) rfl rfl
    (path.frame_live (reached:=source4) h.heap (fun _ _ => rfl) registryAlive) rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h5, inv5
  obtain ⟨_,_,left6,right6,h6,runtime6⟩ := inv5.runtime.call_start_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h5 (.method false) callee (.obj registryAddress) (.obj registryAddress) unregisterArgs env (unregisterCaller env frames)
    (blockFrameNote [freeStmt] env::tail) rfl rfl rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h6, inv6
  obtain ⟨s9,left9,right9,h9,inv9,heap9,native9,next9⟩ := inv6.this_private_object_block h6 env thisCell owner brand tokenAddress
    token object tw te rfl thisLookup brandLookup thisRead objectRead ordinary tokenDescriptor thisNote
  host_normalize_retained h9, inv9
  obtain ⟨_,_,_,_,_,left10,right10,h10,runtime10⟩ := inv9.runtime.argument_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h9 (.obj tokenAddress) (.obj tokenAddress) (.obj callee) (.obj registryAddress) [] 0 (.obj callee) (.obj registryAddress)
    [] [] env (unregisterCaller env frames) (blockFrameNote [freeStmt] env::tail) rfl rfl (by decide) rfl rfl
  have inv10 := inv9.heap_step runtime10 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h10, inv10
  obtain ⟨left11,right11,h11,inv11⟩ := inv10.finalization_unregister_step h10 callee calleeObject data (.obj registryAddress)
    [.obj tokenAddress] rfl calleeRead calleeKind
  have l1 := one_step F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := one_step F _ _ C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1
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
    h11,inv11,heap9.trans effects1.2.heap,native9.trans effects1.2.native,next9.trans effects1.2.next⟩
end Host.Ts.Owned.Annotated.Dispose
