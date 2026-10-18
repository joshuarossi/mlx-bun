import host.ts.RenameRouteComposition
import host.ts.renameOrdinary.DriverStructural
import host.ts.renameOrdinary.DriverVariable
import host.ts.renameOrdinary.DriverLiteral
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
host_transport_step P.F, P.RestStream.micro0.micro0.s5 to P.RestStream.micro0.micro0.s6 as Variable5
host_transport_step P.F, P.RestStream.micro0.micro0.s7 to P.RestStream.micro0.micro0.s8 as Literal7
theorem source_active0 : isHalt P.RestStream.micro0.micro0.s0.ctl = false := by host_kernel_rfl
theorem source_active1 : isHalt P.RestStream.micro0.micro0.s1.ctl = false := by host_kernel_rfl
theorem source_active2 : isHalt P.RestStream.micro0.micro0.s2.ctl = false := by host_kernel_rfl
theorem source_active3 : isHalt P.RestStream.micro0.micro0.s3.ctl = false := by host_kernel_rfl
theorem source_active4 : isHalt P.RestStream.micro0.micro0.s4.ctl = false := by host_kernel_rfl
theorem source_active5 : isHalt P.RestStream.micro0.micro0.s5.ctl = false := by host_kernel_rfl
theorem source_active6 : isHalt P.RestStream.micro0.micro0.s6.ctl = false := by host_kernel_rfl
theorem source_active7 : isHalt P.RestStream.micro0.micro0.s7.ctl = false := by host_kernel_rfl
theorem first_eight_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s) :
    ∃ result, runC P.F 8 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        P.RestStream.micro0.micro0.s8 result := by
  obtain ⟨v0,hr0,h1,_⟩ := FirstVariable.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s h
  let s1 := s.ret v0
  obtain ⟨s2,hr1,h2⟩ := Structural1.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s1 h1
  obtain ⟨hr2,h3,_,_⟩ := FirstLiteral.transport FR R ν₀ ν C₀ C live framed before after old old' s2 h2
  let s3 := s2.ret FirstLiteral.sourceValue
  obtain ⟨s4,hr3,h4⟩ := Structural3.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s3 h3
  obtain ⟨s5,hr4,h5⟩ := Structural4.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s4 h4
  obtain ⟨v5,hr5,h6,_⟩ := Variable5.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s5 h5
  let s6 := s5.ret v5
  obtain ⟨s7,hr6,h7⟩ := Structural6.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s6 h6
  obtain ⟨hr7,h8,_,_⟩ := Literal7.transport FR R ν₀ ν C₀ C live framed before after old old' s7 h7
  let result := s7.ret Literal7.sourceValue
  refine ⟨result,?_,h8⟩
  apply runC_cons P.F 7 s s1 result C C C (h.control.isHalt_eq.trans source_active0) hr0
  apply runC_cons P.F 6 s1 s2 result C C C (h1.control.isHalt_eq.trans source_active1) hr1
  apply runC_cons P.F 5 s2 s3 result C C C (h2.control.isHalt_eq.trans source_active2) hr2
  apply runC_cons P.F 4 s3 s4 result C C C (h3.control.isHalt_eq.trans source_active3) hr3
  apply runC_cons P.F 3 s4 s5 result C C C (h4.control.isHalt_eq.trans source_active4) hr4
  apply runC_cons P.F 2 s5 s6 result C C C (h5.control.isHalt_eq.trans source_active5) hr5
  apply runC_cons P.F 1 s6 s7 result C C C (h6.control.isHalt_eq.trans source_active6) hr6
  apply runC_cons P.F 0 s7 result result C C C (h7.control.isHalt_eq.trans source_active7) hr7
  rfl
end Host.Load.Run.Full.Ordinary
