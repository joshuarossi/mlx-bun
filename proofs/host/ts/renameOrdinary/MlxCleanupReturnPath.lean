import host.ts.renameOrdinary.MlxCleanupReturnSteps
import host.ts.RenameRoutePrivateFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem concat_return_control : ConcatReturn427.output.ctl = .ret (.obj 3126703) := by host_kernel_rfl

/-- Real finalizer completion resumes the saved MlxArray and returns it to
the original caller, preserving every heap slot across all six transitions. -/
theorem finish_vector_cleanup (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' FinalizerBlock422.input s) :
    ∃ result, runC P.F 6 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ConcatReturn427.output result ∧
      result.ctl = .ret (.obj (R.a 3126703)) ∧ result.heap = s.heap := by
  obtain ⟨s423,r422,h423⟩ := FinalizerBlock422.transport NR FR R C₀ C live framed before after old old' s h
  have heap423 := step_return_exit_heap P.F NR FR R live framed before after old old' _ _ _ C C h
    FinalizerBlock422.sourceValue FinalizerBlock422.sourceAction FinalizerBlock422.sourceEnv FinalizerBlock422.sourceTail
    FinalizerBlock422.source_control FinalizerBlock422.source_frame r422
  obtain ⟨s424,r423,h424⟩ := FinalizerScope423.transport NR FR R C₀ C live framed before after old old' s423 h423
  have heap424 := step_return_exit_heap P.F NR FR R live framed before after old old' _ _ _ C C h423
    FinalizerScope423.sourceValue FinalizerScope423.sourceAction FinalizerScope423.sourceEnv FinalizerScope423.sourceTail
    FinalizerScope423.source_control FinalizerScope423.source_frame r423
  obtain ⟨s425,r424,h425,heap425⟩ := FinalizerResume424.transport NR FR R C₀ C live framed before after old old' s424 h424
  obtain ⟨s426,r425,h426⟩ := ConcatBlock425.transport NR FR R C₀ C live framed before after old old' s425 h425
  have heap426 := step_return_unwind_heap P.F NR FR R live framed before after old old' _ _ _ C C h425
    ConcatBlock425.sourceValue ConcatBlock425.sourceAction ConcatBlock425.sourceEnv ConcatBlock425.sourceTail
    ConcatBlock425.source_control ConcatBlock425.source_frame r425
  obtain ⟨s427,r426,h427⟩ := ConcatScope426.transport NR FR R C₀ C live framed before after old old' s426 h426
  have heap427 := step_return_unwind_heap P.F NR FR R live framed before after old old' _ _ _ C C h426
    ConcatScope426.sourceValue ConcatScope426.sourceAction ConcatScope426.sourceEnv ConcatScope426.sourceTail
    ConcatScope426.source_control ConcatScope426.source_frame r426
  obtain ⟨result,r427,h428⟩ := ConcatReturn427.transport NR FR R C₀ C live framed before after old old' s427 h427
  have heap428 := step_return_unwind_heap P.F NR FR R live framed before after old old' _ _ _ C C h427
    ConcatReturn427.sourceValue ConcatReturn427.sourceAction ConcatReturn427.sourceEnv ConcatReturn427.sourceTail
    ConcatReturn427.source_control ConcatReturn427.source_frame r427
  obtain ⟨value,ctl,hv⟩ := (h428.control_view concat_return_control).ret_view
  cases hv
  refine ⟨result,?_,h428,ctl,heap428.trans (heap427.trans (heap426.trans (heap425.trans (heap424.trans heap423))))⟩
  apply runC_cons P.F 5 s s423 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r422
  apply runC_cons P.F 4 s423 s424 result C C C (h423.control.isHalt_eq.trans (by host_kernel_rfl)) r423
  apply runC_cons P.F 3 s424 s425 result C C C (h424.control.isHalt_eq.trans (by host_kernel_rfl)) r424
  apply runC_cons P.F 2 s425 s426 result C C C (h425.control.isHalt_eq.trans (by host_kernel_rfl)) r425
  apply runC_cons P.F 1 s426 s427 result C C C (h426.control.isHalt_eq.trans (by host_kernel_rfl)) r426
  apply runC_cons P.F 0 s427 result result C C C (h427.control.isHalt_eq.trans (by host_kernel_rfl)) r427
  rfl
end Host.Load.Run.Full.Ordinary.VectorToConcat
