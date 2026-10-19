import host.ts.RenameTwoParameterEntryFields
import host.ts.RenameRetainedClosure
import host.ts.RenameRetainedParameterBody
import host.ts.RenameRetainedStores
import host.ts.RenameRuntimeParameters
import host.ts.RenameRuntimePureScheduler
import host.ts.RenameRouteComposition

set_option Elab.async false
set_option maxHeartbeats 1000000
set_option maxRecDepth 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

def twoArgumentEntered {S : Type} (source : St S) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) : St S :=
  closureState source (twoParameterFunction functionName firstName secondName body) env false .undef
    receiver [firstValue,secondValue] .call

def twoArgumentEnvironment {S : Type} (source : St S) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver : Val) : Env :=
  closureEnvironment source (twoParameterFunction functionName firstName secondName body) env false .undef receiver

def twoArgumentCaller (source : St S) : List Frame := .k (.fn .call)::source.stack

def twoArgumentFirstSelected {S : Type} (source : St S) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) : St S :=
  parameterArgument {twoArgumentEntered source functionName firstName secondName body env receiver firstValue secondValue
      with stack := twoArgumentCaller source}
    (twoParameterFunction functionName firstName secondName body) firstName [.id secondName]
    [firstValue,secondValue] (twoArgumentEnvironment source functionName firstName secondName body env receiver)

def twoArgumentFirstBound {S : Type} (source : St S) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) : St S :=
  ((twoArgumentFirstSelected source functionName firstName secondName body env receiver firstValue secondValue).setCell
    (source.next+1) firstValue).ret .undef

def twoArgumentSecondSelected {S : Type} (source : St S) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) : St S :=
  parameterArgument {twoArgumentFirstBound source functionName firstName secondName body env receiver firstValue secondValue
      with stack := twoArgumentCaller source}
    (twoParameterFunction functionName firstName secondName body) secondName [] [secondValue]
    (twoArgumentEnvironment source functionName firstName secondName body env receiver)

def twoArgumentSecondBound {S : Type} (source : St S) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) : St S :=
  ((twoArgumentSecondSelected source functionName firstName secondName body env receiver firstValue secondValue).setCell
    (source.next+2) secondValue).ret .undef

/-- Both generated parameter cells are initialized, and the caller suffix is the original call boundary. -/
def twoArgumentBase {S : Type} (source : St S) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) : St S :=
  let entered := twoArgumentEntered source functionName firstName secondName body env receiver firstValue secondValue
  {((entered.setCell (source.next+1) firstValue).setCell (source.next+2) secondValue).ret .undef with
    stack := twoArgumentCaller source}

def twoArgumentEntry {S : Type} (source : St S) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) : St S :=
  enterBlock (twoArgumentBase source functionName firstName secondName body env receiver firstValue secondValue) body
    (twoArgumentEnvironment source functionName firstName secondName body env receiver)

def twoArgumentEntryNotes {S : Type} (notes : RetainedNotes) (source : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val)
    (firstRole secondRole thisRole : Value) : RetainedNotes :=
  let fn := twoParameterFunction functionName firstName secondName body
  let e := twoArgumentEnvironment source functionName firstName secondName body env receiver
  let tail := callBoundaryNote::notes.runtime.stack
  let closed := notes.runtime.closure fn [firstRole,secondRole] e false source.next thisRole
  let first := (closed.parameterArgument fn firstName [.id secondName] [firstRole,secondRole] e tail).initialized
    (source.next+1) firstRole
  let second := (first.parameterArgument fn secondName [] [secondRole] e tail).initialized (source.next+2) secondRole
  let base := twoArgumentBase source functionName firstName secondName body env receiver firstValue secondValue
  notes.withRuntime (second.bodyEntered body (hoist base body e).1 tail)

theorem twoArgument_second_next {S : Type} (source : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) :
    (twoArgumentSecondBound source functionName firstName secondName body env receiver firstValue secondValue).next =
      source.next+3 := by
  simp only [twoArgumentSecondBound,twoArgumentSecondSelected,parameterArgument,twoArgumentFirstBound,
    twoArgumentFirstSelected,twoArgumentEntered,St.setCell,St.ret,St.push,St.go]
  exact twoParameter_next source functionName firstName secondName body env receiver firstValue secondValue

