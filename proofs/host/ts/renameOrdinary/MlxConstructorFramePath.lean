import host.ts.renameOrdinary.MlxFieldsPath
import host.ts.renameOrdinary.MlxHandlePath
import host.ts.renameOrdinary.MlxConstructorBody
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The real constructor changes only fresh instance/parameter cells. This
closed block keeps every older exact caller-cell role while deriving the
new array's private owned handle from its actual supplied argument. -/
theorem construct_array_with_frame (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' MlxClassArgument371.input s)
    (handle : s.ctl = .ret (.big (Int.ofNat (R.handle 29372))))
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (bound : s.next+10 ≤ 2^64) :
    ∃ result, runC P.F 20 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R
        (HandleLive (ConstructorBodyLive (LiveAfter (BaseClassLive live MlxClass372.input.next) TokenObject376.input.next)
          MlxBody380.input.next Sources.Mlx.Array.ast_n20)) framed before after old old' HandleStore390.output result ∧
      PrivateData result (R.a 3126703) (R.a HandleStore390.sourceBrand) HandleStore390.sourceName
        (.big (Int.ofNat (R.handle 29372))) ∧
      (∀ m, m < s.next → result.heap.get m = s.heap.get m) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨s373,r371,h373,arg373,frame373⟩ := concat_construct_array_framed NR FR R C₀ C live framed before after old old'
    s h handle (by omega)
  have next373 : s373.next = s.next+2 := h.target_next_add h373 2 (by host_kernel_rfl)
  have bound373 : s373.next ≤ 2^64 := by rw [next373]; omega
  obtain ⟨s374,r373,h374,arg374⟩ := MlxFields373.transport NR FR R C₀ C (BaseClassLive live MlxClass372.input.next)
    framed before after old old' s373 h373 bound373
  have next374 : s374.next = s.next+2 := h.target_next_add h374 2 (by host_kernel_rfl)
  have proto374 : (BaseClassLive live MlxClass372.input.next) aObjectProto := Or.inl (Or.inl prototypeLive)
  obtain ⟨s380,r374,h380,arg380,frame380⟩ := initialize_array_fields_framed ν₀ ν C₀ C FR R
    (BaseClassLive live MlxClass372.input.next) framed before after old old' s374 h374 proto374 prototypeFixed (by rw [next374]; omega)
  have next380 : s380.next = s.next+3 := h.target_next_add h380 3 (by host_kernel_rfl)
  have paramLength : (paramNames Sources.Mlx.Array.ast_n20).length = 1 := by host_kernel_rfl
  have bodyBound : s380.next+1+(paramNames Sources.Mlx.Array.ast_n20).length ≤ 2^64 := by rw [next380,paramLength]; omega
  obtain ⟨s381,r380,h381,arg381⟩ := MlxBody380.transport NR FR R C₀ C
    (LiveAfter (BaseClassLive live MlxClass372.input.next) TokenObject376.input.next) framed before after old old'
    s380 h380 bodyBound
  have first : constructorParameterArgument s381.stack = .big (Int.ofNat (R.handle 29372)) :=
    arg381.trans (arg380.trans (arg374.trans arg373))
  have next381 : s381.next = s.next+5 := h.target_next_add h381 5 (by host_kernel_rfl)
  have bodyNames : blockNames ConstructorBlock383.sourceBody = [] := by host_kernel_rfl
  have bound381 : s381.next+(blockNames ConstructorBlock383.sourceBody).length ≤ 2^64 := by rw [next381,bodyNames]; simp only [List.length_nil]; omega
  obtain ⟨result,r381,h391,field,frame391⟩ := initialize_constructor_handle_framed NR FR R C₀ C
    (ConstructorBodyLive (LiveAfter (BaseClassLive live MlxClass372.input.next) TokenObject376.input.next)
      MlxBody380.input.next Sources.Mlx.Array.ast_n20)
    framed before after old old' s381 h381 (.big (Int.ofNat (R.handle 29372))) first bound381
  have instanceMap : R.a 3126703 = s.next := by
    have hf := h.heap.fresh 0
    have source : MlxClassArgument371.input.next+0 = 3126703 := by host_kernel_rfl
    rw [source,Nat.add_zero] at hf
    exact hf
  have parameterMap : R.a HandleBinding382.sourceAddress = s.next+4 := by
    have hf := h.heap.fresh 4
    have source : MlxClassArgument371.input.next+4 = HandleBinding382.sourceAddress := by host_kernel_rfl
    rw [source] at hf
    exact hf
  have frame (m : Nat) (below : m < s.next) : result.heap.get m = s.heap.get m := by
    have other : m ≠ R.a 3126703 := by rw [instanceMap]; omega
    have otherParameter : m ≠ R.a HandleBinding382.sourceAddress := by rw [parameterMap]; omega
    have heap374 := step_class_fields_heap_other P.F NR FR R C C (BaseClassLive live MlxClass372.input.next)
      framed before after old old' _ _ _ h373 .undef 3126703 MlxClass372.sourceMembers MlxFields373.sourceEnv
      MlxFields373.sourceTail MlxFields373.source_control MlxFields373.source_frame MlxFields373.source_private bound373 r373 m other
    have heap380 := frame380 m (by rw [next374]; omega) other
    have heap381 := step_constructor_body_heap_below P.F NR FR R C C
      (LiveAfter (BaseClassLive live MlxClass372.input.next) TokenObject376.input.next) framed before after old old' _ _ _ h380
      .undef (.obj 3126703) Sources.Mlx.Array.ast_n20 MlxBody380.sourceEnv [.big (Int.ofNat 29372)] MlxBody380.sourceTail
      MlxBody380.source_control MlxBody380.source_frame (by rw [next380,paramLength]; omega) r380 m (by rw [next380]; omega)
    have heap391 := frame391 m (by rw [next381]; omega) other otherParameter
    exact heap391.trans (heap381.trans (heap380.trans (heap374.trans (frame373 m below))))
  have firstRun : runC P.F 3 s C = some (s374,C) := by
    have one : runC P.F 1 s373 C = some (s374,C) := by
      apply runC_cons P.F 0 s373 s374 s374 C C C (h373.control.isHalt_eq.trans (by host_kernel_rfl)) r373
      rfl
    exact runC_join P.F (m := 2) (n := 1) r371 one
  have middleRun : runC P.F 7 s374 C = some (s381,C) := by
    have one : runC P.F 1 s380 C = some (s381,C) := by
      apply runC_cons P.F 0 s380 s381 s381 C C C (h380.control.isHalt_eq.trans (by host_kernel_rfl)) r380
      rfl
    exact runC_join P.F (m := 6) (n := 1) r374 one
  have ten := runC_join P.F (m := 3) (n := 7) firstRun middleRun
  exact ⟨result,runC_join P.F (m := 10) (n := 10) ten r381,h391,field,frame⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
