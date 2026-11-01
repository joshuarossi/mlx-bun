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

kernel_rfl bodyO659 : PRE_first_tail_x15_r0_body.S659.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S659.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr659 : bridgeOf PRE_first_tail_x15_r0_body.s659.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc659 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.S659) = fun _ _ => true
kernel_rfl bodyAcc660 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s660 PRE_first_tail_x15_r0_body.S660) = fun _ _ => true
kernel_rfl bodyBr661 : bridgeOf PRE_first_tail_x15_r0_body.s661.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt660 : isHalt PRE_first_tail_x15_r0_body.s660.ctl = false
kernel_rfl bodyTop661 : noRetBlock PRE_first_tail_x15_r0_body.s661 = true
kernel_rfl bodyCnt659 : countersOkB PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.s661 = true

theorem bodyGlue68 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26875, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.S659)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26875, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s661 PRE_first_tail_x15_r0_body.S661) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26875, 481, 0, 369⟩) bodyAcc659 PRE_first_tail_x15_r0_body.bodyRunSeg178 bodyAcc660 bodyHalt660 PRE_first_tail_x15_r0_body.bodyStepA179 bodyTop661 (fun _ hm => bodyO659 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr659).trans bodyInactive0) (bodyBr661.trans bodyBr659.symm) bodyCnt659 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
