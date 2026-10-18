import host.ts.RenameRouteDriverArithmetic
import host.ts.renameOrdinary.DriverPrefix
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
host_transport_arithmetic P.F, P.RestStream.micro0.micro0.s8 to P.RestStream.micro0.micro0.s9 as Arithmetic8
end Host.Load.Run.Full.Ordinary
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
host_transport_structural P.F, P.RestStream.micro0.micro0.s9 to P.RestStream.micro0.micro0.s10 as Structural9

theorem source_active8 : isHalt P.RestStream.micro0.micro0.s8.ctl = false := by host_kernel_rfl
theorem source_active9 : isHalt P.RestStream.micro0.micro0.s9.ctl = false := by host_kernel_rfl

/-- The actual shape-pointer argument prefix reaches the native buffer call.
The multiplication executes on the target numeric server and its real table
extension is retained. Literal decoder annotations are a separate obligation. -/
theorem first_ten_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s) :
    ∃ (result : St P.F.S) (D : CSrv), runC P.F 10 s C = some (result,D) ∧
      StateR (NumberRoles ν₀ ν C₀ D) FR R live framed before after old old'
        P.RestStream.micro0.micro0.s10 result ∧ TableExtends C D := by
  obtain ⟨s8,hr8,h8⟩ := first_eight_transport FR R ν₀ ν C₀ C live framed before after old old' s h
  obtain ⟨s9,D,hr9,h9,he⟩ := Arithmetic8.transport FR R ν₀ ν C₀ C live framed before after old old' s8 h8
  obtain ⟨s10,hr10,h10⟩ := Structural9.transport (NumberRoles ν₀ ν C₀ D) FR R C₀ D
    live framed before after old old' s9 h9
  have one : runC P.F 1 s9 D = some (s10,D) :=
    runC_cons P.F 0 s9 s10 s10 D D D (h9.control.isHalt_eq.trans source_active9) hr10 rfl
  have two : runC P.F 2 s8 C = some (s10,D) :=
    runC_cons P.F 1 s8 s9 s10 C D D (h8.control.isHalt_eq.trans source_active8) hr9 one
  exact ⟨s10,D,runC_join P.F hr8 two,h10,he⟩
end Host.Load.Run.Full.Ordinary
