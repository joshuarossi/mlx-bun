import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw15.VWBodyChain
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1780 : PRE_first_tail_x15_r0_body.S1780.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1780.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1780 : bridgeOf PRE_first_tail_x15_r0_body.s1780.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1780 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1780 PRE_first_tail_x15_r0_body.S1780) = fun _ _ => true
kernel_rfl bodyAcc1781 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1781 PRE_first_tail_x15_r0_body.S1781) = fun _ _ => true
kernel_rfl bodyBr1782 : bridgeOf PRE_first_tail_x15_r0_body.s1782.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1781 : isHalt PRE_first_tail_x15_r0_body.s1781.ctl = false
kernel_rfl bodyTop1782 : noRetBlock PRE_first_tail_x15_r0_body.s1782 = true
kernel_rfl bodyCnt1780 : countersOkB PRE_first_tail_x15_r0_body.s1780 PRE_first_tail_x15_r0_body.s1782 = true

theorem bodyGlue185 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64308, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1780 PRE_first_tail_x15_r0_body.S1780)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64308, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1782 PRE_first_tail_x15_r0_body.S1782) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64308, 1226, 0, 981⟩) bodyAcc1780 PRE_first_tail_x15_r0_body.bodyRunSeg480 bodyAcc1781 bodyHalt1781 PRE_first_tail_x15_r0_body.bodyStepA481 bodyTop1782 (fun _ hm => bodyO1780 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1780).trans bodyInactive0) (bodyBr1782.trans bodyBr1780.symm) bodyCnt1780 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
