import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriverPreparation
import host.ts.RenameRouteDriverStructural
import host.ts.RenameRouteComposition
import host.ts.RenameParametricArrayBinding

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full.Ordinary

host_transport_preparation P.F, P.RestStream.micro0.micro0.s25 to P.RestStream.micro0.micro0.s26 as Preparation25
host_transport_preparation P.F, P.RestStream.micro0.micro0.s26 to P.RestStream.micro0.micro0.s27 as Preparation26
host_transport_preparation P.F, P.RestStream.micro0.micro0.s27 to P.RestStream.micro0.micro0.s28 as Preparation27
host_transport_step P.F, P.RestStream.micro0.micro0.s28 to P.RestStream.micro0.micro0.s29 as Preparation28
host_transport_preparation P.F, P.RestStream.micro0.micro0.s29 to P.RestStream.micro0.micro0.s30 as Preparation29
host_transport_preparation P.F, P.RestStream.micro0.micro0.s30 to P.RestStream.micro0.micro0.s31 as Preparation30
host_transport_preparation P.F, P.RestStream.micro0.micro0.s31 to P.RestStream.micro0.micro0.s32 as Preparation31
host_transport_step P.F, P.RestStream.micro0.micro0.s32 to P.RestStream.micro0.micro0.s33 as Preparation32
host_transport_preparation P.F, P.RestStream.micro0.micro0.s33 to P.RestStream.micro0.micro0.s34 as Preparation33
host_transport_step P.F, P.RestStream.micro0.micro0.s34 to P.RestStream.micro0.micro0.s35 as Preparation34
host_transport_preparation P.F, P.RestStream.micro0.micro0.s35 to P.RestStream.micro0.micro0.s36 as Preparation35
host_transport_structural P.F, P.RestStream.micro0.micro0.s36 to P.RestStream.micro0.micro0.s37 as Preparation36
host_transport_step P.F, P.RestStream.micro0.micro0.s37 to P.RestStream.micro0.micro0.s38 as Preparation37
host_transport_structural P.F, P.RestStream.micro0.micro0.s38 to P.RestStream.micro0.micro0.s39 as Preparation38

open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem preparation_active25 : isHalt P.RestStream.micro0.micro0.s25.ctl = false := by host_kernel_rfl
theorem preparation_active26 : isHalt P.RestStream.micro0.micro0.s26.ctl = false := by host_kernel_rfl
theorem preparation_active27 : isHalt P.RestStream.micro0.micro0.s27.ctl = false := by host_kernel_rfl
theorem preparation_active28 : isHalt P.RestStream.micro0.micro0.s28.ctl = false := by host_kernel_rfl
theorem preparation_active29 : isHalt P.RestStream.micro0.micro0.s29.ctl = false := by host_kernel_rfl
theorem preparation_active30 : isHalt P.RestStream.micro0.micro0.s30.ctl = false := by host_kernel_rfl
theorem preparation_active31 : isHalt P.RestStream.micro0.micro0.s31.ctl = false := by host_kernel_rfl
theorem preparation_active32 : isHalt P.RestStream.micro0.micro0.s32.ctl = false := by host_kernel_rfl
theorem preparation_active33 : isHalt P.RestStream.micro0.micro0.s33.ctl = false := by host_kernel_rfl
theorem preparation_active34 : isHalt P.RestStream.micro0.micro0.s34.ctl = false := by host_kernel_rfl
theorem preparation_active35 : isHalt P.RestStream.micro0.micro0.s35.ctl = false := by host_kernel_rfl
theorem preparation_active36 : isHalt P.RestStream.micro0.micro0.s36.ctl = false := by host_kernel_rfl
theorem preparation_active37 : isHalt P.RestStream.micro0.micro0.s37.ctl = false := by host_kernel_rfl
theorem preparation_active38 : isHalt P.RestStream.micro0.micro0.s38.ctl = false := by host_kernel_rfl
theorem preparation_next35 : P.RestStream.micro0.micro0.s35.next = P.RestStream.micro0.micro0.s25.next := by host_kernel_rfl

