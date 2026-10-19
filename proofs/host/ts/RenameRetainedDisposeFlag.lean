import host.ts.RenameRetainedDisposeUnregister
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric

def flaggedObject (object : Obj) (brand : Nat) (enumerable : Bool) : Obj :=
  {object with priv := setPrivL brand flag (.data (.bool true) true enumerable) object.priv}
def flagOutput {S : Type} (source : St S) (env : Env) (frames : List Frame)
    (owner brand : Nat) (object : Obj) (enumerable : Bool) : St S :=
  { source.setObj owner (flaggedObject object brand enumerable) with
    ctl := .ret (.bool true)
    stack := .s (.block [unregisterStmt,freeStmt] env)::frames }
def flagNotes (notes : RetainedNotes) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote (.bool true),blockFrameNote [unregisterStmt,freeStmt] env::tail,notes.runtime.cells⟩

/-- Seven original transitions assign the literal true to the writable
`#disposed` field and retain the differently named handle annotation. -/
theorem flag_block {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (frames : List Frame) (head : Tree) (tail : List Tree)
    (value : Val) (thisCell owner brand : Nat) (object : Obj) (enumerable : Bool)
    (control : source.ctl = .ret value)
    (stack : source.stack = .s (.block [assign,unregisterStmt,freeStmt] env)::frames)
    (stackNotes : notes.runtime.stack = head::tail)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (brandLookup : lookupEnv (privName flag) env = some brand)
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (descriptor : findPriv brand flag object.priv = some (.data (.bool false) true enumerable))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (different : ∀ note, notes.privates.owners owner = some note → nameEq note.name flag = false)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    ∃ result,
      runC F 7 source C₀ = some (flagOutput source env frames owner brand object enumerable,C₀) ∧
      runC F 7 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (flagOutput source env frames owner brand object enumerable) result ∧
      RetainedInventory (flagNotes notes env tail) ν₀ ν C₀ C R live
        (flagOutput source env frames owner brand object enumerable) result ∧
      result.ffi = target.ffi ∧ result.next = target.next := by
  let expression := Expr.assign .assign (.expr (.priv .this flag false)) (.lit (.bool true))
  let rest := [unregisterStmt,freeStmt]
  let caller := Frame.s (.block rest env)::frames
  let callerNotes := blockFrameNote rest env::tail
  obtain ⟨s1,left1,right1,h1,runtime1⟩ := inventory.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    source target h value assign rest env frames head tail control stack stackNotes
  have pure1 := PureRuntimeCase.blockNext h value assign rest env frames control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨left2,right2,h2,runtime2⟩ := inv1.runtime.statement_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 (.expression expression) env rfl
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h2, inv2
  obtain ⟨left3,right3,h3,inv3⟩ := inv2.private_assignment_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 .this flag false (.lit (.bool true)) env brand rfl brandLookup
  host_normalize_retained h3, inv3
  obtain ⟨_,left4,right4,h4,runtime4⟩ := inv3.runtime.this_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h3 env thisCell (.obj owner) (.obj owner) rfl thisLookup thisRead thisNote
  have inv4 := inv3.heap_step runtime4 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h4, inv4
  obtain ⟨_,_,left5,right5,h5,inv5⟩ := inv4.private_receiver_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h4 (.obj owner) brand flag (.lit (.bool true)) env caller (.obj owner)
    (privateReceiverNote brand flag (.lit (.bool true)) env) callerNotes rfl rfl rfl rfl
  host_normalize_retained h5, inv5
  obtain ⟨left6,right6,h6,runtime6⟩ := inv5.runtime.literal_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h5 (.bool true) (.bool true) env (.bool true) rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h6, inv6
  obtain ⟨_,_,_,left7,right7,h7,inv7⟩ := inv6.private_store_other_step h6 owner brand flag (.bool true) (.bool true)
    .undef (.bool false) enumerable object caller (privatePutNote (.obj owner) brand flag) callerNotes
    rfl rfl objectRead ordinary descriptor rfl rfl sourceBound (by change s1.next ≤ 2^64; rw [effects1.2.next]; exact targetBound) different
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
  have l7 := one_step F _ _ C₀ rfl left7
  have r7 := one_step F _ _ C (h6.control.isHalt_eq.trans rfl) right7
  refine ⟨_,runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F l1 l2) l3) l4) l5) l6) l7,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F r1 r2) r3) r4) r5) r6) r7,
    h7,inv7,?_,?_⟩
  · exact effects1.2.native
  · exact effects1.2.next
end Host.Ts.Owned.Annotated.Dispose
