import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeHeapReads
import host.ts.RenameRuntimeStaticRead
import host.ts.RenameRetainedBranch
import host.ts.RenameRuntimeStatements
import host.ts.RenameRouteComposition

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

private theorem runC_one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false)
    (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) :=
  runC_cons F 0 s t t C C C active execution rfl

/-- A reusable source block for `this.#field`. Its source heap, environment,
receiver, field meaning, caller stack, and allocation counter are arbitrary.
The current receiver-cell and owning-field annotations determine the result. -/
theorem RetainedInventory.this_private_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (thisCell owner brand : Nat) (name : Name) (role : Value)
    (object : Obj) (value : Val) (w e : Bool)
    (control : s₀.ctl = .ev (.priv .this name false) env)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (brandLookup : lookupEnv (privName name) env = some brand)
    (thisRead : s₀.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : s₀.heap.get owner = some (.obj object))
    (ordinary : object.kind = .ordinary)
    (descriptor : findPriv brand name object.priv = some (.data value w e))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (fieldNote : notes.privates.owners owner = some ⟨brand,name,role⟩) :
    ∃ result,
      runC F 3 s₀ C₀ = some (s₀.ret value,C₀) ∧
      runC F 3 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.returning role)) ν₀ ν C₀ C R live (s₀.ret value) result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨left1,right1,h1,runtime1⟩ := inventory.runtime.private_descent_step F FR notes.runtime
    ν₀ ν C₀ C R live framed before after old old' s₀ s h .this brand name false env control brandLookup
  have inv1 := inventory.heap_step runtime1 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨receiver,left2,right2,h2,runtime2⟩ := runtime1.this_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h1 env thisCell (.obj owner) (.obj owner) rfl thisLookup thisRead thisNote
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨targetValue,targetFrames,left3,right3,h3,runtime3,_⟩ := runtime2.private_read_step F FR _ notes.privates
    ν₀ ν C₀ C R live framed before after old old' _ _ h2 inv2.privates owner brand name role object value w e
    s₀.stack (privateReadFrameNote brand name false) notes.runtime.stack fieldNote rfl rfl
    objectRead ordinary descriptor rfl
  have inv3 := inv2.heap_step runtime3 rfl rfl (.refl C₀) (.refl C)
  have sourceActive : isHalt s₀.ctl = false := by rw [control]; rfl
  have targetActive : isHalt s.ctl = false := h.control.isHalt_eq.trans sourceActive
  have source1 := runC_one F _ _ C₀ sourceActive left1
  have target1 := runC_one F _ _ C targetActive right1
  have source2 := runC_one F _ _ C₀ rfl left2
  have target2 := runC_one F _ _ C rfl right2
  have source3 := runC_one F _ _ C₀ rfl left3
  have target3 := runC_one F _ _ C rfl right3
  exact ⟨_,runC_join F (runC_join F source1 source2) source3,
    runC_join F (runC_join F target1 target2) target3,h3,inv3,rfl,rfl,rfl⟩

/-- Structural fields such as the disposed boolean use their unique value
constructor, leaving the owner's handle annotation available for the next read. -/
theorem RetainedInventory.this_private_static_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (thisCell owner brand : Nat) (name : Name) (role : Value)
    (object : Obj) (value : Val) (w e : Bool)
    (control : s₀.ctl = .ev (.priv .this name false) env)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (brandLookup : lookupEnv (privName name) env = some brand)
    (thisRead : s₀.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : s₀.heap.get owner = some (.obj object))
    (ordinary : object.kind = .ordinary)
    (descriptor : findPriv brand name object.priv = some (.data value w e))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (static : StaticValue value role) :
    ∃ result,
      runC F 3 s₀ C₀ = some (s₀.ret value,C₀) ∧
      runC F 3 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret value) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.returning role)) ν₀ ν C₀ C R live (s₀.ret value) result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨left1,right1,h1,runtime1⟩ := inventory.runtime.private_descent_step F FR notes.runtime
    ν₀ ν C₀ C R live framed before after old old' s₀ s h .this brand name false env control brandLookup
  have inv1 := inventory.heap_step runtime1 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨receiver,left2,right2,h2,runtime2⟩ := runtime1.this_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h1 env thisCell (.obj owner) (.obj owner) rfl thisLookup thisRead thisNote
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨targetValue,targetFrames,left3,right3,h3,inv3⟩ := inv2.private_static_read_step F FR h2
    owner brand name value w e object role s₀.stack (privateReadFrameNote brand name false)
    notes.runtime.stack rfl rfl objectRead ordinary descriptor static rfl
  have sourceActive : isHalt s₀.ctl = false := by rw [control]; rfl
  have targetActive : isHalt s.ctl = false := h.control.isHalt_eq.trans sourceActive
  have source1 := runC_one F _ _ C₀ sourceActive left1
  have target1 := runC_one F _ _ C targetActive right1
  have source2 := runC_one F _ _ C₀ rfl left2
  have target2 := runC_one F _ _ C rfl right2
  have source3 := runC_one F _ _ C₀ rfl left3
  have target3 := runC_one F _ _ C rfl right3
  exact ⟨_,runC_join F (runC_join F source1 source2) source3,
    runC_join F (runC_join F target1 target2) target3,h3,inv3,rfl,rfl,rfl⟩