theorem twoArgument_base_next {S : Type} (source : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) :
    (twoArgumentBase source functionName firstName secondName body env receiver firstValue secondValue).next =
      source.next+3 := by
  simp only [twoArgumentBase,twoArgumentEntered,St.setCell,St.ret]
  exact twoParameter_next source functionName firstName secondName body env receiver firstValue secondValue

theorem twoArgument_operational_base {S : Type} (source : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val) :
    {twoArgumentSecondBound source functionName firstName secondName body env receiver firstValue secondValue with
      stack := twoArgumentCaller source} =
      twoArgumentBase source functionName firstName secondName body env receiver firstValue secondValue := by
  refine (with_stack_eq (s := twoArgumentSecondBound source functionName firstName secondName body env receiver
      firstValue secondValue)
      (t := twoArgumentBase source functionName firstName secondName body env receiver firstValue secondValue)
      (frames := twoArgumentCaller source) rfl ?_ rfl rfl).trans ?_
  · exact (twoArgument_second_next source functionName firstName secondName body env receiver firstValue secondValue).trans
      (twoArgument_base_next source functionName firstName secondName body env receiver firstValue secondValue).symm
  · rfl

theorem twoArgument_second_cell {S : Type} (source : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val)
    (bound : source.next+2 < 2^64) :
    (twoArgumentSecondSelected source functionName firstName secondName body env receiver firstValue secondValue).heap.get
      (source.next+2) = some (.cell none) := by
  have uninit := twoParameter_uninitialized_second source functionName firstName secondName body env receiver
    firstValue secondValue bound
  change (((twoArgumentEntered source functionName firstName secondName body env receiver firstValue secondValue).heap.set
    (source.next+1) (.cell (some firstValue)))).get (source.next+2) = _
  rw [PTrie.get_set_u64 _ _ _ (by omega),ite_eq_right (by omega : source.next+2 ≠ source.next+1)]
  exact uninit

theorem twoArgument_reached_heap_below {S : Type} (source : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val)
    (inert : noInitFunctions body = true) (bound : source.next+4+(blockNames body).length ≤ 2^64)
    (a : Nat) (below : a < source.next) :
    (twoArgumentEntry source functionName firstName secondName body env receiver firstValue secondValue).heap.get a =
      source.heap.get a := by
  let base := twoArgumentBase source functionName firstName secondName body env receiver firstValue secondValue
  have cellBound : source.next+2 < 2^64 := by omega
  have baseNext := twoArgument_base_next source functionName firstName secondName body env receiver firstValue secondValue
  have old : base.heap.get a = source.heap.get a := by
    have entered : (twoArgumentEntered source functionName firstName secondName body env receiver firstValue secondValue).heap.get a =
        source.heap.get a :=
      twoParameter_heap_below source functionName firstName secondName body env receiver firstValue secondValue cellBound a below
    change ((((twoArgumentEntered source functionName firstName secondName body env receiver firstValue secondValue).heap.set
      (source.next+1) (.cell (some firstValue))).set (source.next+2) (.cell (some secondValue)))).get a = _
    rw [PTrie.get_set_u64 _ _ _ (by omega),ite_eq_right (by omega : a ≠ source.next+2),
      PTrie.get_set_u64 _ _ _ (by omega),ite_eq_right (by omega : a ≠ source.next+1)]
    exact entered
  have belowBase : a < base.next := by rw [baseNext]; omega
  have blockBound : base.next+(blockNames body).length ≤ 2^64 := by rw [baseNext]; omega
  exact (enterBlock_heap_below base body _ a belowBase blockBound inert).trans old

theorem twoArgument_reached_next {S : Type} (source : St S) (functionName : Option Name)
    (firstName secondName : Name) (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val)
    (inert : noInitFunctions body = true) :
    (twoArgumentEntry source functionName firstName secondName body env receiver firstValue secondValue).next =
      source.next + (3 + (blockNames body).length) := by
  rw [twoArgumentEntry,enterBlock_next _ _ _ inert,
    twoArgument_base_next source functionName firstName secondName body env receiver firstValue secondValue,
    Nat.add_assoc]

private theorem entry_run_one (F : Ffi) (source target : St F.S) (C : CSrv)
    (active : isHalt source.ctl = false) (execution : interpC (step F source).run C = some (target,C)) :
    runC F 1 source C = some (target,C) := runC_cons F 0 source target target C C C active execution rfl

