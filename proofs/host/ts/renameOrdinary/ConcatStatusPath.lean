import host.ts.renameOrdinary.ConcatStatusPrefix
import host.ts.RenameRouteCellFields
import host.ts.RenameRouteHeapFields
import host.ts.RenameRouteComposition
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The real callback return and lexical initialization retain the exact
native status in its actual caller cell. Every other live heap occurrence
survives these five original machine steps. -/
theorem concat_status_storage (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' ConcatReturn337.input s)
    (status : s.ctl = .ret (.num zeroN)) (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 5 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' StatusDone341.output result ∧
      result.heap.get (R.a StatusBinding340.sourceAddress) = some (.cell (some (.num zeroN))) ∧
      (∀ a, live a → a ≠ StatusBinding340.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  obtain ⟨s338,hr337,h338⟩ := ConcatReturn337.transport NR FR R C₀ C live framed before after old old' s h
  have hc338 : s338.ctl = .abr (.ret (.num zeroN)) :=
    step_return_exit_control P.F NR FR R live framed before after old old' ConcatReturn337.input s s338 C C h
      (.num zeroN) ConcatReturn337.sourceAction ConcatReturn337.sourceEnv ConcatReturn337.sourceTail
      ConcatReturn337.source_frame status hr337
  have hh338 := step_return_exit_heap P.F NR FR R live framed before after old old' ConcatReturn337.input s s338 C C h
    ConcatReturn337.sourceValue ConcatReturn337.sourceAction ConcatReturn337.sourceEnv ConcatReturn337.sourceTail
    ConcatReturn337.source_control ConcatReturn337.source_frame hr337
  obtain ⟨s339,hr338,h339⟩ := ConcatUnwind338.transport NR FR R C₀ C live framed before after old old' s338 h338
  have hc339 : s339.ctl = .ret (.num zeroN) :=
    step_return_unwind_control P.F NR FR R live framed before after old old' ConcatUnwind338.input s338 s339 C C h338
      (.num zeroN) ConcatUnwind338.sourceAction ConcatUnwind338.sourceEnv ConcatUnwind338.sourceTail
      ConcatUnwind338.source_frame hc338 hr338
  have hh339 := step_return_unwind_heap P.F NR FR R live framed before after old old' ConcatUnwind338.input s338 s339 C C h338
    ConcatUnwind338.sourceValue ConcatUnwind338.sourceAction ConcatUnwind338.sourceEnv ConcatUnwind338.sourceTail
    ConcatUnwind338.source_control ConcatUnwind338.source_frame hr338
  obtain ⟨s340,hr339,h340⟩ := StatusDeclaration339.transport NR FR R C₀ C live framed before after old old' s339 h339
  have hc340 : s340.ctl = .bind (.id StatusBinding340.sourceName) (.num zeroN)
      (R.env StatusBinding340.sourceEnv) .init StatusBinding340.sourceKind := by
    exact step_declaration_control P.F NR FR R live framed before after old old' StatusDeclaration339.input s339 s340 C C h339
      (.num zeroN) StatusDeclaration339.sourceKind StatusDeclaration339.sourcePattern StatusDeclaration339.sourceRest
      StatusDeclaration339.sourceEnv StatusDeclaration339.sourceTail StatusDeclaration339.source_frame hc339 (by decide) hr339
  have hh340 := step_declaration_value_heap P.F NR FR R live framed before after old old' StatusDeclaration339.input s339 s340 C C h339
    StatusDeclaration339.sourceValue StatusDeclaration339.sourceKind StatusDeclaration339.sourcePattern StatusDeclaration339.sourceRest
    StatusDeclaration339.sourceEnv StatusDeclaration339.sourceTail StatusDeclaration339.source_control StatusDeclaration339.source_frame (by decide) hr339
  have bound340 : s340.next ≤ 2^64 := (h.target_next_eq h340 (by host_kernel_rfl)).symm ▸ bound
  obtain ⟨s341,hr340,h341⟩ := StatusBinding340.transport NR FR R C₀ C live framed before after old old' s340 h340 bound340
  have stored := step_bind_init_cell_fields P.F NR FR R live framed before after old old' StatusBinding340.input s340 s341 C C h340
    StatusBinding340.sourceName StatusBinding340.sourceValue (.num zeroN) StatusBinding340.sourceEnv StatusBinding340.sourceKind
    StatusBinding340.sourceAddress StatusBinding340.source_control hc340 StatusBinding340.source_lookup bound340 hr340
  obtain ⟨result,hr341,h342⟩ := StatusDone341.transport NR FR R C₀ C live framed before after old old' s341 h341
  have hh342 := step_declaration_next_heap P.F NR FR R live framed before after old old' StatusDone341.input s341 result C C h341
    StatusDone341.sourceValue StatusDone341.sourceKind StatusDone341.sourceRest StatusDone341.sourceEnv StatusDone341.sourceTail
    StatusDone341.source_control StatusDone341.source_frame hr341
  have frame (a : Nat) (ha : live a) (other : a ≠ StatusBinding340.sourceAddress) :
      result.heap.get (R.a a) = s.heap.get (R.a a) := by
    have cellLive : live StatusBinding340.sourceAddress := by
      have hl := h340.controlLive
      change treeSupport live (Encode.ctl StatusBinding340.input.ctl) at hl
      rw [StatusBinding340.source_control] at hl
      exact env_lookup_live _ _ _ hl.2.2.1 StatusBinding340.source_lookup
    have mappedOther : R.a a ≠ R.a StatusBinding340.sourceAddress := fun he => other (h340.heap.inj _ _ ha cellLive he)
    have hh341 := step_bind_init_heap_other P.F NR FR R live framed before after old old' StatusBinding340.input s340 s341 C C h340
      StatusBinding340.sourceName StatusBinding340.sourceValue StatusBinding340.sourceEnv StatusBinding340.sourceKind
      StatusBinding340.sourceAddress StatusBinding340.source_control StatusBinding340.source_lookup bound340 hr340 (R.a a) mappedOther
    exact (congrArg (fun heap => heap.get (R.a a)) hh342).trans
      (hh341.trans ((congrArg (fun heap => heap.get (R.a a)) hh340).trans
        ((congrArg (fun heap => heap.get (R.a a)) hh339).trans (congrArg (fun heap => heap.get (R.a a)) hh338))))
  have run : runC P.F 5 s C = some (result,C) := by
    apply runC_cons P.F 4 s s338 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr337
    apply runC_cons P.F 3 s338 s339 result C C C (h338.control.isHalt_eq.trans (by host_kernel_rfl)) hr338
    apply runC_cons P.F 2 s339 s340 result C C C (h339.control.isHalt_eq.trans (by host_kernel_rfl)) hr339
    apply runC_cons P.F 1 s340 s341 result C C C (h340.control.isHalt_eq.trans (by host_kernel_rfl)) hr340
    apply runC_cons P.F 0 s341 result result C C C (h341.control.isHalt_eq.trans (by host_kernel_rfl)) hr341
    rfl
  exact ⟨result,run,h342,(congrArg (fun heap => heap.get (R.a StatusBinding340.sourceAddress)) hh342).trans stored,frame⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
