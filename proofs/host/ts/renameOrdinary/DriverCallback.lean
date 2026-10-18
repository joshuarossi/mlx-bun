import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriverPreparation
import host.ts.RenameRouteDriverStructural
import host.ts.RenameRouteDriverGlobal
import host.ts.RenameRouteComposition

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary

host_transport_preparation P.F, P.RestStream.micro0.micro0.s49 to P.RestStream.micro0.micro0.s50 as Callback49
host_transport_preparation P.F, P.RestStream.micro0.micro0.s50 to P.RestStream.micro0.micro0.s51 as Callback50
host_transport_preparation P.F, P.RestStream.micro0.micro0.s51 to P.RestStream.micro0.micro0.s52 as Callback51
host_transport_global P.F, P.RestStream.micro0.micro0.s52 to P.RestStream.micro0.micro0.s53 as Callback52
host_transport_preparation P.F, P.RestStream.micro0.micro0.s53 to P.RestStream.micro0.micro0.s54 as Callback53
host_transport_preparation P.F, P.RestStream.micro0.micro0.s54 to P.RestStream.micro0.micro0.s55 as Callback54
host_transport_step P.F, P.RestStream.micro0.micro0.s55 to P.RestStream.micro0.micro0.s56 as Callback55
host_transport_preparation P.F, P.RestStream.micro0.micro0.s56 to P.RestStream.micro0.micro0.s57 as Callback56
host_transport_preparation P.F, P.RestStream.micro0.micro0.s57 to P.RestStream.micro0.micro0.s58 as Callback57
host_transport_preparation P.F, P.RestStream.micro0.micro0.s58 to P.RestStream.micro0.micro0.s59 as Callback58
host_transport_structural P.F, P.RestStream.micro0.micro0.s59 to P.RestStream.micro0.micro0.s60 as Callback59

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem callback_active49 : isHalt P.RestStream.micro0.micro0.s49.ctl = false := by host_kernel_rfl
theorem callback_active50 : isHalt P.RestStream.micro0.micro0.s50.ctl = false := by host_kernel_rfl
theorem callback_active51 : isHalt P.RestStream.micro0.micro0.s51.ctl = false := by host_kernel_rfl
theorem callback_active52 : isHalt P.RestStream.micro0.micro0.s52.ctl = false := by host_kernel_rfl
theorem callback_active53 : isHalt P.RestStream.micro0.micro0.s53.ctl = false := by host_kernel_rfl
theorem callback_active54 : isHalt P.RestStream.micro0.micro0.s54.ctl = false := by host_kernel_rfl
theorem callback_active55 : isHalt P.RestStream.micro0.micro0.s55.ctl = false := by host_kernel_rfl
theorem callback_active56 : isHalt P.RestStream.micro0.micro0.s56.ctl = false := by host_kernel_rfl
theorem callback_active57 : isHalt P.RestStream.micro0.micro0.s57.ctl = false := by host_kernel_rfl
theorem callback_active58 : isHalt P.RestStream.micro0.micro0.s58.ctl = false := by host_kernel_rfl
theorem callback_active59 : isHalt P.RestStream.micro0.micro0.s59.ctl = false := by host_kernel_rfl
theorem callback_next58 : P.RestStream.micro0.micro0.s58.next = P.RestStream.micro0.micro0.s49.next := by host_kernel_rfl

/-- The real concat helper evaluates its typed-array constructor and the
inherited `arrays.map` method, then allocates and passes its real callback. -/
theorem concat_callback_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s49 s)
    (receiverNotFramed : ¬ framed Callback56.sourceAddress)
    (prototypeLive : live aFunctionProto) (prototypeFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (targetBound : s.next < 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR NR FR R (LiveAfter live P.RestStream.micro0.micro0.s58.next)
        framed before after old old' P.RestStream.micro0.micro0.s60 result := by
  obtain ⟨s50,hr49,h50⟩ := Callback49.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s51,hr50,h51⟩ := Callback50.transport NR FR R C₀ C live framed before after old old' s50 h50
  obtain ⟨s52,hr51,h52⟩ := Callback51.transport NR FR R C₀ C live framed before after old old' s51 h51
  obtain ⟨v52,hr52,h53,_⟩ := Callback52.transport NR FR R C₀ C live framed before after old old' s52 h52 globalLive globalFixed
  let s53 := s52.ret v52
  obtain ⟨s54,hr53,h54⟩ := Callback53.transport NR FR R C₀ C live framed before after old old' s53 h53
  obtain ⟨s55,hr54,h55⟩ := Callback54.transport NR FR R C₀ C live framed before after old old' s54 h54
  obtain ⟨v55,hr55,h56,_⟩ := Callback55.transport NR FR R C₀ C live framed before after old old' s55 h55
  let s56 := s55.ret v55
  obtain ⟨s57,hr56,h57⟩ := Callback56.transport NR FR R C₀ C live framed before after old old' s56 h56 receiverNotFramed
  obtain ⟨s58,hr57,h58⟩ := Callback57.transport NR FR R C₀ C live framed before after old old' s57 h57
  have hb58 : s58.next < 2^64 := by rw [h.target_next_eq h58 callback_next58]; exact targetBound
  obtain ⟨s59,hr58,h59⟩ := Callback58.transport NR FR R C₀ C live framed before after old old' s58 h58
    prototypeLive prototypeFixed hb58
  obtain ⟨result,hr59,h60⟩ := Callback59.transport NR FR R C₀ C (LiveAfter live P.RestStream.micro0.micro0.s58.next)
    framed before after old old' s59 h59
  refine ⟨result,?_,h60⟩
  apply runC_cons P.F 10 s s50 result C C C (h.control.isHalt_eq.trans callback_active49) hr49
  apply runC_cons P.F 9 s50 s51 result C C C (h50.control.isHalt_eq.trans callback_active50) hr50
  apply runC_cons P.F 8 s51 s52 result C C C (h51.control.isHalt_eq.trans callback_active51) hr51
  apply runC_cons P.F 7 s52 s53 result C C C (h52.control.isHalt_eq.trans callback_active52) hr52
  apply runC_cons P.F 6 s53 s54 result C C C (h53.control.isHalt_eq.trans callback_active53) hr53
  apply runC_cons P.F 5 s54 s55 result C C C (h54.control.isHalt_eq.trans callback_active54) hr54
  apply runC_cons P.F 4 s55 s56 result C C C (h55.control.isHalt_eq.trans callback_active55) hr55
  apply runC_cons P.F 3 s56 s57 result C C C (h56.control.isHalt_eq.trans callback_active56) hr56
  apply runC_cons P.F 2 s57 s58 result C C C (h57.control.isHalt_eq.trans callback_active57) hr57
  apply runC_cons P.F 1 s58 s59 result C C C (h58.control.isHalt_eq.trans callback_active58) hr58
  apply runC_cons P.F 0 s59 result result C C C (h59.control.isHalt_eq.trans callback_active59) hr59
  rfl

end Host.Load.Run.Full.Ordinary
