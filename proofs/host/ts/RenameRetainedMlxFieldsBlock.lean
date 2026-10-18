import host.ts.RenameRetainedPrivateFields
import host.ts.RenameRetainedLiterals
import host.ts.RenameRuntimeDispatch
import host.ts.RenameRouteComposition

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.MlxConstruction
open Parametric

def members (brand : Nat) : List InstMember :=
  [.privField brand chars!"handle" none,
   .privField brand chars!"disposed" (some (.lit (.bool false))),
   .privField brand chars!"token" (some (.object [])),
   .privField brand chars!"pinId" (some (.lit (.num chars!"0")))]
def afterHandle (brand : Nat) : PrivateNext :=
  .initial brand chars!"disposed" (.lit (.bool false)) (members brand).tail.tail
def afterDisposed (brand : Nat) : PrivateNext :=
  .initial brand chars!"token" (.object []) (members brand).tail.tail.tail
def afterToken (brand : Nat) : PrivateNext :=
  .initial brand chars!"pinId" (.lit (.num chars!"0")) []

def defineField (object : Obj) (brand : Nat) (name : Name) (value : Val) : Obj :=
  {object with priv := setPrivL brand name (.data value true false) object.priv}
def tokenObject : HObj := .obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩

def fields1 {S : Type} (s : St S) (owner brand : Nat) (object : Obj) (env : Env) (frames : List Frame) : St S :=
  (afterHandle brand).advance ({s with stack := frames}.setObj owner (defineField object brand chars!"handle" .undef)) owner env
def fields3 {S : Type} (s : St S) (owner brand : Nat) (object : Obj) (env : Env) (frames : List Frame) : St S :=
  (afterDisposed brand).advance ({s with stack := frames}.setObj owner
    (defineField (defineField object brand chars!"handle" .undef) brand chars!"disposed" (.bool false))) owner env
def fields4 {S : Type} (s : St S) : St S := (s.alloc tokenObject).2.ret (.obj s.next)
def fields5 {S : Type} (s : St S) (owner brand token : Nat) (object : Obj) (env : Env) (frames : List Frame) : St S :=
  (afterToken brand).advance ({s with stack := frames}.setObj owner
    (defineField (defineField (defineField object brand chars!"handle" .undef)
      brand chars!"disposed" (.bool false)) brand chars!"token" (.obj token))) owner env
def fields7 {S : Type} (s : St S) (owner brand token : Nat) (object : Obj) (env : Env) (frames : List Frame) : St S :=
  PrivateNext.done.advance ({s with stack := frames}.setObj owner
    (defineField (defineField (defineField (defineField object brand chars!"handle" .undef)
      brand chars!"disposed" (.bool false)) brand chars!"token" (.obj token))
      brand chars!"pinId" (.num (.lit (F64.ofNat 0))))) owner env

def fieldNotes1 (notes : RetainedNotes) (owner brand : Nat) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.privateFields owner brand chars!"handle" .undef tail (afterHandle brand) env
def fieldNotes3 (notes : RetainedNotes) (owner brand : Nat) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.privateFields owner brand chars!"disposed" (.bool false) tail (afterDisposed brand) env
def fieldNotes5 (notes : RetainedNotes) (owner brand token : Nat) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.privateFields owner brand chars!"token" (.obj token) tail (afterToken brand) env
def fieldNotes7 (notes : RetainedNotes) (owner brand : Nat) (env : Env) (tail : List Tree) : RetainedNotes :=
  notes.privateFields owner brand chars!"pinId" (.literal (.lit (F64.ofNat 0))) tail .done env

private theorem one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

theorem afterHandle_valid (brand : Nat) : (afterHandle brand).valid := by
  exact .cons _ _ _ (.cons _ _ _ .nil)
theorem afterDisposed_valid (brand : Nat) : (afterDisposed brand).valid := by
  exact .cons _ _ _ .nil

