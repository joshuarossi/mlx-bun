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

kernel_rfl bodyO766 : PRE_first_tail_x15_r0_body.S766.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S766.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr766 : bridgeOf PRE_first_tail_x15_r0_body.s766.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc766 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s766 PRE_first_tail_x15_r0_body.S766) = fun _ _ => true
kernel_rfl bodyAcc767 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s767 PRE_first_tail_x15_r0_body.S767) = fun _ _ => true
kernel_rfl bodyBr768 : bridgeOf PRE_first_tail_x15_r0_body.s768.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt767 : isHalt PRE_first_tail_x15_r0_body.s767.ctl = false
kernel_rfl bodyTop768 : noRetBlock PRE_first_tail_x15_r0_body.s768 = true
kernel_rfl bodyCnt766 : countersOkB PRE_first_tail_x15_r0_body.s766 PRE_first_tail_x15_r0_body.s768 = true
kernel_rfl bodyO768 : PRE_first_tail_x15_r0_body.S768.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S768.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr769 : bridgeOf PRE_first_tail_x15_r0_body.s769.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt768 : countersOkB PRE_first_tail_x15_r0_body.s768 PRE_first_tail_x15_r0_body.s769 = true
kernel_rfl bodyO769 : PRE_first_tail_x15_r0_body.S769.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S769.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc769 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s769 PRE_first_tail_x15_r0_body.S769) = fun _ _ => true
kernel_rfl bodyAcc771 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s771 PRE_first_tail_x15_r0_body.S771) = fun _ _ => true
kernel_rfl bodyBr772 : bridgeOf PRE_first_tail_x15_r0_body.s772.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt771 : isHalt PRE_first_tail_x15_r0_body.s771.ctl = false
kernel_rfl bodyTop772 : noRetBlock PRE_first_tail_x15_r0_body.s772 = true
kernel_rfl bodyCnt769 : countersOkB PRE_first_tail_x15_r0_body.s769 PRE_first_tail_x15_r0_body.s772 = true

theorem bodyGlue79 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30718, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s766 PRE_first_tail_x15_r0_body.S766)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30718, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s772 PRE_first_tail_x15_r0_body.S772) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30718, 558, 0, 432⟩) bodyAcc766 PRE_first_tail_x15_r0_body.bodyRunSeg207 bodyAcc767 bodyHalt767 PRE_first_tail_x15_r0_body.bodyStepA208 bodyTop768 (fun _ hm => bodyO766 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr766).trans bodyInactive0) (bodyBr768.trans bodyBr766.symm) bodyCnt766 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30718, 558, 0, 432⟩) PRE_first_tail_x15_r0_body.sizeA208 PRE_first_tail_x15_r0_body.sizeArgsA208 PRE_first_tail_x15_r0_body.sizeSymA208 PRE_first_tail_x15_r0_body.sizeMlxA208 PRE_first_tail_x15_r0_body.sizePayA208 PRE_first_tail_x15_r0_body.sizeTaA208 PRE_first_tail_x15_r0_body.sizeDecA208 PRE_first_tail_x15_r0_body.sizePreA208 PRE_first_tail_x15_r0_body.bodyPatchB208 (fun _ hm => bodyO768 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr768).trans bodyInactive0) (bodyBr769.trans bodyBr768.symm) bodyCnt768 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30718, 558, 0, 432⟩) bodyAcc769 PRE_first_tail_x15_r0_body.bodyRunSeg208 bodyAcc771 bodyHalt771 PRE_first_tail_x15_r0_body.bodyStepA209 bodyTop772 (fun _ hm => bodyO769 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr769).trans bodyInactive0) (bodyBr772.trans bodyBr769.symm) bodyCnt769 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
