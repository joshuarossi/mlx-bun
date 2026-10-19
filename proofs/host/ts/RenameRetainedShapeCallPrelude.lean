import host.ts.RenameRetainedShapeCallEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric
namespace ShapeCall

def pointerDeclNote (env : Env) : Tree :=
  (statementFrameNotes env (.declarationInit .const (.id pointerName) pointerExpression [])).headD callBoundaryNote
def nativeInput {S : Type} (source : St S) (env : Env) (nativeFn module owner getter : Nat) (caller : List Frame) : St S :=
  {source with ctl := .call (.obj getter) (.obj owner) [],stack := (
    .c (.args 0 (.obj nativeFn) (.obj module) [] [] env)::
      .s (.decl .const (.id pointerName) [] env)::.s (.block [returnStatement] env)::caller)}
def nativeNotes (notes : RetainedNotes) (env : Env) (nativeFn module owner getter : Nat) (caller : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨callNote (.obj getter) (.obj owner) [],
    argumentFrameNote false 0 (.obj nativeFn) (.obj module) [] [] env::pointerDeclNote env::
      blockFrameNote [returnStatement] env::caller,notes.runtime.cells⟩

private theorem one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- Nine original nonzero-shape transitions select the current native shape
function and invoke the real handle getter on the original receiver. -/
theorem native_entry_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (moduleCell module nativeFn thisCell owner getter : Nat) (mw me ge : Bool) (setter : Val)
    (caller : List Frame) (headNote : Tree) (callerNotes : List Tree)
    (control : source.ctl = .ret .undef)
    (stack : source.stack = .s (.block [pointerDeclaration,returnStatement] env)::caller)
    (moduleLookup : lookupEnv NdimCall.nativeModule env = some moduleCell)
    (moduleRead : source.heap.get moduleCell = some (.cell (some (.obj module))))
    (modulePath : OrdinaryLookup source nativeName 16 module (some (.data (.obj nativeFn) mw me)))
    (thisLookup : lookupEnv nThis env = some thisCell)
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (getterPath : OrdinaryLookup source NdimCall.handleName 16 owner (some (.acc (.obj getter) setter ge)))
    (stackNotes : notes.runtime.stack = headNote::callerNotes) :
    ∃ result, runC F 9 source C₀ = some (nativeInput source env nativeFn module owner getter caller,C₀) ∧
      runC F 9 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (nativeInput source env nativeFn module owner getter caller) result ∧
      RetainedInventory (nativeNotes notes env nativeFn module owner getter callerNotes) ν₀ ν C₀ C R live
        (nativeInput source env nativeFn module owner getter caller) result ∧
      result.heap = target.heap ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨_,l1,r1,h1,runtime1⟩ := inventory.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ state .undef pointerDeclaration [returnStatement] env caller headNote callerNotes control stack stackNotes
  have pure1 := PureRuntimeCase.blockNext state .undef pointerDeclaration [returnStatement] env caller control stack
  have effects1 := pure1.effects l1 r1
  have inv1 := inventory.pure_step runtime1 pure1 l1 r1 (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨l2,r2,h2,runtime2⟩ := inv1.runtime.statement_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h1 (.declarationInit .const (.id pointerName) pointerExpression []) env rfl
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h2, inv2
  obtain ⟨l3,r3,h3,runtime3⟩ := inv2.runtime.call_entry_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 (.method (.id NdimCall.nativeModule) nativeName false) nativeArgs false env rfl
  have inv3 := inv2.heap_step runtime3 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h3, inv3
  obtain ⟨l4,r4,h4,inv4⟩ := inv3.variable_object_step h3 NdimCall.nativeModule env moduleCell module rfl moduleLookup moduleRead
  host_normalize_retained h4, inv4
  let tailNotes := pointerDeclNote env::blockFrameNote [returnStatement] env::callerNotes
  let frames := .s (.decl .const (.id pointerName) [] env)::.s (.block [returnStatement] env)::caller
  obtain ⟨_,l5,r5,h5,runtime5,_,_,_⟩ := inv4.runtime.method_object_path_step F FR _ notes.publicFields ν₀ ν C₀ C R
    live framed before after old old' _ _ h4 inv4.publicFields module nativeFn nativeName nativeArgs env false false
    mw me frames (CallEntry.frameNote nativeArgs false env (.method (.id NdimCall.nativeModule) nativeName false)) tailNotes rfl rfl
    (by refine OrdinaryLookup.frame_live state.heap ?_ modulePath h4.controlLive.1; intro a alive; rfl) rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h5, inv5
  obtain ⟨_,_,l6,r6,h6,runtime6⟩ := inv5.runtime.call_start_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h5 (.method false) nativeFn (.obj module) (.obj module) nativeArgs env frames tailNotes rfl rfl rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h6, inv6
  obtain ⟨l7,r7,h7,runtime7⟩ := inv6.runtime.descent_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h6 (.member .this NdimCall.handleName false) env rfl
  have inv7 := inv6.heap_step runtime7 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h7, inv7
  obtain ⟨_,l8,r8,h8,runtime8⟩ := inv7.runtime.this_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h7 env thisCell (.obj owner) (.obj owner) rfl thisLookup thisRead thisNote
  have inv8 := inv7.heap_step runtime8 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h8, inv8
  obtain ⟨_,l9,r9,h9,inv9⟩ := inv8.getter_step h8 owner getter NdimCall.handleName setter ge
    (.c (.args 0 (.obj nativeFn) (.obj module) [] [] env)::frames) (descentFrameNote env (.member .this NdimCall.handleName false))
    (argumentFrameNote false 0 (.obj nativeFn) (.obj module) [] [] env::tailNotes) rfl rfl
    (by refine OrdinaryLookup.frame_live state.heap ?_ getterPath h8.controlLive.1; intro a alive; rfl) rfl
  have sl1 := one F _ _ C₀ (by rw [control]; rfl) l1
  have tr1 := one F _ _ C (state.control.isHalt_eq.trans (by rw [control]; rfl)) r1
  have sl2 := one F _ _ C₀ rfl l2
  have tr2 := one F _ _ C (h1.control.isHalt_eq.trans rfl) r2
  have sl3 := one F _ _ C₀ rfl l3
  have tr3 := one F _ _ C (h2.control.isHalt_eq.trans rfl) r3
  have sl4 := one F _ _ C₀ rfl l4
  have tr4 := one F _ _ C (h3.control.isHalt_eq.trans rfl) r4
  have sl5 := one F _ _ C₀ rfl l5
  have tr5 := one F _ _ C (h4.control.isHalt_eq.trans rfl) r5
  have sl6 := one F _ _ C₀ rfl l6
  have tr6 := one F _ _ C (h5.control.isHalt_eq.trans rfl) r6
  have sl7 := one F _ _ C₀ rfl l7
  have tr7 := one F _ _ C (h6.control.isHalt_eq.trans rfl) r7
  have sl8 := one F _ _ C₀ rfl l8
  have tr8 := one F _ _ C (h7.control.isHalt_eq.trans rfl) r8
  have sl9 := one F _ _ C₀ rfl l9
  have tr9 := one F _ _ C (h8.control.isHalt_eq.trans rfl) r9
  exact ⟨_,runC_join F (runC_join F (runC_join F (runC_join F (runC_join F
    (runC_join F (runC_join F (runC_join F sl1 sl2) sl3) sl4) sl5) sl6) sl7) sl8) sl9,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F
    (runC_join F (runC_join F (runC_join F tr1 tr2) tr3) tr4) tr5) tr6) tr7) tr8) tr9,
    h9,inv9,effects1.2.heap,effects1.2.native,effects1.2.next⟩

end ShapeCall
end Host.Ts.Owned.Annotated
