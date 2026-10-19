import host.ts.RenameRetainedNdim
import host.ts.RenameRetainedGetter
import host.ts.RenameRetainedObjectVariable
import host.ts.RenameRuntimeStaticGlobal
import host.ts.RenameRuntimeCallEntry
import host.ts.RenameRuntimeDescent
import host.ts.RuntimeInventoryMethod
import host.ts.RenameRetainedNormalize
import host.ts.RenameLookupFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

namespace NdimCall

def nativeName : Name := chars!"mlx_array_ndim"
def nativeModule : Name := chars!"C"
def numberName : Name := chars!"Number"
def handleName : Name := chars!"handle"
def handleExpr : Expr := .member .this handleName false
def nativeArgs : List Elem := [.expr handleExpr]
def nativeExpr : Expr := .call (.member (.id nativeModule) nativeName false) nativeArgs false
def numberArgs : List Elem := [.expr nativeExpr]
def expression : Expr := .call (.id numberName) numberArgs false

theorem source_function : singleReturnFunction none expression = Sources.Mlx.Array.ast_n61 := rfl

def getterInput {S : Type} (source : St S) (env : Env) (numberFn nativeFn module owner getter : Nat) : St S :=
  {source with ctl := .call (.obj getter) (.obj owner) [],stack := (.c (.args 0 (.obj nativeFn) (.obj module) [] [] env)::.c (.args 0 (.obj numberFn) .undef [] [] env)::source.stack)}

def getterNotes (notes : RetainedNotes) (env : Env) (numberFn nativeFn module owner getter : Nat) : RetainedNotes :=
  notes.withRuntime ⟨callNote (.obj getter) (.obj owner) [],
    argumentFrameNote false 0 (.obj nativeFn) (.obj module) [] [] env::
      argumentFrameNote false 0 (.obj numberFn) .undef [] [] env::notes.runtime.stack,
    notes.runtime.cells⟩

end NdimCall

theorem RetainedInventory.ndim_global_object_step
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (name : Name) (env : Env) (global : Obj) (fn : Nat) (w e : Bool)
    (control : source.ctl = .ev (.id name) env) (lookup : lookupEnv name env = none)
    (read : source.heap.get aGlobal = some (.obj global)) (kind : global.kind = .ordinary)
    (property : findProp (.str name) global.props = some (.data (.obj fn) w e))
    (alive : live aGlobal) (fixed : R.a aGlobal = aGlobal) :
    interpC (step F source).run C₀ = some (source.ret (.obj fn),C₀) ∧
      interpC (step F target).run C = some (target.ret (.obj (R.a fn)),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (source.ret (.obj fn)) (target.ret (.obj (R.a fn))) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.returning (.obj fn))) ν₀ ν C₀ C R live
        (source.ret (.obj fn)) (target.ret (.obj (R.a fn))) := by
  obtain ⟨value,left,right,post,relation⟩ := step_global_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' source target state name env global (.obj fn) w e
    control lookup read kind property alive fixed
  cases relation
  exact ⟨left,right,post,inventory.heap_step (inventory.runtime.returning (.obj fn) (.obj fn))
    rfl rfl (.refl C₀) (.refl C)⟩

