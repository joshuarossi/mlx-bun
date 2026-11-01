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

kernel_rfl bodyO881 : PRE_first_tail_x15_r0_body.S881.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S881.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr881 : bridgeOf PRE_first_tail_x15_r0_body.s881.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc881 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s881 PRE_first_tail_x15_r0_body.S881) = fun _ _ => true
kernel_rfl bodyAcc882 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s882 PRE_first_tail_x15_r0_body.S882) = fun _ _ => true
kernel_rfl bodyBr883 : bridgeOf PRE_first_tail_x15_r0_body.s883.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt882 : isHalt PRE_first_tail_x15_r0_body.s882.ctl = false
kernel_rfl bodyTop883 : noRetBlock PRE_first_tail_x15_r0_body.s883 = true
kernel_rfl bodyCnt881 : countersOkB PRE_first_tail_x15_r0_body.s881 PRE_first_tail_x15_r0_body.s883 = true
kernel_rfl bodyO883 : PRE_first_tail_x15_r0_body.S883.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S883.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr884 : bridgeOf PRE_first_tail_x15_r0_body.s884.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt883 : countersOkB PRE_first_tail_x15_r0_body.s883 PRE_first_tail_x15_r0_body.s884 = true
kernel_rfl bodyO884 : PRE_first_tail_x15_r0_body.S884.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S884.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc884 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s884 PRE_first_tail_x15_r0_body.S884) = fun _ _ => true
kernel_rfl bodyAcc886 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s886 PRE_first_tail_x15_r0_body.S886) = fun _ _ => true
kernel_rfl bodyBr887 : bridgeOf PRE_first_tail_x15_r0_body.s887.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt886 : isHalt PRE_first_tail_x15_r0_body.s886.ctl = false
kernel_rfl bodyTop887 : noRetBlock PRE_first_tail_x15_r0_body.s887 = true
kernel_rfl bodyCnt884 : countersOkB PRE_first_tail_x15_r0_body.s884 PRE_first_tail_x15_r0_body.s887 = true

theorem bodyGlue91 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34572, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s881 PRE_first_tail_x15_r0_body.S881)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34572, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s887 PRE_first_tail_x15_r0_body.S887) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34572, 635, 0, 495⟩) bodyAcc881 PRE_first_tail_x15_r0_body.bodyRunSeg238 bodyAcc882 bodyHalt882 PRE_first_tail_x15_r0_body.bodyStepA239 bodyTop883 (fun _ hm => bodyO881 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr881).trans bodyInactive0) (bodyBr883.trans bodyBr881.symm) bodyCnt881 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34572, 635, 0, 495⟩) PRE_first_tail_x15_r0_body.sizeA239 PRE_first_tail_x15_r0_body.sizeArgsA239 PRE_first_tail_x15_r0_body.sizeSymA239 PRE_first_tail_x15_r0_body.sizeMlxA239 PRE_first_tail_x15_r0_body.sizePayA239 PRE_first_tail_x15_r0_body.sizeTaA239 PRE_first_tail_x15_r0_body.sizeDecA239 PRE_first_tail_x15_r0_body.sizePreA239 PRE_first_tail_x15_r0_body.bodyPatchB239 (fun _ hm => bodyO883 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr883).trans bodyInactive0) (bodyBr884.trans bodyBr883.symm) bodyCnt883 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34572, 635, 0, 495⟩) bodyAcc884 PRE_first_tail_x15_r0_body.bodyRunSeg239 bodyAcc886 bodyHalt886 PRE_first_tail_x15_r0_body.bodyStepA240 bodyTop887 (fun _ hm => bodyO884 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr884).trans bodyInactive0) (bodyBr887.trans bodyBr884.symm) bodyCnt884 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
