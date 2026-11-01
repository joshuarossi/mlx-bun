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

kernel_rfl bodyO461 : PRE_first_tail_x15_r0_body.S461.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S461.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr461 : bridgeOf PRE_first_tail_x15_r0_body.s461.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc461 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.S461) = fun _ _ => true
kernel_rfl bodyAcc463 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s463 PRE_first_tail_x15_r0_body.S463) = fun _ _ => true
kernel_rfl bodyBr464 : bridgeOf PRE_first_tail_x15_r0_body.s464.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt463 : isHalt PRE_first_tail_x15_r0_body.s463.ctl = false
kernel_rfl bodyTop464 : noRetBlock PRE_first_tail_x15_r0_body.s464 = true
kernel_rfl bodyCnt461 : countersOkB PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.s464 = true
kernel_rfl bodyO464 : PRE_first_tail_x15_r0_body.S464.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S464.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr465 : bridgeOf PRE_first_tail_x15_r0_body.s465.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt464 : countersOkB PRE_first_tail_x15_r0_body.s464 PRE_first_tail_x15_r0_body.s465 = true
kernel_rfl bodyO465 : PRE_first_tail_x15_r0_body.S465.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S465.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc465 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s465 PRE_first_tail_x15_r0_body.S465) = fun _ _ => true
kernel_rfl bodyAcc466 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s466 PRE_first_tail_x15_r0_body.S466) = fun _ _ => true
kernel_rfl bodyBr467 : bridgeOf PRE_first_tail_x15_r0_body.s467.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt466 : isHalt PRE_first_tail_x15_r0_body.s466.ctl = false
kernel_rfl bodyTop467 : noRetBlock PRE_first_tail_x15_r0_body.s467 = true
kernel_rfl bodyCnt465 : countersOkB PRE_first_tail_x15_r0_body.s465 PRE_first_tail_x15_r0_body.s467 = true
kernel_rfl bodyO467 : PRE_first_tail_x15_r0_body.S467.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S467.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr468 : bridgeOf PRE_first_tail_x15_r0_body.s468.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt467 : countersOkB PRE_first_tail_x15_r0_body.s467 PRE_first_tail_x15_r0_body.s468 = true
kernel_rfl bodyO468 : PRE_first_tail_x15_r0_body.S468.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S468.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc468 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s468 PRE_first_tail_x15_r0_body.S468) = fun _ _ => true
kernel_rfl bodyAcc469 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s469 PRE_first_tail_x15_r0_body.S469) = fun _ _ => true
kernel_rfl bodyBr470 : bridgeOf PRE_first_tail_x15_r0_body.s470.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt469 : isHalt PRE_first_tail_x15_r0_body.s469.ctl = false
kernel_rfl bodyTop470 : noRetBlock PRE_first_tail_x15_r0_body.s470 = true
kernel_rfl bodyCnt468 : countersOkB PRE_first_tail_x15_r0_body.s468 PRE_first_tail_x15_r0_body.s470 = true
kernel_rfl bodyO470 : PRE_first_tail_x15_r0_body.S470.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S470.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr471 : bridgeOf PRE_first_tail_x15_r0_body.s471.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt470 : countersOkB PRE_first_tail_x15_r0_body.s470 PRE_first_tail_x15_r0_body.s471 = true
kernel_rfl bodyO471 : PRE_first_tail_x15_r0_body.S471.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S471.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc471 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s471 PRE_first_tail_x15_r0_body.S471) = fun _ _ => true
kernel_rfl bodyAcc472 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s472 PRE_first_tail_x15_r0_body.S472) = fun _ _ => true
kernel_rfl bodyBr473 : bridgeOf PRE_first_tail_x15_r0_body.s473.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt472 : isHalt PRE_first_tail_x15_r0_body.s472.ctl = false
kernel_rfl bodyTop473 : noRetBlock PRE_first_tail_x15_r0_body.s473 = true
kernel_rfl bodyCnt471 : countersOkB PRE_first_tail_x15_r0_body.s471 PRE_first_tail_x15_r0_body.s473 = true
kernel_rfl bodyO473 : PRE_first_tail_x15_r0_body.S473.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S473.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr474 : bridgeOf PRE_first_tail_x15_r0_body.s474.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt473 : countersOkB PRE_first_tail_x15_r0_body.s473 PRE_first_tail_x15_r0_body.s474 = true
kernel_rfl bodyO474 : PRE_first_tail_x15_r0_body.S474.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S474.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc474 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.S474) = fun _ _ => true
kernel_rfl bodyAcc475 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s475 PRE_first_tail_x15_r0_body.S475) = fun _ _ => true
kernel_rfl bodyBr476 : bridgeOf PRE_first_tail_x15_r0_body.s476.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt475 : isHalt PRE_first_tail_x15_r0_body.s475.ctl = false
kernel_rfl bodyTop476 : noRetBlock PRE_first_tail_x15_r0_body.s476 = true
kernel_rfl bodyCnt474 : countersOkB PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.s476 = true

