import host.ts.RenameRetainedNdimCall
import host.ts.RenameTwoParameterEntryFields

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric
namespace ShapeCall

def rankName : Name := chars!"n"
def pointerName : Name := chars!"shapePtr"
def ndimName : Name := chars!"ndim"
def nativeName : Name := chars!"mlx_array_shape"
def typedName : Name := chars!"Int32Array"
def bufferName : Name := chars!"toArrayBuffer"
def zero : Expr := .lit (.num chars!"0")
def four : Expr := .lit (.num chars!"4")
def ndimExpression : Expr := .member .this ndimName false
def rankDeclaration : Stmt := .decl .const [(.id rankName,some ndimExpression)]
def guard : Stmt := .if_ (.bin .seq (.id rankName) zero) (.ret (some (.array []))) none
def nativeArgs : List Elem := [.expr (.member .this NdimCall.handleName false)]
def pointerExpression : Expr := .call (.member (.id NdimCall.nativeModule) nativeName false) nativeArgs false
def pointerDeclaration : Stmt := .decl .const [(.id pointerName,some pointerExpression)]
def countExpression : Expr := .bin .mul (.id rankName) four
def bufferArgs : List Elem := [.expr (.id pointerName),.expr zero,.expr countExpression]
def bufferExpression : Expr := .call (.id bufferName) bufferArgs false
def typedArgs : List Elem := [.expr bufferExpression]
def resultExpression : Expr := .array [.spread (.new (.id typedName) typedArgs)]
def returnStatement : Stmt := .ret (some resultExpression)
def statements : List Stmt := [rankDeclaration,guard,pointerDeclaration,returnStatement]
def function : Func := .mk none [] none (.block statements) false false []
theorem pinned_function : function = Sources.Mlx.Array.ast_n67 := rfl

def closure {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) : St S :=
  closureState source function env false home (.obj owner) [] .call
def lexicalEnv {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) : Env :=
  closureEnvironment source function env false home (.obj owner)
def bodyEnv {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) : Env :=
  (hoist (closure source env home owner) statements (lexicalEnv source env home owner)).1
def body {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) : St S :=
  enterBlock {(closure source env home owner) with stack := .k (.fn .call)::source.stack}
    statements (lexicalEnv source env home owner)
def entry {S : Type} (source : St S) (env : Env) (home : Val) (owner getter : Nat) : St S :=
  {(body source env home owner) with ctl := .call (.obj getter) (.obj owner) [],stack := (
    .s (.decl .const (.id rankName) [] (bodyEnv source env home owner))::
      .s (.block [guard,pointerDeclaration,returnStatement] (bodyEnv source env home owner))::
      .s (.scope [])::.k (.fn .call)::source.stack)}
def entryLive {S : Type} (live : Nat → Prop) (source : St S) (env : Env) (home : Val) (owner : Nat) : Nat → Prop :=
  CellsLive (ClosureLive live source.next false home function) (closure source env home owner).next (blockNames statements)
def entryRuntime (notes : RuntimeNotes) (env : Env) (receiver owner getter : Nat) : RuntimeNotes :=
  {((notes.closure function [] env false receiver (.obj owner)).bodyEntered statements env (callBoundaryNote::notes.stack)) with
    control := callNote (.obj getter) (.obj owner) [],stack := (
      (statementFrameNotes env (.declarationInit .const (.id rankName) ndimExpression [])).headD callBoundaryNote::
      blockFrameNote [guard,pointerDeclaration,returnStatement] env::emptyScopeNote::callBoundaryNote::notes.stack)}
def entryNotes {S : Type} (notes : RetainedNotes) (source : St S) (env : Env) (home : Val) (owner getter : Nat) : RetainedNotes :=
  notes.withRuntime (entryRuntime notes.runtime (bodyEnv source env home owner) source.next owner getter)

theorem closure_room {S : Type} (source : St S) (env : Env) (home receiver : Val) (args : List Val) :
    (closureState source function env false home receiver args .call).next ≤ source.next+2 := by
  cases home <;> first
    | change source.next+1 ≤ source.next+2; omega
    | change source.next+1+1 ≤ source.next+2; omega

