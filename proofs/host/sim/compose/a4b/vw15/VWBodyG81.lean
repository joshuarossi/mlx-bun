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

kernel_rfl bodyO778 : PRE_first_tail_x15_r0_body.S778.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S778.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr778 : bridgeOf PRE_first_tail_x15_r0_body.s778.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc778 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.S778) = fun _ _ => true
kernel_rfl bodyAcc780 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s780 PRE_first_tail_x15_r0_body.S780) = fun _ _ => true
kernel_rfl bodyBr781 : bridgeOf PRE_first_tail_x15_r0_body.s781.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt780 : isHalt PRE_first_tail_x15_r0_body.s780.ctl = false
kernel_rfl bodyTop781 : noRetBlock PRE_first_tail_x15_r0_body.s781 = true
kernel_rfl bodyCnt778 : countersOkB PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.s781 = true
kernel_rfl bodyO781 : PRE_first_tail_x15_r0_body.S781.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S781.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr782 : bridgeOf PRE_first_tail_x15_r0_body.s782.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt781 : countersOkB PRE_first_tail_x15_r0_body.s781 PRE_first_tail_x15_r0_body.s782 = true
kernel_rfl bodyO782 : PRE_first_tail_x15_r0_body.S782.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S782.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc782 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s782 PRE_first_tail_x15_r0_body.S782) = fun _ _ => true
kernel_rfl bodyAcc784 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s784 PRE_first_tail_x15_r0_body.S784) = fun _ _ => true
kernel_rfl bodyBr785 : bridgeOf PRE_first_tail_x15_r0_body.s785.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt784 : isHalt PRE_first_tail_x15_r0_body.s784.ctl = false
kernel_rfl bodyTop785 : noRetBlock PRE_first_tail_x15_r0_body.s785 = true
kernel_rfl bodyCnt782 : countersOkB PRE_first_tail_x15_r0_body.s782 PRE_first_tail_x15_r0_body.s785 = true
kernel_rfl bodyO785 : PRE_first_tail_x15_r0_body.S785.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S785.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr786 : bridgeOf PRE_first_tail_x15_r0_body.s786.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt785 : countersOkB PRE_first_tail_x15_r0_body.s785 PRE_first_tail_x15_r0_body.s786 = true
kernel_rfl bodyO786 : PRE_first_tail_x15_r0_body.S786.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S786.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc786 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s786 PRE_first_tail_x15_r0_body.S786) = fun _ _ => true
kernel_rfl bodyAcc787 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s787 PRE_first_tail_x15_r0_body.S787) = fun _ _ => true
kernel_rfl bodyBr788 : bridgeOf PRE_first_tail_x15_r0_body.s788.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt787 : isHalt PRE_first_tail_x15_r0_body.s787.ctl = false
kernel_rfl bodyTop788 : noRetBlock PRE_first_tail_x15_r0_body.s788 = true
kernel_rfl bodyCnt786 : countersOkB PRE_first_tail_x15_r0_body.s786 PRE_first_tail_x15_r0_body.s788 = true
kernel_rfl bodyO788 : PRE_first_tail_x15_r0_body.S788.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S788.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr789 : bridgeOf PRE_first_tail_x15_r0_body.s789.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt788 : countersOkB PRE_first_tail_x15_r0_body.s788 PRE_first_tail_x15_r0_body.s789 = true
kernel_rfl bodyO789 : PRE_first_tail_x15_r0_body.S789.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S789.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc789 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s789 PRE_first_tail_x15_r0_body.S789) = fun _ _ => true
kernel_rfl bodyAcc791 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s791 PRE_first_tail_x15_r0_body.S791) = fun _ _ => true
kernel_rfl bodyBr792 : bridgeOf PRE_first_tail_x15_r0_body.s792.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt791 : isHalt PRE_first_tail_x15_r0_body.s791.ctl = false
kernel_rfl bodyTop792 : noRetBlock PRE_first_tail_x15_r0_body.s792 = true
kernel_rfl bodyCnt789 : countersOkB PRE_first_tail_x15_r0_body.s789 PRE_first_tail_x15_r0_body.s792 = true

