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

kernel_rfl bodyO116 : PRE_first_tail_x15_r0_body.S116.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S116.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr116 : bridgeOf PRE_first_tail_x15_r0_body.s116.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc116 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.S116) = fun _ _ => true
kernel_rfl bodyAcc118 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s118 PRE_first_tail_x15_r0_body.S118) = fun _ _ => true
kernel_rfl bodyBr119 : bridgeOf PRE_first_tail_x15_r0_body.s119.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt118 : isHalt PRE_first_tail_x15_r0_body.s118.ctl = false
kernel_rfl bodyTop119 : noRetBlock PRE_first_tail_x15_r0_body.s119 = true
kernel_rfl bodyCnt116 : countersOkB PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.s119 = true
kernel_rfl bodyO119 : PRE_first_tail_x15_r0_body.S119.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S119.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr120 : bridgeOf PRE_first_tail_x15_r0_body.s120.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt119 : countersOkB PRE_first_tail_x15_r0_body.s119 PRE_first_tail_x15_r0_body.s120 = true
kernel_rfl bodyO120 : PRE_first_tail_x15_r0_body.S120.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S120.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc120 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s120 PRE_first_tail_x15_r0_body.S120) = fun _ _ => true
kernel_rfl bodyAcc121 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s121 PRE_first_tail_x15_r0_body.S121) = fun _ _ => true
kernel_rfl bodyBr122 : bridgeOf PRE_first_tail_x15_r0_body.s122.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt121 : isHalt PRE_first_tail_x15_r0_body.s121.ctl = false
kernel_rfl bodyTop122 : noRetBlock PRE_first_tail_x15_r0_body.s122 = true
kernel_rfl bodyCnt120 : countersOkB PRE_first_tail_x15_r0_body.s120 PRE_first_tail_x15_r0_body.s122 = true
kernel_rfl bodyO122 : PRE_first_tail_x15_r0_body.S122.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S122.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr123 : bridgeOf PRE_first_tail_x15_r0_body.s123.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt122 : countersOkB PRE_first_tail_x15_r0_body.s122 PRE_first_tail_x15_r0_body.s123 = true
kernel_rfl bodyO123 : PRE_first_tail_x15_r0_body.S123.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S123.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc123 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s123 PRE_first_tail_x15_r0_body.S123) = fun _ _ => true
kernel_rfl bodyAcc124 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s124 PRE_first_tail_x15_r0_body.S124) = fun _ _ => true
kernel_rfl bodyBr125 : bridgeOf PRE_first_tail_x15_r0_body.s125.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt124 : isHalt PRE_first_tail_x15_r0_body.s124.ctl = false
kernel_rfl bodyTop125 : noRetBlock PRE_first_tail_x15_r0_body.s125 = true
kernel_rfl bodyCnt123 : countersOkB PRE_first_tail_x15_r0_body.s123 PRE_first_tail_x15_r0_body.s125 = true
kernel_rfl bodyO125 : PRE_first_tail_x15_r0_body.S125.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S125.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr126 : bridgeOf PRE_first_tail_x15_r0_body.s126.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt125 : countersOkB PRE_first_tail_x15_r0_body.s125 PRE_first_tail_x15_r0_body.s126 = true
kernel_rfl bodyO126 : PRE_first_tail_x15_r0_body.S126.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S126.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc126 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s126 PRE_first_tail_x15_r0_body.S126) = fun _ _ => true
kernel_rfl bodyAcc127 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s127 PRE_first_tail_x15_r0_body.S127) = fun _ _ => true
kernel_rfl bodyBr128 : bridgeOf PRE_first_tail_x15_r0_body.s128.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt127 : isHalt PRE_first_tail_x15_r0_body.s127.ctl = false
kernel_rfl bodyTop128 : noRetBlock PRE_first_tail_x15_r0_body.s128 = true
kernel_rfl bodyCnt126 : countersOkB PRE_first_tail_x15_r0_body.s126 PRE_first_tail_x15_r0_body.s128 = true
kernel_rfl bodyO128 : PRE_first_tail_x15_r0_body.S128.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S128.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr129 : bridgeOf PRE_first_tail_x15_r0_body.s129.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt128 : countersOkB PRE_first_tail_x15_r0_body.s128 PRE_first_tail_x15_r0_body.s129 = true
kernel_rfl bodyO129 : PRE_first_tail_x15_r0_body.S129.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S129.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc129 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s129 PRE_first_tail_x15_r0_body.S129) = fun _ _ => true
kernel_rfl bodyAcc130 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s130 PRE_first_tail_x15_r0_body.S130) = fun _ _ => true
kernel_rfl bodyBr131 : bridgeOf PRE_first_tail_x15_r0_body.s131.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt130 : isHalt PRE_first_tail_x15_r0_body.s130.ctl = false
kernel_rfl bodyTop131 : noRetBlock PRE_first_tail_x15_r0_body.s131 = true
kernel_rfl bodyCnt129 : countersOkB PRE_first_tail_x15_r0_body.s129 PRE_first_tail_x15_r0_body.s131 = true

