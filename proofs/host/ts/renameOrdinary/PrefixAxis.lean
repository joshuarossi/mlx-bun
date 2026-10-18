import host.ts.renameOrdinary.DriverPreparation
import host.ts.RenameRouteArgumentFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The actual literal expression for concat's axis survives argument collection. -/
theorem concat_preparation_axis_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s25 s)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (targetBound : s.next < 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live P.RestStream.micro0.micro0.s35.next)
        framed before after old old' P.RestStream.micro0.micro0.s39 result ∧
      callArgument result.ctl 1 = natV 1 := by
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
  refine ⟨result,?_,h39,?_⟩
  · apply runC_cons P.F 13 s s26 result C C C (h.control.isHalt_eq.trans preparation_active25) hr25
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
  · have hf : Preparation38.input.stack = .c (.args 0 Preparation38.sourceFunction Preparation38.sourceThis
        Preparation38.sourceAcc [] Preparation38.sourceEnv)::Preparation38.sourceTail := by host_kernel_rfl
    have hn : Preparation38.sourceAcc.length = 1 := by host_kernel_rfl
    have hv : Preparation37.sourceValue = natV 1 := by host_kernel_rfl
    have ha := step_argument_last P.F NR FR R live' framed before after old old' Preparation38.input s38 result C C h38
      Preparation38.sourceValue Preparation37.sourceValue Preparation38.sourceFunction Preparation38.sourceThis
      Preparation38.sourceAcc Preparation38.sourceEnv Preparation38.sourceTail Preparation38.source_control rfl hf hr38
    simpa only [hn,hv] using ha

end Host.Load.Run.Full.Ordinary