theorem bodyGlue48 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19530, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s461 PRE_first_tail_x15_r0_body.S461)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19530, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s476 PRE_first_tail_x15_r0_body.S476) 14768 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc461 PRE_first_tail_x15_r0_body.bodyRunSeg124 bodyAcc463 bodyHalt463 PRE_first_tail_x15_r0_body.bodyStepA125 bodyTop464 (fun _ hm => bodyO461 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr461).trans bodyInactive0) (bodyBr464.trans bodyBr461.symm) bodyCnt461 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA125 PRE_first_tail_x15_r0_body.sizeArgsA125 PRE_first_tail_x15_r0_body.sizeSymA125 PRE_first_tail_x15_r0_body.sizeMlxA125 PRE_first_tail_x15_r0_body.sizePayA125 PRE_first_tail_x15_r0_body.sizeTaA125 PRE_first_tail_x15_r0_body.sizeDecA125 PRE_first_tail_x15_r0_body.sizePreA125 PRE_first_tail_x15_r0_body.bodyPatchB125 (fun _ hm => bodyO464 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr464).trans bodyInactive0) (bodyBr465.trans bodyBr464.symm) bodyCnt464 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc465 PRE_first_tail_x15_r0_body.bodyRunSeg125 bodyAcc466 bodyHalt466 PRE_first_tail_x15_r0_body.bodyStepA126 bodyTop467 (fun _ hm => bodyO465 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr465).trans bodyInactive0) (bodyBr467.trans bodyBr465.symm) bodyCnt465 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA126 PRE_first_tail_x15_r0_body.sizeArgsA126 PRE_first_tail_x15_r0_body.sizeSymA126 PRE_first_tail_x15_r0_body.sizeMlxA126 PRE_first_tail_x15_r0_body.sizePayA126 PRE_first_tail_x15_r0_body.sizeTaA126 PRE_first_tail_x15_r0_body.sizeDecA126 PRE_first_tail_x15_r0_body.sizePreA126 PRE_first_tail_x15_r0_body.bodyPatchB126 (fun _ hm => bodyO467 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr467).trans bodyInactive0) (bodyBr468.trans bodyBr467.symm) bodyCnt467 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc468 PRE_first_tail_x15_r0_body.bodyRunSeg126 bodyAcc469 bodyHalt469 PRE_first_tail_x15_r0_body.bodyStepA127 bodyTop470 (fun _ hm => bodyO468 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr468).trans bodyInactive0) (bodyBr470.trans bodyBr468.symm) bodyCnt468 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA127 PRE_first_tail_x15_r0_body.sizeArgsA127 PRE_first_tail_x15_r0_body.sizeSymA127 PRE_first_tail_x15_r0_body.sizeMlxA127 PRE_first_tail_x15_r0_body.sizePayA127 PRE_first_tail_x15_r0_body.sizeTaA127 PRE_first_tail_x15_r0_body.sizeDecA127 PRE_first_tail_x15_r0_body.sizePreA127 PRE_first_tail_x15_r0_body.bodyPatchB127 (fun _ hm => bodyO470 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr470).trans bodyInactive0) (bodyBr471.trans bodyBr470.symm) bodyCnt470 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc471 PRE_first_tail_x15_r0_body.bodyRunSeg127 bodyAcc472 bodyHalt472 PRE_first_tail_x15_r0_body.bodyStepA128 bodyTop473 (fun _ hm => bodyO471 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr471).trans bodyInactive0) (bodyBr473.trans bodyBr471.symm) bodyCnt471 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) PRE_first_tail_x15_r0_body.sizeA128 PRE_first_tail_x15_r0_body.sizeArgsA128 PRE_first_tail_x15_r0_body.sizeSymA128 PRE_first_tail_x15_r0_body.sizeMlxA128 PRE_first_tail_x15_r0_body.sizePayA128 PRE_first_tail_x15_r0_body.sizeTaA128 PRE_first_tail_x15_r0_body.sizeDecA128 PRE_first_tail_x15_r0_body.sizePreA128 PRE_first_tail_x15_r0_body.bodyPatchB128 (fun _ hm => bodyO473 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr473).trans bodyInactive0) (bodyBr474.trans bodyBr473.symm) bodyCnt473 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19530, 329, 0, 252⟩) bodyAcc474 PRE_first_tail_x15_r0_body.bodyRunSeg128 bodyAcc475 bodyHalt475 PRE_first_tail_x15_r0_body.bodyStepA129 bodyTop476 (fun _ hm => bodyO474 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr474).trans bodyInactive0) (bodyBr476.trans bodyBr474.symm) bodyCnt474 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
