import host.ts.renameOrdinary.MlxFieldValues
import host.ts.RenameRouteComposition
import host.ts.RenameClassHeapEffects
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- Execute all three original private initializer returns and their real
literal/object expressions. The saved owned constructor argument is retained
through every write, and the object literal is the sole allocation. -/
theorem initialize_array_fields_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' DisposedLiteral374.input s)
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (bound : s.next+1 ≤ 2^64) :
    ∃ result, runC P.F 6 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live TokenObject376.input.next) framed before after old old' PinField379.output result ∧
      constructorArgument result = constructorArgument s ∧
      (∀ m, m < s.next → m ≠ R.a 3126703 → result.heap.get m = s.heap.get m) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let s374 := s
  have h374 := h
  obtain ⟨hr374,h375,_,_⟩ := DisposedLiteral374.transport FR R ν₀ ν C₀ C live framed before after old old' s374 h374
  let s375 := s374.ret DisposedLiteral374.sourceValue
  have bound375 : s375.next ≤ 2^64 := by change s.next ≤ 2^64; omega
  obtain ⟨s376,hr375,h376,arg376⟩ := DisposedField375.transport NR FR R C₀ C live framed before after old old' s375 h375 bound375
  have bound376 : s376.next < 2^64 := by rw [h.target_next_eq h376 (by host_kernel_rfl)]; omega
  obtain ⟨s377,hr376,h377,arg377⟩ := TokenObject376.transport NR FR R C₀ C live framed before after old old' s376 h376 prototypeLive prototypeFixed bound376
  have bound377 : s377.next ≤ 2^64 := by rw [h.target_next_add h377 1 (by host_kernel_rfl)]; exact bound
  obtain ⟨s378,hr377,h378,arg378⟩ := TokenField377.transport NR FR R C₀ C (LiveAfter live TokenObject376.input.next) framed before after old old' s377 h377 bound377
  obtain ⟨hr378,h379,_,_⟩ := PinLiteral378.transport FR R ν₀ ν C₀ C (LiveAfter live TokenObject376.input.next) framed before after old old' s378 h378
  let s379 := s378.ret PinLiteral378.sourceValue
  have next379 : s379.next = s.next+1 := h.target_next_add h379 1 (by host_kernel_rfl)
  have bound379 : s379.next ≤ 2^64 := by rw [next379]; exact bound
  obtain ⟨result,hr379,h380,arg380⟩ := PinField379.transport NR FR R C₀ C (LiveAfter live TokenObject376.input.next) framed before after old old' s379 h379 bound379
  have run : runC P.F 6 s C = some (result,C) := by
    apply runC_cons P.F 5 s374 s375 result C C C (h374.control.isHalt_eq.trans (by host_kernel_rfl)) hr374
    apply runC_cons P.F 4 s375 s376 result C C C (h375.control.isHalt_eq.trans (by host_kernel_rfl)) hr375
    apply runC_cons P.F 3 s376 s377 result C C C (h376.control.isHalt_eq.trans (by host_kernel_rfl)) hr376
    apply runC_cons P.F 2 s377 s378 result C C C (h377.control.isHalt_eq.trans (by host_kernel_rfl)) hr377
    apply runC_cons P.F 1 s378 s379 result C C C (h378.control.isHalt_eq.trans (by host_kernel_rfl)) hr378
    apply runC_cons P.F 0 s379 result result C C C (h379.control.isHalt_eq.trans (by host_kernel_rfl)) hr379
    rfl
  have frame (m : Nat) (below : m < s.next) (other : m ≠ R.a 3126703) : result.heap.get m = s.heap.get m := by
    have frame376 := step_private_initializer_heap_other P.F NR FR R C C live framed before after old old' _ _ _ h375
      DisposedField375.sourceValue DisposedField375.sourceAddress DisposedField375.sourceBrand DisposedField375.sourceName
      DisposedField375.sourceObject DisposedField375.sourceMembers DisposedField375.sourceEnv DisposedField375.sourceTail
      DisposedField375.source_control DisposedField375.source_frame DisposedField375.source_private
      DisposedField375.source_heap DisposedField375.source_kind bound375 hr375 m other
    have next376 : s376.next = s.next := h.target_next_eq h376 (by host_kernel_rfl)
    have frame377 := step_empty_object_heap_below P.F NR FR R C C live framed before after old old' _ _ _ h376
      TokenObject376.sourceEnv TokenObject376.source_control bound376 hr376 m (by rw [next376]; exact below)
    have frame378 := step_private_initializer_heap_other P.F NR FR R C C (LiveAfter live TokenObject376.input.next)
      framed before after old old' _ _ _ h377 TokenField377.sourceValue TokenField377.sourceAddress TokenField377.sourceBrand
      TokenField377.sourceName TokenField377.sourceObject TokenField377.sourceMembers TokenField377.sourceEnv TokenField377.sourceTail
      TokenField377.source_control TokenField377.source_frame TokenField377.source_private TokenField377.source_heap
      TokenField377.source_kind bound377 hr377 m other
    have frame380 := step_private_initializer_heap_other P.F NR FR R C C (LiveAfter live TokenObject376.input.next)
      framed before after old old' _ _ _ h379 PinField379.sourceValue PinField379.sourceAddress PinField379.sourceBrand
      PinField379.sourceName PinField379.sourceObject PinField379.sourceMembers PinField379.sourceEnv PinField379.sourceTail
      PinField379.source_control PinField379.source_frame PinField379.source_private PinField379.source_heap
      PinField379.source_kind bound379 hr379 m other
    exact frame380.trans (frame378.trans (frame377.trans frame376))
  exact ⟨result,run,h380,arg380.trans (arg378.trans (arg377.trans arg376)),frame⟩

theorem initialize_array_fields (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' DisposedLiteral374.input s)
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (bound : s.next+1 ≤ 2^64) :
    ∃ result, runC P.F 6 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live TokenObject376.input.next) framed before after old old' PinField379.output result ∧
      constructorArgument result = constructorArgument s := by
  obtain ⟨result,run,related,arg,_⟩ := initialize_array_fields_framed ν₀ ν C₀ C FR R live framed before after old old'
    s h prototypeLive prototypeFixed bound
  exact ⟨result,run,related,arg⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
