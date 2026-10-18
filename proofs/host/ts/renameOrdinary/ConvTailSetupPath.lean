import host.ts.renameOrdinary.ConvTailSetupSteps
import host.ts.renameOrdinary.ShapeSequenceBinding
import host.ts.RenameRouteCellFields
import host.ts.RenameArgumentExpressionFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

noncomputable def convThirdExpression : Expr := match ConvTailArguments439.sourceRest with
  | .expr e::_ => e | _ => .this
noncomputable def convThirdRest : List Elem := ConvTailArguments439.sourceRest.tail

theorem sequence_origin_address : ConvSequenceVariable438.address = Binding20.sourceAddress := by host_kernel_rfl
theorem sequence_lookup_at_input : lookupEnv ConvSequenceVariable438.sourceName ConvInputBinding429.sourceEnv = some ConvSequenceVariable438.address := by host_kernel_rfl
theorem sequence_not_input : ConvSequenceVariable438.address ≠ ConvInputBinding429.sourceAddress := by decide +kernel

/-- The returned MlxArray is stored in the original caller, then its actual
convTail call collects the array and the previously established S occurrence.
The latter is saved unchanged while the third argument begins evaluation. -/
theorem conv_tail_setup (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' ConvInputDeclaration428.input s)
    (sequence : s.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))))
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ConvTailArguments439.output result ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      ∃ fn this acc fs, result.stack = .c (.args 0 fn this (natV 1::acc) convThirdRest (R.env ConvTailArguments439.sourceEnv))::fs ∧
        result.ctl = .ev convThirdExpression (R.env ConvTailArguments439.sourceEnv) := by
  let s428 := s
  have h428 := h
  obtain ⟨s429,r428,h429⟩ := ConvInputDeclaration428.transport NR FR R C₀ C live framed before after old old' s428 h428
  obtain ⟨s430,r429,h430⟩ := ConvInputBinding429.transport NR FR R C₀ C live framed before after old old' s429 h429 (by rw [h.target_next_eq h429 (by host_kernel_rfl)]; exact bound)
  obtain ⟨s431,r430,h431⟩ := ConvInputDone430.transport NR FR R C₀ C live framed before after old old' s430 h430
  obtain ⟨s432,r431,h432⟩ := ConvTailBlock431.transport NR FR R C₀ C live framed before after old old' s431 h431
  obtain ⟨s433,r432,h433⟩ := ConvTailDeclaration432.transport NR FR R C₀ C live framed before after old old' s432 h432
  obtain ⟨s434,r433,h434⟩ := ConvTailCall433.transport NR FR R C₀ C live framed before after old old' s433 h433
  obtain ⟨v434,r434,h435,_⟩ := ConvTailVariable434.transport NR FR R C₀ C live framed before after old old' s434 h434
  let s435 := s434.ret v434
  obtain ⟨s436,r435,h436⟩ := ConvTailArguments435.transport NR FR R C₀ C live framed before after old old' s435 h435
  obtain ⟨v436,r436,h437,_⟩ := ConvInputVariable436.transport NR FR R C₀ C live framed before after old old' s436 h436
  let s437 := s436.ret v436
  obtain ⟨s438,r437,h438⟩ := ConvTailArguments437.transport NR FR R C₀ C live framed before after old old' s437 h437
  obtain ⟨v438,r438,h439,_⟩ := ConvSequenceVariable438.transport NR FR R C₀ C live framed before after old old' s438 h438
  let s439 := s438.ret v438
  obtain ⟨result,r439,h440⟩ := ConvTailArguments439.transport NR FR R C₀ C live framed before after old old' s439 h439
  have ctl428 : s.ctl = .ret (.obj (R.a 3126703)) := by
    obtain ⟨v,hc,hv⟩ := (h.control_view ConvInputDeclaration428.source_control).ret_view
    cases hv
    exact hc
  have ctl429 : s429.ctl = .bind (.id ConvInputBinding429.sourceName) (.obj (R.a 3126703))
      (R.env ConvInputBinding429.sourceEnv) .init ConvInputBinding429.sourceKind :=
    step_declaration_control P.F NR FR R live framed before after old old' ConvInputDeclaration428.input s s429 C C h
      (.obj (R.a 3126703)) ConvInputDeclaration428.sourceKind ConvInputDeclaration428.sourcePattern ConvInputDeclaration428.sourceRest
      ConvInputDeclaration428.sourceEnv ConvInputDeclaration428.sourceTail ConvInputDeclaration428.source_frame ctl428 (by decide) r428
  have bound429 : s429.next ≤ 2^64 := (h.target_next_eq h429 (by host_kernel_rfl)).symm ▸ bound
  have stored430 := step_bind_init_cell_fields P.F NR FR R live framed before after old old' ConvInputBinding429.input s429 s430 C C h429
    ConvInputBinding429.sourceName ConvInputBinding429.sourceValue (.obj (R.a 3126703)) ConvInputBinding429.sourceEnv
    ConvInputBinding429.sourceKind ConvInputBinding429.sourceAddress ConvInputBinding429.source_control ctl429
    ConvInputBinding429.source_lookup bound429 r429
  have heap429 := step_declaration_value_heap P.F NR FR R live framed before after old old' ConvInputDeclaration428.input s s429 C C h
    ConvInputDeclaration428.sourceValue ConvInputDeclaration428.sourceKind ConvInputDeclaration428.sourcePattern ConvInputDeclaration428.sourceRest
    ConvInputDeclaration428.sourceEnv ConvInputDeclaration428.sourceTail ConvInputDeclaration428.source_control ConvInputDeclaration428.source_frame (by decide) r428
  have hl := h429.controlLive
  change treeSupport live (Encode.ctl ConvInputBinding429.input.ctl) at hl
  rw [ConvInputBinding429.source_control] at hl
  have sequenceLive := env_lookup_live _ _ _ hl.2.2.1 sequence_lookup_at_input
  have inputLive := env_lookup_live _ _ _ hl.2.2.1 ConvInputBinding429.source_lookup
  have neq : R.a ConvSequenceVariable438.address ≠ R.a ConvInputBinding429.sourceAddress := fun he =>
    sequence_not_input (h429.heap.inj _ _ sequenceLive inputLive he)
  have frame430 := step_bind_init_heap_other P.F NR FR R live framed before after old old' ConvInputBinding429.input s429 s430 C C h429
    ConvInputBinding429.sourceName ConvInputBinding429.sourceValue ConvInputBinding429.sourceEnv ConvInputBinding429.sourceKind
    ConvInputBinding429.sourceAddress ConvInputBinding429.source_control ConvInputBinding429.source_lookup bound429 r429 _ neq
  have sequence430 : s430.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) := by
    rw [←sequence_origin_address,frame430,heap429,sequence_origin_address]
    exact sequence
  have heap431 := step_declaration_next_heap P.F NR FR R live framed before after old old' ConvInputDone430.input s430 s431 C C h430
    ConvInputDone430.sourceValue ConvInputDone430.sourceKind ConvInputDone430.sourceRest ConvInputDone430.sourceEnv ConvInputDone430.sourceTail ConvInputDone430.source_control ConvInputDone430.source_frame r430
  have heap432 := step_block_next_heap P.F NR FR R live framed before after old old' ConvTailBlock431.input s431 s432 C C h431
    ConvTailBlock431.sourceValue ConvTailBlock431.sourceStatement ConvTailBlock431.sourceRest ConvTailBlock431.sourceEnv ConvTailBlock431.sourceTail ConvTailBlock431.source_control ConvTailBlock431.source_frame r431
  have heap433 := step_statement_heap P.F NR FR R live framed before after old old' ConvTailDeclaration432.input s432 s433 C C h432
    ConvTailDeclaration432.sourceAction ConvTailDeclaration432.sourceEnv ConvTailDeclaration432.source_control r432
  have heap434 := step_identifier_call_heap P.F NR FR R live framed before after old old' ConvTailCall433.input s433 s434 C₀ C C h433
    ConvTailCall433.sourceName ConvTailCall433.sourceArgs ConvTailCall433.sourceOptional ConvTailCall433.sourceEnv ConvTailCall433.source_control r433
  have heap435 : s435.heap = s434.heap := rfl
  have heap436 := step_callStart_heap P.F NR FR R live framed before after old old' ConvTailArguments435.input s435 s436 C C h435
    (.callee ConvTailArguments435.sourceOptional) ConvTailArguments435.sourceAddress .undef ConvTailArguments435.sourceArgs ConvTailArguments435.sourceEnv ConvTailArguments435.sourceTail ConvTailArguments435.source_control ConvTailArguments435.source_frame r435
  have heap437 : s437.heap = s436.heap := rfl
  have heap438 := step_argument_heap_from_source P.F NR FR R live framed before after old old' ConvTailArguments437.input s437 s438 C C h437
    ConvTailArguments437.sourceValue ConvTailArguments437.sourceKind ConvTailArguments437.sourceFunction ConvTailArguments437.sourceThis ConvTailArguments437.sourceAcc ConvTailArguments437.sourceRest ConvTailArguments437.sourceEnv ConvTailArguments437.sourceTail ConvTailArguments437.source_control ConvTailArguments437.source_frame (by decide) r437
  have heap438 : s438.heap = s430.heap := heap438.trans (heap437.trans (heap436.trans (heap435.trans (heap434.trans (heap433.trans (heap432.trans heap431))))))
  have sequence438 : s438.heap.get (R.a ConvSequenceVariable438.address) = some (.cell (some (natV 1))) := by
    rw [heap438,sequence_origin_address]
    exact sequence430
  obtain ⟨ctl439,heap439⟩ := step_variable_cell_fields P.F NR FR R live framed before after old old' ConvSequenceVariable438.input s438 s439 C C h438
    ConvSequenceVariable438.sourceName ConvSequenceVariable438.sourceEnv ConvSequenceVariable438.address (natV 1)
    ConvSequenceVariable438.source_control ConvSequenceVariable438.source_lookup sequence438 r438
  have frame439 : ConvTailArguments439.input.stack = .c (.args 0 ConvTailArguments439.sourceFunction ConvTailArguments439.sourceThis
      ConvTailArguments439.sourceAcc (.expr convThirdExpression::convThirdRest) ConvTailArguments439.sourceEnv)::ConvTailArguments439.sourceTail := by host_kernel_rfl
  obtain ⟨fn,this,acc,fs,stack440,ctl440,heap440⟩ := step_argument_expression_fields P.F NR FR R C C live framed before after old old'
    ConvTailArguments439.input s439 result h439 0 ConvTailArguments439.sourceFunction ConvTailArguments439.sourceThis
    ConvTailArguments439.sourceAcc convThirdExpression convThirdRest ConvTailArguments439.sourceEnv ConvTailArguments439.sourceTail
    (natV 1) ctl439 frame439 (by decide) r439
  have finalHeap : result.heap = s430.heap := heap440.trans (heap439.trans heap438)
  refine ⟨result,?_,h440,?_,?_,fn,this,acc,fs,stack440,ctl440⟩
  ·
    apply runC_cons P.F 11 s428 s429 result C C C (h428.control.isHalt_eq.trans (by host_kernel_rfl)) r428
    apply runC_cons P.F 10 s429 s430 result C C C (h429.control.isHalt_eq.trans (by host_kernel_rfl)) r429
    apply runC_cons P.F 9 s430 s431 result C C C (h430.control.isHalt_eq.trans (by host_kernel_rfl)) r430
    apply runC_cons P.F 8 s431 s432 result C C C (h431.control.isHalt_eq.trans (by host_kernel_rfl)) r431
    apply runC_cons P.F 7 s432 s433 result C C C (h432.control.isHalt_eq.trans (by host_kernel_rfl)) r432
    apply runC_cons P.F 6 s433 s434 result C C C (h433.control.isHalt_eq.trans (by host_kernel_rfl)) r433
    apply runC_cons P.F 5 s434 s435 result C C C (h434.control.isHalt_eq.trans (by host_kernel_rfl)) r434
    apply runC_cons P.F 4 s435 s436 result C C C (h435.control.isHalt_eq.trans (by host_kernel_rfl)) r435
    apply runC_cons P.F 3 s436 s437 result C C C (h436.control.isHalt_eq.trans (by host_kernel_rfl)) r436
    apply runC_cons P.F 2 s437 s438 result C C C (h437.control.isHalt_eq.trans (by host_kernel_rfl)) r437
    apply runC_cons P.F 1 s438 s439 result C C C (h438.control.isHalt_eq.trans (by host_kernel_rfl)) r438
    apply runC_cons P.F 0 s439 result result C C C (h439.control.isHalt_eq.trans (by host_kernel_rfl)) r439
    rfl
  · rw [finalHeap]
    exact stored430
  · rw [finalHeap]
    exact sequence430