/-- The seven actual MLXArray private-initializer transitions, on an arbitrary
source heap and caller stack. Only the token object is allocated. Every field
meaning comes from its source initializer; constructor-argument notes in the
tail are retained. No future field or target object is an input. -/
theorem initialize_fields {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (owner brand : Nat) (object : Obj) (env : Env) (frames : List Frame) (head : Tree) (tail : List Tree)
    (control : source.ctl = .ret .undef)
    (stack : source.stack = .k (.fields owner (members brand) env)::frames)
    (read : source.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (stackNotes : notes.runtime.stack = head::tail)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (sourceBound : source.next+1 ≤ 2^64) (targetBound : target.next+1 ≤ 2^64) :
    let s1 := fields1 source owner brand object env frames
    let s3 := fields3 s1 owner brand object env frames
    let s4 := fields4 s3
    let s5 := fields5 s4 owner brand source.next object env frames
    let output := fields7 s5 owner brand source.next object env frames
    let n1 := fieldNotes1 notes owner brand env tail
    let n3 := fieldNotes3 (n1.withRuntime (n1.runtime.returning (.bool false))) owner brand env tail
    let n5 := fieldNotes5 (n3.withRuntime {n3.runtime with control := returnNote (.obj source.next)})
      owner brand source.next env tail
    let outputNotes := fieldNotes7 (n5.withRuntime (n5.runtime.returning (.literal (.lit (F64.ofNat 0))))) owner brand env tail
    ∃ result,
      runC F 7 source C₀ = some (output,C₀) ∧ runC F 7 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live source.next)
        framed before after old old' output result ∧
      RetainedInventory outputNotes ν₀ ν C₀ C R (LiveAfter live source.next) output result := by
  dsimp only
  have support := h.stackLive
  rw [stack] at support
  have ownerLive : live owner := support.1.1.1
  have ownerBound := h.heap.sourceBound owner ownerLive
  have bOwner : owner < 2^64 := by omega
  obtain ⟨targetObject1,frames1,left1,right1,h1,inv1⟩ := inventory.private_fields_step F FR notes ν₀ ν C₀ C R
    live framed before after old old' source target h .undef owner brand chars!"handle" object
    (afterHandle brand) env frames head tail (afterHandle_valid brand) control stack read ordinary stackNotes (by omega) (by omega)
  have read1 : (fields1 source owner brand object env frames).heap.get owner =
      some (.obj (defineField object brand chars!"handle" .undef)) := by
    simp only [fields1,afterHandle,PrivateNext.advance,St.go,St.push,St.setObj,
      PTrie.get_set_u64 _ _ _ bOwner,ite_true]
  obtain ⟨left2,right2,h2,runtime2⟩ := inv1.runtime.literal_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 (.bool false) (.bool false) env (.bool false) rfl
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨_,_,target3,left3,right3,h3,inv3⟩ := inv2.private_initializer_step F FR _ ν₀ ν C₀ C R
    live framed before after old old' _ _ h2 (.bool false) owner brand chars!"disposed"
    (defineField object brand chars!"handle" .undef) (afterDisposed brand) env frames (.bool false)
    (privateInitializerFrameNote owner brand chars!"disposed" (members brand).tail.tail env) tail
    (afterDisposed_valid brand) rfl rfl read1 ordinary rfl rfl
    (by change source.next ≤ 2^64; omega) (by change target.next ≤ 2^64; omega)
  have read3 : (fields3 (fields1 source owner brand object env frames) owner brand object env frames).heap.get owner =
      some (.obj (defineField (defineField object brand chars!"handle" .undef) brand chars!"disposed" (.bool false))) := by
    simp only [fields3,afterDisposed,PrivateNext.advance,St.go,St.push,St.setObj,
      PTrie.get_set_u64 _ _ _ bOwner,ite_true]
  obtain ⟨left4,right4,h4,inv4⟩ := inv3.empty_object_step h3 env rfl objectLive objectFixed
    (by change source.next < 2^64; omega) (by change target.next < 2^64; omega)
  have read4 : (fields4 (fields3 (fields1 source owner brand object env frames) owner brand object env frames)).heap.get owner =
      some (.obj (defineField (defineField object brand chars!"handle" .undef) brand chars!"disposed" (.bool false))) := by
    change ((fields3 (fields1 source owner brand object env frames) owner brand object env frames).heap.set
      source.next tokenObject).get owner = _
    rw [PTrie.get_set_u64 _ _ _ (show source.next < 2^64 by omega)]
    rw [ite_eq_right (show owner ≠ source.next by omega)]
    exact read3
  obtain ⟨_,_,_,left5,right5,h5,inv5⟩ := inv4.private_initializer_step F FR _ ν₀ ν C₀ C R
    (LiveAfter live source.next) framed before after old old' _ _ h4 (.obj source.next) owner brand chars!"token"
    (defineField (defineField object brand chars!"handle" .undef) brand chars!"disposed" (.bool false))
    (afterToken brand) env frames (.obj source.next)
    (privateInitializerFrameNote owner brand chars!"token" (members brand).tail.tail.tail env) tail
    PrivateFields.nil rfl rfl read4 ordinary rfl rfl
    (by change source.next+1 ≤ 2^64; exact sourceBound)
    (by change target.next+1 ≤ 2^64; exact targetBound)
  have read5 : (fields5 (fields4 (fields3 (fields1 source owner brand object env frames) owner brand object env frames))
      owner brand source.next object env frames).heap.get owner = some (.obj
      (defineField (defineField (defineField object brand chars!"handle" .undef) brand chars!"disposed" (.bool false))
        brand chars!"token" (.obj source.next))) := by
    simp only [fields5,afterToken,PrivateNext.advance,St.go,St.push,St.setObj,
      PTrie.get_set_u64 _ _ _ bOwner,ite_true]
  obtain ⟨left6,right6,h6,runtime6⟩ := inv5.runtime.literal_step F FR _ ν₀ ν C₀ C R
    (LiveAfter live source.next) framed before after old old' _ _ h5 (.num chars!"0") (.num (.lit (F64.ofNat 0))) env
    (.number chars!"0" (F64.ofNat 0) (by decide +kernel)) rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨_,_,result,left7,right7,h7,inv7⟩ := inv6.private_initializer_step F FR _ ν₀ ν C₀ C R
    (LiveAfter live source.next) framed before after old old' _ _ h6 (.num (.lit (F64.ofNat 0))) owner brand chars!"pinId"
    (defineField (defineField (defineField object brand chars!"handle" .undef) brand chars!"disposed" (.bool false))
      brand chars!"token" (.obj source.next)) .done env frames (.literal (.lit (F64.ofNat 0)))
    (privateInitializerFrameNote owner brand chars!"pinId" [] env) tail True.intro rfl rfl read5 ordinary rfl rfl
    (by change source.next+1 ≤ 2^64; exact sourceBound)
    (by change target.next+1 ≤ 2^64; exact targetBound)
  have l1 := one F _ _ C₀ (by rw [control]; rfl) left1
  have r1 := one F _ _ C (h.control.isHalt_eq.trans (by rw [control]; rfl)) right1
  have l2 := one F _ _ C₀ rfl left2
  have r2 := one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have l3 := one F _ _ C₀ rfl left3
  have r3 := one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have l4 := one F _ _ C₀ rfl left4
  have r4 := one F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  have l5 := one F _ _ C₀ rfl left5
  have r5 := one F _ _ C (h4.control.isHalt_eq.trans rfl) right5
  have l6 := one F _ _ C₀ rfl left6
  have r6 := one F _ _ C (h5.control.isHalt_eq.trans rfl) right6
  have l7 := one F _ _ C₀ rfl left7
  have r7 := one F _ _ C (h6.control.isHalt_eq.trans rfl) right7
  exact ⟨_,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F l1 l2) l3) l4) l5) l6) l7,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F r1 r2) r3) r4) r5) r6) r7,h7,inv7⟩

end Host.Ts.Owned.Annotated.MlxConstruction
