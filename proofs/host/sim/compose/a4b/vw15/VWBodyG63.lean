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

kernel_rfl bodyO605 : PRE_first_tail_x15_r0_body.S605.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S605.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr605 : bridgeOf PRE_first_tail_x15_r0_body.s605.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc605 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.S605) = fun _ _ => true
kernel_rfl bodyAcc607 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s607 PRE_first_tail_x15_r0_body.S607) = fun _ _ => true
kernel_rfl bodyBr608 : bridgeOf PRE_first_tail_x15_r0_body.s608.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt607 : isHalt PRE_first_tail_x15_r0_body.s607.ctl = false
kernel_rfl bodyTop608 : noRetBlock PRE_first_tail_x15_r0_body.s608 = true
kernel_rfl bodyCnt605 : countersOkB PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.s608 = true
kernel_rfl bodyO608 : PRE_first_tail_x15_r0_body.S608.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S608.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr609 : bridgeOf PRE_first_tail_x15_r0_body.s609.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt608 : countersOkB PRE_first_tail_x15_r0_body.s608 PRE_first_tail_x15_r0_body.s609 = true
kernel_rfl bodyO609 : PRE_first_tail_x15_r0_body.S609.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S609.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc609 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s609 PRE_first_tail_x15_r0_body.S609) = fun _ _ => true
kernel_rfl bodyAcc610 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s610 PRE_first_tail_x15_r0_body.S610) = fun _ _ => true
kernel_rfl bodyBr611 : bridgeOf PRE_first_tail_x15_r0_body.s611.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt610 : isHalt PRE_first_tail_x15_r0_body.s610.ctl = false
kernel_rfl bodyTop611 : noRetBlock PRE_first_tail_x15_r0_body.s611 = true
kernel_rfl bodyCnt609 : countersOkB PRE_first_tail_x15_r0_body.s609 PRE_first_tail_x15_r0_body.s611 = true
kernel_rfl bodyO611 : PRE_first_tail_x15_r0_body.S611.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S611.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr612 : bridgeOf PRE_first_tail_x15_r0_body.s612.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt611 : countersOkB PRE_first_tail_x15_r0_body.s611 PRE_first_tail_x15_r0_body.s612 = true
kernel_rfl bodyO612 : PRE_first_tail_x15_r0_body.S612.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S612.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc612 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s612 PRE_first_tail_x15_r0_body.S612) = fun _ _ => true
kernel_rfl bodyAcc613 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s613 PRE_first_tail_x15_r0_body.S613) = fun _ _ => true
kernel_rfl bodyBr614 : bridgeOf PRE_first_tail_x15_r0_body.s614.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt613 : isHalt PRE_first_tail_x15_r0_body.s613.ctl = false
kernel_rfl bodyTop614 : noRetBlock PRE_first_tail_x15_r0_body.s614 = true
kernel_rfl bodyCnt612 : countersOkB PRE_first_tail_x15_r0_body.s612 PRE_first_tail_x15_r0_body.s614 = true
kernel_rfl bodyO614 : PRE_first_tail_x15_r0_body.S614.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S614.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr615 : bridgeOf PRE_first_tail_x15_r0_body.s615.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt614 : countersOkB PRE_first_tail_x15_r0_body.s614 PRE_first_tail_x15_r0_body.s615 = true
kernel_rfl bodyO615 : PRE_first_tail_x15_r0_body.S615.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S615.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc615 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s615 PRE_first_tail_x15_r0_body.S615) = fun _ _ => true
kernel_rfl bodyAcc616 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s616 PRE_first_tail_x15_r0_body.S616) = fun _ _ => true
kernel_rfl bodyBr617 : bridgeOf PRE_first_tail_x15_r0_body.s617.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt616 : isHalt PRE_first_tail_x15_r0_body.s616.ctl = false
kernel_rfl bodyTop617 : noRetBlock PRE_first_tail_x15_r0_body.s617 = true
kernel_rfl bodyCnt615 : countersOkB PRE_first_tail_x15_r0_body.s615 PRE_first_tail_x15_r0_body.s617 = true
kernel_rfl bodyO617 : PRE_first_tail_x15_r0_body.S617.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S617.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr618 : bridgeOf PRE_first_tail_x15_r0_body.s618.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt617 : countersOkB PRE_first_tail_x15_r0_body.s617 PRE_first_tail_x15_r0_body.s618 = true
kernel_rfl bodyO618 : PRE_first_tail_x15_r0_body.S618.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S618.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc618 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s618 PRE_first_tail_x15_r0_body.S618) = fun _ _ => true
kernel_rfl bodyAcc619 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s619 PRE_first_tail_x15_r0_body.S619) = fun _ _ => true
kernel_rfl bodyBr620 : bridgeOf PRE_first_tail_x15_r0_body.s620.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt619 : isHalt PRE_first_tail_x15_r0_body.s619.ctl = false
kernel_rfl bodyTop620 : noRetBlock PRE_first_tail_x15_r0_body.s620 = true
kernel_rfl bodyCnt618 : countersOkB PRE_first_tail_x15_r0_body.s618 PRE_first_tail_x15_r0_body.s620 = true

