import host.ts.renameOrdinary.RankOriginRemaining
import host.ts.RenameRouteReadFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The actual shape call evaluates its namespace method and receiver before
entering Array.handle. Every old heap field is unchanged through this prefix. -/
theorem shape_getter_preparation (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.micro3275.s19 s) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.micro3275.s28 result ∧
      result.heap = s.heap := by
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
  refine ⟨result,?_,h28,hh⟩
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
end Host.Load.Run.Full.Ordinary.RankOrigin