/-- Execute the original two-argument closure, both identifier parameter
scheduling/initialization pairs, and the real block entry. Exactly six
transitions. Argument roles are stored in the fresh cells created by this
entry; no future parameter cell or target read is assumed. -/
theorem RetainedInventory.two_argument_entry
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address : Nat) (function : Obj) (functionName : Option Name) (firstName secondName : Name)
    (body : List Stmt) (env : Env) (receiver firstValue secondValue : Val)
    (firstRole secondRole fnRole thisRole : Value)
    (distinct : nameEq firstName secondName = false)
    (control : source.ctl = .call (.obj address) receiver [firstValue,secondValue])
    (read : source.heap.get address = some (.obj function))
    (kind : function.kind = .fn (.closure (twoParameterFunction functionName firstName secondName body) env false .undef))
    (controlNote : notes.runtime.control = callNote fnRole thisRole [firstRole,secondRole])
    (inert : noInitFunctions body = true)
    (sourceBound : source.next+4+(blockNames body).length ≤ 2^64)
    (targetBound : target.next+4+(blockNames body).length ≤ 2^64) :
    let fn := twoParameterFunction functionName firstName secondName body
    let reached := twoArgumentEntry source functionName firstName secondName body env receiver firstValue secondValue
    let endLive := CellsLive (ClosureLive live source.next false .undef fn) (source.next+3) (blockNames body)
    ∃ result,
      runC F 6 source C₀ = some (reached,C₀) ∧
      runC F 6 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R endLive framed before after old old' reached result ∧
      RetainedInventory (twoArgumentEntryNotes notes source functionName firstName secondName body env receiver
        firstValue secondValue firstRole secondRole thisRole) ν₀ ν C₀ C R endLive reached result ∧
      result.ffi = target.ffi ∧
      result.next = target.next+3+(blockNames body).length ∧
      (∀ a, a < target.next → result.heap.get a = target.heap.get a) ∧
      (∀ a, a < source.next → reached.heap.get a = source.heap.get a) := by
  dsimp only
  let fn := twoParameterFunction functionName firstName secondName body
  let e := twoArgumentEnvironment source functionName firstName secondName body env receiver
  let frames := twoArgumentCaller source
  let tail := callBoundaryNote::notes.runtime.stack
  have names : (paramNames fn).length = 2 := by rw [twoParameter_param_length]; rfl
  have sourceClosureBound : source.next+2+(paramNames fn).length ≤ 2^64 := by rw [names]; omega
  have targetClosureBound : target.next+2+(paramNames fn).length ≤ 2^64 := by rw [names]; omega
  have cellBound : source.next+2 < 2^64 := by omega
  obtain ⟨targetHome,targetThis,targetArgs,left1,right1,h1,inv1⟩ := inventory.closure_step F FR notes ν₀ ν C₀ C R
    live framed before after old old' source target h address function fn env false .undef receiver
    [firstValue,secondValue] fnRole thisRole [firstRole,secondRole] control read kind controlNote
    sourceClosureBound targetClosureBound
  have enteredNext := twoParameter_next source functionName firstName secondName body env receiver firstValue secondValue
  have closureTargetNext := h.target_next_add h1 3 enteredNext
  obtain ⟨scheduled1,left2,right2,h2,runtime2⟩ := inv1.runtime.parameter_id_step F FR _ ν₀ ν C₀ C R
    _ framed before after old old' _ _ h1 .undef fn firstName [.id secondName] [firstValue,secondValue] e frames
    [firstRole,secondRole] tail rfl (closureState_stack source fn env false .undef receiver [firstValue,secondValue] .call) rfl
  have pure2 := PureRuntimeCase.parameterId h1 .undef fn firstName [.id secondName] [firstValue,secondValue] e frames
    rfl (closureState_stack source fn env false .undef receiver [firstValue,secondValue] .call)
  have effects2 := pure2.effects left2 right2
  have inv2 := inv1.pure_step runtime2 pure2 left2 right2 (.refl C₀) (.refl C)
  have sourceSchedBound : (twoArgumentFirstSelected source functionName firstName secondName body env receiver
      firstValue secondValue).next ≤ 2^64 := by
    have preserved : (twoArgumentFirstSelected source functionName firstName secondName body env receiver
        firstValue secondValue).next = source.next+3 := by
      simp only [twoArgumentFirstSelected,parameterArgument,twoArgumentEntered,St.push,St.go]
      exact twoParameter_next source functionName firstName secondName body env receiver firstValue secondValue
    rw [preserved]; omega
  have targetSchedBound : scheduled1.next ≤ 2^64 := by rw [effects2.2.next,closureTargetNext]; omega
  obtain ⟨initialized1,left3,right3,h3,inv3⟩ := inv2.init_step h2 firstName e (source.next+1) firstValue none .let_
    firstRole rfl (twoParameter_lookup_first source functionName firstName secondName body env receiver distinct)
    (twoParameter_uninitialized_first source functionName firstName secondName body env receiver firstValue secondValue cellBound)
    rfl sourceSchedBound targetSchedBound
  obtain ⟨scheduled2,left4,right4,h4,runtime4⟩ := inv3.runtime.parameter_id_step F FR _ ν₀ ν C₀ C R
    _ framed before after old old' _ _ h3 .undef fn secondName [] [secondValue] e frames [secondRole] tail
    rfl rfl rfl
  have pure4 := PureRuntimeCase.parameterId h3 .undef fn secondName [] [secondValue] e frames rfl rfl
  have effects4 := pure4.effects left4 right4
  have inv4 := inv3.pure_step runtime4 pure4 left4 right4 (.refl C₀) (.refl C)
  have sourceSecondBound : (twoArgumentSecondSelected source functionName firstName secondName body env receiver
      firstValue secondValue).next ≤ 2^64 := by
    have preserved : (twoArgumentSecondSelected source functionName firstName secondName body env receiver
        firstValue secondValue).next = source.next+3 := by
      simp only [twoArgumentSecondSelected,parameterArgument,twoArgumentFirstBound,twoArgumentFirstSelected,
        twoArgumentEntered,St.setCell,St.ret,St.push,St.go]
      exact twoParameter_next source functionName firstName secondName body env receiver firstValue secondValue
    rw [preserved]; omega
  have targetSecondBound : scheduled2.next ≤ 2^64 := by
    have initNext : ((scheduled1.setCell (R.a (source.next+1)) initialized1).ret .undef).next = scheduled1.next := rfl
    rw [effects4.2.next,initNext,effects2.2.next,closureTargetNext]; omega
  obtain ⟨initialized2,left5,right5,h5,inv5⟩ := inv4.init_step h4 secondName e (source.next+2) secondValue none .let_
    secondRole rfl (twoParameter_lookup_second source functionName firstName secondName body env receiver)
    (twoArgument_second_cell source functionName firstName secondName body env receiver firstValue secondValue cellBound)
    rfl sourceSecondBound targetSecondBound
  have sourceBodyBound : (twoArgumentSecondBound source functionName firstName secondName body env receiver
      firstValue secondValue).next+(blockNames body).length ≤ 2^64 := by
    rw [twoArgument_second_next]; omega
  have targetBodyBound : ((scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef).next+
      (blockNames body).length ≤ 2^64 := by
    have initNext : ((scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef).next = scheduled2.next := rfl
    have schedNext : scheduled2.next = target.next+3 := by
      have firstInit : ((scheduled1.setCell (R.a (source.next+1)) initialized1).ret .undef).next = scheduled1.next := rfl
      rw [effects4.2.next,firstInit,effects2.2.next,closureTargetNext]
    rw [initNext,schedNext]; omega
  obtain ⟨targetFrames,left6,right6,h6,inv6⟩ := inv5.parameter_body_step h5 .undef functionName
    [.id firstName,.id secondName] body [] e frames (parameterFrameNote fn [] [] e) tail rfl rfl rfl inert
    sourceBodyBound targetBodyBound
  have preNext := twoArgument_second_next source functionName firstName secondName body env receiver
    firstValue secondValue
  simp only [twoArgumentSecondBound,twoArgumentSecondSelected,parameterArgument,twoArgumentFirstBound,
    twoArgumentFirstSelected,twoArgumentEntered,St.setCell,St.ret,St.push,St.go] at preNext
  rw [preNext] at h6 inv6
  have sourceActive : isHalt source.ctl = false := by rw [control]; rfl
  have targetActive : isHalt target.ctl = false := h.control.isHalt_eq.trans sourceActive
  have source1 := entry_run_one F _ _ C₀ sourceActive left1
  have target1 := entry_run_one F _ _ C targetActive right1
  have source2 := entry_run_one F _ _ C₀ rfl left2
  have target2 := entry_run_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have source3 := entry_run_one F _ _ C₀ rfl left3
  have target3 := entry_run_one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have source4 := entry_run_one F _ _ C₀ rfl left4
  have target4 := entry_run_one F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  have source5 := entry_run_one F _ _ C₀ rfl left5
  have target5 := entry_run_one F _ _ C (h4.control.isHalt_eq.trans rfl) right5
  have source6 := entry_run_one F _ _ C₀ rfl left6
  have target6 := entry_run_one F _ _ C (h5.control.isHalt_eq.trans rfl) right6
  let reached := twoArgumentEntry source functionName firstName secondName body env receiver firstValue secondValue
  refine ⟨enterBlock {(scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef with stack := targetFrames}
      body (R.env e),
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F source1 source2) source3) source4) source5) source6,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F target1 target2) target3) target4) target5) target6,
    h6,inv6,?_,?_,?_,?_⟩
  · have closureFfi := closureState_ffi target fn (R.env env) false targetHome targetThis targetArgs .call
    have blockFfi := enterBlock_ffi {(scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef with
      stack := targetFrames} body (R.env e) inert
    have scheduledFfi : scheduled2.ffi = scheduled1.ffi := by
      have firstFfi : ((scheduled1.setCell (R.a (source.next+1)) initialized1).ret .undef).ffi = scheduled1.ffi := rfl
      exact effects4.2.native.trans firstFfi
    exact blockFfi.trans (scheduledFfi.trans (effects2.2.native.trans closureFfi))
  · have sourceReached := twoArgument_reached_next source functionName firstName secondName body env receiver
      firstValue secondValue inert
    have grown := h.target_next_add h6 (3+(blockNames body).length) sourceReached
    rw [← Nat.add_assoc] at grown
    exact grown
  · intro a below
    have address1 : R.a (source.next+1) = target.next+1 := h.heap.fresh 1
    have address2 : R.a (source.next+2) = target.next+2 := h.heap.fresh 2
    have word1 : target.next+1 < 2^64 := by omega
    have word2 : target.next+2 < 2^64 := by omega
    have preNext : ((scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef).next = target.next+3 := by
      have secondNext : ((scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef).next = scheduled2.next := rfl
      have firstNext : ((scheduled1.setCell (R.a (source.next+1)) initialized1).ret .undef).next = scheduled1.next := rfl
      rw [secondNext,effects4.2.next,firstNext,effects2.2.next,closureTargetNext]
    have belowBlock : a < ((scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef).next := by
      rw [preNext]; omega
    have blockBound : ((scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef).next+
        (blockNames body).length ≤ 2^64 := by rw [preNext]; omega
    have blockHeap := enterBlock_heap_below
      {(scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef with stack := targetFrames}
      body (R.env e) a belowBlock blockBound inert
    have secondStored : (((scheduled2.setCell (R.a (source.next+2)) initialized2).ret .undef).heap).get a =
        scheduled2.heap.get a := by
      change (scheduled2.heap.set (R.a (source.next+2)) (.cell (some initialized2))).get a = _
      rw [address2,PTrie.get_set_u64 _ _ _ word2,ite_eq_right (by omega : a ≠ target.next+2)]
    have firstStored : ((scheduled1.setCell (R.a (source.next+1)) initialized1).ret .undef).heap.get a =
        scheduled1.heap.get a := by
      change (scheduled1.heap.set (R.a (source.next+1)) (.cell (some initialized1))).get a = _
      rw [address1,PTrie.get_set_u64 _ _ _ word1,ite_eq_right (by omega : a ≠ target.next+1)]
    have scheduledHeap : scheduled2.heap.get a =
        ((scheduled1.setCell (R.a (source.next+1)) initialized1).ret .undef).heap.get a := by
      rw [effects4.2.heap]
    have pureHeap : scheduled1.heap.get a = target.heap.get a := by
      rw [effects2.2.heap]
      exact closureState_heap_below F target fn (R.env env) false targetHome targetThis targetArgs .call
        targetClosureBound a below
    exact blockHeap.trans (secondStored.trans (scheduledHeap.trans (firstStored.trans pureHeap)))
  · exact twoArgument_reached_heap_below source functionName firstName secondName body env receiver
      firstValue secondValue inert sourceBound

end Host.Ts.Owned.Annotated