/-- Ten actual expression transitions select both initialized native functions
and invoke the handle getter on the original receiver. Every lookup is a
current source fact and every target operand is derived from the retained state. -/
theorem RetainedInventory.ndim_expression_entry
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (env : Env) (numberFn nativeFn moduleCell module thisCell owner getter : Nat)
    (global : Obj) (nw ne mw me ge : Bool) (setter : Val)
    (control : source.ctl = .ev NdimCall.expression env)
    (numberLookup : lookupEnv NdimCall.numberName env = none)
    (globalRead : source.heap.get aGlobal = some (.obj global)) (globalKind : global.kind = .ordinary)
    (numberProperty : findProp (.str NdimCall.numberName) global.props = some (.data (.obj numberFn) nw ne))
    (moduleLookup : lookupEnv NdimCall.nativeModule env = some moduleCell)
    (moduleRead : source.heap.get moduleCell = some (.cell (some (.obj module))))
    (modulePath : OrdinaryLookup source NdimCall.nativeName 16 module (some (.data (.obj nativeFn) mw me)))
    (thisLookup : lookupEnv nThis env = some thisCell)
    (thisRead : source.heap.get thisCell = some (.cell (some (.obj owner))))
    (thisNote : notes.runtime.cells.cells thisCell = some (.obj owner))
    (getterPath : OrdinaryLookup source NdimCall.handleName 16 owner (some (.acc (.obj getter) setter ge)))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ result,
      runC F 10 source C₀ = some (NdimCall.getterInput source env numberFn nativeFn module owner getter,C₀) ∧
      runC F 10 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (NdimCall.getterInput source env numberFn nativeFn module owner getter) result ∧
      RetainedInventory (NdimCall.getterNotes notes env numberFn nativeFn module owner getter)
        ν₀ ν C₀ C R live (NdimCall.getterInput source env numberFn nativeFn module owner getter) result ∧
      result.heap = target.heap ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨l1,r1,h1,runtime1⟩ := inventory.runtime.call_entry_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ state (.identifier NdimCall.numberName) NdimCall.numberArgs false env control
  have inv1 := inventory.heap_step runtime1 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨l2,r2,h2,inv2⟩ := inv1.ndim_global_object_step h1 NdimCall.numberName env global numberFn
    nw ne rfl numberLookup globalRead globalKind numberProperty globalLive globalFixed
  host_normalize_retained h2, inv2
  obtain ⟨_,_,l3,r3,h3,runtime3⟩ := inv2.runtime.call_start_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 (.callee false) numberFn .undef .undef NdimCall.numberArgs env source.stack notes.runtime.stack rfl rfl rfl
  have inv3 := inv2.heap_step runtime3 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h3, inv3
  obtain ⟨l4,r4,h4,runtime4⟩ := inv3.runtime.call_entry_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h3 (.method (.id NdimCall.nativeModule) NdimCall.nativeName false) NdimCall.nativeArgs false env rfl
  have inv4 := inv3.heap_step runtime4 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h4, inv4
  obtain ⟨l5,r5,h5,inv5⟩ := inv4.variable_object_step h4 NdimCall.nativeModule env moduleCell module rfl moduleLookup moduleRead
  host_normalize_retained h5, inv5
  let source5 : St F.S := {source with ctl := .ret (.obj module),stack := (.c (.member (.str NdimCall.nativeName) NdimCall.nativeArgs env false false)::.c (.args 0 (.obj numberFn) .undef [] [] env)::source.stack)}
  obtain ⟨_,l6,r6,h6,runtime6,_,_,_⟩ := inv5.runtime.method_object_path_step F FR _ notes.publicFields ν₀ ν C₀ C R
    live framed before after old old' _ _ h5 inv5.publicFields module nativeFn NdimCall.nativeName NdimCall.nativeArgs env false false
    mw me (.c (.args 0 (.obj numberFn) .undef [] [] env)::source.stack)
    (CallEntry.frameNote NdimCall.nativeArgs false env (.method (.id NdimCall.nativeModule) NdimCall.nativeName false))
    (argumentFrameNote false 0 (.obj numberFn) .undef [] [] env::notes.runtime.stack) rfl rfl
    (modulePath.frame_live (reached:=source5) state.heap (fun _ _ => rfl) h5.controlLive.1) rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h6, inv6
  obtain ⟨_,_,l7,r7,h7,runtime7⟩ := inv6.runtime.call_start_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h6 (.method false) nativeFn (.obj module) (.obj module) NdimCall.nativeArgs env
    (.c (.args 0 (.obj numberFn) .undef [] [] env)::source.stack)
    (argumentFrameNote false 0 (.obj numberFn) .undef [] [] env::notes.runtime.stack) rfl rfl rfl
  have inv7 := inv6.heap_step runtime7 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h7, inv7
  obtain ⟨l8,r8,h8,runtime8⟩ := inv7.runtime.descent_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h7 (.member .this NdimCall.handleName false) env rfl
  have inv8 := inv7.heap_step runtime8 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h8, inv8
  obtain ⟨_,l9,r9,h9,runtime9⟩ := inv8.runtime.this_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h8 env thisCell (.obj owner) (.obj owner) rfl thisLookup thisRead thisNote
  have inv9 := inv8.heap_step runtime9 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h9, inv9
  let source9 : St F.S := {source with ctl := .ret (.obj owner),stack := (.e (.member (.str NdimCall.handleName) false)::.c (.args 0 (.obj nativeFn) (.obj module) [] [] env)::.c (.args 0 (.obj numberFn) .undef [] [] env)::source.stack)}
  obtain ⟨_,l10,r10,h10,inv10⟩ := inv9.getter_step h9 owner getter NdimCall.handleName setter ge
    (.c (.args 0 (.obj nativeFn) (.obj module) [] [] env)::.c (.args 0 (.obj numberFn) .undef [] [] env)::source.stack)
    (descentFrameNote env (.member .this NdimCall.handleName false))
    (argumentFrameNote false 0 (.obj nativeFn) (.obj module) [] [] env::
      argumentFrameNote false 0 (.obj numberFn) .undef [] [] env::notes.runtime.stack)
    rfl rfl (getterPath.frame_live (reached:=source9) state.heap (fun _ _ => rfl) h9.controlLive.1) rfl
  have one := fun (s t : St F.S) (C : CSrv) (a : isHalt s.ctl = false)
    (r : interpC (step F s).run C = some (t,C)) => runC_cons F 0 s t t C C C a r rfl
  have sl1 := one _ _ C₀ (by rw [control]; rfl) l1
  have tr1 := one _ _ C (state.control.isHalt_eq.trans (by rw [control]; rfl)) r1
  have sl2 := one _ _ C₀ rfl l2
  have tr2 := one _ _ C (h1.control.isHalt_eq.trans rfl) r2
  have sl3 := one _ _ C₀ rfl l3
  have tr3 := one _ _ C (h2.control.isHalt_eq.trans rfl) r3
  have sl4 := one _ _ C₀ rfl l4
  have tr4 := one _ _ C (h3.control.isHalt_eq.trans rfl) r4
  have sl5 := one _ _ C₀ rfl l5
  have tr5 := one _ _ C (h4.control.isHalt_eq.trans rfl) r5
  have sl6 := one _ _ C₀ rfl l6
  have tr6 := one _ _ C (h5.control.isHalt_eq.trans rfl) r6
  have sl7 := one _ _ C₀ rfl l7
  have tr7 := one _ _ C (h6.control.isHalt_eq.trans rfl) r7
  have sl8 := one _ _ C₀ rfl l8
  have tr8 := one _ _ C (h7.control.isHalt_eq.trans rfl) r8
  have sl9 := one _ _ C₀ rfl l9
  have tr9 := one _ _ C (h8.control.isHalt_eq.trans rfl) r9
  have sl10 := one _ _ C₀ rfl l10
  have tr10 := one _ _ C (h9.control.isHalt_eq.trans rfl) r10
  exact ⟨_,runC_join F (runC_join F (runC_join F (runC_join F (runC_join F
    (runC_join F (runC_join F (runC_join F (runC_join F sl1 sl2) sl3) sl4) sl5) sl6) sl7) sl8) sl9) sl10,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F
    (runC_join F (runC_join F (runC_join F (runC_join F tr1 tr2) tr3) tr4) tr5) tr6) tr7) tr8) tr9) tr10,
    h10,inv10,rfl,rfl,rfl⟩

end Host.Ts.Owned.Annotated
