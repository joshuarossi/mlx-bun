import host.ts.renameOrdinary.WeightShapeSteps
import host.ts.RenameParameterEffects
import host.ts.RenameClosureEffects
import host.ts.RenameRouteReadFields
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteArgumentFields
import host.ts.RenameParametricRankNative
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem getter_body_no_cells : blockNames GetterBody29.sourceBody = [] := by host_kernel_rfl

theorem getter_body_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s12 s)
    (bound : s.next ≤ 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s13 result ∧ result.heap = s.heap := by
  have hb : s.next + (blockNames GetterBody29.sourceBody).length ≤ 2^64 := by rw [getter_body_no_cells]; exact bound
  obtain ⟨result,hr,hs⟩ := GetterBody29.transport NR FR R C₀ C live framed before after old old' s h hb
  change interpC (step P.F s).run C = some (result,C) at hr
  have hs' : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s13 result := by
    simp only [getter_body_no_cells,CellsLive] at hs
    exact hs
  obtain ⟨v,hc,_⟩ := (h.control_view GetterBody29.source_control).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view GetterBody29.source_frame
  obtain ⟨args,hft,_⟩ := hfr.params_view
  rw [hft] at hf
  have exactRun := hr
  rw [step_parameter_body_eq P.F s v GetterBody29.sourceName GetterBody29.sourceParams GetterBody29.sourceBody
    args (R.env GetterBody29.sourceEnv) fs hc hf] at exactRun
  have he := congrArg Prod.fst (Option.some.inj exactRun)
  dsimp only at he
  have hh := congrArg St.heap he
  have inert : (enterBlock {s with stack := fs} GetterBody29.sourceBody (R.env GetterBody29.sourceEnv)).heap = s.heap := by
    change (hoist {s with stack := fs} GetterBody29.sourceBody (R.env GetterBody29.sourceEnv)).2.heap = s.heap
    rw [hoist_inert_eq _ _ _ GetterBody29.source_hoist,getter_body_no_cells]
    rfl
  exact ⟨result,hr,hs',hh.symm.trans inert⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def GetterLive (live : Nat → Prop) : Nat → Prop :=
  ClosureLive live EnterGetter28.input.next EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceFunction

theorem getter_next : P.RestStream.micro0.micro5.s12.next = P.RestStream.micro0.micro5.s11.next+2 := by host_kernel_rfl

theorem getter_entry_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s11 s)
    (bound : s.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64) :
    ∃ result, runC P.F 2 s C = some (result,C) ∧
      StateR NR FR R (GetterLive live) framed before after old old' P.RestStream.micro0.micro5.s13 result ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) ∧ result.stack.drop 8 = s.stack.drop 5 := by
  obtain ⟨s29,hr28,h29⟩ := EnterGetter28.transport NR FR R C₀ C live framed before after old old' s h bound
  have hn29 : s29.next = s.next+2 := h.target_next_add h29 2 getter_next
  have hb29 : s29.next ≤ 2^64 := by rw [hn29]; omega
  obtain ⟨result,hr29,h30,hh30⟩ := getter_body_transport NR FR R C₀ C (GetterLive live) framed before after old old' s29 h29 hb29
  have hh29 := step_closure_heap_below P.F NR FR R live framed before after old old' EnterGetter28.input s s29 C C h
    EnterGetter28.address EnterGetter28.object EnterGetter28.sourceFunction EnterGetter28.sourceEnv
    EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceThis EnterGetter28.sourceArgs
    EnterGetter28.source_control EnterGetter28.source_heap EnterGetter28.source_kind bound hr28
  obtain ⟨_,_,stack29⟩ := step_closure_stack_prefix P.F NR FR R live framed before after old old' EnterGetter28.input s s29 C C h
    EnterGetter28.address EnterGetter28.object EnterGetter28.sourceFunction EnterGetter28.sourceEnv EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceThis EnterGetter28.sourceArgs
    EnterGetter28.source_control EnterGetter28.source_heap EnterGetter28.source_kind hr28
  obtain ⟨_,stack30⟩ := step_parameter_body_stack_prefix P.F NR FR R (GetterLive live) framed before after old old' GetterBody29.input s29 result C C h29
    GetterBody29.sourceValue GetterBody29.sourceName GetterBody29.sourceParams GetterBody29.sourceBody GetterBody29.sourceArgs GetterBody29.sourceEnv GetterBody29.sourceTail
    GetterBody29.source_control GetterBody29.source_frame GetterBody29.source_hoist hr29
  have effect29 : s29.stack.drop 2 = s.stack := by simpa only [List.drop_succ_cons,List.drop_zero] using congrArg (List.drop 2) stack29
  have effect30 : result.stack.drop 2 = s29.stack.drop 1 := by simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one] using congrArg (List.drop 2) stack30
  have suffix29 : s29.stack.drop 7 = s.stack.drop 5 := stack_drop_extend effect29 5
  have suffix30 : result.stack.drop 8 = s.stack.drop 5 := (stack_drop_extend effect30 6).trans suffix29
  refine ⟨result,?_,h30,?_,suffix30⟩
  · apply runC_cons P.F 1 s s29 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr28
    apply runC_cons P.F 0 s29 result result C C C (h29.control.isHalt_eq.trans (by host_kernel_rfl)) hr29
    rfl
  · intro a ha
    rw [hh30]
    exact hh29 a ha
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The actual shape call evaluates its namespace method and receiver before
entering Array.handle. Every old heap field is unchanged through this prefix. -/
theorem shape_getter_preparation (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s2 s) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s11 result ∧
      result.heap = s.heap ∧ result.stack.drop 5 = s.stack.drop 3 := by
  obtain ⟨s20,hr19,h20⟩ := Block19.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s21,hr20,h21⟩ := Declaration20.transport NR FR R C₀ C live framed before after old old' s20 h20
  obtain ⟨s22,hr21,h22⟩ := ShapeMethod21.transport NR FR R C₀ C live framed before after old old' s21 h21
  obtain ⟨v22,hr22,h23,_⟩ := NativeNamespace22.transport NR FR R C₀ C live framed before after old old' s22 h22
  let s23 := s22.ret v22
  obtain ⟨s24,hr23,h24⟩ := ShapeLookup23.transport NR FR R C₀ C live framed before after old old' s23 h23
  obtain ⟨s25,hr24,h25⟩ := ShapeCallee24.transport NR FR R C₀ C live framed before after old old' s24 h24
  obtain ⟨s26,hr25,h26⟩ := HandleMember25.transport NR FR R C₀ C live framed before after old old' s25 h25
  obtain ⟨s27,hr26,h27⟩ := This26.transport NR FR R C₀ C live framed before after old old' s26 h26
  obtain ⟨result,hr27,h28⟩ := HandleGetter27.transport NR FR R C₀ C live framed before after old old' s27 h27
  have hh20 := step_block_next_heap P.F NR FR R live framed before after old old' Block19.input s s20 C C h
    Block19.sourceValue Block19.sourceStatement Block19.sourceRest Block19.sourceEnv Block19.sourceTail
    Block19.source_control Block19.source_frame hr19
  have hh21 := step_statement_heap P.F NR FR R live framed before after old old' Declaration20.input s20 s21 C C h20
    Declaration20.sourceAction Declaration20.sourceEnv Declaration20.source_control hr20
  have hh22 := step_method_descent_heap P.F NR FR R live framed before after old old' ShapeMethod21.input s21 s22 C₀ C C h21
    ShapeMethod21.sourceExpression ShapeMethod21.sourceName ShapeMethod21.sourceArgs ShapeMethod21.sourceEnv
    ShapeMethod21.sourceOptObject ShapeMethod21.sourceOptCall ShapeMethod21.source_control hr21
  have hh24 := step_method_data_heap P.F NR FR R live framed before after old old' ShapeLookup23.input s23 s24 C C h23
    ShapeLookup23.sourceAddress ShapeLookup23.sourceObject ShapeLookup23.sourceName ShapeLookup23.sourceArgs ShapeLookup23.sourceEnv
    ShapeLookup23.sourceOptObject ShapeLookup23.sourceOptCall ShapeLookup23.sourceMethod ShapeLookup23.sourceWritable
    ShapeLookup23.sourceEnumerable ShapeLookup23.sourceTail ShapeLookup23.source_control ShapeLookup23.source_frame
    ShapeLookup23.source_heap ShapeLookup23.source_kind ShapeLookup23.source_property hr23
  have hh25 := step_callStart_heap P.F NR FR R live framed before after old old' ShapeCallee24.input s24 s25 C C h24
    ShapeCallee24.sourceMode ShapeCallee24.sourceAddress ShapeCallee24.sourceThis ShapeCallee24.sourceArgs ShapeCallee24.sourceEnv
    ShapeCallee24.sourceTail ShapeCallee24.source_control ShapeCallee24.source_frame hr24
  have hh26 := step_descent_heap_from_source P.F NR FR R live framed before after old old' HandleMember25.input s25 s26 C C h25
    HandleMember25.descent HandleMember25.sourceEnv HandleMember25.source_control hr25
  have hh27 := step_this_heap_from_source P.F NR FR R live framed before after old old' This26.input s26 s27 C₀ C C h26
    This26.sourceEnv This26.sourceAddress This26.sourceValue This26.source_control This26.source_lookup This26.source_cell hr26
  have hh28 := HandleGetter27.heap_frame NR FR R C₀ C C live framed before after old old' s27 result h27 hr27
  have hh : result.heap = s.heap := hh28.trans (hh27.trans (hh26.trans (hh25.trans (hh24.trans (hh22.trans (hh21.trans hh20))))))
  have stack20 := step_block_next_stack P.F NR FR R live framed before after old old' Block19.input s s20 C C h
    Block19.sourceValue Block19.sourceStatement Block19.sourceRest Block19.sourceEnv Block19.sourceTail
    Block19.source_control Block19.source_frame hr19
  have effect20 : s20.stack.drop 1 = s.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack20)
  have suffix20 : s20.stack.drop 3 = s.stack.drop 3 :=
    (stack_drop_extend effect20 2).trans (by rfl)
  have stack21 := step_statement_stack P.F NR FR R live framed before after old old' Declaration20.input s20 s21 C C h20
    Declaration20.sourceAction Declaration20.sourceEnv Declaration20.source_control hr20
  have effect21 : s21.stack.drop 1 = s20.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,Declaration20.sourceAction,StatementAction.frames,List.cons_append,List.nil_append] using (congrArg (List.drop 1) stack21)
  have suffix21 : s21.stack.drop 4 = s.stack.drop 3 :=
    (stack_drop_extend effect21 3).trans suffix20
  have stack22 := step_method_descent_stack P.F NR FR R live framed before after old old' ShapeMethod21.input s21 s22 C₀ C C h21
    ShapeMethod21.sourceExpression ShapeMethod21.sourceName ShapeMethod21.sourceArgs ShapeMethod21.sourceEnv
    ShapeMethod21.sourceOptObject ShapeMethod21.sourceOptCall ShapeMethod21.source_control hr21
  have effect22 : s22.stack.drop 1 = s21.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack22)
  have suffix22 : s22.stack.drop 5 = s.stack.drop 3 :=
    (stack_drop_extend effect22 4).trans suffix21
  have stack23 : s23.stack = s22.stack := rfl
  have effect23 : s23.stack.drop 0 = s22.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack23)
  have suffix23 : s23.stack.drop 5 = s.stack.drop 3 :=
    (stack_drop_extend effect23 5).trans suffix22
  have stack24 := step_method_data_stack P.F NR FR R live framed before after old old' ShapeLookup23.input s23 s24 C C h23
    ShapeLookup23.sourceAddress ShapeLookup23.sourceObject ShapeLookup23.sourceName ShapeLookup23.sourceArgs ShapeLookup23.sourceEnv
    ShapeLookup23.sourceOptObject ShapeLookup23.sourceOptCall ShapeLookup23.sourceMethod ShapeLookup23.sourceWritable
    ShapeLookup23.sourceEnumerable ShapeLookup23.sourceTail ShapeLookup23.source_control ShapeLookup23.source_frame
    ShapeLookup23.source_heap ShapeLookup23.source_kind ShapeLookup23.source_property hr23
  have effect24 : s24.stack.drop 1 = s23.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack24)
  have suffix24 : s24.stack.drop 5 = s.stack.drop 3 :=
    (stack_drop_extend effect24 4).trans suffix23
  have stack25 := step_callStart_expression_stack P.F NR FR R live framed before after old old' ShapeCallee24.input s24 s25 C C h24
    ShapeCallee24.sourceMode ShapeCallee24.sourceAddress ShapeCallee24.sourceThis ShapeCallee24.sourceArgs ShapeCallee24.sourceEnv
    ShapeCallee24.sourceTail ShapeCallee24.source_control ShapeCallee24.source_frame (match ShapeCallee24.sourceArgs with | .expr e::_ => e | _ => .lit .null) ShapeCallee24.sourceArgs.tail (by host_kernel_rfl) hr24
  have effect25 : s25.stack.drop 1 = s24.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack25)
  have suffix25 : s25.stack.drop 5 = s.stack.drop 3 :=
    (stack_drop_extend effect25 4).trans suffix24
  have stack26 := step_descent_stack P.F NR FR R live framed before after old old' HandleMember25.input s25 s26 C C h25
    HandleMember25.descent HandleMember25.sourceEnv HandleMember25.source_control hr25
  have effect26 : s26.stack.drop 1 = s25.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (congrArg (List.drop 1) stack26)
  have suffix26 : s26.stack.drop 6 = s.stack.drop 3 :=
    (stack_drop_extend effect26 5).trans suffix25
  have stack27 := step_this_stack_from_source P.F NR FR R live framed before after old old' This26.input s26 s27 C₀ C C h26
    This26.sourceEnv This26.sourceAddress This26.sourceValue This26.source_control This26.source_lookup This26.source_cell hr26
  have effect27 : s27.stack.drop 0 = s26.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack27)
  have suffix27 : s27.stack.drop 6 = s.stack.drop 3 :=
    (stack_drop_extend effect27 6).trans suffix26
  have stack28 := step_member_lookup_stack P.F NR FR R live framed before after old old' HandleGetter27.input s27 result C₀ C C h27
    HandleGetter27.sourceAddress HandleGetter27.sourceName (some HandleGetter27.sourceProperty) HandleGetter27.sourceTail HandleGetter27.source_control HandleGetter27.source_frame HandleGetter27.source_path hr27
  have effect28 : result.stack.drop 0 = s27.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack28)
  have suffix28 : result.stack.drop 5 = s.stack.drop 3 :=
    (stack_drop_extend effect28 5).trans suffix27
  refine ⟨result,?_,h28,hh,suffix28⟩
  apply runC_cons P.F 8 s s20 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr19
  apply runC_cons P.F 7 s20 s21 result C C C (h20.control.isHalt_eq.trans (by host_kernel_rfl)) hr20
  apply runC_cons P.F 6 s21 s22 result C C C (h21.control.isHalt_eq.trans (by host_kernel_rfl)) hr21
  apply runC_cons P.F 5 s22 s23 result C C C (h22.control.isHalt_eq.trans (by host_kernel_rfl)) hr22
  apply runC_cons P.F 4 s23 s24 result C C C (h23.control.isHalt_eq.trans (by host_kernel_rfl)) hr23
  apply runC_cons P.F 3 s24 s25 result C C C (h24.control.isHalt_eq.trans (by host_kernel_rfl)) hr24
  apply runC_cons P.F 2 s25 s26 result C C C (h25.control.isHalt_eq.trans (by host_kernel_rfl)) hr25
  apply runC_cons P.F 1 s26 s27 result C C C (h26.control.isHalt_eq.trans (by host_kernel_rfl)) hr26
  apply runC_cons P.F 0 s27 result result C C C (h27.control.isHalt_eq.trans (by host_kernel_rfl)) hr27
  rfl
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The real handle getter returns the owned private occurrence unchanged,
through the disposed guard and return frames, into the shape-call argument.
The owned value is supplied only at the initial object field. -/
theorem shape_handle_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s13 s)
    (field : PrivateData s (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
      Handle40.sourceName (.big (Int.ofNat (R.handle 1365)))) :
    ∃ result, runC P.F 16 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s29 result ∧
      callArgument result.ctl 0 = .big (Int.ofNat (R.handle 1365)) ∧ result.heap = s.heap ∧ result.stack.drop 4 = s.stack.drop 8 := by
  obtain ⟨s31,hr30,h31⟩ := GetterBlock30.transport NR FR R C₀ C live framed before after old old' s h
  have hh31 := step_block_next_heap P.F NR FR R live framed before after old old' GetterBlock30.input s s31 C C h
    GetterBlock30.sourceValue GetterBlock30.sourceStatement GetterBlock30.sourceRest GetterBlock30.sourceEnv GetterBlock30.sourceTail
    GetterBlock30.source_control GetterBlock30.source_frame hr30
  have heap31 : s31.heap = s.heap := hh31
  obtain ⟨s32,hr31,h32⟩ := DisposedTest31.transport NR FR R C₀ C live framed before after old old' s31 h31
  have hh32 := step_statement_heap P.F NR FR R live framed before after old old' DisposedTest31.input s31 s32 C C h31 DisposedTest31.sourceAction DisposedTest31.sourceEnv DisposedTest31.source_control hr31
  have heap32 : s32.heap = s.heap := hh32.trans heap31
  obtain ⟨s33,hr32,h33⟩ := PrivateDisposed32.transport NR FR R C₀ C live framed before after old old' s32 h32
  have hh33 := step_private_descent_heap P.F NR FR R live framed before after old old' PrivateDisposed32.input s32 s33 C₀ C C h32
    PrivateDisposed32.sourceObject PrivateDisposed32.sourceName PrivateDisposed32.sourceOptional PrivateDisposed32.sourceEnv PrivateDisposed32.sourceBrand
    PrivateDisposed32.source_control PrivateDisposed32.source_brand hr32
  have heap33 : s33.heap = s.heap := hh33.trans heap32
  obtain ⟨s34,hr33,h34⟩ := This33.transport NR FR R C₀ C live framed before after old old' s33 h33
  have hh34 := step_this_heap_from_source P.F NR FR R live framed before after old old' This33.input s33 s34 C₀ C C h33
    This33.sourceEnv This33.sourceAddress This33.sourceValue This33.source_control This33.source_lookup This33.source_cell hr33
  have heap34 : s34.heap = s.heap := hh34.trans heap33
  obtain ⟨s35,hr34,h35⟩ := Disposed34.transport NR FR R C₀ C live framed before after old old' s34 h34
  have hh35 := Disposed34.heap_frame NR FR R C₀ C C live framed before after old old' s34 s35 h34 hr34
  have heap35 : s35.heap = s.heap := hh35.trans heap34
  obtain ⟨s36,hr35,h36⟩ := DisposedBranch35.transport NR FR R C₀ C live framed before after old old' s35 h35
  have hh36 := step_if_heap P.F NR FR R live framed before after old old' DisposedBranch35.input s35 s36 C C h35
    DisposedBranch35.sourceGuard DisposedBranch35.sourceYes DisposedBranch35.sourceNo DisposedBranch35.sourceEnv DisposedBranch35.sourceTail DisposedBranch35.source_control DisposedBranch35.source_frame hr35
  have heap36 : s36.heap = s.heap := hh36.trans heap35
  obtain ⟨s37,hr36,h37⟩ := GetterBlock36.transport NR FR R C₀ C live framed before after old old' s36 h36
  have hh37 := step_block_next_heap P.F NR FR R live framed before after old old' GetterBlock36.input s36 s37 C C h36
    GetterBlock36.sourceValue GetterBlock36.sourceStatement GetterBlock36.sourceRest GetterBlock36.sourceEnv GetterBlock36.sourceTail
    GetterBlock36.source_control GetterBlock36.source_frame hr36
  have heap37 : s37.heap = s.heap := hh37.trans heap36
  obtain ⟨s38,hr37,h38⟩ := HandleReturn37.transport NR FR R C₀ C live framed before after old old' s37 h37
  have hh38 := step_statement_heap P.F NR FR R live framed before after old old' HandleReturn37.input s37 s38 C C h37
    (.returnExpression HandleReturn37.sourceExpression) HandleReturn37.sourceEnv HandleReturn37.source_control hr37
  have heap38 : s38.heap = s.heap := hh38.trans heap37
  obtain ⟨s39,hr38,h39⟩ := PrivateHandle38.transport NR FR R C₀ C live framed before after old old' s38 h38
  have hh39 := step_private_descent_heap P.F NR FR R live framed before after old old' PrivateHandle38.input s38 s39 C₀ C C h38
    PrivateHandle38.sourceObject PrivateHandle38.sourceName PrivateHandle38.sourceOptional PrivateHandle38.sourceEnv PrivateHandle38.sourceBrand
    PrivateHandle38.source_control PrivateHandle38.source_brand hr38
  have heap39 : s39.heap = s.heap := hh39.trans heap38
  obtain ⟨s40,hr39,h40⟩ := This39.transport NR FR R C₀ C live framed before after old old' s39 h39
  have hh40 := step_this_heap_from_source P.F NR FR R live framed before after old old' This39.input s39 s40 C₀ C C h39
    This39.sourceEnv This39.sourceAddress This39.sourceValue This39.source_control This39.source_lookup This39.source_cell hr39
  have heap40 : s40.heap = s.heap := hh40.trans heap39
  obtain ⟨s41,hr40,h41⟩ := Handle40.transport NR FR R C₀ C live framed before after old old' s40 h40
  have hh41 := Handle40.heap_frame NR FR R C₀ C C live framed before after old old' s40 s41 h40 hr40
  have heap41 : s41.heap = s.heap := hh41.trans heap40
  have fixed40 := field.heap_eq heap40
  have hc41 := (step_private_data_fields P.F NR FR R live framed before after old old' Handle40.input s40 s41 C C h40
    Handle40.sourceAddress Handle40.sourceBrand Handle40.sourceName (.big (Int.ofNat (R.handle 1365))) Handle40.sourceTail
    Handle40.source_control Handle40.source_frame fixed40 hr40).1
  obtain ⟨s42,hr41,h42⟩ := HandleReturn41.transport NR FR R C₀ C live framed before after old old' s41 h41
  have hh42 := step_return_exit_heap P.F NR FR R live framed before after old old' HandleReturn41.input s41 s42 C C h41
    HandleReturn41.sourceValue HandleReturn41.sourceAction HandleReturn41.sourceEnv HandleReturn41.sourceTail HandleReturn41.source_control HandleReturn41.source_frame hr41
  have heap42 : s42.heap = s.heap := hh42.trans heap41
  have hc42 := step_return_exit_control P.F NR FR R live framed before after old old' HandleReturn41.input s41 s42 C C h41
    (.big (Int.ofNat (R.handle 1365))) HandleReturn41.sourceAction HandleReturn41.sourceEnv HandleReturn41.sourceTail HandleReturn41.source_frame hc41 hr41
  obtain ⟨s43,hr42,h43⟩ := HandleReturn42.transport NR FR R C₀ C live framed before after old old' s42 h42
  have hh43 := step_return_unwind_heap P.F NR FR R live framed before after old old' HandleReturn42.input s42 s43 C C h42
    HandleReturn42.sourceValue HandleReturn42.sourceAction HandleReturn42.sourceEnv HandleReturn42.sourceTail HandleReturn42.source_control HandleReturn42.source_frame hr42
  have heap43 : s43.heap = s.heap := hh43.trans heap42
  have hc43 := step_return_unwind_control P.F NR FR R live framed before after old old' HandleReturn42.input s42 s43 C C h42
    (.big (Int.ofNat (R.handle 1365))) HandleReturn42.sourceAction HandleReturn42.sourceEnv HandleReturn42.sourceTail HandleReturn42.source_frame hc42 hr42
  obtain ⟨s44,hr43,h44⟩ := HandleReturn43.transport NR FR R C₀ C live framed before after old old' s43 h43
  have hh44 := step_return_unwind_heap P.F NR FR R live framed before after old old' HandleReturn43.input s43 s44 C C h43
    HandleReturn43.sourceValue HandleReturn43.sourceAction HandleReturn43.sourceEnv HandleReturn43.sourceTail HandleReturn43.source_control HandleReturn43.source_frame hr43
  have heap44 : s44.heap = s.heap := hh44.trans heap43
  have hc44 := step_return_unwind_control P.F NR FR R live framed before after old old' HandleReturn43.input s43 s44 C C h43
    (.big (Int.ofNat (R.handle 1365))) HandleReturn43.sourceAction HandleReturn43.sourceEnv HandleReturn43.sourceTail HandleReturn43.source_frame hc43 hr43
  obtain ⟨s45,hr44,h45⟩ := HandleReturn44.transport NR FR R C₀ C live framed before after old old' s44 h44
  have hh45 := step_return_unwind_heap P.F NR FR R live framed before after old old' HandleReturn44.input s44 s45 C C h44
    HandleReturn44.sourceValue HandleReturn44.sourceAction HandleReturn44.sourceEnv HandleReturn44.sourceTail HandleReturn44.source_control HandleReturn44.source_frame hr44
  have heap45 : s45.heap = s.heap := hh45.trans heap44
  have hc45 := step_return_unwind_control P.F NR FR R live framed before after old old' HandleReturn44.input s44 s45 C C h44
    (.big (Int.ofNat (R.handle 1365))) HandleReturn44.sourceAction HandleReturn44.sourceEnv HandleReturn44.sourceTail HandleReturn44.source_frame hc44 hr44
  obtain ⟨s46,hr45,h46⟩ := ShapeArgument45.transport NR FR R C₀ C live framed before after old old' s45 h45
  have hh46 := step_argument_heap_from_source P.F NR FR R live framed before after old old' ShapeArgument45.input s45 s46 C C h45
    ShapeArgument45.sourceValue ShapeArgument45.sourceKind ShapeArgument45.sourceFunction ShapeArgument45.sourceThis ShapeArgument45.sourceAcc ShapeArgument45.sourceRest
    ShapeArgument45.sourceEnv ShapeArgument45.sourceTail ShapeArgument45.source_control ShapeArgument45.source_frame (by decide) hr45
  have heap46 : s46.heap = s.heap := hh46.trans heap45
  have slot := step_argument_last P.F NR FR R live framed before after old old' ShapeArgument45.input s45 s46 C C h45
    ShapeArgument45.sourceValue (.big (Int.ofNat (R.handle 1365))) ShapeArgument45.sourceFunction ShapeArgument45.sourceThis
    ShapeArgument45.sourceAcc ShapeArgument45.sourceEnv ShapeArgument45.sourceTail ShapeArgument45.source_control hc45
    ShapeArgument45.source_frame hr45
  have accEmpty : ShapeArgument45.sourceAcc.length = 0 := by host_kernel_rfl
  rw [accEmpty] at slot
  have stack31 := step_block_next_stack P.F NR FR R live framed before after old old' GetterBlock30.input s s31 C C h
    GetterBlock30.sourceValue GetterBlock30.sourceStatement GetterBlock30.sourceRest GetterBlock30.sourceEnv GetterBlock30.sourceTail
    GetterBlock30.source_control GetterBlock30.source_frame hr30
  have effect31 : s31.stack.drop 1 = s.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack31)
  have suffix31 : s31.stack.drop 8 = s.stack.drop 8 :=
    (stack_drop_extend effect31 7).trans (by rfl)
  have stack32 := step_statement_stack P.F NR FR R live framed before after old old' DisposedTest31.input s31 s32 C C h31 DisposedTest31.sourceAction DisposedTest31.sourceEnv DisposedTest31.source_control hr31
  have effect32 : s32.stack.drop 1 = s31.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,DisposedTest31.sourceAction,StatementAction.frames,List.cons_append,List.nil_append] using (congrArg (List.drop 1) stack32)
  have suffix32 : s32.stack.drop 9 = s.stack.drop 8 :=
    (stack_drop_extend effect32 8).trans suffix31
  have stack33 := step_private_descent_stack P.F NR FR R live framed before after old old' PrivateDisposed32.input s32 s33 C₀ C C h32
    PrivateDisposed32.sourceObject PrivateDisposed32.sourceName PrivateDisposed32.sourceOptional PrivateDisposed32.sourceEnv PrivateDisposed32.sourceBrand
    PrivateDisposed32.source_control PrivateDisposed32.source_brand hr32
  have effect33 : s33.stack.drop 1 = s32.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack33)
  have suffix33 : s33.stack.drop 10 = s.stack.drop 8 :=
    (stack_drop_extend effect33 9).trans suffix32
  have stack34 := step_this_stack_from_source P.F NR FR R live framed before after old old' This33.input s33 s34 C₀ C C h33
    This33.sourceEnv This33.sourceAddress This33.sourceValue This33.source_control This33.source_lookup This33.source_cell hr33
  have effect34 : s34.stack.drop 0 = s33.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack34)
  have suffix34 : s34.stack.drop 10 = s.stack.drop 8 :=
    (stack_drop_extend effect34 10).trans suffix33
  have stack35 := step_private_read_stack P.F NR FR R C₀ C C live framed before after old old' Disposed34.input s34 s35 h34
    Disposed34.sourceAddress Disposed34.sourceBrand Disposed34.sourceName Disposed34.sourceObject Disposed34.sourceProperty Disposed34.sourceTail Disposed34.source_control Disposed34.source_frame Disposed34.source_heap Disposed34.source_kind Disposed34.source_property hr34
  have effect35 : s35.stack.drop 0 = s34.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack35)
  have suffix35 : s35.stack.drop 9 = s.stack.drop 8 :=
    (stack_drop_extend effect35 9).trans suffix34
  have stack36 := step_if_stack P.F NR FR R live framed before after old old' DisposedBranch35.input s35 s36 C C h35
    DisposedBranch35.sourceGuard DisposedBranch35.sourceYes DisposedBranch35.sourceNo DisposedBranch35.sourceEnv DisposedBranch35.sourceTail DisposedBranch35.source_control DisposedBranch35.source_frame hr35
  have effect36 : s36.stack.drop 0 = s35.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack36)
  have suffix36 : s36.stack.drop 8 = s.stack.drop 8 :=
    (stack_drop_extend effect36 8).trans suffix35
  have stack37 := step_block_next_stack P.F NR FR R live framed before after old old' GetterBlock36.input s36 s37 C C h36
    GetterBlock36.sourceValue GetterBlock36.sourceStatement GetterBlock36.sourceRest GetterBlock36.sourceEnv GetterBlock36.sourceTail
    GetterBlock36.source_control GetterBlock36.source_frame hr36
  have effect37 : s37.stack.drop 1 = s36.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack37)
  have suffix37 : s37.stack.drop 8 = s.stack.drop 8 :=
    (stack_drop_extend effect37 7).trans suffix36
  have stack38 := step_statement_stack P.F NR FR R live framed before after old old' HandleReturn37.input s37 s38 C C h37
    (.returnExpression HandleReturn37.sourceExpression) HandleReturn37.sourceEnv HandleReturn37.source_control hr37
  have effect38 : s38.stack.drop 1 = s37.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (congrArg (List.drop 1) stack38)
  have suffix38 : s38.stack.drop 9 = s.stack.drop 8 :=
    (stack_drop_extend effect38 8).trans suffix37
  have stack39 := step_private_descent_stack P.F NR FR R live framed before after old old' PrivateHandle38.input s38 s39 C₀ C C h38
    PrivateHandle38.sourceObject PrivateHandle38.sourceName PrivateHandle38.sourceOptional PrivateHandle38.sourceEnv PrivateHandle38.sourceBrand
    PrivateHandle38.source_control PrivateHandle38.source_brand hr38
  have effect39 : s39.stack.drop 1 = s38.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack39)
  have suffix39 : s39.stack.drop 10 = s.stack.drop 8 :=
    (stack_drop_extend effect39 9).trans suffix38
  have stack40 := step_this_stack_from_source P.F NR FR R live framed before after old old' This39.input s39 s40 C₀ C C h39
    This39.sourceEnv This39.sourceAddress This39.sourceValue This39.source_control This39.source_lookup This39.source_cell hr39
  have effect40 : s40.stack.drop 0 = s39.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack40)
  have suffix40 : s40.stack.drop 10 = s.stack.drop 8 :=
    (stack_drop_extend effect40 10).trans suffix39
  have stack41 := step_private_read_stack P.F NR FR R C₀ C C live framed before after old old' Handle40.input s40 s41 h40
    Handle40.sourceAddress Handle40.sourceBrand Handle40.sourceName Handle40.sourceObject Handle40.sourceProperty Handle40.sourceTail Handle40.source_control Handle40.source_frame Handle40.source_heap Handle40.source_kind Handle40.source_property hr40
  have effect41 : s41.stack.drop 0 = s40.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack41)
  have suffix41 : s41.stack.drop 9 = s.stack.drop 8 :=
    (stack_drop_extend effect41 9).trans suffix40
  have stack42 := step_return_exit_stack P.F NR FR R live framed before after old old' HandleReturn41.input s41 s42 C C h41
    HandleReturn41.sourceValue HandleReturn41.sourceAction HandleReturn41.sourceEnv HandleReturn41.sourceTail HandleReturn41.source_control HandleReturn41.source_frame hr41
  have effect42 : s42.stack.drop 0 = s41.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,HandleReturn41.sourceAction,StatementAction.frames,List.cons_append,List.nil_append] using (stack42)
  have suffix42 : s42.stack.drop 8 = s.stack.drop 8 :=
    (stack_drop_extend effect42 8).trans suffix41
  have stack43 := step_return_unwind_stack P.F NR FR R live framed before after old old' HandleReturn42.input s42 s43 C C h42
    HandleReturn42.sourceValue HandleReturn42.sourceAction HandleReturn42.sourceEnv HandleReturn42.sourceTail HandleReturn42.source_control HandleReturn42.source_frame hr42
  have effect43 : s43.stack.drop 0 = s42.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,HandleReturn42.sourceAction,StatementAction.frames,List.cons_append,List.nil_append] using (stack43)
  have suffix43 : s43.stack.drop 7 = s.stack.drop 8 :=
    (stack_drop_extend effect43 7).trans suffix42
  have stack44 := step_return_unwind_stack P.F NR FR R live framed before after old old' HandleReturn43.input s43 s44 C C h43
    HandleReturn43.sourceValue HandleReturn43.sourceAction HandleReturn43.sourceEnv HandleReturn43.sourceTail HandleReturn43.source_control HandleReturn43.source_frame hr43
  have effect44 : s44.stack.drop 0 = s43.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,HandleReturn43.sourceAction,StatementAction.frames,List.cons_append,List.nil_append] using (stack44)
  have suffix44 : s44.stack.drop 6 = s.stack.drop 8 :=
    (stack_drop_extend effect44 6).trans suffix43
  have stack45 := step_return_unwind_stack P.F NR FR R live framed before after old old' HandleReturn44.input s44 s45 C C h44
    HandleReturn44.sourceValue HandleReturn44.sourceAction HandleReturn44.sourceEnv HandleReturn44.sourceTail HandleReturn44.source_control HandleReturn44.source_frame hr44
  have effect45 : s45.stack.drop 0 = s44.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,HandleReturn44.sourceAction,StatementAction.frames,List.cons_append,List.nil_append] using (stack45)
  have suffix45 : s45.stack.drop 5 = s.stack.drop 8 :=
    (stack_drop_extend effect45 5).trans suffix44
  have stack46 := step_argument_done_stack P.F NR FR R live framed before after old old' ShapeArgument45.input s45 s46 C C h45
    ShapeArgument45.sourceValue ShapeArgument45.sourceKind ShapeArgument45.sourceFunction ShapeArgument45.sourceThis ShapeArgument45.sourceAcc ShapeArgument45.sourceRest
    ShapeArgument45.sourceEnv ShapeArgument45.sourceTail ShapeArgument45.source_control ShapeArgument45.source_frame (by decide) (by host_kernel_rfl) hr45
  have effect46 : s46.stack.drop 0 = s45.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack46)
  have suffix46 : s46.stack.drop 4 = s.stack.drop 8 :=
    (stack_drop_extend effect46 4).trans suffix45
  refine ⟨s46,?_,h46,slot,heap46,suffix46⟩
  apply runC_cons P.F 15 s s31 s46 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr30
  apply runC_cons P.F 14 s31 s32 s46 C C C (h31.control.isHalt_eq.trans (by host_kernel_rfl)) hr31
  apply runC_cons P.F 13 s32 s33 s46 C C C (h32.control.isHalt_eq.trans (by host_kernel_rfl)) hr32
  apply runC_cons P.F 12 s33 s34 s46 C C C (h33.control.isHalt_eq.trans (by host_kernel_rfl)) hr33
  apply runC_cons P.F 11 s34 s35 s46 C C C (h34.control.isHalt_eq.trans (by host_kernel_rfl)) hr34
  apply runC_cons P.F 10 s35 s36 s46 C C C (h35.control.isHalt_eq.trans (by host_kernel_rfl)) hr35
  apply runC_cons P.F 9 s36 s37 s46 C C C (h36.control.isHalt_eq.trans (by host_kernel_rfl)) hr36
  apply runC_cons P.F 8 s37 s38 s46 C C C (h37.control.isHalt_eq.trans (by host_kernel_rfl)) hr37
  apply runC_cons P.F 7 s38 s39 s46 C C C (h38.control.isHalt_eq.trans (by host_kernel_rfl)) hr38
  apply runC_cons P.F 6 s39 s40 s46 C C C (h39.control.isHalt_eq.trans (by host_kernel_rfl)) hr39
  apply runC_cons P.F 5 s40 s41 s46 C C C (h40.control.isHalt_eq.trans (by host_kernel_rfl)) hr40
  apply runC_cons P.F 4 s41 s42 s46 C C C (h41.control.isHalt_eq.trans (by host_kernel_rfl)) hr41
  apply runC_cons P.F 3 s42 s43 s46 C C C (h42.control.isHalt_eq.trans (by host_kernel_rfl)) hr42
  apply runC_cons P.F 2 s43 s44 s46 C C C (h43.control.isHalt_eq.trans (by host_kernel_rfl)) hr43
  apply runC_cons P.F 1 s44 s45 s46 C C C (h44.control.isHalt_eq.trans (by host_kernel_rfl)) hr44
  apply runC_cons P.F 0 s45 s46 s46 C C C (h45.control.isHalt_eq.trans (by host_kernel_rfl)) hr45
  rfl
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape.ShapeNative
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro5.s29
noncomputable def output : St LSt := P.RestStream.micro0.micro5.s30
noncomputable def functionObject : Obj := match input.heap.get 4636 with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def signature : Nat := match functionObject.kind with
  | .fn (.native (.ffi .symbol) [_,.obj a,_]) => a | _ => 0
