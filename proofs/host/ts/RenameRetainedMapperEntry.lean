import host.ts.RenameRetainedClosure
import host.ts.RenameRetainedStores
import host.ts.RenameRetainedExpressionBody
import host.ts.RenameRuntimeParameters
import host.ts.RenameRuntimePureScheduler
import host.ts.RenameRouteComposition

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def mapperFunction (name field : Name) : Func :=
  .mk none [.id name] none (.expr (.member (.id name) field false)) false false []
def mapperEnvironment {S : Type} (s : St S) (env : Env) (name : Name) : Env :=
  (name,s.next)::env
def mapperEntered {S : Type} (s : St S) (env : Env) (name field : Name) (receiver : Val) (owner : Nat) (extraArgs : List Val) : St S :=
  closureState s (mapperFunction name field) env true .undef receiver (.obj owner::extraArgs) .call
def mapperSelected {S : Type} (s : St S) (env : Env) (name field : Name) (receiver : Val) (owner : Nat) (extraArgs : List Val) : St S :=
  parameterArgument {mapperEntered s env name field receiver owner extraArgs with stack := .k (.fn .call)::s.stack}
    (mapperFunction name field) name [] (.obj owner::extraArgs) (mapperEnvironment s env name)
def mapperBound {S : Type} (s : St S) (env : Env) (name field : Name) (receiver : Val) (owner : Nat) (extraArgs : List Val) : St S :=
  ((mapperSelected s env name field receiver owner extraArgs).setCell s.next (.obj owner)).ret .undef
def mapperEntrySource {S : Type} (s : St S) (env : Env) (name field : Name) (receiver : Val) (owner : Nat) (extraArgs : List Val) : St S :=
  expressionBodyState (mapperBound s env name field receiver owner extraArgs) (.member (.id name) field false)
    (mapperEnvironment s env name) (.k (.fn .call)::s.stack)
def RuntimeNotes.mapperEntry (notes : RuntimeNotes) (env : Env) (name field : Name) (cell owner : Nat) : RuntimeNotes :=
  ⟨expressionNote (.member (.id name) field false) ((name,cell)::env),
    expressionReturnNote::callBoundaryNote::notes.stack,notes.cells.write cell (.obj owner)⟩

theorem mapper_enter_environment {S : Type} (s : St S) (env : Env) (name field : Name) (receiver : Val) :
    closureEnvironment s (mapperFunction name field) env true .undef receiver = mapperEnvironment s env name := rfl

theorem mapper_enter_cell {S : Type} (s : St S) (env : Env) (name field : Name) (receiver : Val) (owner : Nat) (extraArgs : List Val)
    (bound : s.next < 2^64) :
    (mapperEntered s env name field receiver owner extraArgs).heap.get s.next = some (.cell none) := by
  change (s.heap.set s.next (.cell none)).get s.next = _
  rw [PTrie.get_set_u64 _ _ _ bound]
  simp

theorem mapper_entry_heap_below {S : Type} (s : St S) (env : Env) (name field : Name) (receiver : Val) (owner : Nat) (extraArgs : List Val)
    (bound : s.next < 2^64) (a : Nat) (below : a < s.next) :
    (mapperEntrySource s env name field receiver owner extraArgs).heap.get a = s.heap.get a := by
  change ((s.heap.set s.next (.cell none)).set s.next (.cell (some (.obj owner)))).get a = _
  rw [PTrie.get_set_u64 _ _ _ bound,ite_eq_right (Nat.ne_of_lt below),
    PTrie.get_set_u64 _ _ _ bound,ite_eq_right (Nat.ne_of_lt below)]

private theorem mapper_run_one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- Enter the actual `x => x.field` mapper with an arbitrary source receiver,
captured environment, heap and caller. The argument role is stored in the real
fresh parameter cell before the member expression begins. -/
theorem RetainedInventory.mapper_entry_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (callee owner : Nat) (object : Obj) (env : Env) (name field : Name) (receiver : Val)
    (fnRole thisRole : Value) (extraArgs : List Val) (extraRoles : List Value)
    (control : s₀.ctl = .call (.obj callee) receiver (.obj owner::extraArgs))
    (read : s₀.heap.get callee = some (.obj object))
    (kind : object.kind = .fn (.closure (mapperFunction name field) env true .undef))
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj owner::extraRoles))
    (sourceBound : s₀.next+3 ≤ 2^64) (targetBound : s.next+3 ≤ 2^64) :
    ∃ result,
      runC F 4 s₀ C₀ = some (mapperEntrySource s₀ env name field receiver owner extraArgs,C₀) ∧
      runC F 4 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
        (ClosureLive live s₀.next true .undef (mapperFunction name field)) framed before after old old'
        (mapperEntrySource s₀ env name field receiver owner extraArgs) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.mapperEntry env name field s₀.next owner))
        ν₀ ν C₀ C R (ClosureLive live s₀.next true .undef (mapperFunction name field))
        (mapperEntrySource s₀ env name field receiver owner extraArgs) result ∧
      result.ffi = s.ffi ∧ result.next = s.next+1 ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨home,this,args,left1,right1,h1,inv1⟩ := inventory.closure_step F FR notes ν₀ ν C₀ C R
    live framed before after old old' s₀ s h
    callee object (mapperFunction name field) env true .undef receiver (.obj owner::extraArgs)
    fnRole thisRole (.obj owner::extraRoles) control read kind controlNote sourceBound targetBound
  obtain ⟨s2,left2,right2,h2,runtime2⟩ := inv1.runtime.parameter_id_step F FR _ ν₀ ν C₀ C R
    _ framed before after old old' _ _ h1 .undef (mapperFunction name field) name [] (.obj owner::extraArgs)
    (mapperEnvironment s₀ env name) (.k (.fn .call)::s₀.stack) (.obj owner::extraRoles)
    (callBoundaryNote::notes.runtime.stack) rfl rfl rfl
  have pure2 := PureRuntimeCase.parameterId h1 .undef (mapperFunction name field) name [] (.obj owner::extraArgs)
    (mapperEnvironment s₀ env name) (.k (.fn .call)::s₀.stack) rfl rfl
  have effects2 := pure2.effects left2 right2
  have inv2 := inv1.pure_step runtime2 pure2 left2 right2 (.refl C₀) (.refl C)
  have sourceWord : s₀.next < 2^64 := by omega
  have source2Bound : (mapperSelected s₀ env name field receiver owner extraArgs).next ≤ 2^64 := by
    change s₀.next+1 ≤ 2^64
    omega
  have target2Bound : s2.next ≤ 2^64 := by
    have next2 := effects2.2.next
    change s2.next = s.next+1 at next2
    omega
  obtain ⟨targetValue,left3,right3,h3,inv3⟩ := inv2.init_step h2 name (mapperEnvironment s₀ env name)
    s₀.next (.obj owner) none .let_ (.obj owner) rfl (by simp [mapperEnvironment,lookupEnv,brec])
    (mapper_enter_cell s₀ env name field receiver owner extraArgs sourceWord) rfl source2Bound target2Bound
  obtain ⟨targetFrames,left4,right4,h4,inv4⟩ := inv3.parameter_expression_step h3 .undef none [.id name]
    (.member (.id name) field false) extraArgs (mapperEnvironment s₀ env name) (.k (.fn .call)::s₀.stack)
    (parameterFrameNote (mapperFunction name field) [] extraRoles (mapperEnvironment s₀ env name))
    (callBoundaryNote::notes.runtime.stack) rfl rfl rfl
  have sourceActive : isHalt s₀.ctl = false := by rw [control]; rfl
  have targetActive : isHalt s.ctl = false := h.control.isHalt_eq.trans sourceActive
  have source1 := mapper_run_one F _ _ C₀ sourceActive left1
  have target1 := mapper_run_one F _ _ C targetActive right1
  have source2 := mapper_run_one F _ _ C₀ rfl left2
  have target2 := mapper_run_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have source3 := mapper_run_one F _ _ C₀ rfl left3
  have target3 := mapper_run_one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have source4 := mapper_run_one F _ _ C₀ rfl left4
  have target4 := mapper_run_one F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  refine ⟨_,runC_join F (runC_join F (runC_join F source1 source2) source3) source4,
    runC_join F (runC_join F (runC_join F target1 target2) target3) target4,h4,inv4,?_,?_,?_⟩
  · exact effects2.2.native
  · exact effects2.2.next
  · intro a below
    have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
    have targetWord : s.next < 2^64 := by omega
    change (s2.heap.set (R.a s₀.next) (.cell (some targetValue))).get a = s.heap.get a
    rw [fresh,PTrie.get_set_u64 _ _ _ targetWord,ite_eq_right (Nat.ne_of_lt below),effects2.2.heap]
    exact closureState_heap_below F s (mapperFunction name field) (R.env env) true home this args .call targetBound a below

end Host.Ts.Owned.Annotated
