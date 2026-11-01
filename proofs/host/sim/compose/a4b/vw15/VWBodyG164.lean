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

kernel_rfl bodyO1579 : PRE_first_tail_x15_r0_body.S1579.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1579.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1579 : bridgeOf PRE_first_tail_x15_r0_body.s1579.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1579 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1579 PRE_first_tail_x15_r0_body.S1579) = fun _ _ => true
kernel_rfl bodyAcc1580 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1580 PRE_first_tail_x15_r0_body.S1580) = fun _ _ => true
kernel_rfl bodyBr1581 : bridgeOf PRE_first_tail_x15_r0_body.s1581.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1580 : isHalt PRE_first_tail_x15_r0_body.s1580.ctl = false
kernel_rfl bodyTop1581 : noRetBlock PRE_first_tail_x15_r0_body.s1581 = true
kernel_rfl bodyCnt1579 : countersOkB PRE_first_tail_x15_r0_body.s1579 PRE_first_tail_x15_r0_body.s1581 = true

theorem bodyGlue164 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨57716, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1579 PRE_first_tail_x15_r0_body.S1579)
      (bodyCut NB T tk π i x0 bodyΘ ⟨57716, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1581 PRE_first_tail_x15_r0_body.S1581) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57716, 1097, 0, 873⟩) bodyAcc1579 PRE_first_tail_x15_r0_body.bodyRunSeg426 bodyAcc1580 bodyHalt1580 PRE_first_tail_x15_r0_body.bodyStepA427 bodyTop1581 (fun _ hm => bodyO1579 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1579).trans bodyInactive0) (bodyBr1581.trans bodyBr1579.symm) bodyCnt1579 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