noncomputable def returns : Name := match functionObject.kind with
  | .fn (.native (.ffi .symbol) [_,_,.str rt]) => rt | _ => []
noncomputable def signatureObject : Obj := match input.heap.get signature with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
noncomputable def node : Host.Mlx.Ffi.Node := match input.ffi.mlx.node? 1365 with
  | some n => n | _ => ⟨.zeros,[],[],0⟩
theorem source_control : input.ctl = .call (.obj 4636) (.obj 4817) [.big (Int.ofNat 1365)] := by host_kernel_rfl
theorem source_heap : input.heap.get 4636 = some (.obj functionObject) := by host_kernel_rfl
theorem source_kind : functionObject.kind = .fn (.native (.ffi .symbol)
    [.str chars!"mlx_array_shape",.obj signature,.str returns]) := by host_kernel_rfl
theorem source_signature : input.heap.get signature = some (.obj signatureObject) := by host_kernel_rfl
theorem source_types : signatureObject.kind = .array [.str chars!"u64"] := by host_kernel_rfl
theorem source_node : input.ffi.mlx.node? 1365 = some node := by host_kernel_rfl
theorem source_post : finishPointer input input.ffi chars!"mlx_array_shape" [.big (Int.ofNat 1365)]
    (4*1365) 0 = output := by host_kernel_rfl

theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (signatureFrame : ¬ framed signature) (handleLive : H 1365)
    (region : R.region (4*1365) = 4*R.handle 1365)
    (handleRole : (Annotated.Value.handle 1365).Holds ν C R (callArgument s.ctl 0)) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' output result ∧
      result.ctl = .ret (.ptr (.ext (R.region (4*1365))) 0) ∧ result.heap = s.heap ∧ result.stack = s.stack := by
  obtain ⟨_,hr,hs⟩ := step_shape_from_source NR FR R C₀ C ν live framed before after old old' input s h
    NodeRel ObjRel H N tail native 4636 signature 1365 functionObject signatureObject returns (.obj 4817) node
    source_control source_heap source_kind source_signature source_types signatureFrame handleLive source_node region handleRole
  have hs' : StateR NR FR R live framed before after old old' output
      (finishPointer s s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle 1365))] (R.region (4*1365)) 0) := source_post ▸ hs
  exact ⟨_,hr,hs',rfl,rfl,rfl⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape.ShapeNative

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- Shape-pointer binding and real typed-buffer call preparation preserve
all other heap occurrences, including the initialized rank and receiver. -/
theorem shape_pointer_preparation (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s30 s)
    (bound : s.next ≤ 2^64) (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s42 result ∧
      (∀ b, b ≠ R.a PointerBinding48.sourceAddress → result.heap.get b = s.heap.get b) ∧ result.stack.drop 7 = s.stack.drop 4 := by
  obtain ⟨s48,hr47,h48⟩ := PointerDeclaration47.transport NR FR R C₀ C live framed before after old old' s h
  have hh48 := step_declaration_value_heap P.F NR FR R live framed before after old old' PointerDeclaration47.input s s48 C C h
    PointerDeclaration47.sourceValue PointerDeclaration47.sourceKind PointerDeclaration47.sourcePattern PointerDeclaration47.sourceRest PointerDeclaration47.sourceEnv PointerDeclaration47.sourceTail
    PointerDeclaration47.source_control PointerDeclaration47.source_frame PointerDeclaration47.source_kind hr47
  have hb48 : s48.next ≤ 2^64 := (h.target_next_eq h48 (by host_kernel_rfl)) ▸ bound
  obtain ⟨s49,hr48,h49⟩ := PointerBinding48.transport NR FR R C₀ C live framed before after old old' s48 h48 hb48
  have hh49 := step_bind_init_heap_other P.F NR FR R live framed before after old old' PointerBinding48.input s48 s49 C C h48
    PointerBinding48.sourceName PointerBinding48.sourceValue PointerBinding48.sourceEnv PointerBinding48.sourceKind PointerBinding48.sourceAddress PointerBinding48.source_control PointerBinding48.source_lookup hb48 hr48
  obtain ⟨s50,hr49,h50⟩ := PointerDone49.transport NR FR R C₀ C live framed before after old old' s49 h49
  have hh50 := step_declaration_next_heap P.F NR FR R live framed before after old old' PointerDone49.input s49 s50 C C h49
    PointerDone49.sourceValue PointerDone49.sourceKind PointerDone49.sourceRest PointerDone49.sourceEnv PointerDone49.sourceTail PointerDone49.source_control PointerDone49.source_frame hr49
  have heap50 : s50.heap = s49.heap := hh50
  obtain ⟨s51,hr50,h51⟩ := ShapeBlock50.transport NR FR R C₀ C live framed before after old old' s50 h50
  have hh51 := step_block_next_heap P.F NR FR R live framed before after old old' ShapeBlock50.input s50 s51 C C h50
    ShapeBlock50.sourceValue ShapeBlock50.sourceStatement ShapeBlock50.sourceRest ShapeBlock50.sourceEnv ShapeBlock50.sourceTail ShapeBlock50.source_control ShapeBlock50.source_frame hr50
  have heap51 : s51.heap = s49.heap := hh51.trans heap50
  obtain ⟨s52,hr51,h52⟩ := ShapeReturn51.transport NR FR R C₀ C live framed before after old old' s51 h51
  have hh52 := step_statement_heap P.F NR FR R live framed before after old old' ShapeReturn51.input s51 s52 C C h51
    (.returnExpression ShapeReturn51.sourceExpression) ShapeReturn51.sourceEnv ShapeReturn51.source_control hr51
  have heap52 : s52.heap = s49.heap := hh52.trans heap51
  obtain ⟨s53,hr52,h53⟩ := ShapeArray52.transport NR FR R C₀ C live framed before after old old' s52 h52
  have hh53 := step_array_spread_entry_heap P.F NR FR R live framed before after old old' ShapeArray52.input s52 s53 C₀ C C h52
    ShapeArray52.sourceObject ShapeArray52.sourceRest ShapeArray52.sourceEnv ShapeArray52.source_control hr52
  have heap53 : s53.heap = s49.heap := hh53.trans heap52
  obtain ⟨s54,hr53,h54⟩ := TypedCtor53.transport NR FR R C₀ C live framed before after old old' s53 h53
  have hh54 := step_descent_heap_from_source P.F NR FR R live framed before after old old' TypedCtor53.input s53 s54 C C h53
    TypedCtor53.sourceDescent TypedCtor53.sourceEnv TypedCtor53.source_control hr53
  have heap54 : s54.heap = s49.heap := hh54.trans heap53
  obtain ⟨v54,hr54,h55,_⟩ := TypedGlobal54.transport NR FR R C₀ C live framed before after old old' s54 h54 globalLive globalFixed
  let s55 := s54.ret v54
  have hh55 := step_global_heap_from_source P.F NR FR R live framed before after old old' TypedGlobal54.input s54 s55 C₀ C C h54
    TypedGlobal54.sourceName TypedGlobal54.sourceEnv TypedGlobal54.sourceObject TypedGlobal54.sourceValue TypedGlobal54.sourceWritable TypedGlobal54.sourceEnumerable
    TypedGlobal54.source_control TypedGlobal54.source_local TypedGlobal54.source_heap TypedGlobal54.source_kind TypedGlobal54.source_property globalLive globalFixed hr54
  have heap55 : s55.heap = s49.heap := hh55.trans heap54
  obtain ⟨s56,hr55,h56⟩ := TypedCallee55.transport NR FR R C₀ C live framed before after old old' s55 h55
  have hh56 := step_callStart_heap P.F NR FR R live framed before after old old' TypedCallee55.input s55 s56 C C h55
    TypedCallee55.sourceMode TypedCallee55.sourceAddress TypedCallee55.sourceThis TypedCallee55.sourceArgs TypedCallee55.sourceEnv TypedCallee55.sourceTail
    TypedCallee55.source_control TypedCallee55.source_frame hr55
  have heap56 : s56.heap = s49.heap := hh56.trans heap55
  obtain ⟨s57,hr56,h57⟩ := BufferCall56.transport NR FR R C₀ C live framed before after old old' s56 h56
  have hh57 := step_identifier_call_heap P.F NR FR R live framed before after old old' BufferCall56.input s56 s57 C₀ C C h56
    BufferCall56.sourceName BufferCall56.sourceArgs BufferCall56.sourceOptional BufferCall56.sourceEnv BufferCall56.source_control hr56
  have heap57 : s57.heap = s49.heap := hh57.trans heap56
  obtain ⟨v57,hr57,h58,_⟩ := BufferVariable57.transport NR FR R C₀ C live framed before after old old' s57 h57
  let s58 := s57.ret v57
  have hh58 := step_variable_heap_from_source P.F NR FR R live framed before after old old' BufferVariable57.input s57 s58 C₀ C C h57
    BufferVariable57.sourceName BufferVariable57.sourceEnv BufferVariable57.address BufferVariable57.sourceValue BufferVariable57.source_control BufferVariable57.source_lookup BufferVariable57.source_cell hr57
  have heap58 : s58.heap = s49.heap := hh58.trans heap57
  obtain ⟨s59,hr58,h59⟩ := BufferCallee58.transport NR FR R C₀ C live framed before after old old' s58 h58
  have hh59 := step_callStart_heap P.F NR FR R live framed before after old old' BufferCallee58.input s58 s59 C C h58
    (.callee BufferCallee58.sourceOptional) BufferCallee58.sourceAddress .undef BufferCallee58.sourceArgs BufferCallee58.sourceEnv BufferCallee58.sourceTail
    BufferCallee58.source_control BufferCallee58.source_frame hr58
  have heap59 : s59.heap = s49.heap := hh59.trans heap58
  have stack48 := step_declaration_value_stack P.F NR FR R live framed before after old old' PointerDeclaration47.input s s48 C C h
    PointerDeclaration47.sourceValue PointerDeclaration47.sourceKind PointerDeclaration47.sourcePattern PointerDeclaration47.sourceRest PointerDeclaration47.sourceEnv PointerDeclaration47.sourceTail
    PointerDeclaration47.source_control PointerDeclaration47.source_frame PointerDeclaration47.source_kind hr47
  have effect48 : s48.stack.drop 1 = s.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack48)
  have suffix48 : s48.stack.drop 4 = s.stack.drop 4 :=
    (stack_drop_extend effect48 3).trans (by rfl)
  have stack49 := step_bind_init_stack P.F NR FR R live framed before after old old' PointerBinding48.input s48 s49 C C h48
    PointerBinding48.sourceName PointerBinding48.sourceValue PointerBinding48.sourceEnv PointerBinding48.sourceKind PointerBinding48.sourceAddress PointerBinding48.source_control PointerBinding48.source_lookup hr48
  have effect49 : s49.stack.drop 0 = s48.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack49)
  have suffix49 : s49.stack.drop 4 = s.stack.drop 4 :=
    (stack_drop_extend effect49 4).trans suffix48
  have stack50 := step_declaration_done_stack P.F NR FR R live framed before after old old' PointerDone49.input s49 s50 C C h49
    PointerDone49.sourceValue PointerDone49.sourceKind PointerDone49.sourceRest PointerDone49.sourceEnv PointerDone49.sourceTail PointerDone49.source_control PointerDone49.source_frame (by host_kernel_rfl) hr49
  have effect50 : s50.stack.drop 0 = s49.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack50)
  have suffix50 : s50.stack.drop 3 = s.stack.drop 4 :=
    (stack_drop_extend effect50 3).trans suffix49
  have stack51 := step_block_next_stack P.F NR FR R live framed before after old old' ShapeBlock50.input s50 s51 C C h50
    ShapeBlock50.sourceValue ShapeBlock50.sourceStatement ShapeBlock50.sourceRest ShapeBlock50.sourceEnv ShapeBlock50.sourceTail ShapeBlock50.source_control ShapeBlock50.source_frame hr50
  have effect51 : s51.stack.drop 1 = s50.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack51)
  have suffix51 : s51.stack.drop 3 = s.stack.drop 4 :=
    (stack_drop_extend effect51 2).trans suffix50
  have stack52 := step_statement_stack P.F NR FR R live framed before after old old' ShapeReturn51.input s51 s52 C C h51
    (.returnExpression ShapeReturn51.sourceExpression) ShapeReturn51.sourceEnv ShapeReturn51.source_control hr51
  have effect52 : s52.stack.drop 1 = s51.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (congrArg (List.drop 1) stack52)
  have suffix52 : s52.stack.drop 4 = s.stack.drop 4 :=
    (stack_drop_extend effect52 3).trans suffix51
  have stack53 := step_array_spread_entry_stack P.F NR FR R live framed before after old old' ShapeArray52.input s52 s53 C₀ C C h52
    ShapeArray52.sourceObject ShapeArray52.sourceRest ShapeArray52.sourceEnv ShapeArray52.source_control hr52
  have effect53 : s53.stack.drop 1 = s52.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack53)
  have suffix53 : s53.stack.drop 5 = s.stack.drop 4 :=
    (stack_drop_extend effect53 4).trans suffix52
  have stack54 := step_descent_stack P.F NR FR R live framed before after old old' TypedCtor53.input s53 s54 C C h53
    TypedCtor53.sourceDescent TypedCtor53.sourceEnv TypedCtor53.source_control hr53
  have effect54 : s54.stack.drop 1 = s53.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (congrArg (List.drop 1) stack54)
  have suffix54 : s54.stack.drop 6 = s.stack.drop 4 :=
    (stack_drop_extend effect54 5).trans suffix53
  have stack55 : s55.stack = s54.stack := rfl
  have effect55 : s55.stack.drop 0 = s54.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack55)
  have suffix55 : s55.stack.drop 6 = s.stack.drop 4 :=
    (stack_drop_extend effect55 6).trans suffix54
  have stack56 := step_callStart_expression_stack P.F NR FR R live framed before after old old' TypedCallee55.input s55 s56 C C h55
    TypedCallee55.sourceMode TypedCallee55.sourceAddress TypedCallee55.sourceThis TypedCallee55.sourceArgs TypedCallee55.sourceEnv TypedCallee55.sourceTail
    TypedCallee55.source_control TypedCallee55.source_frame (match TypedCallee55.sourceArgs with | .expr e::_ => e | _ => .lit .null) TypedCallee55.sourceArgs.tail (by host_kernel_rfl) hr55
  have effect56 : s56.stack.drop 1 = s55.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack56)
  have suffix56 : s56.stack.drop 6 = s.stack.drop 4 :=
    (stack_drop_extend effect56 5).trans suffix55
  have stack57 := step_identifier_call_stack P.F NR FR R live framed before after old old' BufferCall56.input s56 s57 C₀ C C h56
    BufferCall56.sourceName BufferCall56.sourceArgs BufferCall56.sourceOptional BufferCall56.sourceEnv BufferCall56.source_control hr56
  have effect57 : s57.stack.drop 1 = s56.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack57)
  have suffix57 : s57.stack.drop 7 = s.stack.drop 4 :=
    (stack_drop_extend effect57 6).trans suffix56
  have stack58 : s58.stack = s57.stack := rfl
  have effect58 : s58.stack.drop 0 = s57.stack.drop 0 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack58)
  have suffix58 : s58.stack.drop 7 = s.stack.drop 4 :=
    (stack_drop_extend effect58 7).trans suffix57
  have stack59 := step_callStart_expression_stack P.F NR FR R live framed before after old old' BufferCallee58.input s58 s59 C C h58
    (.callee BufferCallee58.sourceOptional) BufferCallee58.sourceAddress .undef BufferCallee58.sourceArgs BufferCallee58.sourceEnv BufferCallee58.sourceTail
    BufferCallee58.source_control BufferCallee58.source_frame (match BufferCallee58.sourceArgs with | .expr e::_ => e | _ => .lit .null) BufferCallee58.sourceArgs.tail (by host_kernel_rfl) hr58
  have effect59 : s59.stack.drop 1 = s58.stack.drop 1 := by
    simpa only [List.drop_succ_cons,List.drop_zero,List.drop_one,List.tail_cons,StatementAction.frames,List.cons_append,List.nil_append] using (stack59)
  have suffix59 : s59.stack.drop 7 = s.stack.drop 4 :=
    (stack_drop_extend effect59 6).trans suffix58
  refine ⟨s59,?_,h59,?_,suffix59⟩
  ·
    apply runC_cons P.F 11 s s48 s59 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr47
    apply runC_cons P.F 10 s48 s49 s59 C C C (h48.control.isHalt_eq.trans (by host_kernel_rfl)) hr48
    apply runC_cons P.F 9 s49 s50 s59 C C C (h49.control.isHalt_eq.trans (by host_kernel_rfl)) hr49
    apply runC_cons P.F 8 s50 s51 s59 C C C (h50.control.isHalt_eq.trans (by host_kernel_rfl)) hr50
    apply runC_cons P.F 7 s51 s52 s59 C C C (h51.control.isHalt_eq.trans (by host_kernel_rfl)) hr51
    apply runC_cons P.F 6 s52 s53 s59 C C C (h52.control.isHalt_eq.trans (by host_kernel_rfl)) hr52
    apply runC_cons P.F 5 s53 s54 s59 C C C (h53.control.isHalt_eq.trans (by host_kernel_rfl)) hr53
    apply runC_cons P.F 4 s54 s55 s59 C C C (h54.control.isHalt_eq.trans (by host_kernel_rfl)) hr54
    apply runC_cons P.F 3 s55 s56 s59 C C C (h55.control.isHalt_eq.trans (by host_kernel_rfl)) hr55
    apply runC_cons P.F 2 s56 s57 s59 C C C (h56.control.isHalt_eq.trans (by host_kernel_rfl)) hr56
    apply runC_cons P.F 1 s57 s58 s59 C C C (h57.control.isHalt_eq.trans (by host_kernel_rfl)) hr57
    apply runC_cons P.F 0 s58 s59 s59 C C C (h58.control.isHalt_eq.trans (by host_kernel_rfl)) hr58
    rfl
  · intro b hb
    rw [heap59,hh49 b hb,hh48]
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- All forty actual source steps from the rank guard to typed-buffer argument
preparation. The original receiver's owned private handle and rank cell are
preserved; native shape dispatch is derived at its real call occurrence. -/
theorem shape_path_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro5.s2 s)
    (rank : s.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))))
    (rankLive : live WeightInitialize9.sourceAddress) (receiverLive : live Handle40.sourceAddress)
    (field : PrivateData s (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
      Handle40.sourceName (.big (Int.ofNat (R.handle 1365))))
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail P.RestStream.micro0.micro5.s2.ffi.mlx s.ffi.mlx)
    (signatureFrame : ¬ framed ShapeNative.signature) (handleLive : H 1365)
    (region : R.region (4*1365) = 4*R.handle 1365)
    (bound : s.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ result, runC P.F 40 s C = some (result,C) ∧
      StateR NR FR R (GetterLive live) framed before after old old' P.RestStream.micro0.micro5.s42 result ∧
      result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) ∧
      PrivateData result (R.a Handle40.sourceAddress) (R.a Handle40.sourceBrand)
        Handle40.sourceName (.big (Int.ofNat (R.handle 1365))) ∧
      (∀ a, a < s.next → a ≠ R.a PointerBinding48.sourceAddress → result.heap.get a = s.heap.get a) ∧ result.stack.drop 7 = s.stack.drop 3 := by
  let GR : Ren → LSt → LSt → Prop := fun Q x y => FR Q x y ∧
    Host.Mlx.Ffi.NativeRoles.Live NR Q NodeRel ObjRel H N tail x.mlx y.mlx
  have hg : StateR NR GR R live framed before after old old' P.RestStream.micro0.micro5.s2 s :=
    ⟨h.heap,h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,⟨h.native,native⟩,h.trace⟩
  obtain ⟨s28,hr28,h28,heap28,stack28⟩ := shape_getter_preparation NR GR R C₀ C live framed before after old old' s hg
  have hn28 : s28.next = s.next := hg.target_next_eq h28 (by host_kernel_rfl)
  have hb28 : s28.next + 2 + (paramNames EnterGetter28.sourceFunction).length ≤ 2^64 := hn28 ▸ bound
  obtain ⟨s30,hr30,h30,frame30,stack30⟩ := getter_entry_transport NR GR R C₀ C live framed before after old old' s28 h28 hb28
  have rank30 : s30.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) := by
    rw [frame30 _ (h28.heap.targetBound _ rankLive),heap28]
    exact rank
  have field30 := (field.heap_eq heap28).heap_at (frame30 _ (h28.heap.targetBound _ receiverLive))
  obtain ⟨s46,hr46,h46,slot46,heap46,stack46⟩ := shape_handle_transport NR GR R C₀ C (GetterLive live) framed before after old old' s30 h30 field30
  have role46 : (Annotated.Value.handle 1365).Holds ν C R (callArgument s46.ctl 0) :=
    slot46.symm ▸ Annotated.Value.Holds.handle 1365
  obtain ⟨s47,hr47,h47,_,heap47,stack47⟩ := ShapeNative.transport NR GR R C₀ C ν (GetterLive live) framed before after old old' s46 h46
    NodeRel ObjRel H N tail h46.native.2 signatureFrame handleLive region role46
  have hn47 : s47.next = s.next+2 := hg.target_next_add h47 2 (by host_kernel_rfl)
  have hb47 : s47.next ≤ 2^64 := by rw [hn47]; omega
  have grow : ∀ a, live a → GetterLive live a := ClosureLive.grow live EnterGetter28.input.next
    EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceFunction
  obtain ⟨result,hr59,h59,frame59,stack59⟩ := shape_pointer_preparation NR GR R C₀ C (GetterLive live) framed before after old old' s47 h47
    hb47 (grow _ globalLive) globalFixed
  have hl := h47.stackLive
  change listSupport (fun f => treeSupport (GetterLive live) (Encode.frame f)) PointerDeclaration47.input.stack at hl
  rw [PointerDeclaration47.source_frame] at hl
  have pointerLookup : lookupEnv PointerBinding48.sourceName PointerDeclaration47.sourceEnv = some PointerBinding48.sourceAddress := by host_kernel_rfl
  have pointerLive := env_lookup_live PointerBinding48.sourceName PointerDeclaration47.sourceEnv PointerBinding48.sourceAddress
    hl.1.1.2.2.2.1 pointerLookup
  have distinctRank : R.a WeightInitialize9.sourceAddress ≠ R.a PointerBinding48.sourceAddress := by
    intro he
    have hn := h47.heap.inj _ _ (grow _ rankLive) pointerLive he
    have hn' : WeightInitialize9.sourceAddress ≠ PointerBinding48.sourceAddress := by decide +kernel
    exact hn' hn
  have distinctReceiver : R.a Handle40.sourceAddress ≠ R.a PointerBinding48.sourceAddress := by
    intro he
    have hn := h47.heap.inj _ _ (grow _ receiverLive) pointerLive he
    have hn' : Handle40.sourceAddress ≠ PointerBinding48.sourceAddress := by decide +kernel
    exact hn' hn
  have rank59 : result.heap.get (R.a WeightInitialize9.sourceAddress) = some (.cell (some (natV 3))) := by
    rw [frame59 _ distinctRank,heap47,heap46]
    exact rank30
  have field47 := field30.heap_eq (heap47.trans heap46)
  have field59 := field47.heap_at (frame59 _ distinctReceiver)
  have oldFields : ∀ a, a < s.next → a ≠ R.a PointerBinding48.sourceAddress → result.heap.get a = s.heap.get a := by
    intro a ha hn
    have ha28 : a < s28.next := hn28.symm ▸ ha
    rw [frame59 _ hn,heap47,heap46,frame30 _ ha28,heap28]
  have final := h59.native_map (fun _ _ _ p => p.1)
  have stack : result.stack.drop 7 = s.stack.drop 3 :=
    stack59.trans ((congrArg (List.drop 4) stack47).trans (stack46.trans (stack30.trans stack28)))
  refine ⟨result,?_,final,rank59,field59,oldFields,stack⟩
  have one : runC P.F 1 s46 C = some (s47,C) := by
    apply runC_cons P.F 0 s46 s47 s47 C C C (h46.control.isHalt_eq.trans (by host_kernel_rfl)) hr47
    rfl
  have first11 : runC P.F 11 s C = some (s30,C) := runC_join P.F (m:=9) (n:=2) hr28 hr30
  have first27 : runC P.F 27 s C = some (s46,C) := runC_join P.F (m:=11) (n:=16) first11 hr46
  have first28 : runC P.F 28 s C = some (s47,C) := runC_join P.F (m:=27) (n:=1) first27 one
  exact runC_join P.F (m:=28) (n:=12) first28 hr59
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape

