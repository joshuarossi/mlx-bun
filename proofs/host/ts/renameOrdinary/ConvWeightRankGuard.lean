import host.ts.renameOrdinary.ConvWeightRankBinding
import host.ts.RenameRouteHeapFields
import host.ts.RenameRouteDriverMapControl
import host.ts.RenameParametricTests
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
host_transport_binding P.F, P.RestStream.micro0.micro4.s93 to P.RestStream.micro0.micro4.s94 as WeightContinue10
host_transport_preparation P.F, P.RestStream.micro0.micro4.s94 to P.RestStream.micro0.micro4.s95 as WeightBlock11
host_transport_map_control P.F, P.RestStream.micro0.micro4.s95 to P.RestStream.micro0.micro4.s96 as WeightIf12
host_transport_structural P.F, P.RestStream.micro0.micro4.s96 to P.RestStream.micro0.micro4.s97 as WeightBinary13
host_transport_step P.F, P.RestStream.micro0.micro4.s97 to P.RestStream.micro0.micro4.s98 as WeightRank14
host_transport_structural P.F, P.RestStream.micro0.micro4.s98 to P.RestStream.micro0.micro4.s99 as WeightLeft15
host_transport_step P.F, P.RestStream.micro0.micro4.s99 to P.RestStream.micro0.micro5.s0 as WeightZero16
host_transport_map_control P.F, P.RestStream.micro0.micro5.s1 to P.RestStream.micro0.micro5.s2 as WeightGuard18
noncomputable def WeightcomparisonInput : St LSt := P.RestStream.micro0.micro5.s0
noncomputable def WeightcomparisonTail : List Frame := WeightcomparisonInput.stack.tail
theorem Weightcomparison_control : WeightcomparisonInput.ctl = .ret (natV 0) := by host_kernel_rfl
theorem Weightcomparison_frame : WeightcomparisonInput.stack = .e (.binR .seq (natV 3))::WeightcomparisonTail := by host_kernel_rfl
theorem Weightcomparison_post : ({WeightcomparisonInput with stack := WeightcomparisonTail}.ret (.bool false)) = P.RestStream.micro0.micro5.s1 := by host_kernel_rfl

theorem weight_if_frame_length (env : Env) : (WeightIf12.sourceAction.frames env).length = 1 := by host_kernel_rfl

