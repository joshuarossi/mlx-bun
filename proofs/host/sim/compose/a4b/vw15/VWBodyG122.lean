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

kernel_rfl bodyO1176 : PRE_first_tail_x15_r0_body.S1176.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1176.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1176 : bridgeOf PRE_first_tail_x15_r0_body.s1176.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1176 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.S1176) = fun _ _ => true
kernel_rfl bodyAcc1177 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1177 PRE_first_tail_x15_r0_body.S1177) = fun _ _ => true
kernel_rfl bodyBr1178 : bridgeOf PRE_first_tail_x15_r0_body.s1178.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1177 : isHalt PRE_first_tail_x15_r0_body.s1177.ctl = false
kernel_rfl bodyTop1178 : noRetBlock PRE_first_tail_x15_r0_body.s1178 = true
kernel_rfl bodyCnt1176 : countersOkB PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.s1178 = true

theorem bodyGlue122 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨43814, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.S1176)
      (bodyCut NB T tk π i x0 bodyΘ ⟨43814, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1178 PRE_first_tail_x15_r0_body.S1178) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨43814, 816, 0, 648⟩) bodyAcc1176 PRE_first_tail_x15_r0_body.bodyRunSeg317 bodyAcc1177 bodyHalt1177 PRE_first_tail_x15_r0_body.bodyStepA318 bodyTop1178 (fun _ hm => bodyO1176 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1176).trans bodyInactive0) (bodyBr1178.trans bodyBr1176.symm) bodyCnt1176 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
