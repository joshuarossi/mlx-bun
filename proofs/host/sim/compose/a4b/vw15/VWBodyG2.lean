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

kernel_rfl bodyO26 : PRE_first_tail_x15_r0_body.S26.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S26.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr26 : bridgeOf PRE_first_tail_x15_r0_body.s26.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc26 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s26 PRE_first_tail_x15_r0_body.S26) = fun _ _ => true
kernel_rfl bodyAcc27 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s27 PRE_first_tail_x15_r0_body.S27) = fun _ _ => true
kernel_rfl bodyBr28 : bridgeOf PRE_first_tail_x15_r0_body.s28.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt27 : isHalt PRE_first_tail_x15_r0_body.s27.ctl = false
kernel_rfl bodyTop28 : noRetBlock PRE_first_tail_x15_r0_body.s28 = true
kernel_rfl bodyCnt26 : countersOkB PRE_first_tail_x15_r0_body.s26 PRE_first_tail_x15_r0_body.s28 = true

theorem bodyGlue2 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5265, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s26 PRE_first_tail_x15_r0_body.S26)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5265, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s28 PRE_first_tail_x15_r0_body.S28) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5265, 46, 0, 18⟩) bodyAcc26 PRE_first_tail_x15_r0_body.bodyRunSeg7 bodyAcc27 bodyHalt27 PRE_first_tail_x15_r0_body.bodyStepA8 bodyTop28 (fun _ hm => bodyO26 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr26).trans bodyInactive0) (bodyBr28.trans bodyBr26.symm) bodyCnt26 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
