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

kernel_rfl bodyO893 : PRE_first_tail_x15_r0_body.S893.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S893.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr893 : bridgeOf PRE_first_tail_x15_r0_body.s893.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc893 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s893 PRE_first_tail_x15_r0_body.S893) = fun _ _ => true
kernel_rfl bodyAcc895 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s895 PRE_first_tail_x15_r0_body.S895) = fun _ _ => true
kernel_rfl bodyBr896 : bridgeOf PRE_first_tail_x15_r0_body.s896.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt895 : isHalt PRE_first_tail_x15_r0_body.s895.ctl = false
kernel_rfl bodyTop896 : noRetBlock PRE_first_tail_x15_r0_body.s896 = true
kernel_rfl bodyCnt893 : countersOkB PRE_first_tail_x15_r0_body.s893 PRE_first_tail_x15_r0_body.s896 = true
kernel_rfl bodyO896 : PRE_first_tail_x15_r0_body.S896.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S896.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr897 : bridgeOf PRE_first_tail_x15_r0_body.s897.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt896 : countersOkB PRE_first_tail_x15_r0_body.s896 PRE_first_tail_x15_r0_body.s897 = true
kernel_rfl bodyO897 : PRE_first_tail_x15_r0_body.S897.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S897.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc897 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s897 PRE_first_tail_x15_r0_body.S897) = fun _ _ => true
kernel_rfl bodyAcc899 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s899 PRE_first_tail_x15_r0_body.S899) = fun _ _ => true
kernel_rfl bodyBr900 : bridgeOf PRE_first_tail_x15_r0_body.s900.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt899 : isHalt PRE_first_tail_x15_r0_body.s899.ctl = false
kernel_rfl bodyTop900 : noRetBlock PRE_first_tail_x15_r0_body.s900 = true
kernel_rfl bodyCnt897 : countersOkB PRE_first_tail_x15_r0_body.s897 PRE_first_tail_x15_r0_body.s900 = true
kernel_rfl bodyO900 : PRE_first_tail_x15_r0_body.S900.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S900.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr901 : bridgeOf PRE_first_tail_x15_r0_body.s901.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt900 : countersOkB PRE_first_tail_x15_r0_body.s900 PRE_first_tail_x15_r0_body.s901 = true
kernel_rfl bodyO901 : PRE_first_tail_x15_r0_body.S901.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S901.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc901 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s901 PRE_first_tail_x15_r0_body.S901) = fun _ _ => true
kernel_rfl bodyAcc902 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s902 PRE_first_tail_x15_r0_body.S902) = fun _ _ => true
kernel_rfl bodyBr903 : bridgeOf PRE_first_tail_x15_r0_body.s903.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt902 : isHalt PRE_first_tail_x15_r0_body.s902.ctl = false
kernel_rfl bodyTop903 : noRetBlock PRE_first_tail_x15_r0_body.s903 = true
kernel_rfl bodyCnt901 : countersOkB PRE_first_tail_x15_r0_body.s901 PRE_first_tail_x15_r0_body.s903 = true
kernel_rfl bodyO903 : PRE_first_tail_x15_r0_body.S903.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S903.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr904 : bridgeOf PRE_first_tail_x15_r0_body.s904.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt903 : countersOkB PRE_first_tail_x15_r0_body.s903 PRE_first_tail_x15_r0_body.s904 = true
kernel_rfl bodyO904 : PRE_first_tail_x15_r0_body.S904.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S904.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc904 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s904 PRE_first_tail_x15_r0_body.S904) = fun _ _ => true
kernel_rfl bodyAcc906 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s906 PRE_first_tail_x15_r0_body.S906) = fun _ _ => true
kernel_rfl bodyBr907 : bridgeOf PRE_first_tail_x15_r0_body.s907.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt906 : isHalt PRE_first_tail_x15_r0_body.s906.ctl = false
kernel_rfl bodyTop907 : noRetBlock PRE_first_tail_x15_r0_body.s907 = true
kernel_rfl bodyCnt904 : countersOkB PRE_first_tail_x15_r0_body.s904 PRE_first_tail_x15_r0_body.s907 = true

