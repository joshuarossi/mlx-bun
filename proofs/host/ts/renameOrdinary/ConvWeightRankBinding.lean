import host.ts.renameOrdinary.ConvWeightRankPath
import host.ts.RenameStackEffects
import host.ts.RenameRouteArgumentFields
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteReturnFields
import host.ts.RenameRouteDriverReturns
import host.ts.RenameRouteDriverBinding
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
host_transport_structural P.F, P.RestStream.micro0.micro4.s85 to P.RestStream.micro0.micro4.s86 as WeightCollect2
host_transport_return P.F, P.RestStream.micro0.micro4.s87 to P.RestStream.micro0.micro4.s88 as WeightReturn4
host_transport_return P.F, P.RestStream.micro0.micro4.s88 to P.RestStream.micro0.micro4.s89 as WeightReturn5
host_transport_return P.F, P.RestStream.micro0.micro4.s89 to P.RestStream.micro0.micro4.s90 as WeightReturn6
host_transport_return P.F, P.RestStream.micro0.micro4.s90 to P.RestStream.micro0.micro4.s91 as WeightReturn7
host_transport_binding P.F, P.RestStream.micro0.micro4.s91 to P.RestStream.micro0.micro4.s92 as WeightDeclare8
host_transport_binding P.F, P.RestStream.micro0.micro4.s92 to P.RestStream.micro0.micro4.s93 as WeightInitialize9

noncomputable def WeightnumberInput : St LSt := P.RestStream.micro0.micro4.s86
noncomputable def WeightnumberAddress : Nat := match WeightnumberInput.ctl with
  | .call (.obj a) _ _ => a | _ => 0
noncomputable def WeightnumberReceiver : Val := match WeightnumberInput.ctl with
  | .call _ this _ => this | _ => .undef
noncomputable def WeightnumberObject : Obj := match WeightnumberInput.heap.get WeightnumberAddress with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
theorem Weightnumber_control : WeightnumberInput.ctl = .call (.obj WeightnumberAddress) WeightnumberReceiver [.big (Int.ofNat 3)] := by host_kernel_rfl
theorem Weightnumber_heap : WeightnumberInput.heap.get WeightnumberAddress = some (.obj WeightnumberObject) := by host_kernel_rfl
theorem Weightnumber_kind : WeightnumberObject.kind = .fn (.native (.num .number) []) := by host_kernel_rfl
theorem Weightnumber_post : WeightnumberInput.ret (intV (Int.ofNat 3)) = P.RestStream.micro0.micro4.s87 := by host_kernel_rfl

