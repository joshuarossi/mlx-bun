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

kernel_rfl bodyO112 : PRE_first_tail_x15_r0_body.S112.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S112.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr112 : bridgeOf PRE_first_tail_x15_r0_body.s112.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc112 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.S112) = fun _ _ => true
kernel_rfl bodyAcc113 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s113 PRE_first_tail_x15_r0_body.S113) = fun _ _ => true
kernel_rfl bodyBr114 : bridgeOf PRE_first_tail_x15_r0_body.s114.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt113 : isHalt PRE_first_tail_x15_r0_body.s113.ctl = false
kernel_rfl bodyTop114 : noRetBlock PRE_first_tail_x15_r0_body.s114 = true
kernel_rfl bodyCnt112 : countersOkB PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.s114 = true

theorem bodyGlue11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7958, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.S112)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7958, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s114 PRE_first_tail_x15_r0_body.S114) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7958, 98, 0, 63⟩) bodyAcc112 PRE_first_tail_x15_r0_body.bodyRunSeg30 bodyAcc113 bodyHalt113 PRE_first_tail_x15_r0_body.bodyStepA31 bodyTop114 (fun _ hm => bodyO112 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr112).trans bodyInactive0) (bodyBr114.trans bodyBr112.symm) bodyCnt112 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
