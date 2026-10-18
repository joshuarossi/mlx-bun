import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriverReturns
import host.ts.RenameRouteComposition

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

host_transport_return P.F, P.RestStream.micro0.micro0.s14 to P.RestStream.micro0.micro0.s15 as Return14
host_transport_return P.F, P.RestStream.micro0.micro0.s15 to P.RestStream.micro0.micro0.s16 as Return15
host_transport_return P.F, P.RestStream.micro0.micro0.s16 to P.RestStream.micro0.micro0.s17 as Return16
host_transport_return P.F, P.RestStream.micro0.micro0.s17 to P.RestStream.micro0.micro0.s18 as Return17

/-- error: host_transport_step: unsupported source constructor Host.Ts.Frame.l -/
#guard_msgs in
host_transport_return P.F, P.RestStream.micro0.micro0.s13 to P.RestStream.micro0.micro0.s14 as UnsupportedSpreadReturn

theorem return_source_active14 : isHalt P.RestStream.micro0.micro0.s14.ctl = false := by host_kernel_rfl
theorem return_source_active15 : isHalt P.RestStream.micro0.micro0.s15.ctl = false := by host_kernel_rfl
theorem return_source_active16 : isHalt P.RestStream.micro0.micro0.s16.ctl = false := by host_kernel_rfl
theorem return_source_active17 : isHalt P.RestStream.micro0.micro0.s17.ctl = false := by host_kernel_rfl

/-- The actual shape getter returns through its block, scope and function
boundary in four interpreter steps, preserving the complete related state. -/
theorem shape_return_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s14 s) :
    ∃ result, runC P.F 4 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s18 result := by
  obtain ⟨s15,hr14,h15⟩ := Return14.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s16,hr15,h16⟩ := Return15.transport NR FR R C₀ C live framed before after old old' s15 h15
  obtain ⟨s17,hr16,h17⟩ := Return16.transport NR FR R C₀ C live framed before after old old' s16 h16
  obtain ⟨result,hr17,h18⟩ := Return17.transport NR FR R C₀ C live framed before after old old' s17 h17
  refine ⟨result,?_,h18⟩
  apply runC_cons P.F 3 s s15 result C C C (h.control.isHalt_eq.trans return_source_active14) hr14
  apply runC_cons P.F 2 s15 s16 result C C C (h15.control.isHalt_eq.trans return_source_active15) hr15
  apply runC_cons P.F 1 s16 s17 result C C C (h16.control.isHalt_eq.trans return_source_active16) hr16
  apply runC_cons P.F 0 s17 result result C C C (h17.control.isHalt_eq.trans return_source_active17) hr17
  rfl

end Host.Load.Run.Full.Ordinary
