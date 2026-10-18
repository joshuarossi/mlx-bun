import host.ts.renameOrdinary.RankOriginRemaining
import host.ts.RenameRoutePrivateFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- Shape-pointer binding and real typed-buffer call preparation preserve
all other heap occurrences, including the initialized rank and receiver. -/
theorem shape_pointer_preparation (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.micro3275.s47 s)
    (bound : s.next ≤ 2^64) (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.micro3275.s59 result ∧
      (∀ b, b ≠ R.a PointerBinding48.sourceAddress → result.heap.get b = s.heap.get b) := by
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
  refine ⟨s59,?_,h59,?_⟩
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
end Host.Load.Run.Full.Ordinary.RankOrigin
