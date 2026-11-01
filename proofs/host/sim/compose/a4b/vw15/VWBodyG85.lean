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

kernel_rfl bodyO823 : PRE_first_tail_x15_r0_body.S823.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S823.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr823 : bridgeOf PRE_first_tail_x15_r0_body.s823.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc823 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s823 PRE_first_tail_x15_r0_body.S823) = fun _ _ => true
kernel_rfl bodyAcc824 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s824 PRE_first_tail_x15_r0_body.S824) = fun _ _ => true
kernel_rfl bodyBr825 : bridgeOf PRE_first_tail_x15_r0_body.s825.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt824 : isHalt PRE_first_tail_x15_r0_body.s824.ctl = false
kernel_rfl bodyTop825 : noRetBlock PRE_first_tail_x15_r0_body.s825 = true
kernel_rfl bodyCnt823 : countersOkB PRE_first_tail_x15_r0_body.s823 PRE_first_tail_x15_r0_body.s825 = true
kernel_rfl bodyO825 : PRE_first_tail_x15_r0_body.S825.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S825.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr826 : bridgeOf PRE_first_tail_x15_r0_body.s826.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt825 : countersOkB PRE_first_tail_x15_r0_body.s825 PRE_first_tail_x15_r0_body.s826 = true
kernel_rfl bodyO826 : PRE_first_tail_x15_r0_body.S826.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S826.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc826 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s826 PRE_first_tail_x15_r0_body.S826) = fun _ _ => true
kernel_rfl bodyAcc828 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s828 PRE_first_tail_x15_r0_body.S828) = fun _ _ => true
kernel_rfl bodyBr829 : bridgeOf PRE_first_tail_x15_r0_body.s829.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt828 : isHalt PRE_first_tail_x15_r0_body.s828.ctl = false
kernel_rfl bodyTop829 : noRetBlock PRE_first_tail_x15_r0_body.s829 = true
kernel_rfl bodyCnt826 : countersOkB PRE_first_tail_x15_r0_body.s826 PRE_first_tail_x15_r0_body.s829 = true

theorem bodyGlue85 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨32241, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s823 PRE_first_tail_x15_r0_body.S823)
      (bodyCut NB T tk π i x0 bodyΘ ⟨32241, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s829 PRE_first_tail_x15_r0_body.S829) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32241, 585, 0, 459⟩) bodyAcc823 PRE_first_tail_x15_r0_body.bodyRunSeg222 bodyAcc824 bodyHalt824 PRE_first_tail_x15_r0_body.bodyStepA223 bodyTop825 (fun _ hm => bodyO823 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr823).trans bodyInactive0) (bodyBr825.trans bodyBr823.symm) bodyCnt823 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32241, 585, 0, 459⟩) PRE_first_tail_x15_r0_body.sizeA223 PRE_first_tail_x15_r0_body.sizeArgsA223 PRE_first_tail_x15_r0_body.sizeSymA223 PRE_first_tail_x15_r0_body.sizeMlxA223 PRE_first_tail_x15_r0_body.sizePayA223 PRE_first_tail_x15_r0_body.sizeTaA223 PRE_first_tail_x15_r0_body.sizeDecA223 PRE_first_tail_x15_r0_body.sizePreA223 PRE_first_tail_x15_r0_body.bodyPatchB223 (fun _ hm => bodyO825 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr825).trans bodyInactive0) (bodyBr826.trans bodyBr825.symm) bodyCnt825 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32241, 585, 0, 459⟩) bodyAcc826 PRE_first_tail_x15_r0_body.bodyRunSeg223 bodyAcc828 bodyHalt828 PRE_first_tail_x15_r0_body.bodyStepA224 bodyTop829 (fun _ hm => bodyO826 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr826).trans bodyInactive0) (bodyBr829.trans bodyBr826.symm) bodyCnt826 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
