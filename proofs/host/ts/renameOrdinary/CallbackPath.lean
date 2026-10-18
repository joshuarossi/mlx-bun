import host.ts.renameOrdinary.DriverCallback
import host.ts.RenameRouteHeapFields
import host.ts.RenameRouteReadFields
import host.ts.RenameCallbackEffects

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem concat_callback_fields (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s49 s)
    (receiverNotFramed : ¬ framed Callback56.sourceAddress)
    (prototypeLive : live aFunctionProto) (prototypeFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (targetBound : s.next < 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR NR FR R (LiveAfter live P.RestStream.micro0.micro0.s58.next)
        framed before after old old' P.RestStream.micro0.micro0.s60 result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨s50,hr49,h50⟩ := Callback49.transport NR FR R C₀ C live framed before after old old' s h
  have heap50 := step_block_next_heap P.F NR FR R live framed before after old old' Callback49.input s s50 C C h Callback49.sourceValue Callback49.sourceStatement Callback49.sourceRest Callback49.sourceEnv Callback49.sourceTail Callback49.source_control Callback49.source_frame hr49
  obtain ⟨s51,hr50,h51⟩ := Callback50.transport NR FR R C₀ C live framed before after old old' s50 h50
  have heap51 := step_statement_heap P.F NR FR R live framed before after old old' Callback50.input s50 s51 C C h50 Callback50.sourceAction Callback50.sourceEnv Callback50.source_control hr50
  obtain ⟨s52,hr51,h52⟩ := Callback51.transport NR FR R C₀ C live framed before after old old' s51 h51
  have heap52 := step_descent_heap_from_source P.F NR FR R live framed before after old old' Callback51.input s51 s52 C C h51 Callback51.sourceDescent Callback51.sourceEnv Callback51.source_control hr51
  obtain ⟨v52,hr52,h53,_⟩ := Callback52.transport NR FR R C₀ C live framed before after old old' s52 h52 globalLive globalFixed
  let s53 := s52.ret v52
  have heap53 : s53.heap = s52.heap := rfl
  obtain ⟨s54,hr53,h54⟩ := Callback53.transport NR FR R C₀ C live framed before after old old' s53 h53
  have heap54 := step_callStart_heap P.F NR FR R live framed before after old old' Callback53.input s53 s54 C C h53 Callback53.sourceMode Callback53.sourceAddress Callback53.sourceThis Callback53.sourceArgs Callback53.sourceEnv Callback53.sourceTail Callback53.source_control Callback53.source_frame hr53
  obtain ⟨s55,hr54,h55⟩ := Callback54.transport NR FR R C₀ C live framed before after old old' s54 h54
  have heap55 := step_method_descent_heap P.F NR FR R live framed before after old old' Callback54.input s54 s55 C₀ C C h54 Callback54.sourceExpression Callback54.sourceName Callback54.sourceArgs Callback54.sourceEnv Callback54.sourceOptObject Callback54.sourceOptCall Callback54.source_control hr54
  obtain ⟨v55,hr55,h56,_⟩ := Callback55.transport NR FR R C₀ C live framed before after old old' s55 h55
  let s56 := s55.ret v55
  have heap56 : s56.heap = s55.heap := rfl
  obtain ⟨s57,hr56,h57⟩ := Callback56.transport NR FR R C₀ C live framed before after old old' s56 h56 receiverNotFramed
  obtain ⟨other56,_,replay56,_,heapOther56⟩ := step_array_method_from_source_fields P.F NR FR R C₀ C live framed
    before after old old' Callback56.input s56 h56 Callback56.sourceAddress Callback56.sourcePrototype
    Callback56.sourceObject Callback56.sourceParent Callback56.sourceElements Callback56.sourceName Callback56.sourceArgs
    Callback56.sourceEnv Callback56.sourceOptObject Callback56.sourceOptCall Callback56.sourceMethod Callback56.sourceWritable
    Callback56.sourceEnumerable Callback56.sourceTail Callback56.source_control Callback56.source_frame Callback56.source_heap
    Callback56.source_kind Callback56.source_nonindex Callback56.source_nonlength Callback56.source_absent Callback56.source_prototype
    Callback56.source_parent Callback56.source_parentKind Callback56.source_property receiverNotFramed
  have heap57 : s57.heap = s56.heap :=
    (congrArg St.heap (congrArg Prod.fst (Option.some.inj (hr56.symm.trans replay56)))).trans heapOther56
  obtain ⟨s58,hr57,h58⟩ := Callback57.transport NR FR R C₀ C live framed before after old old' s57 h57
  have heap58 := step_callStart_heap P.F NR FR R live framed before after old old' Callback57.input s57 s58 C C h57 Callback57.sourceMode Callback57.sourceAddress Callback57.sourceThis Callback57.sourceArgs Callback57.sourceEnv Callback57.sourceTail Callback57.source_control Callback57.source_frame hr57
  have hb58 : s58.next < 2^64 := by rw [h.target_next_eq h58 callback_next58]; exact targetBound
  obtain ⟨s59,hr58,h59⟩ := Callback58.transport NR FR R C₀ C live framed before after old old' s58 h58
    prototypeLive prototypeFixed hb58
  have heap59 := step_callback_heap_below P.F NR FR R live framed before after old old' Callback58.input s58 s59 C C h58
    Callback58.sourceFunction Callback58.sourceEnv Callback58.source_control hb58 hr58
  obtain ⟨result,hr59,h60⟩ := Callback59.transport NR FR R C₀ C (LiveAfter live P.RestStream.micro0.micro0.s58.next)
    framed before after old old' s59 h59
  have heap60 := step_argument_heap_from_source P.F NR FR R (LiveAfter live P.RestStream.micro0.micro0.s58.next)
    framed before after old old' Callback59.input s59 result C C h59 Callback59.sourceValue Callback59.sourceKind
    Callback59.sourceFunction Callback59.sourceThis Callback59.sourceAcc Callback59.sourceRest Callback59.sourceEnv Callback59.sourceTail
    Callback59.source_control Callback59.source_frame (by decide +kernel) hr59
  refine ⟨result,?_,h60,?_⟩
  · apply runC_cons P.F 10 s s50 result C C C (h.control.isHalt_eq.trans callback_active49) hr49
    apply runC_cons P.F 9 s50 s51 result C C C (h50.control.isHalt_eq.trans callback_active50) hr50
    apply runC_cons P.F 8 s51 s52 result C C C (h51.control.isHalt_eq.trans callback_active51) hr51
    apply runC_cons P.F 7 s52 s53 result C C C (h52.control.isHalt_eq.trans callback_active52) hr52
    apply runC_cons P.F 6 s53 s54 result C C C (h53.control.isHalt_eq.trans callback_active53) hr53
    apply runC_cons P.F 5 s54 s55 result C C C (h54.control.isHalt_eq.trans callback_active54) hr54
    apply runC_cons P.F 4 s55 s56 result C C C (h55.control.isHalt_eq.trans callback_active55) hr55
    apply runC_cons P.F 3 s56 s57 result C C C (h56.control.isHalt_eq.trans callback_active56) hr56
    apply runC_cons P.F 2 s57 s58 result C C C (h57.control.isHalt_eq.trans callback_active57) hr57
    apply runC_cons P.F 1 s58 s59 result C C C (h58.control.isHalt_eq.trans callback_active58) hr58
    apply runC_cons P.F 0 s59 result result C C C (h59.control.isHalt_eq.trans callback_active59) hr59
    rfl
  · intro a ha
    rw [heap60,heap59 a (by rw [h.target_next_eq h58 callback_next58]; exact ha),heap58,heap57,heap56,heap55,
      heap54,heap53,heap52,heap51,heap50]


end Host.Load.Run.Full.Ordinary
