import host.ts.RenameDefaultIdentifierParameterFields
import host.ts.RenameRuntimeParameters
import host.ts.RenameRuntimeDispatch
import host.ts.RenameRuntimePureScheduler
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRouteComposition

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Ts.Owned.Annotated
open Parametric

private theorem default_identifier_parameter_one (F : Ffi) (source target : St F.S) (C : CSrv)
    (active : isHalt source.ctl = false)
    (execution : interpC (step F source).run C = some (target,C)) :
    runC F 1 source C = some (target,C) :=
  runC_cons F 0 source target target C C C active execution rfl

private theorem default_identifier_parameter_ret_stack {S : Type} (state : St S) (value : Val) :
    (state.ret value).stack = state.stack := by
  cases state
  rfl

section
variable {F : Ffi} {FR : Ren → F.S → F.S → Prop} {ν₀ ν : Nat → F64}
  {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop} {before after : List Val}
  {old old' : List Event} {source target : St F.S} {notes : RetainedNotes}

/-- Schedule, read, return, and initialize a missing defaulted identifier
parameter in exactly four original transitions. The target value comes from
the current cell relation and its role; the target execution is constructed
from those checked transitions. -/
theorem RetainedInventory.default_identifier_parameter_block
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (related : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (value : Val) (fn : Func) (parameterName defaultName : Name)
    (remainingParams : List Pat) (args : List Val) (env : Env) (callerFrames : List Frame)
    (roles : List Value) (tailNotes : List Tree) (parameterAddress defaultAddress : Nat)
    (defaultValue : Val) (defaultRole : Value)
    (control : source.ctl = .ret value)
    (stack : source.stack = .k (.params fn
      (.dflt (.id parameterName) (.id defaultName)::remainingParams) args env)::callerFrames)
    (missing : nthD .undef args 0 = .undef)
    (parameterLookup : lookupEnv parameterName env = some parameterAddress)
    (parameterCell : source.heap.get parameterAddress = some (.cell none))
    (defaultLookup : lookupEnv defaultName env = some defaultAddress)
    (defaultCell : source.heap.get defaultAddress = some (.cell (some defaultValue)))
    (defaultEntry : notes.runtime.cells.cells defaultAddress = some defaultRole)
    (parameterBound : parameterAddress < source.next)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64)
    (stackNotes : notes.runtime.stack =
      parameterFrameNote fn (.dflt (.id parameterName) (.id defaultName)::remainingParams)
        roles env::tailNotes) :
    ∃ (targetDefaultValue targetValue : Val) (result : St F.S),
      runC F 4 target C = some (result,C) ∧
      runC F 4 source C₀ = some
        (defaultIdentifierParameterReached source parameterAddress defaultValue fn remainingParams args env callerFrames,C₀) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (defaultIdentifierParameterReached source parameterAddress defaultValue fn remainingParams args env callerFrames)
        result ∧
      RetainedInventory
        (defaultIdentifierParameterNotes notes fn remainingParams roles env tailNotes
          parameterAddress defaultRole)
        ν₀ ν C₀ C R live
        (defaultIdentifierParameterReached source parameterAddress defaultValue fn remainingParams args env callerFrames)
        result ∧
      defaultRole.Holds ν C R targetDefaultValue ∧
      targetValue = targetDefaultValue ∧
      (defaultIdentifierParameterReached source parameterAddress defaultValue fn remainingParams args env callerFrames).heap.get
        parameterAddress = some (.cell (some defaultValue)) ∧
      result.heap.get (R.a parameterAddress) = some (.cell (some targetValue)) ∧
      result.ffi = target.ffi ∧
      result.next = target.next ∧
      (∀ address, address ≠ R.a parameterAddress →
        result.heap.get address = target.heap.get address) := by
  let sourceAfterSchedule :=
    Parametric.parameterDefault {source with stack := callerFrames} fn
      (.id parameterName) (.id defaultName) remainingParams args env
  let noteAfterSchedule :=
    notes.runtime.parameterDefault fn (.id parameterName) (.id defaultName)
      remainingParams roles env tailNotes
  obtain ⟨targetAfterSchedule,sourceRun1,targetRun1,related1,inventory1⟩ :=
    inventory.runtime.parameter_default_step F FR notes.runtime ν₀ ν C₀ C R live framed
      before after old old' source target related value fn
      (.id parameterName) (.id defaultName) remainingParams args env callerFrames roles tailNotes
      control stack missing stackNotes
  have pure1 : PureRuntimeCase F source target :=
    PureRuntimeCase.parameterDefault related value fn (.id parameterName) (.id defaultName)
      remainingParams args env callerFrames control stack missing
  have effects1 := pure1.effects sourceRun1 targetRun1
  have retained1 : RetainedInventory (notes.withRuntime noteAfterSchedule) ν₀ ν C₀ C R live
      sourceAfterSchedule targetAfterSchedule :=
    inventory.pure_step inventory1 pure1 sourceRun1 targetRun1 (.refl C₀) (.refl C)

  let sourceAfterRead := sourceAfterSchedule.ret defaultValue
  let noteAfterRead := noteAfterSchedule.returning defaultRole
  have readControl : sourceAfterSchedule.ctl = .ev (.id defaultName) env := by
    simp [sourceAfterSchedule, Parametric.parameterDefault, St.push, St.go]
  have readCell : sourceAfterSchedule.heap.get defaultAddress =
      some (.cell (some defaultValue)) := by
    rw [effects1.1.heap]
    exact defaultCell
  obtain ⟨targetDefaultValue,sourceRun2,targetRun2,related2,runtime2⟩ :=
    retained1.runtime.variable_step F FR noteAfterSchedule ν₀ ν C₀ C R live framed before after
      old old' sourceAfterSchedule targetAfterSchedule related1
      defaultName env defaultAddress defaultValue defaultRole readControl defaultLookup readCell defaultEntry
  obtain ⟨targetDefaultValueFromCell,_,targetRun2FromCell,_,_,_,targetDefaultRole⟩ :=
    retained1.runtime.cellInventory.variable_step F FR noteAfterSchedule.cells ν₀ ν C₀ C R
      live framed before after old old' sourceAfterSchedule targetAfterSchedule related1
      defaultName env defaultAddress defaultValue defaultRole
      readControl defaultLookup readCell defaultEntry
  have sameDefaultValue : targetDefaultValue = targetDefaultValueFromCell := by
    have sameState := congrArg Prod.fst (Option.some.inj (targetRun2.symm.trans targetRun2FromCell))
    have sameControl := congrArg St.ctl sameState
    injection sameControl
  have pure2 : PureRuntimeCase F sourceAfterSchedule targetAfterSchedule :=
    PureRuntimeCase.variable related1 defaultName env defaultAddress defaultValue
      readControl defaultLookup readCell
  have effects2 := pure2.effects sourceRun2 targetRun2
  have retained2 : RetainedInventory (notes.withRuntime noteAfterRead) ν₀ ν C₀ C R live
      sourceAfterRead (targetAfterSchedule.ret targetDefaultValue) :=
    retained1.heap_step runtime2 (by rfl) (by rfl) (.refl C₀) (.refl C)
  have related2' : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      sourceAfterRead (targetAfterSchedule.ret targetDefaultValue) := by
    simpa only [sourceAfterRead] using related2
  have readStack : sourceAfterRead.stack =
      .k (.paramDflt fn (.id parameterName) remainingParams args.tail env)::callerFrames := by
    change (sourceAfterSchedule.ret defaultValue).stack = _
    rw [default_identifier_parameter_ret_stack]
    rfl
  have pure3 : PureRuntimeCase F sourceAfterRead (targetAfterSchedule.ret targetDefaultValue) :=
    PureRuntimeCase.parameterDefaultReturn related2' defaultValue fn (.id parameterName)
      remainingParams args.tail env callerFrames rfl readStack
  let sourceAfterReturn :=
    Parametric.parameterDefaultReturn {sourceAfterRead with stack := callerFrames} fn
      (.id parameterName) remainingParams args.tail env defaultValue
  let noteAfterReturn :=
    noteAfterSchedule.parameterDefaultReturn fn (.id parameterName) remainingParams
      roles.tail defaultRole env tailNotes
  obtain ⟨targetAfterReturn,sourceRun3,targetRun3,related3,runtime3⟩ :=
    runtime2.parameter_default_return_step F FR noteAfterRead ν₀ ν C₀ C R live framed before after
      old old' sourceAfterRead (targetAfterSchedule.ret targetDefaultValue) related2'
      defaultValue fn (.id parameterName) remainingParams args.tail env callerFrames
      roles.tail defaultRole tailNotes rfl
      readStack
      rfl rfl
  have effects3 := pure3.effects sourceRun3 targetRun3
  have retained3 : RetainedInventory (notes.withRuntime noteAfterReturn) ν₀ ν C₀ C R live
      sourceAfterReturn targetAfterReturn :=
    retained2.pure_step runtime3 pure3 sourceRun3 targetRun3 (.refl C₀) (.refl C)
  have sourceBound3 : sourceAfterReturn.next ≤ 2^64 := by
    calc
      sourceAfterReturn.next = sourceAfterRead.next := effects3.1.next
      _ = sourceAfterSchedule.next := effects2.1.next
      _ = source.next := effects1.1.next
      _ ≤ 2^64 := sourceBound
  have targetBound3 : targetAfterReturn.next ≤ 2^64 := by
    calc
      targetAfterReturn.next = (targetAfterSchedule.ret targetDefaultValue).next := effects3.2.next
      _ = targetAfterSchedule.next := rfl
      _ = target.next := effects2.2.next.trans effects1.2.next
      _ ≤ 2^64 := targetBound
  have parameterCell3 : sourceAfterReturn.heap.get parameterAddress = some (.cell none) := by
    rw [effects3.1.heap, effects2.1.heap, effects1.1.heap]
    exact parameterCell
  have parameterControl : sourceAfterReturn.ctl = .bind (.id parameterName) defaultValue env .init .let_ := by
    simp [sourceAfterReturn, Parametric.parameterDefaultReturn, St.push, St.go]
  have parameterStack : sourceAfterReturn.stack =
      .k (.params fn remainingParams args.tail env)::callerFrames := by
    simp [sourceAfterReturn, Parametric.parameterDefaultReturn, St.push, St.go]
  obtain ⟨targetRetValue,targetRetControl,_⟩ := (related2'.control_view rfl).ret_view
  obtain ⟨_,targetFrames,targetStack,frameRelation,_⟩ := related2'.stack_view readStack
  obtain ⟨targetArgs,frameEq,_⟩ := frameRelation.paramDflt_view
  rw [frameEq] at targetStack
  have targetReturnSpec : interpC (step F (targetAfterSchedule.ret targetDefaultValue)).run C =
      some (Parametric.parameterDefaultReturn
        {(targetAfterSchedule.ret targetDefaultValue) with stack := targetFrames} fn
        (.id parameterName) remainingParams targetArgs (R.env env) targetRetValue,C) := by
    rw [Parametric.step_parameter_default_return_eq F (targetAfterSchedule.ret targetDefaultValue)
      targetRetValue fn (.id parameterName) remainingParams targetArgs (R.env env) targetFrames
      targetRetControl targetStack]
    rfl
  have targetAfterReturnEq : targetAfterReturn = Parametric.parameterDefaultReturn
      {(targetAfterSchedule.ret targetDefaultValue) with stack := targetFrames} fn
      (.id parameterName) remainingParams targetArgs (R.env env) targetRetValue := by
    have outputs := Option.some.inj (targetRun3.symm.trans targetReturnSpec)
    exact congrArg Prod.fst outputs
  obtain ⟨targetControlValue,targetControl,_⟩ :=
    (related3.control_view parameterControl).bind_view
  have targetReturnControl : targetAfterReturn.ctl =
      .bind (.id parameterName) targetRetValue (R.env env) .init .let_ := by
    rw [targetAfterReturnEq]
    simp [Parametric.parameterDefaultReturn, St.push, St.go]
  have targetControlValueEq : targetControlValue = targetRetValue := by
    rw [targetReturnControl] at targetControl
    injection targetControl with _ valueEq
    exact valueEq.symm
  have targetRetValueEq : targetRetValue = targetDefaultValue := by
    have h : Ctl.ret targetDefaultValue = Ctl.ret targetRetValue := by
      simpa only [St.ret] using targetRetControl
    injection h with valueEq
    exact valueEq.symm
  have targetParameterControl : targetAfterReturn.ctl =
      .bind (.id parameterName) targetDefaultValue (R.env env) .init .let_ := by
    rw [targetControlValueEq, targetRetValueEq] at targetControl
    exact targetControl
  have targetAddressBound : R.a parameterAddress < 2^64 := by
    have currentLive := related3.controlLive
    rw [parameterControl] at currentLive
    have parameterLive := env_lookup_live parameterName env parameterAddress currentLive.2.2.1 parameterLookup
    exact Nat.lt_of_lt_of_le (related3.heap.targetBound parameterAddress parameterLive) targetBound3
  have parameterControlNote : noteAfterReturn.control =
      bindingNote (.id parameterName) defaultRole env .init .let_ := rfl
  obtain ⟨targetValue,sourceRun4,targetRun4,related4,runtime4⟩ :=
    retained3.init_step related3 parameterName env parameterAddress defaultValue none .let_
      defaultRole parameterControl parameterLookup parameterCell3 parameterControlNote
      sourceBound3 targetBound3
  have targetInitSpec := Parametric.step_bind_init_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' sourceAfterReturn targetAfterReturn related3 parameterName defaultValue
    targetDefaultValue env .let_ parameterAddress none parameterControl targetParameterControl
    parameterLookup parameterCell3 sourceBound3 targetBound3
  have targetInitStateEq := congrArg Prod.fst (Option.some.inj (targetRun4.symm.trans targetInitSpec.2.1))
  have targetValueEq : targetValue = targetDefaultValue := by
    have h := congrArg (fun st : St F.S => st.heap.get (R.a parameterAddress)) targetInitStateEq
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetAddressBound,ite_true] at h
    injection h with cellEq
    injection cellEq with innerEq
    exact Option.some.inj innerEq
  have sourceReached :
      (sourceAfterReturn.setCell parameterAddress defaultValue).ret .undef =
        defaultIdentifierParameterReached source parameterAddress defaultValue fn remainingParams
          args env callerFrames := by
    rfl
  let result := (targetAfterReturn.setCell (R.a parameterAddress) targetValue).ret .undef
  have sourceWord : parameterAddress < 2^64 := Nat.lt_of_lt_of_le parameterBound sourceBound
  have sourceCellReached :
      (defaultIdentifierParameterReached source parameterAddress defaultValue fn remainingParams args env callerFrames).heap.get
        parameterAddress = some (.cell (some defaultValue)) := by
    rw [← sourceReached]
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ sourceWord,ite_true]
  have targetCellReached : result.heap.get (R.a parameterAddress) = some (.cell (some targetValue)) := by
    dsimp only [result]
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetAddressBound,ite_true]
  have targetNext : result.next = target.next := by
    calc
      _ = targetAfterReturn.next := rfl
      _ = (targetAfterSchedule.ret targetDefaultValue).next := effects3.2.next
      _ = targetAfterSchedule.next := rfl
      _ = target.next := effects2.2.next.trans effects1.2.next
  have targetFfi : result.ffi = target.ffi := by
    calc
      _ = targetAfterReturn.ffi := rfl
      _ = (targetAfterSchedule.ret targetDefaultValue).ffi := effects3.2.native
      _ = targetAfterSchedule.ffi := rfl
      _ = target.ffi := effects2.2.native.trans effects1.2.native
  have retainedFinal : RetainedInventory
      (defaultIdentifierParameterNotes notes fn remainingParams roles env tailNotes
        parameterAddress defaultRole)
      ν₀ ν C₀ C R live
      (defaultIdentifierParameterReached source parameterAddress defaultValue fn remainingParams args env callerFrames)
      result := by
    simpa [defaultIdentifierParameterNotes, RetainedNotes.withRuntime, noteAfterSchedule, noteAfterReturn,
      RuntimeNotes.initialized, RuntimeNotes.parameterDefault, RuntimeNotes.parameterDefaultReturn, parameterFrameNote,
      Notes.write, sourceReached, result] using runtime4
  have sourceStep4 : runC F 1 sourceAfterReturn C₀ =
      some ((sourceAfterReturn.setCell parameterAddress defaultValue).ret .undef,C₀) := by
    have active : isHalt sourceAfterReturn.ctl = false := by simp [parameterControl, isHalt]
    exact default_identifier_parameter_one F sourceAfterReturn
      ((sourceAfterReturn.setCell parameterAddress defaultValue).ret .undef) C₀ active sourceRun4
  have targetStep4 : runC F 1 targetAfterReturn C =
      some ((targetAfterReturn.setCell (R.a parameterAddress) targetValue).ret .undef,C) := by
    have sourceActive : isHalt sourceAfterReturn.ctl = false := by simp [parameterControl,isHalt]
    have active : isHalt targetAfterReturn.ctl = false := related3.control.isHalt_eq.trans sourceActive
    exact default_identifier_parameter_one F targetAfterReturn
      ((targetAfterReturn.setCell (R.a parameterAddress) targetValue).ret .undef) C active targetRun4
  have sourceStep1 : runC F 1 source C₀ = some (sourceAfterSchedule,C₀) := by
    have active : isHalt source.ctl = false := by simp [control,isHalt]
    simpa [sourceAfterSchedule] using default_identifier_parameter_one F source sourceAfterSchedule
      C₀ active sourceRun1
  have targetStep1 : runC F 1 target C = some (targetAfterSchedule,C) := by
    have sourceActive : isHalt source.ctl = false := by simp [control,isHalt]
    have active : isHalt target.ctl = false := related.control.isHalt_eq.trans sourceActive
    exact default_identifier_parameter_one F target targetAfterSchedule C active targetRun1
  have sourceReadControl : sourceAfterSchedule.ctl = .ev (.id defaultName) env := readControl
  have sourceStep2 : runC F 1 sourceAfterSchedule C₀ = some (sourceAfterRead,C₀) := by
    have active : isHalt sourceAfterSchedule.ctl = false := by simp [sourceReadControl,isHalt]
    simpa [sourceAfterRead] using default_identifier_parameter_one F sourceAfterSchedule sourceAfterRead
      C₀ active sourceRun2
  have targetStep2 : runC F 1 targetAfterSchedule C =
      some (targetAfterSchedule.ret targetDefaultValue,C) := by
    have sourceActive : isHalt sourceAfterSchedule.ctl = false := by simp [readControl,isHalt]
    have active : isHalt targetAfterSchedule.ctl = false := related1.control.isHalt_eq.trans sourceActive
    exact default_identifier_parameter_one F targetAfterSchedule (targetAfterSchedule.ret targetDefaultValue)
      C active targetRun2
  have sourceStep3 : runC F 1 sourceAfterRead C₀ = some (sourceAfterReturn,C₀) := by
    have active : isHalt sourceAfterRead.ctl = false := by simp [sourceAfterRead,St.ret,isHalt]
    simpa [sourceAfterReturn] using default_identifier_parameter_one F sourceAfterRead sourceAfterReturn
      C₀ active sourceRun3
  have targetStep3 : runC F 1 (targetAfterSchedule.ret targetDefaultValue) C =
      some (targetAfterReturn,C) := by
    have sourceActive : isHalt sourceAfterRead.ctl = false := by simp [sourceAfterRead,St.ret,isHalt]
    have active : isHalt (targetAfterSchedule.ret targetDefaultValue).ctl = false :=
      related2'.control.isHalt_eq.trans sourceActive
    exact default_identifier_parameter_one F (targetAfterSchedule.ret targetDefaultValue)
      targetAfterReturn C active targetRun3
  have source12 := runC_join F sourceStep1 sourceStep2
  have source34 := runC_join F sourceStep3 sourceStep4
  have target12 := runC_join F targetStep1 targetStep2
  have target34 := runC_join F targetStep3 targetStep4
  have sourceFour := runC_join F source12 source34
  have targetFour := runC_join F target12 target34
  refine ⟨targetDefaultValue, targetValue, result, ?_, ?_, related4, retainedFinal,
    (by rw [sameDefaultValue]; exact targetDefaultRole), targetValueEq, sourceCellReached,
    targetCellReached, targetFfi, targetNext, ?_⟩
  · simpa [result] using targetFour
  · simpa [sourceReached] using sourceFour
  · intro address different
    have distinct : address ≠ R.a parameterAddress := different
    dsimp only [result]
    simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ targetAddressBound,ite_eq_right distinct]
    rw [effects3.2.heap, effects2.2.heap, effects1.2.heap]
end

end Host.Ts.Owned.Annotated
