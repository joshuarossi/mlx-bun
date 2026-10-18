import host.ts.renameOrdinary.PrefixAxis
import host.ts.RenamePreparationHeap
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem concat_preparation_axis_frame_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s25 s)
    (prototypeLive : live aArrayProto) (prototypeFixed : R.a aArrayProto = aArrayProto)
    (targetBound : s.next < 2^64) :
    ∃ result, runC P.F 14 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live P.RestStream.micro0.micro0.s35.next)
        framed before after old old' P.RestStream.micro0.micro0.s39 result ∧
      callArgument result.ctl 1 = natV 1 ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
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
  refine ⟨result,?_,h39,?_,?_⟩
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

  · intro a ha
    have hh26 := step_block_next_heap P.F NR FR R live framed before after old old' Preparation25.input s s26 C C h
      Preparation25.sourceValue Preparation25.sourceStatement Preparation25.sourceRest Preparation25.sourceEnv Preparation25.sourceTail Preparation25.source_control Preparation25.source_frame hr25
    have hh27 := step_statement_heap P.F NR FR R live framed before after old old' Preparation26.input s26 s27 C C h26
      Preparation26.sourceAction Preparation26.sourceEnv Preparation26.source_control hr26
    have hh28 := step_method_descent_heap P.F NR FR R live framed before after old old' Preparation27.input s27 s28 C₀ C C h27
      Preparation27.sourceExpression Preparation27.sourceName Preparation27.sourceArgs Preparation27.sourceEnv
      Preparation27.sourceOptObject Preparation27.sourceOptCall Preparation27.source_control hr27
    have hh29 : s29.heap = s28.heap := rfl
    have hh30 := step_namespace_method_heap P.F NR FR R live framed before after old old' Preparation29.input s29 s30 C C h29
      Preparation29.sourceAddress Preparation29.sourceObject Preparation29.sourceExports Preparation29.sourceName Preparation29.sourceArgs Preparation29.sourceEnv Preparation29.sourceOptObject Preparation29.sourceOptCall Preparation29.sourceCell Preparation29.sourceMethod Preparation29.sourceTail Preparation29.source_control Preparation29.source_frame Preparation29.source_heap Preparation29.source_kind Preparation29.source_export Preparation29.source_cell hr29
    have hh31 := step_callStart_heap P.F NR FR R live framed before after old old' Preparation30.input s30 s31 C C h30
      Preparation30.sourceMode Preparation30.sourceAddress Preparation30.sourceThis Preparation30.sourceArgs Preparation30.sourceEnv Preparation30.sourceTail Preparation30.source_control Preparation30.source_frame hr30
    have hh32 := step_array_entry_heap P.F NR FR R live framed before after old old' Preparation31.input s31 s32 C C h31
      Preparation31.sourceExpression Preparation31.sourceRest Preparation31.sourceEnv Preparation31.source_control hr31
    have hh33 : s33.heap = s32.heap := rfl
    have hh34 := step_array_next_heap P.F NR FR R live framed before after old old' Preparation33.input s33 s34 C C h33
      Preparation33.sourceValue Preparation33.sourceAcc Preparation33.sourceExpression Preparation33.sourceRest Preparation33.sourceEnv Preparation33.sourceTail Preparation33.source_control Preparation33.source_frame hr33
    have hh35 : s35.heap = s34.heap := rfl
    have next35 : s35.next = s.next := h.target_next_eq h35 preparation_next35
    have hh36 := step_array_final_heap_below P.F NR FR R live framed before after old old' Preparation35.input s35 s36 C C h35
      Preparation35.sourceValue Preparation35.sourceAcc Preparation35.sourceEnv Preparation35.sourceTail
      Preparation35.source_control Preparation35.source_frame hb35 hr35 a (by omega)
    have hh37 := step_argument_heap_from_source P.F NR FR R live' framed before after old old' Preparation36.input s36 s37 C C h36
      Preparation36.sourceValue Preparation36.sourceKind Preparation36.sourceFunction Preparation36.sourceThis Preparation36.sourceAcc Preparation36.sourceRest Preparation36.sourceEnv Preparation36.sourceTail Preparation36.source_control Preparation36.source_frame (by decide) hr36
    have hh39 := step_argument_heap_from_source P.F NR FR R live' framed before after old old' Preparation38.input s38 result C C h38
      Preparation38.sourceValue Preparation38.sourceKind Preparation38.sourceFunction Preparation38.sourceThis Preparation38.sourceAcc Preparation38.sourceRest Preparation38.sourceEnv Preparation38.sourceTail Preparation38.source_control Preparation38.source_frame (by decide) hr38
    have hh38 : s38.heap = s37.heap := rfl
    rw [hh39,hh38,hh37,hh36,hh35,hh34,hh33,hh32,hh31,hh30,hh29,hh28,hh27,hh26]

end Host.Load.Run.Full.Ordinary