/-- The rank-zero branch is decided from the initialized literal rank and the
actual zero expression. The target guard and unchanged rank cell are derived. -/
theorem conv_weight_rank_guard_framed (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro4.s93 s)
    (rank : s.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3)))) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro5.s2 result ∧
      result.heap = s.heap ∧ result.stack.drop 3 = s.stack.drop 4 := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨s11,hr10,h11⟩ := WeightContinue10.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s12,hr11,h12⟩ := WeightBlock11.transport NR FR R C₀ C live framed before after old old' s11 h11
  obtain ⟨s13,hr12,h13⟩ := WeightIf12.transport NR FR R C₀ C live framed before after old old' s12 h12
  obtain ⟨s14,hr13,h14⟩ := WeightBinary13.transport NR FR R C₀ C live framed before after old old' s13 h13
  have hh11 := step_declaration_next_heap P.F NR FR R live framed before after old old'
    WeightContinue10.input s s11 C C h WeightContinue10.sourceValue WeightContinue10.sourceKind WeightContinue10.sourceRest
    WeightContinue10.sourceEnv WeightContinue10.sourceTail WeightContinue10.source_control WeightContinue10.source_frame hr10
  have hh12 := step_block_next_heap P.F NR FR R live framed before after old old' WeightBlock11.input s11 s12 C C h11
    WeightBlock11.sourceValue WeightBlock11.sourceStatement WeightBlock11.sourceRest WeightBlock11.sourceEnv WeightBlock11.sourceTail
    WeightBlock11.source_control WeightBlock11.source_frame hr11
  have hh13 := step_statement_heap P.F NR FR R live framed before after old old' WeightIf12.input s12 s13 C C h12
    WeightIf12.sourceAction WeightIf12.sourceEnv WeightIf12.source_control hr12
  have hh14 := step_descent_heap_from_source P.F NR FR R live framed before after old old' WeightBinary13.input s13 s14 C C h13
    WeightBinary13.descent WeightBinary13.sourceEnv WeightBinary13.source_control hr13
  have hh14all : s14.heap = s.heap := hh14.trans (hh13.trans (hh12.trans hh11))
  have addr : WeightRank14.address = WeightInitialize9.sourceAddress := by host_kernel_rfl
  have hc14 := (h14.control_view WeightRank14.source_control).ev_view
  have hl14 : lookupEnv WeightRank14.sourceName (R.env WeightRank14.sourceEnv) = some (R.a WeightRank14.address) := by
    rw [lookupEnv_map,WeightRank14.source_lookup]; rfl
  have hp14 : s14.heap.get (R.a WeightRank14.address) = some (.cell (some (natV 3))) := by rw [hh14all,addr]; exact rank
  obtain ⟨v14,hr14,h15,_⟩ := WeightRank14.transport NR FR R C₀ C live framed before after old old' s14 h14
  have fixed14 : interpC (step P.F s14).run C = some (s14.ret (natV 3),C) := by
    rw [step_variable_eq P.F s14 WeightRank14.sourceName (R.env WeightRank14.sourceEnv) (R.a WeightRank14.address)
      (natV 3) hc14 hl14 hp14]; rfl
  have hv14 : v14 = natV 3 := by
    have he := congrArg (fun p : St LSt × CSrv => p.1.ctl) (Option.some.inj (hr14.symm.trans fixed14))
    exact Ctl.ret.inj he
  subst v14
  let s15 := s14.ret (natV 3)
  obtain ⟨s16,hr15,h16⟩ := WeightLeft15.transport NR FR R C₀ C live framed before after old old' s15 h15
  obtain ⟨fs,hf16,_,hh16⟩ := step_binary_left_saved_fields P.F NR FR R live framed before after old old'
    WeightLeft15.input s15 s16 C C h15 (natV 3) WeightLeft15.sourceOp WeightLeft15.sourceRight WeightLeft15.sourceEnv
    WeightLeft15.sourceTail WeightLeft15.source_frame rfl hr15
  have op15 : WeightLeft15.sourceOp = .seq := by host_kernel_rfl
  rw [op15] at hf16
  obtain ⟨hr16,h17,_,_⟩ := WeightZero16.transport FR R ν₀ ν C₀ C live framed before after old old' s16 h16
  let s17 := s16.ret WeightZero16.sourceValue
  have zero : WeightZero16.sourceValue = natV 0 := by host_kernel_rfl
  have hc17 : s17.ctl = .ret (natV 0) := congrArg Ctl.ret zero
  have hf17 : s17.stack = .e (.binR .seq (natV 3))::fs := hf16
  have nonzero : F64.test .eq (F64.ofNat 3) (F64.ofNat 0) = false := by decide +kernel
  obtain ⟨_,hr17,h18raw⟩ := step_comparison_roles Host.Load.ffi FR R ν₀ ν C₀ C live framed before after old old'
    WeightcomparisonInput s17 h17 .seq (.lit (F64.ofNat 3)) (.lit (F64.ofNat 3)) (.lit (F64.ofNat 0)) (.lit (F64.ofNat 0))
    (.lit (F64.ofNat 3)) (.lit (F64.ofNat 0)) WeightcomparisonTail fs
    (NumRole.literal ν₀ ν C₀ C _) (NumRole.literal ν₀ ν C₀ C _)
    Weightcomparison_control hc17 Weightcomparison_frame hf17 false nonzero nonzero
  let s18 := ({s17 with stack := fs}.ret (.bool false))
  have h18 : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s1 s18 := Weightcomparison_post ▸ h18raw
  obtain ⟨result,hr18,h19⟩ := WeightGuard18.transport NR FR R C₀ C live framed before after old old' s18 h18
  have hh19 := step_if_heap P.F NR FR R live framed before after old old' WeightGuard18.input s18 result C C h18
    WeightGuard18.sourceGuard WeightGuard18.sourceYes WeightGuard18.sourceNo WeightGuard18.sourceEnv WeightGuard18.sourceTail
    WeightGuard18.source_control WeightGuard18.source_frame hr18
  have hh : result.heap = s.heap := hh19.trans (hh16.trans hh14all)
  have stack11 := step_declaration_done_stack P.F NR FR R live framed before after old old' WeightContinue10.input s s11 C C h
    WeightContinue10.sourceValue WeightContinue10.sourceKind WeightContinue10.sourceRest WeightContinue10.sourceEnv WeightContinue10.sourceTail
    WeightContinue10.source_control WeightContinue10.source_frame (by host_kernel_rfl) hr10
  have stack12 := step_block_next_stack P.F NR FR R live framed before after old old' WeightBlock11.input s11 s12 C C h11
    WeightBlock11.sourceValue WeightBlock11.sourceStatement WeightBlock11.sourceRest WeightBlock11.sourceEnv WeightBlock11.sourceTail
    WeightBlock11.source_control WeightBlock11.source_frame hr11
  have stack13 := step_statement_stack P.F NR FR R live framed before after old old' WeightIf12.input s12 s13 C C h12
    WeightIf12.sourceAction WeightIf12.sourceEnv WeightIf12.source_control hr12
  have stack14 := step_descent_stack P.F NR FR R live framed before after old old' WeightBinary13.input s13 s14 C C h13
    WeightBinary13.descent WeightBinary13.sourceEnv WeightBinary13.source_control hr13
  have stack15 : s15.stack = s14.stack := rfl
  have stack16 := step_binary_left_stack_from_source P.F NR FR R live framed before after old old' WeightLeft15.input s15 s16 C C h15
    WeightLeft15.sourceValue WeightLeft15.sourceOp WeightLeft15.sourceRight WeightLeft15.sourceEnv WeightLeft15.sourceTail
    WeightLeft15.source_control WeightLeft15.source_frame hr15
  have stack17 : s17.stack = s16.stack := rfl
  have stack18 : s18.stack = s17.stack.tail := by rw [hf17]; rfl
  have stack19 := step_if_stack P.F NR FR R live framed before after old old' WeightGuard18.input s18 result C C h18
    WeightGuard18.sourceGuard WeightGuard18.sourceYes WeightGuard18.sourceNo WeightGuard18.sourceEnv WeightGuard18.sourceTail
    WeightGuard18.source_control WeightGuard18.source_frame hr18
  have effect11 : s11.stack.drop 0 = s.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack11)
  have suffix11 : s11.stack.drop 3 = s.stack.drop 4 :=
    (stack_drop_extend effect11 3).trans (by rfl)
  have effect12 : s12.stack.drop 1 = s11.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack12)
  have suffix12 : s12.stack.drop 3 = s.stack.drop 4 :=
    (stack_drop_extend effect12 2).trans suffix11
  have effect13 : s13.stack.drop 1 = s12.stack.drop 0 := by
    rw [stack13]
    exact List.drop_left' (weight_if_frame_length (R.env WeightIf12.sourceEnv))
  have suffix13 : s13.stack.drop 4 = s.stack.drop 4 :=
    (stack_drop_extend effect13 3).trans suffix12
  have effect14 : s14.stack.drop 1 = s13.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (congrArg (List.drop 1) stack14)
  have suffix14 : s14.stack.drop 5 = s.stack.drop 4 :=
    (stack_drop_extend effect14 4).trans suffix13
  have effect15 : s15.stack.drop 0 = s14.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack15)
  have suffix15 : s15.stack.drop 5 = s.stack.drop 4 :=
    (stack_drop_extend effect15 5).trans suffix14
  have effect16 : s16.stack.drop 1 = s15.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack16)
  have suffix16 : s16.stack.drop 5 = s.stack.drop 4 :=
    (stack_drop_extend effect16 4).trans suffix15
  have effect17 : s17.stack.drop 0 = s16.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack17)
  have suffix17 : s17.stack.drop 5 = s.stack.drop 4 :=
    (stack_drop_extend effect17 5).trans suffix16
  have effect18 : s18.stack.drop 0 = s17.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack18)
  have suffix18 : s18.stack.drop 4 = s.stack.drop 4 :=
    (stack_drop_extend effect18 4).trans suffix17
  have effect19 : result.stack.drop 0 = s18.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack19)
  have suffix19 : result.stack.drop 3 = s.stack.drop 4 :=
    (stack_drop_extend effect19 3).trans suffix18
  refine ⟨result,?_,h19,hh,suffix19⟩
  apply runC_cons P.F 8 s s11 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr10
  apply runC_cons P.F 7 s11 s12 result C C C (h11.control.isHalt_eq.trans (by host_kernel_rfl)) hr11
  apply runC_cons P.F 6 s12 s13 result C C C (h12.control.isHalt_eq.trans (by host_kernel_rfl)) hr12
  apply runC_cons P.F 5 s13 s14 result C C C (h13.control.isHalt_eq.trans (by host_kernel_rfl)) hr13
  apply runC_cons P.F 4 s14 s15 result C C C (h14.control.isHalt_eq.trans (by host_kernel_rfl)) hr14
  apply runC_cons P.F 3 s15 s16 result C C C (h15.control.isHalt_eq.trans (by host_kernel_rfl)) hr15
  apply runC_cons P.F 2 s16 s17 result C C C (h16.control.isHalt_eq.trans (by host_kernel_rfl)) hr16
  apply runC_cons P.F 1 s17 s18 result C C C (h17.control.isHalt_eq.trans (by host_kernel_rfl)) hr17
  apply runC_cons P.F 0 s18 result result C C C (h18.control.isHalt_eq.trans (by host_kernel_rfl)) hr18
  rfl

theorem conv_weight_rank_guard (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro4.s93 s)
    (rank : s.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3)))) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro5.s2 result ∧
      result.heap = s.heap := by
  obtain ⟨result,run,hresult,heap,_⟩ := conv_weight_rank_guard_framed FR R ν₀ ν C₀ C live framed before after old old' s h rank
  exact ⟨result,run,hresult,heap⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat
