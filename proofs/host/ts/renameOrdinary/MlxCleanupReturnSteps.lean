import host.ts.renameOrdinary.MlxCleanupSteps
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
host_transport_return P.F, P.RestStream.micro0.micro4.s22 to P.RestStream.micro0.micro4.s23 as FinalizerBlock422
host_transport_return P.F, P.RestStream.micro0.micro4.s23 to P.RestStream.micro0.micro4.s24 as FinalizerScope423
host_transport_return P.F, P.RestStream.micro0.micro4.s25 to P.RestStream.micro0.micro4.s26 as ConcatBlock425
host_transport_return P.F, P.RestStream.micro0.micro4.s26 to P.RestStream.micro0.micro4.s27 as ConcatScope426
host_transport_return P.F, P.RestStream.micro0.micro4.s27 to P.RestStream.micro0.micro4.s28 as ConcatReturn427
end Host.Load.Run.Full.Ordinary.VectorToConcat
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.FinalizerResume424
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro4.s24
noncomputable def output : St LSt := P.RestStream.micro0.micro4.s25
noncomputable def sourceTail : List Frame := input.stack.tail
theorem source_control : input.ctl = .ret .undef := by host_kernel_rfl
theorem source_frame : input.stack = .s (.finally_ (.abrupt (.ret (.obj 3126703))))::sourceTail := by host_kernel_rfl
theorem source_post : {input with stack := sourceTail}.go (.abr (.ret (.obj 3126703))) = output := by host_kernel_rfl

theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt) (h : StateR NR FR R live framed before after old old' input s) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' output result ∧ result.heap = s.heap := by
  obtain ⟨value,fs,_,run,related⟩ := step_finally_return_from_source P.F NR FR R C₀ C live framed before after old old'
    input s h .undef (.obj 3126703) sourceTail source_control source_frame
  exact ⟨_,run,source_post ▸ related,rfl⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.FinalizerResume424