private theorem one_step (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- The actual shape closure enters its real two-cell lexical block and calls
its ndim accessor in seven original transitions. -/
theorem entry_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (shapeGetter owner ndimGetter : Nat) (object : Obj) (env : Env) (home : Val) (setter : Val) (enumerable : Bool)
    (control : source.ctl = .call (.obj shapeGetter) (.obj owner) [])
    (read : source.heap.get shapeGetter = some (.obj object))
    (kind : object.kind = .fn (.closure Sources.Mlx.Array.ast_n67 env false home))
    (path : OrdinaryLookup source ndimName 16 owner (some (.acc (.obj ndimGetter) setter enumerable)))
    (ownerLive : live owner) (controlNote : notes.runtime.control = callNote (.obj shapeGetter) (.obj owner) [])
    (sourceBound : source.next+4 ≤ 2^64) (targetBound : target.next+4 ≤ 2^64) :
    ∃ result, runC F 7 source C₀ = some (entry source env home owner ndimGetter,C₀) ∧
      runC F 7 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (entryLive live source env home owner)
        framed before after old old' (entry source env home owner ndimGetter) result ∧
      RetainedInventory (entryNotes notes source env home owner ndimGetter) ν₀ ν C₀ C R
        (entryLive live source env home owner) (entry source env home owner ndimGetter) result ∧
      result.ffi = target.ffi ∧ result.next ≤ target.next+4 ∧
      (∀ a, a < target.next → result.heap.get a = target.heap.get a) := by
  let e := lexicalEnv source env home owner
  let b := bodyEnv source env home owner
  let live' := entryLive live source env home owner
  have sourceBound2 : source.next+2 ≤ 2^64 := by omega
  have targetBound2 : target.next+2 ≤ 2^64 := by omega
  obtain ⟨targetHome,targetThis,targetArgs,l1,r1,h1,inv1⟩ := inventory.closure_step F FR notes ν₀ ν C₀ C R
    live framed before after old old' source target state shapeGetter object function env false home (.obj owner) []
    (.obj shapeGetter) (.obj owner) [] control read (by simpa only [pinned_function] using kind) controlNote sourceBound2 targetBound2
  have sourceRoom : (closureState source function env false home (.obj owner) [] .call).next + (blockNames statements).length ≤ 2^64 := by
    have room := closure_room source env home (.obj owner) []
    change (closureState source function env false home (.obj owner) [] .call).next+2 ≤ 2^64
    omega
  have targetRoom : (closureState target function (R.env env) false targetHome targetThis targetArgs .call).next + (blockNames statements).length ≤ 2^64 := by
    have room := closure_room target (R.env env) targetHome targetThis targetArgs
    change (closureState target function (R.env env) false targetHome targetThis targetArgs .call).next+2 ≤ 2^64
    omega
  obtain ⟨targetFrames,l2,r2,h2,inv2⟩ := inv1.parameter_body_step h1 .undef none [] statements [] e
    (.k (.fn .call)::source.stack) (parameterFrameNote function [] [] e) (callBoundaryNote::notes.runtime.stack)
    rfl (closureState_stack source function env false home (.obj owner) [] .call) rfl rfl sourceRoom targetRoom
  obtain ⟨target3,l3,r3,h3,runtime3⟩ := inv2.runtime.block_next_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h2 .undef rankDeclaration [guard,pointerDeclaration,returnStatement] b
    (.s (.scope [])::.k (.fn .call)::source.stack) (blockFrameNote statements b)
    (emptyScopeNote::callBoundaryNote::notes.runtime.stack) rfl rfl rfl
  have pure3 := PureRuntimeCase.blockNext h2 .undef rankDeclaration [guard,pointerDeclaration,returnStatement] b
    (.s (.scope [])::.k (.fn .call)::source.stack) rfl rfl
  have effects3 := pure3.effects l3 r3
  have inv3 := inv2.pure_step runtime3 pure3 l3 r3 (.refl C₀) (.refl C)
  obtain ⟨l4,r4,h4,runtime4⟩ := runtime3.statement_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h3 (.declarationInit .const (.id rankName) ndimExpression []) b rfl
  have inv4 := inv3.heap_step runtime4 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨l5,r5,h5,runtime5⟩ := runtime4.descent_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h4 (.member .this ndimName false) b rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  have bodyEnvEq : b = (pointerName,(closure source env home owner).next+1)::
      (rankName,(closure source env home owner).next)::e := rfl
  have thisLookup : lookupEnv nThis b = some source.next := by
    rw [bodyEnvEq,lookupEnv_skip nThis pointerName _ _ (by decide +kernel),
      lookupEnv_skip nThis rankName _ _ (by decide +kernel)]
    exact getter_environment_this source none env home owner chars!"disposed" chars!"handle" (.block [])
  have receiverRead := closureState_receiver F source function env home (.obj owner) [] .call sourceBound2
  have receiverBelow : source.next < (closure source env home owner).next := by
    cases home <;> first
      | change source.next < source.next+1; omega
      | change source.next < source.next+1+1; omega
  have bodyReceiver : (body source env home owner).heap.get source.next = some (.cell (some (.obj owner))) :=
    (enterBlock_heap_below _ statements e source.next receiverBelow sourceRoom rfl).trans receiverRead
  obtain ⟨_,l6,r6,h6,runtime6⟩ := runtime5.this_step F FR _ ν₀ ν C₀ C R _ framed before after old old'
    _ _ h5 b source.next (.obj owner) (.obj owner) rfl thisLookup bodyReceiver
    (by change (notes.runtime.cells.write source.next (.obj owner)).cells source.next = _; simp only [Notes.write,ite_true])
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  have readFrame : ∀ a, live a → (body source env home owner).heap.get a = source.heap.get a := by
    intro a alive
    have below := state.heap.sourceBound a alive
    have belowClosure : a < (closure source env home owner).next := Nat.lt_trans below receiverBelow
    exact (enterBlock_heap_below _ statements e a belowClosure sourceRoom rfl).trans
      (closureState_heap_below F source function env false home (.obj owner) [] .call sourceBound2 a below)
  obtain ⟨_,l7,r7,h7,inv7⟩ := inv6.getter_step h6 owner ndimGetter ndimName setter enumerable
    (.s (.decl .const (.id rankName) [] b)::.s (.block [guard,pointerDeclaration,returnStatement] b)::
      .s (.scope [])::.k (.fn .call)::source.stack) (descentFrameNote b (.member .this ndimName false))
    ((statementFrameNotes b (.declarationInit .const (.id rankName) ndimExpression [])).headD callBoundaryNote::
      blockFrameNote [guard,pointerDeclaration,returnStatement] b::emptyScopeNote::callBoundaryNote::notes.runtime.stack)
    rfl rfl (by
      refine OrdinaryLookup.frame_live state.heap ?_ path ownerLive
      intro a alive
      exact readFrame a alive) rfl
  have sl1 := one_step F _ _ C₀ (by rw [control]; rfl) l1
  have tr1 := one_step F _ _ C (state.control.isHalt_eq.trans (by rw [control]; rfl)) r1
  have sl2 := one_step F _ _ C₀ rfl l2
  have tr2 := one_step F _ _ C (h1.control.isHalt_eq.trans rfl) r2
  have sl3 := one_step F _ _ C₀ rfl l3
  have tr3 := one_step F _ _ C (h2.control.isHalt_eq.trans rfl) r3
  have sl4 := one_step F _ _ C₀ rfl l4
  have tr4 := one_step F _ _ C (h3.control.isHalt_eq.trans rfl) r4
  have sl5 := one_step F _ _ C₀ rfl l5
  have tr5 := one_step F _ _ C (h4.control.isHalt_eq.trans rfl) r5
  have sl6 := one_step F _ _ C₀ rfl l6
  have tr6 := one_step F _ _ C (h5.control.isHalt_eq.trans rfl) r6
  have sl7 := one_step F _ _ C₀ rfl l7
  have tr7 := one_step F _ _ C (h6.control.isHalt_eq.trans rfl) r7
  refine ⟨_,runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F sl1 sl2) sl3) sl4) sl5) sl6) sl7,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F tr1 tr2) tr3) tr4) tr5) tr6) tr7,h7,inv7,?_,?_,?_⟩
  · have baseNative : (enterBlock {(closureState target function (R.env env) false targetHome targetThis targetArgs .call) with stack := targetFrames} statements (R.env e)).ffi = target.ffi := by
      rw [enterBlock_ffi _ _ _ rfl]
      exact closureState_ffi target function (R.env env) false targetHome targetThis targetArgs .call
    exact effects3.2.native.trans baseNative
  · change target3.next ≤ target.next+4
    rw [effects3.2.next,enterBlock_next _ _ _ rfl]
    have room := closure_room target (R.env env) targetHome targetThis targetArgs
    change (closureState target function (R.env env) false targetHome targetThis targetArgs .call).next+2 ≤ target.next+4
    omega
  · intro a below
    have belowClosure : a < (closureState target function (R.env env) false targetHome targetThis targetArgs .call).next := by
      cases targetHome <;> first
        | change a < target.next+1; omega
        | change a < target.next+1+1; omega
    exact (congrArg (fun heap : PTrie HObj => heap.get a) effects3.2.heap).trans
      ((enterBlock_heap_below _ statements (R.env e) a belowClosure targetRoom rfl).trans
        (closureState_heap_below F target function (R.env env) false targetHome targetThis targetArgs .call targetBound2 a below))

end ShapeCall
end Host.Ts.Owned.Annotated