theorem conv_tail_setup_framed (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' ConvInputDeclaration428.input s)
    (sequence : s.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))))
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ConvTailArguments439.output result ∧
      result.heap.get (R.a ConvInputBinding429.sourceAddress) = some (.cell (some (.obj (R.a 3126703)))) ∧
      result.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) ∧
      (∀ a, live a → a ≠ ConvInputBinding429.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      ∃ fn this acc fs, result.stack = .c (.args 0 fn this (natV 1::acc) convThirdRest (R.env ConvTailArguments439.sourceEnv))::fs ∧
        result.ctl = .ev convThirdExpression (R.env ConvTailArguments439.sourceEnv) := by
  let s428 := s
  have h428 := h
  obtain ⟨s429,r428,h429⟩ := ConvInputDeclaration428.transport NR FR R C₀ C live framed before after old old' s428 h428
  obtain ⟨s430,r429,h430⟩ := ConvInputBinding429.transport NR FR R C₀ C live framed before after old old' s429 h429 (by rw [h.target_next_eq h429 (by host_kernel_rfl)]; exact bound)
  obtain ⟨s431,r430,h431⟩ := ConvInputDone430.transport NR FR R C₀ C live framed before after old old' s430 h430
  obtain ⟨s432,r431,h432⟩ := ConvTailBlock431.transport NR FR R C₀ C live framed before after old old' s431 h431
  obtain ⟨s433,r432,h433⟩ := ConvTailDeclaration432.transport NR FR R C₀ C live framed before after old old' s432 h432
  obtain ⟨s434,r433,h434⟩ := ConvTailCall433.transport NR FR R C₀ C live framed before after old old' s433 h433
  obtain ⟨v434,r434,h435,_⟩ := ConvTailVariable434.transport NR FR R C₀ C live framed before after old old' s434 h434
  let s435 := s434.ret v434
  obtain ⟨s436,r435,h436⟩ := ConvTailArguments435.transport NR FR R C₀ C live framed before after old old' s435 h435
  obtain ⟨v436,r436,h437,_⟩ := ConvInputVariable436.transport NR FR R C₀ C live framed before after old old' s436 h436
  let s437 := s436.ret v436
  obtain ⟨s438,r437,h438⟩ := ConvTailArguments437.transport NR FR R C₀ C live framed before after old old' s437 h437
  obtain ⟨v438,r438,h439,_⟩ := ConvSequenceVariable438.transport NR FR R C₀ C live framed before after old old' s438 h438
  let s439 := s438.ret v438
  obtain ⟨result,r439,h440⟩ := ConvTailArguments439.transport NR FR R C₀ C live framed before after old old' s439 h439
  have ctl428 : s.ctl = .ret (.obj (R.a 3126703)) := by
    obtain ⟨v,hc,hv⟩ := (h.control_view ConvInputDeclaration428.source_control).ret_view
    cases hv
    exact hc
  have ctl429 : s429.ctl = .bind (.id ConvInputBinding429.sourceName) (.obj (R.a 3126703))
      (R.env ConvInputBinding429.sourceEnv) .init ConvInputBinding429.sourceKind :=
    step_declaration_control P.F NR FR R live framed before after old old' ConvInputDeclaration428.input s s429 C C h
      (.obj (R.a 3126703)) ConvInputDeclaration428.sourceKind ConvInputDeclaration428.sourcePattern ConvInputDeclaration428.sourceRest
      ConvInputDeclaration428.sourceEnv ConvInputDeclaration428.sourceTail ConvInputDeclaration428.source_frame ctl428 (by decide) r428
  have bound429 : s429.next ≤ 2^64 := (h.target_next_eq h429 (by host_kernel_rfl)).symm ▸ bound
  have stored430 := step_bind_init_cell_fields P.F NR FR R live framed before after old old' ConvInputBinding429.input s429 s430 C C h429
    ConvInputBinding429.sourceName ConvInputBinding429.sourceValue (.obj (R.a 3126703)) ConvInputBinding429.sourceEnv
    ConvInputBinding429.sourceKind ConvInputBinding429.sourceAddress ConvInputBinding429.source_control ctl429
    ConvInputBinding429.source_lookup bound429 r429
  have heap429 := step_declaration_value_heap P.F NR FR R live framed before after old old' ConvInputDeclaration428.input s s429 C C h
    ConvInputDeclaration428.sourceValue ConvInputDeclaration428.sourceKind ConvInputDeclaration428.sourcePattern ConvInputDeclaration428.sourceRest
    ConvInputDeclaration428.sourceEnv ConvInputDeclaration428.sourceTail ConvInputDeclaration428.source_control ConvInputDeclaration428.source_frame (by decide) r428
  have hl := h429.controlLive
  change treeSupport live (Encode.ctl ConvInputBinding429.input.ctl) at hl
  rw [ConvInputBinding429.source_control] at hl
  have sequenceLive := env_lookup_live _ _ _ hl.2.2.1 sequence_lookup_at_input
  have inputLive := env_lookup_live _ _ _ hl.2.2.1 ConvInputBinding429.source_lookup
  have neq : R.a ConvSequenceVariable438.address ≠ R.a ConvInputBinding429.sourceAddress := fun he =>
    sequence_not_input (h429.heap.inj _ _ sequenceLive inputLive he)
  have frame430 := step_bind_init_heap_other P.F NR FR R live framed before after old old' ConvInputBinding429.input s429 s430 C C h429
    ConvInputBinding429.sourceName ConvInputBinding429.sourceValue ConvInputBinding429.sourceEnv ConvInputBinding429.sourceKind
    ConvInputBinding429.sourceAddress ConvInputBinding429.source_control ConvInputBinding429.source_lookup bound429 r429 _ neq
  have sequence430 : s430.heap.get (R.a Binding20.sourceAddress) = some (.cell (some (natV 1))) := by
    rw [←sequence_origin_address,frame430,heap429,sequence_origin_address]
    exact sequence
  have heap431 := step_declaration_next_heap P.F NR FR R live framed before after old old' ConvInputDone430.input s430 s431 C C h430
    ConvInputDone430.sourceValue ConvInputDone430.sourceKind ConvInputDone430.sourceRest ConvInputDone430.sourceEnv ConvInputDone430.sourceTail ConvInputDone430.source_control ConvInputDone430.source_frame r430
  have heap432 := step_block_next_heap P.F NR FR R live framed before after old old' ConvTailBlock431.input s431 s432 C C h431
    ConvTailBlock431.sourceValue ConvTailBlock431.sourceStatement ConvTailBlock431.sourceRest ConvTailBlock431.sourceEnv ConvTailBlock431.sourceTail ConvTailBlock431.source_control ConvTailBlock431.source_frame r431
  have heap433 := step_statement_heap P.F NR FR R live framed before after old old' ConvTailDeclaration432.input s432 s433 C C h432
    ConvTailDeclaration432.sourceAction ConvTailDeclaration432.sourceEnv ConvTailDeclaration432.source_control r432
  have heap434 := step_identifier_call_heap P.F NR FR R live framed before after old old' ConvTailCall433.input s433 s434 C₀ C C h433
    ConvTailCall433.sourceName ConvTailCall433.sourceArgs ConvTailCall433.sourceOptional ConvTailCall433.sourceEnv ConvTailCall433.source_control r433
  have heap435 : s435.heap = s434.heap := rfl
  have heap436 := step_callStart_heap P.F NR FR R live framed before after old old' ConvTailArguments435.input s435 s436 C C h435
    (.callee ConvTailArguments435.sourceOptional) ConvTailArguments435.sourceAddress .undef ConvTailArguments435.sourceArgs ConvTailArguments435.sourceEnv ConvTailArguments435.sourceTail ConvTailArguments435.source_control ConvTailArguments435.source_frame r435
  have heap437 : s437.heap = s436.heap := rfl
  have heap438 := step_argument_heap_from_source P.F NR FR R live framed before after old old' ConvTailArguments437.input s437 s438 C C h437
    ConvTailArguments437.sourceValue ConvTailArguments437.sourceKind ConvTailArguments437.sourceFunction ConvTailArguments437.sourceThis ConvTailArguments437.sourceAcc ConvTailArguments437.sourceRest ConvTailArguments437.sourceEnv ConvTailArguments437.sourceTail ConvTailArguments437.source_control ConvTailArguments437.source_frame (by decide) r437
  have heap438 : s438.heap = s430.heap := heap438.trans (heap437.trans (heap436.trans (heap435.trans (heap434.trans (heap433.trans (heap432.trans heap431))))))
  have sequence438 : s438.heap.get (R.a ConvSequenceVariable438.address) = some (.cell (some (natV 1))) := by
    rw [heap438,sequence_origin_address]
    exact sequence430
  obtain ⟨ctl439,heap439⟩ := step_variable_cell_fields P.F NR FR R live framed before after old old' ConvSequenceVariable438.input s438 s439 C C h438
    ConvSequenceVariable438.sourceName ConvSequenceVariable438.sourceEnv ConvSequenceVariable438.address (natV 1)
    ConvSequenceVariable438.source_control ConvSequenceVariable438.source_lookup sequence438 r438
  have frame439 : ConvTailArguments439.input.stack = .c (.args 0 ConvTailArguments439.sourceFunction ConvTailArguments439.sourceThis
      ConvTailArguments439.sourceAcc (.expr convThirdExpression::convThirdRest) ConvTailArguments439.sourceEnv)::ConvTailArguments439.sourceTail := by host_kernel_rfl
  obtain ⟨fn,this,acc,fs,stack440,ctl440,heap440⟩ := step_argument_expression_fields P.F NR FR R C C live framed before after old old'
    ConvTailArguments439.input s439 result h439 0 ConvTailArguments439.sourceFunction ConvTailArguments439.sourceThis
    ConvTailArguments439.sourceAcc convThirdExpression convThirdRest ConvTailArguments439.sourceEnv ConvTailArguments439.sourceTail
    (natV 1) ctl439 frame439 (by decide) r439
  have finalHeap : result.heap = s430.heap := heap440.trans (heap439.trans heap438)
  refine ⟨result,?_,h440,?_,?_,?_,fn,this,acc,fs,stack440,ctl440⟩
  ·
    apply runC_cons P.F 11 s428 s429 result C C C (h428.control.isHalt_eq.trans (by host_kernel_rfl)) r428
    apply runC_cons P.F 10 s429 s430 result C C C (h429.control.isHalt_eq.trans (by host_kernel_rfl)) r429
    apply runC_cons P.F 9 s430 s431 result C C C (h430.control.isHalt_eq.trans (by host_kernel_rfl)) r430
    apply runC_cons P.F 8 s431 s432 result C C C (h431.control.isHalt_eq.trans (by host_kernel_rfl)) r431
    apply runC_cons P.F 7 s432 s433 result C C C (h432.control.isHalt_eq.trans (by host_kernel_rfl)) r432
    apply runC_cons P.F 6 s433 s434 result C C C (h433.control.isHalt_eq.trans (by host_kernel_rfl)) r433
    apply runC_cons P.F 5 s434 s435 result C C C (h434.control.isHalt_eq.trans (by host_kernel_rfl)) r434
    apply runC_cons P.F 4 s435 s436 result C C C (h435.control.isHalt_eq.trans (by host_kernel_rfl)) r435
    apply runC_cons P.F 3 s436 s437 result C C C (h436.control.isHalt_eq.trans (by host_kernel_rfl)) r436
    apply runC_cons P.F 2 s437 s438 result C C C (h437.control.isHalt_eq.trans (by host_kernel_rfl)) r437
    apply runC_cons P.F 1 s438 s439 result C C C (h438.control.isHalt_eq.trans (by host_kernel_rfl)) r438
    apply runC_cons P.F 0 s439 result result C C C (h439.control.isHalt_eq.trans (by host_kernel_rfl)) r439
    rfl
  · rw [finalHeap]
    exact stored430
  · rw [finalHeap]
    exact sequence430
  · intro a alive other
    have ne : R.a a ≠ R.a ConvInputBinding429.sourceAddress := fun he => other (h429.heap.inj _ _ alive inputLive he)
    have frame := step_bind_init_heap_other P.F NR FR R live framed before after old old' ConvInputBinding429.input s429 s430 C C h429
      ConvInputBinding429.sourceName ConvInputBinding429.sourceValue ConvInputBinding429.sourceEnv ConvInputBinding429.sourceKind
      ConvInputBinding429.sourceAddress ConvInputBinding429.source_control ConvInputBinding429.source_lookup bound429 r429 _ ne
    rw [finalHeap,frame,heap429]


end Host.Load.Run.Full.Ordinary.VectorToConcat