theorem bodyGlue12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7968, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.S116)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7968, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s131 PRE_first_tail_x15_r0_body.S131) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc116 PRE_first_tail_x15_r0_body.bodyRunSeg31 bodyAcc118 bodyHalt118 PRE_first_tail_x15_r0_body.bodyStepA32 bodyTop119 (fun _ hm => bodyO116 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr116).trans bodyInactive0) (bodyBr119.trans bodyBr116.symm) bodyCnt116 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) PRE_first_tail_x15_r0_body.sizeA32 PRE_first_tail_x15_r0_body.sizeArgsA32 PRE_first_tail_x15_r0_body.sizeSymA32 PRE_first_tail_x15_r0_body.sizeMlxA32 PRE_first_tail_x15_r0_body.sizePayA32 PRE_first_tail_x15_r0_body.sizeTaA32 PRE_first_tail_x15_r0_body.sizeDecA32 PRE_first_tail_x15_r0_body.sizePreA32 PRE_first_tail_x15_r0_body.bodyPatchB32 (fun _ hm => bodyO119 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr119).trans bodyInactive0) (bodyBr120.trans bodyBr119.symm) bodyCnt119 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc120 PRE_first_tail_x15_r0_body.bodyRunSeg32 bodyAcc121 bodyHalt121 PRE_first_tail_x15_r0_body.bodyStepA33 bodyTop122 (fun _ hm => bodyO120 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr120).trans bodyInactive0) (bodyBr122.trans bodyBr120.symm) bodyCnt120 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) PRE_first_tail_x15_r0_body.sizeA33 PRE_first_tail_x15_r0_body.sizeArgsA33 PRE_first_tail_x15_r0_body.sizeSymA33 PRE_first_tail_x15_r0_body.sizeMlxA33 PRE_first_tail_x15_r0_body.sizePayA33 PRE_first_tail_x15_r0_body.sizeTaA33 PRE_first_tail_x15_r0_body.sizeDecA33 PRE_first_tail_x15_r0_body.sizePreA33 PRE_first_tail_x15_r0_body.bodyPatchB33 (fun _ hm => bodyO122 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr122).trans bodyInactive0) (bodyBr123.trans bodyBr122.symm) bodyCnt122 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc123 PRE_first_tail_x15_r0_body.bodyRunSeg33 bodyAcc124 bodyHalt124 PRE_first_tail_x15_r0_body.bodyStepA34 bodyTop125 (fun _ hm => bodyO123 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr123).trans bodyInactive0) (bodyBr125.trans bodyBr123.symm) bodyCnt123 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) PRE_first_tail_x15_r0_body.sizeA34 PRE_first_tail_x15_r0_body.sizeArgsA34 PRE_first_tail_x15_r0_body.sizeSymA34 PRE_first_tail_x15_r0_body.sizeMlxA34 PRE_first_tail_x15_r0_body.sizePayA34 PRE_first_tail_x15_r0_body.sizeTaA34 PRE_first_tail_x15_r0_body.sizeDecA34 PRE_first_tail_x15_r0_body.sizePreA34 PRE_first_tail_x15_r0_body.bodyPatchB34 (fun _ hm => bodyO125 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr125).trans bodyInactive0) (bodyBr126.trans bodyBr125.symm) bodyCnt125 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc126 PRE_first_tail_x15_r0_body.bodyRunSeg34 bodyAcc127 bodyHalt127 PRE_first_tail_x15_r0_body.bodyStepA35 bodyTop128 (fun _ hm => bodyO126 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr126).trans bodyInactive0) (bodyBr128.trans bodyBr126.symm) bodyCnt126 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) PRE_first_tail_x15_r0_body.sizeA35 PRE_first_tail_x15_r0_body.sizeArgsA35 PRE_first_tail_x15_r0_body.sizeSymA35 PRE_first_tail_x15_r0_body.sizeMlxA35 PRE_first_tail_x15_r0_body.sizePayA35 PRE_first_tail_x15_r0_body.sizeTaA35 PRE_first_tail_x15_r0_body.sizeDecA35 PRE_first_tail_x15_r0_body.sizePreA35 PRE_first_tail_x15_r0_body.bodyPatchB35 (fun _ hm => bodyO128 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr128).trans bodyInactive0) (bodyBr129.trans bodyBr128.symm) bodyCnt128 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7968, 98, 0, 63⟩) bodyAcc129 PRE_first_tail_x15_r0_body.bodyRunSeg35 bodyAcc130 bodyHalt130 PRE_first_tail_x15_r0_body.bodyStepA36 bodyTop131 (fun _ hm => bodyO129 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr129).trans bodyInactive0) (bodyBr131.trans bodyBr129.symm) bodyCnt129 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
