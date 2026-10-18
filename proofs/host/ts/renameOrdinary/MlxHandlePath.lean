import host.ts.renameOrdinary.MlxConstructorSteps
import host.ts.RenameConstructorAssignmentEffects
import host.ts.RenameRouteCellFields
import host.ts.RenameResourceFields
import host.ts.RenameClassHeapEffects
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def HandleLive (live : Nat → Prop) : Nat → Prop :=
  CellsLive live ConstructorBlock383.input.next (blockNames ConstructorBlock383.sourceBody)

theorem handle_cell_identity : ConstructorHandle389.address = HandleBinding382.sourceAddress := by host_kernel_rfl

theorem handle_receiver_identity : HandleStore390.sourceAddress = 3126703 := by host_kernel_rfl

/-- Execute the real constructor parameter, body entry and private assignment.
The exact incoming argument is stored into #handle; it is not recovered by
choosing one of ValueR's bigint interpretations. -/
theorem initialize_constructor_handle_framed (NR : NumV → NumV → Prop)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' HandleParameter381.input s)
    (argument : Val) (first : constructorParameterArgument s.stack = argument)
    (bound : s.next+(blockNames ConstructorBlock383.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      StateR NR FR R (HandleLive live) framed before after old old' HandleStore390.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName argument ∧
      (∀ m, m < s.next → m ≠ R.a 3126703 → m ≠ R.a HandleBinding382.sourceAddress →
        result.heap.get m = s.heap.get m) := by
  have bound0 : s.next ≤ 2^64 := by omega
  obtain ⟨s382,r381,h382⟩ := HandleParameter381.transport NR FR R C₀ C live framed before after old old' s h
  have arg382 := (step_parameter_argument_fields P.F NR FR R C C live framed before after old old' _ _ _ h
    HandleParameter381.sourceValue HandleParameter381.sourceFunction HandleParameter381.sourceName
    HandleParameter381.sourceParams HandleParameter381.sourceArgs HandleParameter381.sourceEnv HandleParameter381.sourceTail
    HandleParameter381.source_control HandleParameter381.source_frame r381).1
  have bind382 : s382.ctl = .bind (.id HandleBinding382.sourceName) argument
      (R.env HandleBinding382.sourceEnv) .init HandleBinding382.sourceKind := by
    rw [first] at arg382
    exact arg382
  have next382 : s382.next = s.next := h.target_next_eq h382 (by host_kernel_rfl)
  obtain ⟨s383,r382,h383⟩ := HandleBinding382.transport NR FR R C₀ C live framed before after old old' s382 h382 (by rw [next382]; exact bound0)
  have cell383 := step_bind_init_cell_fields P.F NR FR R live framed before after old old' _ _ _ C C h382
    HandleBinding382.sourceName HandleBinding382.sourceValue argument HandleBinding382.sourceEnv HandleBinding382.sourceKind
    HandleBinding382.sourceAddress HandleBinding382.source_control bind382 HandleBinding382.source_lookup
    (by rw [next382]; exact bound0) r382
  have next383 : s383.next = s.next := h.target_next_eq h383 (by host_kernel_rfl)
  have bodyBound : s383.next+(blockNames ConstructorBlock383.sourceBody).length ≤ 2^64 := by rw [next383]; exact bound
  obtain ⟨s384,r383,h384⟩ := ConstructorBlock383.transport NR FR R C₀ C live framed before after old old' s383 h383 bodyBound
  have cellLive : live HandleBinding382.sourceAddress := by
    have hl := h382.controlLive
    change treeSupport live (Encode.ctl HandleBinding382.input.ctl) at hl
    rw [HandleBinding382.source_control] at hl
    exact env_lookup_live _ _ _ hl.2.2.1 HandleBinding382.source_lookup
  have cellBelow : R.a HandleBinding382.sourceAddress < s383.next := h383.heap.targetBound _ cellLive
  have heap384 := step_parameter_body_heap P.F NR FR R C C live framed before after old old' _ _ _ h383
    ConstructorBlock383.sourceValue ConstructorBlock383.sourceName ConstructorBlock383.sourceParams
    ConstructorBlock383.sourceBody ConstructorBlock383.sourceArgs ConstructorBlock383.sourceEnv ConstructorBlock383.sourceTail
    ConstructorBlock383.source_control ConstructorBlock383.source_frame ConstructorBlock383.source_hoist
    (R.a HandleBinding382.sourceAddress) cellBelow bodyBound r383
  have cell384 := heap384.trans cell383
  obtain ⟨s385,r384,h385⟩ := ConstructorStatement384.transport NR FR R C₀ C (HandleLive live) framed before after old old' s384 h384
  have heap385 := step_block_next_heap P.F NR FR R (HandleLive live) framed before after old old' _ _ _ C C h384
    ConstructorStatement384.sourceValue ConstructorStatement384.sourceStatement ConstructorStatement384.sourceRest
    ConstructorStatement384.sourceEnv ConstructorStatement384.sourceTail ConstructorStatement384.source_control ConstructorStatement384.source_frame r384
  obtain ⟨s386,r385,h386⟩ := ConstructorExpression385.transport NR FR R C₀ C (HandleLive live) framed before after old old' s385 h385
  have heap386 := step_statement_heap P.F NR FR R (HandleLive live) framed before after old old' _ _ _ C C h385
    ConstructorExpression385.sourceAction ConstructorExpression385.sourceEnv ConstructorExpression385.source_control r385
  obtain ⟨s387,r386,h387⟩ := HandleAssignment386.transport NR FR R C₀ C (HandleLive live) framed before after old old' s386 h386
  have heap387 := step_private_assignment_heap P.F NR FR R C₀ C C (HandleLive live) framed before after old old' _ _ _ h386
    HandleAssignment386.sourceReceiver HandleAssignment386.sourceName HandleAssignment386.sourceOptional
    HandleAssignment386.sourceRhs HandleAssignment386.sourceEnv HandleAssignment386.sourceBrand
    HandleAssignment386.source_control HandleAssignment386.source_lookup r386
  obtain ⟨s388,r387,h388⟩ := ConstructorThis387.transport NR FR R C₀ C (HandleLive live) framed before after old old' s387 h387
  have heap388 := step_this_heap_from_source P.F NR FR R (HandleLive live) framed before after old old' _ _ _ C₀ C C h387
    ConstructorThis387.sourceEnv ConstructorThis387.sourceAddress ConstructorThis387.sourceValue
    ConstructorThis387.source_control ConstructorThis387.source_lookup ConstructorThis387.source_cell r387
  obtain ⟨s389,r388,h389⟩ := HandleReceiver388.transport NR FR R C₀ C (HandleLive live) framed before after old old' s388 h388
  have heap389 := step_private_receiver_heap P.F NR FR R C₀ C C (HandleLive live) framed before after old old' _ _ _ h388
    HandleReceiver388.sourceValue HandleReceiver388.sourceBrand HandleReceiver388.sourceName HandleReceiver388.sourceRhs
    HandleReceiver388.sourceEnv HandleReceiver388.sourceTail HandleReceiver388.source_control HandleReceiver388.source_frame r388
  have cell389 : s389.heap.get (R.a ConstructorHandle389.address) = some (.cell (some argument)) := by
    rw [handle_cell_identity,heap389,heap388,heap387,heap386,heap385]
    exact cell384
  obtain ⟨v,r389,h390,_⟩ := ConstructorHandle389.transport NR FR R C₀ C (HandleLive live) framed before after old old' s389 h389
  let s390 := s389.ret v
  have ctl390 := (step_variable_cell_fields P.F NR FR R (HandleLive live) framed before after old old' _ _ _ C C h389
    ConstructorHandle389.sourceName ConstructorHandle389.sourceEnv ConstructorHandle389.address argument
    ConstructorHandle389.source_control ConstructorHandle389.source_lookup cell389 r389).1
  have next390 : s390.next = s.next := h.target_next_eq h390 (by host_kernel_rfl)
  have bound390 : s390.next ≤ 2^64 := by rw [next390]; exact bound0
  obtain ⟨result,r390,h391⟩ := HandleStore390.transport NR FR R C₀ C (HandleLive live) framed before after old old' s390 h390 bound390
  have stored := (step_private_store_fields P.F NR FR R C₀ C C (HandleLive live) framed before after old old' _ _ _ h390
    HandleStore390.sourceAddress HandleStore390.sourceBrand HandleStore390.sourceName HandleStore390.sourceValue argument
    HandleStore390.sourcePrior HandleStore390.sourceOld HandleStore390.sourceEnumerable HandleStore390.sourceObject
    HandleStore390.sourceTail HandleStore390.source_control ctl390 HandleStore390.source_frame HandleStore390.source_heap
    HandleStore390.source_kind HandleStore390.source_property HandleStore390.source_bound bound390 r390).2
  rw [handle_receiver_identity] at stored
  have frame (m : Nat) (below : m < s.next) (notInstance : m ≠ R.a 3126703)
      (notParameter : m ≠ R.a HandleBinding382.sourceAddress) : result.heap.get m = s.heap.get m := by
    have heap382 := (step_parameter_argument_fields P.F NR FR R C C live framed before after old old' _ _ _ h
      HandleParameter381.sourceValue HandleParameter381.sourceFunction HandleParameter381.sourceName
      HandleParameter381.sourceParams HandleParameter381.sourceArgs HandleParameter381.sourceEnv HandleParameter381.sourceTail
      HandleParameter381.source_control HandleParameter381.source_frame r381).2
    have heap383 := step_bind_init_heap_other P.F NR FR R live framed before after old old' _ _ _ C C h382
      HandleBinding382.sourceName HandleBinding382.sourceValue HandleBinding382.sourceEnv HandleBinding382.sourceKind
      HandleBinding382.sourceAddress HandleBinding382.source_control HandleBinding382.source_lookup
      (by rw [next382]; exact bound0) r382 m notParameter
    have heap384m := step_parameter_body_heap P.F NR FR R C C live framed before after old old' _ _ _ h383
      ConstructorBlock383.sourceValue ConstructorBlock383.sourceName ConstructorBlock383.sourceParams
      ConstructorBlock383.sourceBody ConstructorBlock383.sourceArgs ConstructorBlock383.sourceEnv ConstructorBlock383.sourceTail
      ConstructorBlock383.source_control ConstructorBlock383.source_frame ConstructorBlock383.source_hoist
      m (by rw [next383]; exact below) bodyBound r383
    have heap391m := step_private_store_heap_other P.F NR FR R C₀ C C (HandleLive live) framed before after old old' _ _ _ h390
      HandleStore390.sourceAddress HandleStore390.sourceBrand HandleStore390.sourceName HandleStore390.sourceValue
      HandleStore390.sourcePrior HandleStore390.sourceOld HandleStore390.sourceEnumerable HandleStore390.sourceObject
      HandleStore390.sourceTail HandleStore390.source_control HandleStore390.source_frame HandleStore390.source_heap
      HandleStore390.source_kind HandleStore390.source_property HandleStore390.source_bound bound390 r390 m
      (by rw [handle_receiver_identity]; exact notInstance)
    have beforeStore : s390.heap = s384.heap := heap389.trans (heap388.trans (heap387.trans (heap386.trans heap385)))
    exact heap391m.trans ((congrArg (fun heap => heap.get m) beforeStore).trans (heap384m.trans (heap383.trans (congrArg (fun heap => heap.get m) heap382))))
  refine ⟨result,?_,h391,stored,frame⟩
  apply runC_cons P.F 9 s s382 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r381
  apply runC_cons P.F 8 s382 s383 result C C C (h382.control.isHalt_eq.trans (by host_kernel_rfl)) r382
  apply runC_cons P.F 7 s383 s384 result C C C (h383.control.isHalt_eq.trans (by host_kernel_rfl)) r383
  apply runC_cons P.F 6 s384 s385 result C C C (h384.control.isHalt_eq.trans (by host_kernel_rfl)) r384
  apply runC_cons P.F 5 s385 s386 result C C C (h385.control.isHalt_eq.trans (by host_kernel_rfl)) r385
  apply runC_cons P.F 4 s386 s387 result C C C (h386.control.isHalt_eq.trans (by host_kernel_rfl)) r386
  apply runC_cons P.F 3 s387 s388 result C C C (h387.control.isHalt_eq.trans (by host_kernel_rfl)) r387
  apply runC_cons P.F 2 s388 s389 result C C C (h388.control.isHalt_eq.trans (by host_kernel_rfl)) r388
  apply runC_cons P.F 1 s389 s390 result C C C (h389.control.isHalt_eq.trans (by host_kernel_rfl)) r389
  apply runC_cons P.F 0 s390 result result C C C (h390.control.isHalt_eq.trans (by host_kernel_rfl)) r390
  rfl

theorem initialize_constructor_handle (NR : NumV → NumV → Prop)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' HandleParameter381.input s)
    (argument : Val) (first : constructorParameterArgument s.stack = argument)
    (bound : s.next+(blockNames ConstructorBlock383.sourceBody).length ≤ 2^64) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      StateR NR FR R (HandleLive live) framed before after old old' HandleStore390.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName argument := by
  obtain ⟨result,run,related,field,_⟩ := initialize_constructor_handle_framed NR FR R C₀ C live framed before after old old'
    s h argument first bound
  exact ⟨result,run,related,field⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