/-- The native rank result flows through the real Number conversion, returns
and lexical binding into the shape getter's rank cell. -/
theorem conv_weight_rank_binding_framed (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' WeightCollect2.input s)
    (rank : s.ctl = .ret (.big (Int.ofNat 3)))
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 8 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro4.s93 result ∧
      result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) ∧
      (∀ a, a ≠ R.a WeightInitialize9.sourceAddress → result.heap.get a = s.heap.get a) ∧
      result.stack.drop 4 = s.stack.drop 9 := by
  let NR := NumberRoles ν₀ ν C₀ C
  let s2 := s
  have h2 := h
  have hc2 := rank
  obtain ⟨s3,hr2,h3⟩ := WeightCollect2.transport NR FR R C₀ C live framed before after old old' s2 h2
  have hf2 : WeightCollect2.input.stack = .c (.args 0 WeightCollect2.sourceFunction WeightCollect2.sourceThis
      WeightCollect2.sourceAcc [] WeightCollect2.sourceEnv)::WeightCollect2.sourceTail := by host_kernel_rfl
  have hl2 : WeightCollect2.sourceAcc.length = 0 := by host_kernel_rfl
  have argument : callArgument s3.ctl 0 = .big (Int.ofNat 3) := by
    have ha := step_argument_last P.F NR FR R live framed before after old old' WeightCollect2.input s2 s3 C C h2
      WeightCollect2.sourceValue (.big (Int.ofNat 3)) WeightCollect2.sourceFunction WeightCollect2.sourceThis
      WeightCollect2.sourceAcc WeightCollect2.sourceEnv WeightCollect2.sourceTail WeightCollect2.source_control hc2 hf2 hr2
    simpa only [hl2] using ha
  have integerRole : (Annotated.Value.ordinaryBig (Int.ofNat 3)).Holds ν C R (callArgument s3.ctl 0) :=
    argument.symm ▸ Annotated.Value.Holds.ordinaryBig (Int.ofNat 3)
  obtain ⟨_,hr3,h4raw⟩ := step_number_integer_from_source Host.Load.ffi FR R ν₀ ν C₀ C live framed before after old old'
    WeightnumberInput s3 h3 WeightnumberAddress WeightnumberObject [] WeightnumberReceiver (Int.ofNat 3)
    Weightnumber_control Weightnumber_heap Weightnumber_kind integerRole
  have h4 : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro4.s87 (s3.ret (intV (Int.ofNat 3))) :=
    Weightnumber_post ▸ h4raw
  let s4 := s3.ret (intV (Int.ofNat 3))
  have hi : intV (Int.ofNat 3) = natV 3 := by host_kernel_rfl
  have hc4 : s4.ctl = .ret (natV 3) := congrArg Ctl.ret hi
  obtain ⟨s5,hr4,h5⟩ := WeightReturn4.transport NR FR R C₀ C live framed before after old old' s4 h4
  have hc5 : s5.ctl = .abr (.ret (natV 3)) := step_return_exit_control P.F NR FR R live framed
    before after old old' WeightReturn4.input s4 s5 C C h4 (natV 3) WeightReturn4.sourceAction WeightReturn4.sourceEnv
    WeightReturn4.sourceTail WeightReturn4.source_frame hc4 hr4
  obtain ⟨s6,hr5,h6⟩ := WeightReturn5.transport NR FR R C₀ C live framed before after old old' s5 h5
  have hc6 : s6.ctl = .abr (.ret (natV 3)) := step_return_unwind_control P.F NR FR R live framed
    before after old old' WeightReturn5.input s5 s6 C C h5 (natV 3) WeightReturn5.sourceAction WeightReturn5.sourceEnv
    WeightReturn5.sourceTail WeightReturn5.source_frame hc5 hr5
  obtain ⟨s7,hr6,h7⟩ := WeightReturn6.transport NR FR R C₀ C live framed before after old old' s6 h6
  have hc7 : s7.ctl = .abr (.ret (natV 3)) := step_return_unwind_control P.F NR FR R live framed
    before after old old' WeightReturn6.input s6 s7 C C h6 (natV 3) WeightReturn6.sourceAction WeightReturn6.sourceEnv
    WeightReturn6.sourceTail WeightReturn6.source_frame hc6 hr6
  obtain ⟨s8,hr7,h8⟩ := WeightReturn7.transport NR FR R C₀ C live framed before after old old' s7 h7
  have hc8 : s8.ctl = .ret (natV 3) := step_return_unwind_control P.F NR FR R live framed
    before after old old' WeightReturn7.input s7 s8 C C h7 (natV 3) WeightReturn7.sourceAction WeightReturn7.sourceEnv
    WeightReturn7.sourceTail WeightReturn7.source_frame hc7 hr7
  obtain ⟨s9,hr8,h9⟩ := WeightDeclare8.transport NR FR R C₀ C live framed before after old old' s8 h8
  have hc9 := step_declaration_control P.F NR FR R live framed before after old old' WeightDeclare8.input s8 s9 C C h8
    (natV 3) WeightDeclare8.sourceKind WeightDeclare8.sourcePattern WeightDeclare8.sourceRest WeightDeclare8.sourceEnv
    WeightDeclare8.sourceTail WeightDeclare8.source_frame hc8 WeightDeclare8.source_kind hr8
  have hpat : WeightDeclare8.sourcePattern = .id WeightInitialize9.sourceName := by host_kernel_rfl
  have henv : WeightDeclare8.sourceEnv = WeightInitialize9.sourceEnv := by host_kernel_rfl
  have hkind : WeightDeclare8.sourceKind = WeightInitialize9.sourceKind := by host_kernel_rfl
  rw [hpat,henv,hkind] at hc9
  have hn9 : s9.next = s.next := h.target_next_eq h9 (by host_kernel_rfl)
  have hb9 : s9.next ≤ 2^64 := hn9 ▸ bound
  obtain ⟨result,hr9,h10⟩ := WeightInitialize9.transport NR FR R C₀ C live framed before after old old' s9 h9 hb9
  have hlookup : lookupEnv WeightInitialize9.sourceName (R.env WeightInitialize9.sourceEnv) =
      some (R.a WeightInitialize9.sourceAddress) := by rw [lookupEnv_map,WeightInitialize9.source_lookup]; rfl
  have fixedRun : interpC (step P.F s9).run C =
      some (((s9.setCell (R.a WeightInitialize9.sourceAddress) (natV 3)).ret .undef),C) := by
    rw [step_bind_init_eq P.F s9 WeightInitialize9.sourceName (natV 3) (R.env WeightInitialize9.sourceEnv)
      WeightInitialize9.sourceKind (R.a WeightInitialize9.sourceAddress) hc9 hlookup]
    rfl
  have he := congrArg Prod.fst (Option.some.inj (hr9.symm.trans fixedRun))
  dsimp only at he
  have ha : live WeightInitialize9.sourceAddress := by
    have hl := h9.controlLive
    change treeSupport live (Encode.ctl WeightInitialize9.input.ctl) at hl
    rw [WeightInitialize9.source_control] at hl
    exact env_lookup_live _ _ _ hl.2.2.1 WeightInitialize9.source_lookup
  have haddress : R.a WeightInitialize9.sourceAddress < 2^64 := Nat.lt_of_lt_of_le (h9.heap.targetBound _ ha) hb9
  have hcell : result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) := by
    rw [he]
    simp only [St.ret,St.setCell,PTrie.get_set_u64 _ _ _ haddress,ite_true]
  have hsourceAddress : WeightInitialize9.sourceAddress = WeightInitialize9.sourceAddress := by host_kernel_rfl
  rw [hsourceAddress] at hcell
  have hh3 := step_argument_heap_from_source P.F NR FR R live framed before after old old' WeightCollect2.input s2 s3 C C h2
    WeightCollect2.sourceValue WeightCollect2.sourceKind WeightCollect2.sourceFunction WeightCollect2.sourceThis WeightCollect2.sourceAcc WeightCollect2.sourceRest
    WeightCollect2.sourceEnv WeightCollect2.sourceTail WeightCollect2.source_control WeightCollect2.source_frame (by decide) hr2
  have hh5 := step_return_exit_heap P.F NR FR R live framed before after old old' WeightReturn4.input s4 s5 C C h4
    WeightReturn4.sourceValue WeightReturn4.sourceAction WeightReturn4.sourceEnv WeightReturn4.sourceTail WeightReturn4.source_control WeightReturn4.source_frame hr4
  have hh6 := step_return_unwind_heap P.F NR FR R live framed before after old old' WeightReturn5.input s5 s6 C C h5
    WeightReturn5.sourceValue WeightReturn5.sourceAction WeightReturn5.sourceEnv WeightReturn5.sourceTail WeightReturn5.source_control WeightReturn5.source_frame hr5
  have hh7 := step_return_unwind_heap P.F NR FR R live framed before after old old' WeightReturn6.input s6 s7 C C h6
    WeightReturn6.sourceValue WeightReturn6.sourceAction WeightReturn6.sourceEnv WeightReturn6.sourceTail WeightReturn6.source_control WeightReturn6.source_frame hr6
  have hh8 := step_return_unwind_heap P.F NR FR R live framed before after old old' WeightReturn7.input s7 s8 C C h7
    WeightReturn7.sourceValue WeightReturn7.sourceAction WeightReturn7.sourceEnv WeightReturn7.sourceTail WeightReturn7.source_control WeightReturn7.source_frame hr7
  have hh9 := step_declaration_value_heap P.F NR FR R live framed before after old old' WeightDeclare8.input s8 s9 C C h8
    WeightDeclare8.sourceValue WeightDeclare8.sourceKind WeightDeclare8.sourcePattern WeightDeclare8.sourceRest WeightDeclare8.sourceEnv WeightDeclare8.sourceTail
    WeightDeclare8.source_control WeightDeclare8.source_frame WeightDeclare8.source_kind hr8
  have heap9 : s9.heap = s.heap := hh9.trans (hh8.trans (hh7.trans (hh6.trans (hh5.trans hh3))))
  have frame : ∀ a, a ≠ R.a WeightInitialize9.sourceAddress → result.heap.get a = s.heap.get a := by
    intro a ha
    have ha' : a ≠ R.a WeightInitialize9.sourceAddress := hsourceAddress.symm ▸ ha
    rw [he]
    simp only [St.ret,St.setCell,PTrie.get_set_u64 _ _ _ haddress,ite_eq_right ha']
    rw [heap9]
  have stack3 := step_argument_done_stack P.F NR FR R live framed before after old old' WeightCollect2.input s2 s3 C C h2
    WeightCollect2.sourceValue WeightCollect2.sourceKind WeightCollect2.sourceFunction WeightCollect2.sourceThis WeightCollect2.sourceAcc WeightCollect2.sourceRest
    WeightCollect2.sourceEnv WeightCollect2.sourceTail WeightCollect2.source_control WeightCollect2.source_frame (by decide) (by host_kernel_rfl) hr2
  have stack4 : s4.stack = s3.stack := rfl
  have stack5 := step_return_exit_stack P.F NR FR R live framed before after old old' WeightReturn4.input s4 s5 C C h4
    WeightReturn4.sourceValue WeightReturn4.sourceAction WeightReturn4.sourceEnv WeightReturn4.sourceTail WeightReturn4.source_control WeightReturn4.source_frame hr4
  have stack6 := step_return_unwind_stack P.F NR FR R live framed before after old old' WeightReturn5.input s5 s6 C C h5
    WeightReturn5.sourceValue WeightReturn5.sourceAction WeightReturn5.sourceEnv WeightReturn5.sourceTail WeightReturn5.source_control WeightReturn5.source_frame hr5
  have stack7 := step_return_unwind_stack P.F NR FR R live framed before after old old' WeightReturn6.input s6 s7 C C h6
    WeightReturn6.sourceValue WeightReturn6.sourceAction WeightReturn6.sourceEnv WeightReturn6.sourceTail WeightReturn6.source_control WeightReturn6.source_frame hr6
  have stack8 := step_return_unwind_stack P.F NR FR R live framed before after old old' WeightReturn7.input s7 s8 C C h7
    WeightReturn7.sourceValue WeightReturn7.sourceAction WeightReturn7.sourceEnv WeightReturn7.sourceTail WeightReturn7.source_control WeightReturn7.source_frame hr7
  have stack9 := step_declaration_value_stack P.F NR FR R live framed before after old old' WeightDeclare8.input s8 s9 C C h8
    WeightDeclare8.sourceValue WeightDeclare8.sourceKind WeightDeclare8.sourcePattern WeightDeclare8.sourceRest WeightDeclare8.sourceEnv WeightDeclare8.sourceTail
    WeightDeclare8.source_control WeightDeclare8.source_frame WeightDeclare8.source_kind hr8
  have stack10 : result.stack = s9.stack := by
    simpa only [St.ret,St.setCell,St.go] using congrArg St.stack he
  have effect3 : s3.stack.drop 0 = s2.stack.drop 1 := by
    simpa only [List.drop_zero,List.drop_one] using stack3
  have suffix3 : s3.stack.drop 8 = s.stack.drop 9 :=
    (stack_drop_extend effect3 8).trans (by rfl)
  have effect4 : s4.stack.drop 0 = s3.stack.drop 0 := by
    simpa only [List.drop_zero,List.drop_one] using stack4
  have suffix4 : s4.stack.drop 8 = s.stack.drop 9 :=
    (stack_drop_extend effect4 8).trans suffix3
  have effect5 : s5.stack.drop 0 = s4.stack.drop 1 := by
    simpa only [List.drop_zero,List.drop_one] using stack5
  have suffix5 : s5.stack.drop 7 = s.stack.drop 9 :=
    (stack_drop_extend effect5 7).trans suffix4
  have effect6 : s6.stack.drop 0 = s5.stack.drop 1 := by
    simpa only [List.drop_zero,List.drop_one] using stack6
  have suffix6 : s6.stack.drop 6 = s.stack.drop 9 :=
    (stack_drop_extend effect6 6).trans suffix5
  have effect7 : s7.stack.drop 0 = s6.stack.drop 1 := by
    simpa only [List.drop_zero,List.drop_one] using stack7
  have suffix7 : s7.stack.drop 5 = s.stack.drop 9 :=
    (stack_drop_extend effect7 5).trans suffix6
  have effect8 : s8.stack.drop 0 = s7.stack.drop 1 := by
    simpa only [List.drop_zero,List.drop_one] using stack8
  have suffix8 : s8.stack.drop 4 = s.stack.drop 9 :=
    (stack_drop_extend effect8 4).trans suffix7
  have effect9 : s9.stack.drop 1 = s8.stack.drop 1 := by
    simpa only [List.drop_zero,List.drop_one] using stack9
  have suffix9 : s9.stack.drop 4 = s.stack.drop 9 :=
    (stack_drop_extend effect9 3).trans suffix8
  have effect10 : result.stack.drop 0 = s9.stack.drop 0 := by
    simpa only [List.drop_zero,List.drop_one] using stack10
  have suffix10 : result.stack.drop 4 = s.stack.drop 9 :=
    (stack_drop_extend effect10 4).trans suffix9
  refine ⟨result,?_,h10,hcell,frame,suffix10⟩
  apply runC_cons P.F 7 s2 s3 result C C C (h2.control.isHalt_eq.trans (by host_kernel_rfl)) hr2
  apply runC_cons P.F 6 s3 s4 result C C C (h3.control.isHalt_eq.trans (by host_kernel_rfl)) hr3
  apply runC_cons P.F 5 s4 s5 result C C C (h4.control.isHalt_eq.trans (by host_kernel_rfl)) hr4
  apply runC_cons P.F 4 s5 s6 result C C C (h5.control.isHalt_eq.trans (by host_kernel_rfl)) hr5
  apply runC_cons P.F 3 s6 s7 result C C C (h6.control.isHalt_eq.trans (by host_kernel_rfl)) hr6
  apply runC_cons P.F 2 s7 s8 result C C C (h7.control.isHalt_eq.trans (by host_kernel_rfl)) hr7
  apply runC_cons P.F 1 s8 s9 result C C C (h8.control.isHalt_eq.trans (by host_kernel_rfl)) hr8
  apply runC_cons P.F 0 s9 result result C C C (h9.control.isHalt_eq.trans (by host_kernel_rfl)) hr9
  rfl

theorem conv_weight_rank_binding (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' WeightCollect2.input s)
    (rank : s.ctl = .ret (.big (Int.ofNat 3)))
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 8 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro4.s93 result ∧
      result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) ∧
      (∀ a, a ≠ R.a WeightInitialize9.sourceAddress → result.heap.get a = s.heap.get a) := by
  obtain ⟨result,run,hresult,rankCell,heap,_⟩ := conv_weight_rank_binding_framed FR R ν₀ ν C₀ C live framed before after old old' s h rank bound
  exact ⟨result,run,hresult,rankCell,heap⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat
