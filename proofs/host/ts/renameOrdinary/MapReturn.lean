import host.ts.renameOrdinary.DriverMapReturn
import host.ts.RenameRouteHeapFields
import host.ts.RenameRoutePrivateFields
import host.ts.RenameMapBodyEffects

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem map_return (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' MapExit214.input s) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' MapReturn222.output result ∧
      result.heap = s.heap := by
  obtain ⟨s215,r214,h215⟩ := MapExit214.transport NR FR R C₀ C live framed before after old old' s h
  have heap215 := step_for_body_heap_from_source P.F NR FR R live framed before after old old' MapExit214.input s s215 C C h MapExit214.sourceGuard MapExit214.sourceTest MapExit214.sourceUpdate MapExit214.sourceBody MapExit214.sourceEnv MapExit214.sourceNames MapExit214.sourceLabels MapExit214.sourceTail MapExit214.source_control MapExit214.source_frame r214
  obtain ⟨s216,r215,h216⟩ := MapReturn215.transport NR FR R C₀ C live framed before after old old' s215 h215
  have heap216 := step_block_next_heap P.F NR FR R live framed before after old old' MapReturn215.input s215 s216 C C h215 MapReturn215.sourceValue MapReturn215.sourceStatement MapReturn215.sourceRest MapReturn215.sourceEnv MapReturn215.sourceTail MapReturn215.source_control MapReturn215.source_frame r215
  obtain ⟨s217,r216,h217⟩ := MapReturn216.transport NR FR R C₀ C live framed before after old old' s216 h216
  have heap217 := step_statement_heap P.F NR FR R live framed before after old old' MapReturn216.input s216 s217 C C h216 (.returnExpression MapReturn216.sourceExpression) MapReturn216.sourceEnv MapReturn216.source_control r216
  obtain ⟨v217,r217,h218,_⟩ := MapReturn217.transport NR FR R C₀ C live framed before after old old' s217 h217
  let s218 := s217.ret v217
  have heap218 : s218.heap = s217.heap := rfl
  obtain ⟨s219,r218,h219⟩ := MapReturn218.transport NR FR R C₀ C live framed before after old old' s218 h218
  have heap219 := step_return_exit_heap P.F NR FR R live framed before after old old' MapReturn218.input s218 s219 C C h218 MapReturn218.sourceValue MapReturn218.sourceAction MapReturn218.sourceEnv MapReturn218.sourceTail MapReturn218.source_control MapReturn218.source_frame r218
  obtain ⟨s220,r219,h220⟩ := MapReturn219.transport NR FR R C₀ C live framed before after old old' s219 h219
  have heap220 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapReturn219.input s219 s220 C C h219 MapReturn219.sourceValue MapReturn219.sourceAction MapReturn219.sourceEnv MapReturn219.sourceTail MapReturn219.source_control MapReturn219.source_frame r219
  obtain ⟨s221,r220,h221⟩ := MapReturn220.transport NR FR R C₀ C live framed before after old old' s220 h220
  have heap221 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapReturn220.input s220 s221 C C h220 MapReturn220.sourceValue MapReturn220.sourceAction MapReturn220.sourceEnv MapReturn220.sourceTail MapReturn220.source_control MapReturn220.source_frame r220
  obtain ⟨s222,r221,h222⟩ := MapReturn221.transport NR FR R C₀ C live framed before after old old' s221 h221
  have heap222 := step_return_unwind_heap P.F NR FR R live framed before after old old' MapReturn221.input s221 s222 C C h221 MapReturn221.sourceValue MapReturn221.sourceAction MapReturn221.sourceEnv MapReturn221.sourceTail MapReturn221.source_control MapReturn221.source_frame r221
  obtain ⟨s223,r222,h223⟩ := MapReturn222.transport NR FR R C₀ C live framed before after old old' s222 h222
  have heap223 := step_argument_heap_from_source P.F NR FR R live framed before after old old' MapReturn222.input s222 s223 C C h222 MapReturn222.sourceValue MapReturn222.sourceKind MapReturn222.sourceFunction MapReturn222.sourceThis MapReturn222.sourceAcc MapReturn222.sourceRest MapReturn222.sourceEnv MapReturn222.sourceTail MapReturn222.source_control MapReturn222.source_frame (by decide +kernel) r222
  refine ⟨s223,?_,h223,?_⟩
  · apply runC_cons P.F 8 s s215 s223 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r214
    apply runC_cons P.F 7 s215 s216 s223 C C C (h215.control.isHalt_eq.trans (by host_kernel_rfl)) r215
    apply runC_cons P.F 6 s216 s217 s223 C C C (h216.control.isHalt_eq.trans (by host_kernel_rfl)) r216
    apply runC_cons P.F 5 s217 s218 s223 C C C (h217.control.isHalt_eq.trans (by host_kernel_rfl)) r217
    apply runC_cons P.F 4 s218 s219 s223 C C C (h218.control.isHalt_eq.trans (by host_kernel_rfl)) r218
    apply runC_cons P.F 3 s219 s220 s223 C C C (h219.control.isHalt_eq.trans (by host_kernel_rfl)) r219
    apply runC_cons P.F 2 s220 s221 s223 C C C (h220.control.isHalt_eq.trans (by host_kernel_rfl)) r220
    apply runC_cons P.F 1 s221 s222 s223 C C C (h221.control.isHalt_eq.trans (by host_kernel_rfl)) r221
    apply runC_cons P.F 0 s222 s223 s223 C C C (h222.control.isHalt_eq.trans (by host_kernel_rfl)) r222
    rfl
  · rw [heap223,heap222,heap221,heap220,heap219,heap218,heap217,heap216,heap215]

end Host.Load.Run.Full.Ordinary
