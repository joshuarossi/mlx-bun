import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriverBinding
import host.ts.RenameRouteComposition

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary

host_transport_binding P.F, P.RestStream.micro0.micro0.s18 to P.RestStream.micro0.micro0.s19 as Binding18
host_transport_binding P.F, P.RestStream.micro0.micro0.s19 to P.RestStream.micro0.micro0.s20 as Binding19
host_transport_binding P.F, P.RestStream.micro0.micro0.s20 to P.RestStream.micro0.micro0.s21 as Binding20
host_transport_binding P.F, P.RestStream.micro0.micro0.s21 to P.RestStream.micro0.micro0.s22 as Binding21
host_transport_binding P.F, P.RestStream.micro0.micro0.s22 to P.RestStream.micro0.micro0.s23 as Binding22
host_transport_binding P.F, P.RestStream.micro0.micro0.s23 to P.RestStream.micro0.micro0.s24 as Binding23
host_transport_binding P.F, P.RestStream.micro0.micro0.s24 to P.RestStream.micro0.micro0.s25 as Binding24

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem binding_active18 : isHalt P.RestStream.micro0.micro0.s18.ctl = false := by host_kernel_rfl
theorem binding_active19 : isHalt P.RestStream.micro0.micro0.s19.ctl = false := by host_kernel_rfl
theorem binding_active20 : isHalt P.RestStream.micro0.micro0.s20.ctl = false := by host_kernel_rfl
theorem binding_active21 : isHalt P.RestStream.micro0.micro0.s21.ctl = false := by host_kernel_rfl
theorem binding_active22 : isHalt P.RestStream.micro0.micro0.s22.ctl = false := by host_kernel_rfl
theorem binding_active23 : isHalt P.RestStream.micro0.micro0.s23.ctl = false := by host_kernel_rfl
theorem binding_active24 : isHalt P.RestStream.micro0.micro0.s24.ctl = false := by host_kernel_rfl
theorem binding_next20 : P.RestStream.micro0.micro0.s20.next = P.RestStream.micro0.micro0.s18.next := by host_kernel_rfl
theorem binding_next22 : P.RestStream.micro0.micro0.s22.next = P.RestStream.micro0.micro0.s18.next := by host_kernel_rfl

/-- The actual caller skips the first shape dimension, initializes S and D,
then finishes the declaration. Both values come from the related shape array. -/
theorem shape_binding_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s18 s)
    (notFramed : ¬ framed Binding19.sourceAddress) (targetBound : s.next ≤ 2^64) :
    ∃ result, runC P.F 7 s C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.RestStream.micro0.micro0.s25 result := by
  obtain ⟨s19,hr18,h19⟩ := Binding18.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s20,hr19,h20⟩ := Binding19.transport NR FR R C₀ C live framed before after old old' s19 h19 notFramed
  have hb20 : s20.next ≤ 2^64 := by rw [h.target_next_eq h20 binding_next20]; exact targetBound
  obtain ⟨s21,hr20,h21⟩ := Binding20.transport NR FR R C₀ C live framed before after old old' s20 h20 hb20
  obtain ⟨s22,hr21,h22⟩ := Binding21.transport NR FR R C₀ C live framed before after old old' s21 h21
  have hb22 : s22.next ≤ 2^64 := by rw [h.target_next_eq h22 binding_next22]; exact targetBound
  obtain ⟨s23,hr22,h23⟩ := Binding22.transport NR FR R C₀ C live framed before after old old' s22 h22 hb22
  obtain ⟨s24,hr23,h24⟩ := Binding23.transport NR FR R C₀ C live framed before after old old' s23 h23
  obtain ⟨result,hr24,h25⟩ := Binding24.transport NR FR R C₀ C live framed before after old old' s24 h24
  refine ⟨result,?_,h25⟩
  apply runC_cons P.F 6 s s19 result C C C (h.control.isHalt_eq.trans binding_active18) hr18
  apply runC_cons P.F 5 s19 s20 result C C C (h19.control.isHalt_eq.trans binding_active19) hr19
  apply runC_cons P.F 4 s20 s21 result C C C (h20.control.isHalt_eq.trans binding_active20) hr20
  apply runC_cons P.F 3 s21 s22 result C C C (h21.control.isHalt_eq.trans binding_active21) hr21
  apply runC_cons P.F 2 s22 s23 result C C C (h22.control.isHalt_eq.trans binding_active22) hr22
  apply runC_cons P.F 1 s23 s24 result C C C (h23.control.isHalt_eq.trans binding_active23) hr23
  apply runC_cons P.F 0 s24 result result C C C (h24.control.isHalt_eq.trans binding_active24) hr24
  rfl

/-- error: host_transport_step: unsupported source constructor Host.Ts.Ctl.construct -/
#guard_msgs in
host_transport_binding P.F, P.RestStream.micro0.micro0.s12 to P.RestStream.micro0.micro0.s13 as UnsupportedConstructorBinding

end Host.Load.Run.Full.Ordinary
