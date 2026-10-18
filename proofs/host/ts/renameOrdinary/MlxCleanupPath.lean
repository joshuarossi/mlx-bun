import host.ts.renameOrdinary.MlxCleanupSteps
import host.ts.RenameArgumentEffects
import host.ts.RenameRoutePrivateFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem cleanup_finally_names : blockNames CleanupFinally412.sourceBody = [] := by host_kernel_rfl

/-- The actual returning concat enters its original finalizer and reaches
vector-free. Every heap slot and the exact read-to-argument relation survive. -/
theorem enter_vector_cleanup (NR : NumV → NumV → Prop)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' CleanupReturn409.input s)
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' CleanupArguments420.output result ∧
      result.heap = s.heap ∧
      callArgument result.ctl 0 = cellValueAt s (R.a CleanupVector419.address) := by
  obtain ⟨s410,r409,h410⟩ := CleanupReturn409.transport NR FR R C₀ C live framed before after old old' s h
  have heap410 := step_return_exit_heap P.F NR FR R live framed before after old old' _ _ _ C C h CleanupReturn409.sourceValue CleanupReturn409.sourceAction CleanupReturn409.sourceEnv CleanupReturn409.sourceTail CleanupReturn409.source_control CleanupReturn409.source_frame r409
  obtain ⟨s411,r410,h411⟩ := CleanupBlock410.transport NR FR R C₀ C live framed before after old old' s410 h410
  have heap411 := step_return_unwind_heap P.F NR FR R live framed before after old old' _ _ _ C C h410 CleanupBlock410.sourceValue CleanupBlock410.sourceAction CleanupBlock410.sourceEnv CleanupBlock410.sourceTail CleanupBlock410.source_control CleanupBlock410.source_frame r410
  obtain ⟨s412,r411,h412⟩ := CleanupScope411.transport NR FR R C₀ C live framed before after old old' s411 h411
  have heap412 := step_return_unwind_heap P.F NR FR R live framed before after old old' _ _ _ C C h411 CleanupScope411.sourceValue CleanupScope411.sourceAction CleanupScope411.sourceEnv CleanupScope411.sourceTail CleanupScope411.source_control CleanupScope411.source_frame r411
  have next412 : s412.next = s.next := h.target_next_eq h412 (by host_kernel_rfl)
  have bound412 : s412.next+(blockNames CleanupFinally412.sourceBody).length ≤ 2^64 := by rw [cleanup_finally_names]; simp only [List.length_nil,Nat.add_zero]; rw [next412]; exact bound
  obtain ⟨s413,r412,h413raw⟩ := CleanupFinally412.transport NR FR R C₀ C live framed before after old old' s412 h412 bound412
  have h413 : StateR NR FR R live framed before after old old' CleanupFinally412.output s413 := by
    simp only [cleanup_finally_names,CellsLive] at h413raw
    exact h413raw
  have heap413 := step_return_finally_heap P.F NR FR R C₀ C C live framed before after old old' _ _ _ h412 CleanupFinally412.sourceValue CleanupFinally412.sourceHandler CleanupFinally412.sourceBody CleanupFinally412.sourceEnv CleanupFinally412.sourceTail CleanupFinally412.source_control CleanupFinally412.source_frame CleanupFinally412.source_hoist cleanup_finally_names r412
  obtain ⟨s414,r413,h414⟩ := CleanupStatement413.transport NR FR R C₀ C live framed before after old old' s413 h413
  have heap414 := step_block_next_heap P.F NR FR R live framed before after old old' _ _ _ C C h413 CleanupStatement413.sourceValue CleanupStatement413.sourceStatement CleanupStatement413.sourceRest CleanupStatement413.sourceEnv CleanupStatement413.sourceTail CleanupStatement413.source_control CleanupStatement413.source_frame r413
  obtain ⟨s415,r414,h415⟩ := CleanupExpression414.transport NR FR R C₀ C live framed before after old old' s414 h414
  have heap415 := step_statement_heap P.F NR FR R live framed before after old old' _ _ _ C C h414 CleanupExpression414.sourceAction CleanupExpression414.sourceEnv CleanupExpression414.source_control r414
  obtain ⟨s416,r415,h416⟩ := CleanupMethod415.transport NR FR R C₀ C live framed before after old old' s415 h415
  have heap416 := step_method_descent_heap P.F NR FR R live framed before after old old' _ _ _ C₀ C C h415 CleanupMethod415.sourceExpression CleanupMethod415.sourceName CleanupMethod415.sourceArgs CleanupMethod415.sourceEnv CleanupMethod415.sourceOptObject CleanupMethod415.sourceOptCall CleanupMethod415.source_control r415
  obtain ⟨v416,r416,h417,_⟩ := CleanupNamespace416.transport NR FR R C₀ C live framed before after old old' s416 h416
  let s417 := s416.ret v416
  have heap417 : s417.heap = s416.heap := rfl
  obtain ⟨s418,r417,h418⟩ := CleanupMethod417.transport NR FR R C₀ C live framed before after old old' s417 h417
  have heap418 := step_method_data_heap P.F NR FR R live framed before after old old' _ _ _ C C h417 CleanupMethod417.sourceAddress CleanupMethod417.sourceObject CleanupMethod417.sourceName CleanupMethod417.sourceArgs CleanupMethod417.sourceEnv CleanupMethod417.sourceOptObject CleanupMethod417.sourceOptCall CleanupMethod417.sourceMethod CleanupMethod417.sourceWritable CleanupMethod417.sourceEnumerable CleanupMethod417.sourceTail CleanupMethod417.source_control CleanupMethod417.source_frame CleanupMethod417.source_heap CleanupMethod417.source_kind CleanupMethod417.source_property r417
  obtain ⟨s419,r418,h419⟩ := CleanupArguments418.transport NR FR R C₀ C live framed before after old old' s418 h418
  have heap419 := step_callStart_heap P.F NR FR R live framed before after old old' _ _ _ C C h418 CleanupArguments418.sourceMode CleanupArguments418.sourceAddress CleanupArguments418.sourceThis CleanupArguments418.sourceArgs CleanupArguments418.sourceEnv CleanupArguments418.sourceTail CleanupArguments418.source_control CleanupArguments418.source_frame r418
  obtain ⟨v419,r419,h420,_⟩ := CleanupVector419.transport NR FR R C₀ C live framed before after old old' s419 h419
  let s420 := s419.ret v419
  have heap420 : s420.heap = s419.heap := rfl
  obtain ⟨s421,r420,h421⟩ := CleanupArguments420.transport NR FR R C₀ C live framed before after old old' s420 h420
  have heap421 := step_argument_heap_from_source P.F NR FR R live framed before after old old' _ _ _ C C h420 CleanupArguments420.sourceValue CleanupArguments420.sourceKind CleanupArguments420.sourceFunction CleanupArguments420.sourceThis CleanupArguments420.sourceAcc CleanupArguments420.sourceRest CleanupArguments420.sourceEnv CleanupArguments420.sourceTail CleanupArguments420.source_control CleanupArguments420.source_frame (by decide) r420
  have heapAll : s421.heap = s.heap := heap421.trans (heap420.trans (heap419.trans (heap418.trans (heap417.trans (heap416.trans (heap415.trans (heap414.trans (heap413.trans (heap412.trans (heap411.trans (heap410)))))))))))
  have cellLive : live CleanupVector419.address := by
    have hl := h419.controlLive
    change treeSupport live (Encode.ctl CleanupVector419.input.ctl) at hl
    rw [CleanupVector419.source_control] at hl
    exact env_lookup_live _ _ _ hl.2.1 CleanupVector419.source_lookup
  obtain ⟨value,cell,_,_⟩ := h419.heap.readCell _ _ cellLive CleanupVector419.source_cell
  have ctl420 := (step_variable_cell_fields P.F NR FR R live framed before after old old' _ _ _ C C h419
    CleanupVector419.sourceName CleanupVector419.sourceEnv CleanupVector419.address value
    CleanupVector419.source_control CleanupVector419.source_lookup cell r419).1
  have sourceFrame420 : CleanupArguments420.input.stack = .c (.args 0 CleanupArguments420.sourceFunction
      CleanupArguments420.sourceThis [] [] CleanupArguments420.sourceEnv)::CleanupArguments420.sourceTail := by host_kernel_rfl
  have argument := step_single_argument_fields P.F NR FR R C C live framed before after old old' _ _ _ h420
    CleanupArguments420.sourceFunction CleanupArguments420.sourceThis value CleanupArguments420.sourceEnv
    CleanupArguments420.sourceTail sourceFrame420 ctl420 r420
  have heap419 : s419.heap = s.heap := heap419.trans (heap418.trans (heap417.trans (heap416.trans (heap415.trans (heap414.trans (heap413.trans (heap412.trans (heap411.trans (heap410)))))))))
  have entryCell : s.heap.get (R.a CleanupVector419.address) = some (.cell (some value)) := by rw [← heap419]; exact cell
  refine ⟨s421,?_,h421,heapAll,?_⟩
  · apply runC_cons P.F 11 s s410 s421 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r409
    apply runC_cons P.F 10 s410 s411 s421 C C C (h410.control.isHalt_eq.trans (by host_kernel_rfl)) r410
    apply runC_cons P.F 9 s411 s412 s421 C C C (h411.control.isHalt_eq.trans (by host_kernel_rfl)) r411
    apply runC_cons P.F 8 s412 s413 s421 C C C (h412.control.isHalt_eq.trans (by host_kernel_rfl)) r412
    apply runC_cons P.F 7 s413 s414 s421 C C C (h413.control.isHalt_eq.trans (by host_kernel_rfl)) r413
    apply runC_cons P.F 6 s414 s415 s421 C C C (h414.control.isHalt_eq.trans (by host_kernel_rfl)) r414
    apply runC_cons P.F 5 s415 s416 s421 C C C (h415.control.isHalt_eq.trans (by host_kernel_rfl)) r415
    apply runC_cons P.F 4 s416 s417 s421 C C C (h416.control.isHalt_eq.trans (by host_kernel_rfl)) r416
    apply runC_cons P.F 3 s417 s418 s421 C C C (h417.control.isHalt_eq.trans (by host_kernel_rfl)) r417
    apply runC_cons P.F 2 s418 s419 s421 C C C (h418.control.isHalt_eq.trans (by host_kernel_rfl)) r418
    apply runC_cons P.F 1 s419 s420 s421 C C C (h419.control.isHalt_eq.trans (by host_kernel_rfl)) r419
    apply runC_cons P.F 0 s420 s421 s421 C C C (h420.control.isHalt_eq.trans (by host_kernel_rfl)) r420
    rfl
  · simpa only [cellValueAt,entryCell] using argument
end Host.Load.Run.Full.Ordinary.VectorToConcat