theorem bodyGlue63 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24563, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s605 PRE_first_tail_x15_r0_body.S605)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24563, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s620 PRE_first_tail_x15_r0_body.S620) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) bodyAcc605 PRE_first_tail_x15_r0_body.bodyRunSeg163 bodyAcc607 bodyHalt607 PRE_first_tail_x15_r0_body.bodyStepA164 bodyTop608 (fun _ hm => bodyO605 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr605).trans bodyInactive0) (bodyBr608.trans bodyBr605.symm) bodyCnt605 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) PRE_first_tail_x15_r0_body.sizeA164 PRE_first_tail_x15_r0_body.sizeArgsA164 PRE_first_tail_x15_r0_body.sizeSymA164 PRE_first_tail_x15_r0_body.sizeMlxA164 PRE_first_tail_x15_r0_body.sizePayA164 PRE_first_tail_x15_r0_body.sizeTaA164 PRE_first_tail_x15_r0_body.sizeDecA164 PRE_first_tail_x15_r0_body.sizePreA164 PRE_first_tail_x15_r0_body.bodyPatchB164 (fun _ hm => bodyO608 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr608).trans bodyInactive0) (bodyBr609.trans bodyBr608.symm) bodyCnt608 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) bodyAcc609 PRE_first_tail_x15_r0_body.bodyRunSeg164 bodyAcc610 bodyHalt610 PRE_first_tail_x15_r0_body.bodyStepA165 bodyTop611 (fun _ hm => bodyO609 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr609).trans bodyInactive0) (bodyBr611.trans bodyBr609.symm) bodyCnt609 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) PRE_first_tail_x15_r0_body.sizeA165 PRE_first_tail_x15_r0_body.sizeArgsA165 PRE_first_tail_x15_r0_body.sizeSymA165 PRE_first_tail_x15_r0_body.sizeMlxA165 PRE_first_tail_x15_r0_body.sizePayA165 PRE_first_tail_x15_r0_body.sizeTaA165 PRE_first_tail_x15_r0_body.sizeDecA165 PRE_first_tail_x15_r0_body.sizePreA165 PRE_first_tail_x15_r0_body.bodyPatchB165 (fun _ hm => bodyO611 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr611).trans bodyInactive0) (bodyBr612.trans bodyBr611.symm) bodyCnt611 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) bodyAcc612 PRE_first_tail_x15_r0_body.bodyRunSeg165 bodyAcc613 bodyHalt613 PRE_first_tail_x15_r0_body.bodyStepA166 bodyTop614 (fun _ hm => bodyO612 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr612).trans bodyInactive0) (bodyBr614.trans bodyBr612.symm) bodyCnt612 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) PRE_first_tail_x15_r0_body.sizeA166 PRE_first_tail_x15_r0_body.sizeArgsA166 PRE_first_tail_x15_r0_body.sizeSymA166 PRE_first_tail_x15_r0_body.sizeMlxA166 PRE_first_tail_x15_r0_body.sizePayA166 PRE_first_tail_x15_r0_body.sizeTaA166 PRE_first_tail_x15_r0_body.sizeDecA166 PRE_first_tail_x15_r0_body.sizePreA166 PRE_first_tail_x15_r0_body.bodyPatchB166 (fun _ hm => bodyO614 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr614).trans bodyInactive0) (bodyBr615.trans bodyBr614.symm) bodyCnt614 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) bodyAcc615 PRE_first_tail_x15_r0_body.bodyRunSeg166 bodyAcc616 bodyHalt616 PRE_first_tail_x15_r0_body.bodyStepA167 bodyTop617 (fun _ hm => bodyO615 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr615).trans bodyInactive0) (bodyBr617.trans bodyBr615.symm) bodyCnt615 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) PRE_first_tail_x15_r0_body.sizeA167 PRE_first_tail_x15_r0_body.sizeArgsA167 PRE_first_tail_x15_r0_body.sizeSymA167 PRE_first_tail_x15_r0_body.sizeMlxA167 PRE_first_tail_x15_r0_body.sizePayA167 PRE_first_tail_x15_r0_body.sizeTaA167 PRE_first_tail_x15_r0_body.sizeDecA167 PRE_first_tail_x15_r0_body.sizePreA167 PRE_first_tail_x15_r0_body.bodyPatchB167 (fun _ hm => bodyO617 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr617).trans bodyInactive0) (bodyBr618.trans bodyBr617.symm) bodyCnt617 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨24563, 431, 0, 333⟩) bodyAcc618 PRE_first_tail_x15_r0_body.bodyRunSeg167 bodyAcc619 bodyHalt619 PRE_first_tail_x15_r0_body.bodyStepA168 bodyTop620 (fun _ hm => bodyO618 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr618).trans bodyInactive0) (bodyBr620.trans bodyBr618.symm) bodyCnt618 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