/-- The actual caller resolves `ops.concatAxis` through its namespace export,
evaluates both real array arguments, allocates their array and calls the method. -/
theorem concat_preparation_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s25 s)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (targetBound : s.next < 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live P.RestStream.micro0.micro0.s35.next)
        framed before after old old' P.RestStream.micro0.micro0.s39 result := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨s26,hr25,h26⟩ := Preparation25.transport NR FR R C₀ C live framed before after old old' s h
  obtain ⟨s27,hr26,h27⟩ := Preparation26.transport NR FR R C₀ C live framed before after old old' s26 h26
  obtain ⟨s28,hr27,h28⟩ := Preparation27.transport NR FR R C₀ C live framed before after old old' s27 h27
  obtain ⟨v28,hr28,h29,_⟩ := Preparation28.transport NR FR R C₀ C live framed before after old old' s28 h28
  let s29 := s28.ret v28
  obtain ⟨s30,hr29,h30⟩ := Preparation29.transport NR FR R C₀ C live framed before after old old' s29 h29
  obtain ⟨s31,hr30,h31⟩ := Preparation30.transport NR FR R C₀ C live framed before after old old' s30 h30
  obtain ⟨s32,hr31,h32⟩ := Preparation31.transport NR FR R C₀ C live framed before after old old' s31 h31
  obtain ⟨v32,hr32,h33,_⟩ := Preparation32.transport NR FR R C₀ C live framed before after old old' s32 h32
  let s33 := s32.ret v32
  obtain ⟨s34,hr33,h34⟩ := Preparation33.transport NR FR R C₀ C live framed before after old old' s33 h33
  obtain ⟨v34,hr34,h35,_⟩ := Preparation34.transport NR FR R C₀ C live framed before after old old' s34 h34
  let s35 := s34.ret v34
  have hb35 : s35.next < 2^64 := by
    calc s35.next = s.next := h.target_next_eq h35 preparation_next35
      _ < 2^64 := targetBound
  obtain ⟨s36,hr35,h36⟩ := Preparation35.transport NR FR R C₀ C live framed before after old old' s35 h35
    prototypeLive prototypeFixed hb35
  let live' := LiveAfter live P.RestStream.micro0.micro0.s35.next
  obtain ⟨s37,hr36,h37⟩ := Preparation36.transport NR FR R C₀ C live' framed before after old old' s36 h36
  obtain ⟨hr37,h38,_,_⟩ := Preparation37.transport FR R ν₀ ν C₀ C live' framed before after old old' s37 h37
  let s38 := s37.ret Preparation37.sourceValue
  obtain ⟨result,hr38,h39⟩ := Preparation38.transport NR FR R C₀ C live' framed before after old old' s38 h38
  refine ⟨result,?_,h39⟩
  apply runC_cons P.F 13 s s26 result C C C (h.control.isHalt_eq.trans preparation_active25) hr25
  apply runC_cons P.F 12 s26 s27 result C C C (h26.control.isHalt_eq.trans preparation_active26) hr26
  apply runC_cons P.F 11 s27 s28 result C C C (h27.control.isHalt_eq.trans preparation_active27) hr27
  apply runC_cons P.F 10 s28 s29 result C C C (h28.control.isHalt_eq.trans preparation_active28) hr28
  apply runC_cons P.F 9 s29 s30 result C C C (h29.control.isHalt_eq.trans preparation_active29) hr29
  apply runC_cons P.F 8 s30 s31 result C C C (h30.control.isHalt_eq.trans preparation_active30) hr30
  apply runC_cons P.F 7 s31 s32 result C C C (h31.control.isHalt_eq.trans preparation_active31) hr31
  apply runC_cons P.F 6 s32 s33 result C C C (h32.control.isHalt_eq.trans preparation_active32) hr32
  apply runC_cons P.F 5 s33 s34 result C C C (h33.control.isHalt_eq.trans preparation_active33) hr33
  apply runC_cons P.F 4 s34 s35 result C C C (h34.control.isHalt_eq.trans preparation_active34) hr34
  apply runC_cons P.F 3 s35 s36 result C C C (h35.control.isHalt_eq.trans preparation_active35) hr35
  apply runC_cons P.F 2 s36 s37 result C C C (h36.control.isHalt_eq.trans preparation_active36) hr36
  apply runC_cons P.F 1 s37 s38 result C C C (h37.control.isHalt_eq.trans preparation_active37) hr37
  apply runC_cons P.F 0 s38 result result C C C (h38.control.isHalt_eq.trans preparation_active38) hr38
  rfl

/-- error: host_transport_step: unsupported source constructor Host.Ts.Ctl.construct -/
#guard_msgs in
host_transport_preparation P.F, P.RestStream.micro0.micro0.s12 to P.RestStream.micro0.micro0.s13 as UnsupportedConstructPreparation

end Host.Load.Run.Full.Ordinary