theorem bodyGlue81 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30730, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.S778)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30730, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s792 PRE_first_tail_x15_r0_body.S792) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30730, 558, 0, 432⟩) bodyAcc778 PRE_first_tail_x15_r0_body.bodyRunSeg210 bodyAcc780 bodyHalt780 PRE_first_tail_x15_r0_body.bodyStepA211 bodyTop781 (fun _ hm => bodyO778 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr778).trans bodyInactive0) (bodyBr781.trans bodyBr778.symm) bodyCnt778 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30730, 558, 0, 432⟩) PRE_first_tail_x15_r0_body.sizeA211 PRE_first_tail_x15_r0_body.sizeArgsA211 PRE_first_tail_x15_r0_body.sizeSymA211 PRE_first_tail_x15_r0_body.sizeMlxA211 PRE_first_tail_x15_r0_body.sizePayA211 PRE_first_tail_x15_r0_body.sizeTaA211 PRE_first_tail_x15_r0_body.sizeDecA211 PRE_first_tail_x15_r0_body.sizePreA211 PRE_first_tail_x15_r0_body.bodyPatchB211 (fun _ hm => bodyO781 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr781).trans bodyInactive0) (bodyBr782.trans bodyBr781.symm) bodyCnt781 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30730, 558, 0, 432⟩) bodyAcc782 PRE_first_tail_x15_r0_body.bodyRunSeg211 bodyAcc784 bodyHalt784 PRE_first_tail_x15_r0_body.bodyStepA212 bodyTop785 (fun _ hm => bodyO782 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr782).trans bodyInactive0) (bodyBr785.trans bodyBr782.symm) bodyCnt782 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30730, 558, 0, 432⟩) PRE_first_tail_x15_r0_body.sizeA212 PRE_first_tail_x15_r0_body.sizeArgsA212 PRE_first_tail_x15_r0_body.sizeSymA212 PRE_first_tail_x15_r0_body.sizeMlxA212 PRE_first_tail_x15_r0_body.sizePayA212 PRE_first_tail_x15_r0_body.sizeTaA212 PRE_first_tail_x15_r0_body.sizeDecA212 PRE_first_tail_x15_r0_body.sizePreA212 PRE_first_tail_x15_r0_body.bodyPatchB212 (fun _ hm => bodyO785 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr785).trans bodyInactive0) (bodyBr786.trans bodyBr785.symm) bodyCnt785 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30730, 558, 0, 432⟩) bodyAcc786 PRE_first_tail_x15_r0_body.bodyRunSeg212 bodyAcc787 bodyHalt787 PRE_first_tail_x15_r0_body.bodyStepA213 bodyTop788 (fun _ hm => bodyO786 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr786).trans bodyInactive0) (bodyBr788.trans bodyBr786.symm) bodyCnt786 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30730, 558, 0, 432⟩) PRE_first_tail_x15_r0_body.sizeA213 PRE_first_tail_x15_r0_body.sizeArgsA213 PRE_first_tail_x15_r0_body.sizeSymA213 PRE_first_tail_x15_r0_body.sizeMlxA213 PRE_first_tail_x15_r0_body.sizePayA213 PRE_first_tail_x15_r0_body.sizeTaA213 PRE_first_tail_x15_r0_body.sizeDecA213 PRE_first_tail_x15_r0_body.sizePreA213 PRE_first_tail_x15_r0_body.bodyPatchB213 (fun _ hm => bodyO788 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr788).trans bodyInactive0) (bodyBr789.trans bodyBr788.symm) bodyCnt788 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨30730, 558, 0, 432⟩) bodyAcc789 PRE_first_tail_x15_r0_body.bodyRunSeg213 bodyAcc791 bodyHalt791 PRE_first_tail_x15_r0_body.bodyStepA214 bodyTop792 (fun _ hm => bodyO789 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr789).trans bodyInactive0) (bodyBr792.trans bodyBr789.symm) bodyCnt789 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
