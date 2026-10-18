import host.ts.renameOrdinary.MlxFieldsPath
import host.ts.renameOrdinary.MlxConstructorBody
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- Real private-field initialization followed by original constructor closure
entry. The previously produced handle reaches the parameter scheduler exactly. -/
theorem initialize_and_enter_constructor (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' DisposedLiteral374.input s)
    (prototypeLive : live aObjectProto) (prototypeFixed : R.a aObjectProto = aObjectProto)
    (bound : s.next+2+(paramNames Sources.Mlx.Array.ast_n20).length ≤ 2^64) :
    ∃ result, runC P.F 7 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R
        (ConstructorBodyLive (LiveAfter live TokenObject376.input.next) MlxBody380.input.next Sources.Mlx.Array.ast_n20)
        framed before after old old' MlxBody380.output result ∧
      constructorParameterArgument result.stack = constructorArgument s := by
  obtain ⟨s380,hr374,h380,arg380⟩ := initialize_array_fields ν₀ ν C₀ C FR R live framed before after old old' s h prototypeLive prototypeFixed (by omega)
  have next380 : s380.next = s.next+1 := h.target_next_add h380 1 (by host_kernel_rfl)
  have bodyBound : s380.next+1+(paramNames Sources.Mlx.Array.ast_n20).length ≤ 2^64 := by rw [next380]; omega
  obtain ⟨result,hr380,h381,arg381⟩ := MlxBody380.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    (LiveAfter live TokenObject376.input.next) framed before after old old' s380 h380 bodyBound
  have lastRun : runC P.F 1 s380 C = some (result,C) := by
    apply runC_cons P.F 0 s380 result result C C C (h380.control.isHalt_eq.trans (by host_kernel_rfl)) hr380
    rfl
  exact ⟨result,runC_join P.F (m := 6) (n := 1) hr374 lastRun,h381,arg381.trans arg380⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