theorem bodyGlue93 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34584, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s893 PRE_first_tail_x15_r0_body.S893)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34584, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s907 PRE_first_tail_x15_r0_body.S907) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34584, 635, 0, 495⟩) bodyAcc893 PRE_first_tail_x15_r0_body.bodyRunSeg241 bodyAcc895 bodyHalt895 PRE_first_tail_x15_r0_body.bodyStepA242 bodyTop896 (fun _ hm => bodyO893 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr893).trans bodyInactive0) (bodyBr896.trans bodyBr893.symm) bodyCnt893 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34584, 635, 0, 495⟩) PRE_first_tail_x15_r0_body.sizeA242 PRE_first_tail_x15_r0_body.sizeArgsA242 PRE_first_tail_x15_r0_body.sizeSymA242 PRE_first_tail_x15_r0_body.sizeMlxA242 PRE_first_tail_x15_r0_body.sizePayA242 PRE_first_tail_x15_r0_body.sizeTaA242 PRE_first_tail_x15_r0_body.sizeDecA242 PRE_first_tail_x15_r0_body.sizePreA242 PRE_first_tail_x15_r0_body.bodyPatchB242 (fun _ hm => bodyO896 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr896).trans bodyInactive0) (bodyBr897.trans bodyBr896.symm) bodyCnt896 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34584, 635, 0, 495⟩) bodyAcc897 PRE_first_tail_x15_r0_body.bodyRunSeg242 bodyAcc899 bodyHalt899 PRE_first_tail_x15_r0_body.bodyStepA243 bodyTop900 (fun _ hm => bodyO897 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr897).trans bodyInactive0) (bodyBr900.trans bodyBr897.symm) bodyCnt897 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34584, 635, 0, 495⟩) PRE_first_tail_x15_r0_body.sizeA243 PRE_first_tail_x15_r0_body.sizeArgsA243 PRE_first_tail_x15_r0_body.sizeSymA243 PRE_first_tail_x15_r0_body.sizeMlxA243 PRE_first_tail_x15_r0_body.sizePayA243 PRE_first_tail_x15_r0_body.sizeTaA243 PRE_first_tail_x15_r0_body.sizeDecA243 PRE_first_tail_x15_r0_body.sizePreA243 PRE_first_tail_x15_r0_body.bodyPatchB243 (fun _ hm => bodyO900 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr900).trans bodyInactive0) (bodyBr901.trans bodyBr900.symm) bodyCnt900 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34584, 635, 0, 495⟩) bodyAcc901 PRE_first_tail_x15_r0_body.bodyRunSeg243 bodyAcc902 bodyHalt902 PRE_first_tail_x15_r0_body.bodyStepA244 bodyTop903 (fun _ hm => bodyO901 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr901).trans bodyInactive0) (bodyBr903.trans bodyBr901.symm) bodyCnt901 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34584, 635, 0, 495⟩) PRE_first_tail_x15_r0_body.sizeA244 PRE_first_tail_x15_r0_body.sizeArgsA244 PRE_first_tail_x15_r0_body.sizeSymA244 PRE_first_tail_x15_r0_body.sizeMlxA244 PRE_first_tail_x15_r0_body.sizePayA244 PRE_first_tail_x15_r0_body.sizeTaA244 PRE_first_tail_x15_r0_body.sizeDecA244 PRE_first_tail_x15_r0_body.sizePreA244 PRE_first_tail_x15_r0_body.bodyPatchB244 (fun _ hm => bodyO903 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr903).trans bodyInactive0) (bodyBr904.trans bodyBr903.symm) bodyCnt903 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34584, 635, 0, 495⟩) bodyAcc904 PRE_first_tail_x15_r0_body.bodyRunSeg244 bodyAcc906 bodyHalt906 PRE_first_tail_x15_r0_body.bodyStepA245 bodyTop907 (fun _ hm => bodyO904 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr904).trans bodyInactive0) (bodyBr907.trans bodyBr904.symm) bodyCnt904 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
