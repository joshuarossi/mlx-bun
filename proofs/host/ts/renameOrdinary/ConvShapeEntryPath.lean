import host.ts.renameOrdinary.ConvShapeEntrySteps
import host.ts.RenameReadStack
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The real third-argument expression begins its length subtraction and
weight.shape index. The getter call retains the complete saved caller stack,
including the fixed S argument, and changes no heap field. -/
theorem conv_shape_getter_entry (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' ConvLengthExpression440.input s) :
    ∃ result, runC P.F 5 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ConvWeightGetter444.output result ∧
      result.heap = s.heap ∧
      result.stack = ConvWeightIndex441.descent.frame (R.env ConvWeightIndex441.sourceEnv)::
        ConvLengthExpression440.descent.frame (R.env ConvLengthExpression440.sourceEnv)::s.stack := by
  obtain ⟨s441,r440,h441⟩ := ConvLengthExpression440.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s442,r441,h442⟩ := ConvWeightIndex441.transport NR FR R C₀ C live framed before after old old' s441 h441
  obtain ⟨s443,r442,h443⟩ := ConvWeightShape442.transport NR FR R C₀ C live framed before after old old' s442 h442
  obtain ⟨v443,r443,h444,_⟩ := ConvWeightVariable443.transport NR FR R C₀ C live framed before after old old' s443 h443
  let s444 := s443.ret v443
  obtain ⟨result,r444,h445⟩ := ConvWeightGetter444.transport NR FR R C₀ C live framed before after old old' s444 h444
  have heap441 := step_descent_heap_from_source P.F NR FR R live framed before after old old' ConvLengthExpression440.input s s441 C C h
    ConvLengthExpression440.descent ConvLengthExpression440.sourceEnv ConvLengthExpression440.source_control r440
  have heap442 := step_descent_heap_from_source P.F NR FR R live framed before after old old' ConvWeightIndex441.input s441 s442 C C h441
    ConvWeightIndex441.descent ConvWeightIndex441.sourceEnv ConvWeightIndex441.source_control r441
  have heap443 := step_descent_heap_from_source P.F NR FR R live framed before after old old' ConvWeightShape442.input s442 s443 C C h442
    ConvWeightShape442.descent ConvWeightShape442.sourceEnv ConvWeightShape442.source_control r442
  have heap445 := ConvWeightGetter444.heap_frame NR FR R C₀ C C live framed before after old old' s444 result h444 r444
  have stack441 := step_descent_stack P.F NR FR R live framed before after old old' ConvLengthExpression440.input s s441 C C h
    ConvLengthExpression440.descent ConvLengthExpression440.sourceEnv ConvLengthExpression440.source_control r440
  have stack442 := step_descent_stack P.F NR FR R live framed before after old old' ConvWeightIndex441.input s441 s442 C C h441
    ConvWeightIndex441.descent ConvWeightIndex441.sourceEnv ConvWeightIndex441.source_control r441
  have stack443 := step_descent_stack P.F NR FR R live framed before after old old' ConvWeightShape442.input s442 s443 C C h442
    ConvWeightShape442.descent ConvWeightShape442.sourceEnv ConvWeightShape442.source_control r442
  have stack445 := step_member_lookup_stack P.F NR FR R live framed before after old old' ConvWeightGetter444.input s444 result C₀ C C h444
    ConvWeightGetter444.sourceAddress ConvWeightGetter444.sourceName (some ConvWeightGetter444.sourceProperty)
    ConvWeightGetter444.sourceTail ConvWeightGetter444.source_control ConvWeightGetter444.source_frame ConvWeightGetter444.source_path r444
  have heap : result.heap = s.heap := heap445.trans (heap443.trans (heap442.trans heap441))
  have stack : result.stack = ConvWeightIndex441.descent.frame (R.env ConvWeightIndex441.sourceEnv)::
        ConvLengthExpression440.descent.frame (R.env ConvLengthExpression440.sourceEnv)::s.stack := by
    change result.stack = _
    rw [stack445]
    change s443.stack.tail = _
    rw [stack443]
    change s442.stack = _
    rw [stack442,stack441]
  refine ⟨result,?_,h445,heap,stack⟩
  apply runC_cons P.F 4 s s441 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r440
  apply runC_cons P.F 3 s441 s442 result C C C (h441.control.isHalt_eq.trans (by host_kernel_rfl)) r441
  apply runC_cons P.F 2 s442 s443 result C C C (h442.control.isHalt_eq.trans (by host_kernel_rfl)) r442
  apply runC_cons P.F 1 s443 s444 result C C C (h443.control.isHalt_eq.trans (by host_kernel_rfl)) r443
  apply runC_cons P.F 0 s444 result result C C C (h444.control.isHalt_eq.trans (by host_kernel_rfl)) r444
  rfl
end Host.Load.Run.Full.Ordinary.VectorToConcat