def getterBodyOutput {S : Type} (s : St S) (env : Env) (frames : List Frame) (value : Val) : St S :=
  {s with ctl := .ret value,stack := .s .ret :: .s (.block [] env) :: frames}

def RuntimeNotes.getterBodyResult (notes : RuntimeNotes) (env : Env) (frames : List Tree)
    (name : Name) (role : Value) : RuntimeNotes :=
  ((notes.blockNext (.ret (some (.priv .this name false))) [] env frames).statement
    (.returnExpression (.priv .this name false)) env).returning role

/-- The non-disposed getter body is one nine-step contract. Both real private
reads, the false branch, and return-expression setup are derived from entry
metadata and retained notes. No intermediate source snapshot is used. -/
theorem RetainedInventory.getter_body_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (thisCell owner brand : Nat) (disposedName handleName : Name)
    (object : Obj) (value : Val) (role : Value) (dw de hw he : Bool)
    (yes : Stmt) (frames : List Frame) (ifNote blockNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ev (.priv .this disposedName false) env)
    (stack : s₀.stack = .s (.if_ yes none env) ::
      .s (.block [.ret (some (.priv .this handleName false))] env) :: frames)
    (thisLookup : lookupEnv nThis env = some thisCell)
    (disposedLookup : lookupEnv (privName disposedName) env = some brand)
    (handleLookup : lookupEnv (privName handleName) env = some brand)
    (thisRead : s₀.heap.get thisCell = some (.cell (some (.obj owner))))
    (objectRead : s₀.heap.get owner = some (.obj object))
    (ordinary : object.kind = .ordinary)
    (disposed : findPriv brand disposedName object.priv = some (.data (.bool false) dw de))
    (handle : findPriv brand handleName object.priv = some (.data value hw he))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (fieldNote : notes.privates.owners owner = some ⟨brand,handleName,role⟩)
    (stackNotes : notes.runtime.stack = ifNote::blockNote::tailNotes) :
    ∃ result,
      runC F 9 s₀ C₀ = some (getterBodyOutput s₀ env frames value,C₀) ∧
      runC F 9 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (getterBodyOutput s₀ env frames value) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.getterBodyResult env tailNotes handleName role))
        ν₀ ν C₀ C R live (getterBodyOutput s₀ env frames value) result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨s3,left3,right3,h3,inv3,heap3,ffi3,next3⟩ := inventory.this_private_static_block h
    env thisCell owner brand disposedName (.bool false) object (.bool false) dw de control
    thisLookup disposedLookup thisRead objectRead ordinary disposed thisNote (.bool false)
  obtain ⟨targetFrames,left4,right4,h4,inv4⟩ := inv3.if_bool_step h3 false yes none env
    (.s (.block [.ret (some (.priv .this handleName false))] env)::frames)
    ifNote (blockNote::tailNotes) rfl stack stackNotes
  obtain ⟨s5,left5,right5,h5,runtime5⟩ := inv4.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h4 .undef (.ret (some (.priv .this handleName false))) [] env frames
    blockNote tailNotes rfl rfl rfl
  have pure5 := PureRuntimeCase.blockNext h4 .undef (.ret (some (.priv .this handleName false))) [] env frames rfl rfl
  have effects5 := pure5.effects left5 right5
  have inv5 := inv4.pure_step runtime5 pure5 left5 right5 (.refl C₀) (.refl C)
  obtain ⟨left6,right6,h6,runtime6⟩ := runtime5.statement_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h5 (.returnExpression (.priv .this handleName false)) env rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨result,left9,right9,h9,inv9,heap9,ffi9,next9⟩ := inv6.this_private_block h6 env thisCell owner brand
    handleName role object value hw he rfl thisLookup handleLookup thisRead objectRead ordinary handle thisNote fieldNote
  have source4 := runC_one F _ _ C₀ rfl left4
  have target4 := runC_one F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  have source5 := runC_one F _ _ C₀ rfl left5
  have target5 := runC_one F _ _ C (h4.control.isHalt_eq.trans rfl) right5
  have source6 := runC_one F _ _ C₀ rfl left6
  have target6 := runC_one F _ _ C (h5.control.isHalt_eq.trans rfl) right6
  refine ⟨result,runC_join F (runC_join F (runC_join F (runC_join F left3 source4) source5) source6) left9,
    runC_join F (runC_join F (runC_join F (runC_join F right3 target4) target5) target6) right9,h9,inv9,?_,?_,?_⟩
  · exact heap9.trans (effects5.2.heap.trans heap3)
  · exact ffi9.trans (effects5.2.native.trans ffi3)
  · exact next9.trans (effects5.2.next.trans next3)

end Host.Ts.Owned.Annotated
