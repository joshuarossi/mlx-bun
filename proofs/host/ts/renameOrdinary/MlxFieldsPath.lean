import host.ts.renameOrdinary.MlxFieldValues
import host.ts.RenameRouteComposition
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- Execute all three original private initializer returns and their real
literal/object expressions. The saved owned constructor argument is retained
through every write, and the object literal is the sole allocation. -/
theorem initialize_array_fields (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' DisposedLiteral374.input s)
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (bound : s.next+1 ≤ 2^64) :
    ∃ result, runC P.F 6 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live TokenObject376.input.next) framed before after old old' PinField379.output result ∧
      constructorArgument result = constructorArgument s := by
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
  exact ⟨result,run,h380,arg380.trans (arg378.trans (arg377.trans arg376))⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
