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

kernel_rfl bodyO0 : PRE_first_tail_x15_r0_body.S0.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S0.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr0 : bridgeOf PRE_first_tail_x15_r0_body.s0.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc0 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S0) = fun _ _ => true
kernel_rfl bodyAcc1 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1 PRE_first_tail_x15_r0_body.S1) = fun _ _ => true
kernel_rfl bodyBr2 : bridgeOf PRE_first_tail_x15_r0_body.s2.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1 : isHalt PRE_first_tail_x15_r0_body.s1.ctl = false
kernel_rfl bodyTop2 : noRetBlock PRE_first_tail_x15_r0_body.s2 = true
kernel_rfl bodyCnt0 : countersOkB PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.s2 = true
kernel_rfl bodyO2 : PRE_first_tail_x15_r0_body.S2.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S2.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr3 : bridgeOf PRE_first_tail_x15_r0_body.s3.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt2 : countersOkB PRE_first_tail_x15_r0_body.s2 PRE_first_tail_x15_r0_body.s3 = true
kernel_rfl bodyO3 : PRE_first_tail_x15_r0_body.S3.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S3.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc3 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s3 PRE_first_tail_x15_r0_body.S3) = fun _ _ => true
kernel_rfl bodyAcc5 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s5 PRE_first_tail_x15_r0_body.S5) = fun _ _ => true
kernel_rfl bodyBr6 : bridgeOf PRE_first_tail_x15_r0_body.s6.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt5 : isHalt PRE_first_tail_x15_r0_body.s5.ctl = false
kernel_rfl bodyTop6 : noRetBlock PRE_first_tail_x15_r0_body.s6 = true
kernel_rfl bodyCnt3 : countersOkB PRE_first_tail_x15_r0_body.s3 PRE_first_tail_x15_r0_body.s6 = true
kernel_rfl bodyO6 : PRE_first_tail_x15_r0_body.S6.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S6.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr7 : bridgeOf PRE_first_tail_x15_r0_body.s7.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt6 : countersOkB PRE_first_tail_x15_r0_body.s6 PRE_first_tail_x15_r0_body.s7 = true
kernel_rfl bodyO7 : PRE_first_tail_x15_r0_body.S7.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S7.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc7 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s7 PRE_first_tail_x15_r0_body.S7) = fun _ _ => true
kernel_rfl bodyAcc8 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s8 PRE_first_tail_x15_r0_body.S8) = fun _ _ => true
kernel_rfl bodyBr9 : bridgeOf PRE_first_tail_x15_r0_body.s9.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt8 : isHalt PRE_first_tail_x15_r0_body.s8.ctl = false
kernel_rfl bodyTop9 : noRetBlock PRE_first_tail_x15_r0_body.s9 = true
kernel_rfl bodyCnt7 : countersOkB PRE_first_tail_x15_r0_body.s7 PRE_first_tail_x15_r0_body.s9 = true
kernel_rfl bodyO9 : PRE_first_tail_x15_r0_body.S9.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S9.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr10 : bridgeOf PRE_first_tail_x15_r0_body.s10.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt9 : countersOkB PRE_first_tail_x15_r0_body.s9 PRE_first_tail_x15_r0_body.s10 = true
kernel_rfl bodyO10 : PRE_first_tail_x15_r0_body.S10.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S10.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc10 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s10 PRE_first_tail_x15_r0_body.S10) = fun _ _ => true
kernel_rfl bodyAcc11 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s11 PRE_first_tail_x15_r0_body.S11) = fun _ _ => true
kernel_rfl bodyBr12 : bridgeOf PRE_first_tail_x15_r0_body.s12.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt11 : isHalt PRE_first_tail_x15_r0_body.s11.ctl = false
kernel_rfl bodyTop12 : noRetBlock PRE_first_tail_x15_r0_body.s12 = true
kernel_rfl bodyCnt10 : countersOkB PRE_first_tail_x15_r0_body.s10 PRE_first_tail_x15_r0_body.s12 = true
kernel_rfl bodyO12 : PRE_first_tail_x15_r0_body.S12.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S12.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr13 : bridgeOf PRE_first_tail_x15_r0_body.s13.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt12 : countersOkB PRE_first_tail_x15_r0_body.s12 PRE_first_tail_x15_r0_body.s13 = true
kernel_rfl bodyO13 : PRE_first_tail_x15_r0_body.S13.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S13.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc13 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s13 PRE_first_tail_x15_r0_body.S13) = fun _ _ => true
kernel_rfl bodyAcc14 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s14 PRE_first_tail_x15_r0_body.S14) = fun _ _ => true
kernel_rfl bodyBr15 : bridgeOf PRE_first_tail_x15_r0_body.s15.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt14 : isHalt PRE_first_tail_x15_r0_body.s14.ctl = false
kernel_rfl bodyTop15 : noRetBlock PRE_first_tail_x15_r0_body.s15 = true
kernel_rfl bodyCnt13 : countersOkB PRE_first_tail_x15_r0_body.s13 PRE_first_tail_x15_r0_body.s15 = true

theorem bodyGlue0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S0)
      (bodyCut NB T tk π i x0 bodyΘ ⟨3571, 0, 0, 0⟩ bodyM PRE_first_tail_x15_r0_body.s15 PRE_first_tail_x15_r0_body.S15) 13512 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc0 PRE_first_tail_x15_r0_body.bodyRunSeg0 bodyAcc1 bodyHalt1 PRE_first_tail_x15_r0_body.bodyStepA1 bodyTop2 (fun _ hm => bodyO0 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr0).trans bodyInactive0) (bodyBr2.trans bodyBr0.symm) bodyCnt0 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x15_r0_body.sizeA1 PRE_first_tail_x15_r0_body.sizeArgsA1 PRE_first_tail_x15_r0_body.sizeSymA1 PRE_first_tail_x15_r0_body.sizeMlxA1 PRE_first_tail_x15_r0_body.sizePayA1 PRE_first_tail_x15_r0_body.sizeTaA1 PRE_first_tail_x15_r0_body.sizeDecA1 PRE_first_tail_x15_r0_body.sizePreA1 PRE_first_tail_x15_r0_body.bodyPatchB1 (fun _ hm => bodyO2 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr2).trans bodyInactive0) (bodyBr3.trans bodyBr2.symm) bodyCnt2 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc3 PRE_first_tail_x15_r0_body.bodyRunSeg1 bodyAcc5 bodyHalt5 PRE_first_tail_x15_r0_body.bodyStepA2 bodyTop6 (fun _ hm => bodyO3 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr3).trans bodyInactive0) (bodyBr6.trans bodyBr3.symm) bodyCnt3 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x15_r0_body.sizeA2 PRE_first_tail_x15_r0_body.sizeArgsA2 PRE_first_tail_x15_r0_body.sizeSymA2 PRE_first_tail_x15_r0_body.sizeMlxA2 PRE_first_tail_x15_r0_body.sizePayA2 PRE_first_tail_x15_r0_body.sizeTaA2 PRE_first_tail_x15_r0_body.sizeDecA2 PRE_first_tail_x15_r0_body.sizePreA2 PRE_first_tail_x15_r0_body.bodyPatchB2 (fun _ hm => bodyO6 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr6).trans bodyInactive0) (bodyBr7.trans bodyBr6.symm) bodyCnt6 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc7 PRE_first_tail_x15_r0_body.bodyRunSeg2 bodyAcc8 bodyHalt8 PRE_first_tail_x15_r0_body.bodyStepA3 bodyTop9 (fun _ hm => bodyO7 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr7).trans bodyInactive0) (bodyBr9.trans bodyBr7.symm) bodyCnt7 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x15_r0_body.sizeA3 PRE_first_tail_x15_r0_body.sizeArgsA3 PRE_first_tail_x15_r0_body.sizeSymA3 PRE_first_tail_x15_r0_body.sizeMlxA3 PRE_first_tail_x15_r0_body.sizePayA3 PRE_first_tail_x15_r0_body.sizeTaA3 PRE_first_tail_x15_r0_body.sizeDecA3 PRE_first_tail_x15_r0_body.sizePreA3 PRE_first_tail_x15_r0_body.bodyPatchB3 (fun _ hm => bodyO9 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr9).trans bodyInactive0) (bodyBr10.trans bodyBr9.symm) bodyCnt9 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc10 PRE_first_tail_x15_r0_body.bodyRunSeg3 bodyAcc11 bodyHalt11 PRE_first_tail_x15_r0_body.bodyStepA4 bodyTop12 (fun _ hm => bodyO10 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr10).trans bodyInactive0) (bodyBr12.trans bodyBr10.symm) bodyCnt10 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) PRE_first_tail_x15_r0_body.sizeA4 PRE_first_tail_x15_r0_body.sizeArgsA4 PRE_first_tail_x15_r0_body.sizeSymA4 PRE_first_tail_x15_r0_body.sizeMlxA4 PRE_first_tail_x15_r0_body.sizePayA4 PRE_first_tail_x15_r0_body.sizeTaA4 PRE_first_tail_x15_r0_body.sizeDecA4 PRE_first_tail_x15_r0_body.sizePreA4 PRE_first_tail_x15_r0_body.bodyPatchB4 (fun _ hm => bodyO12 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr12).trans bodyInactive0) (bodyBr13.trans bodyBr12.symm) bodyCnt12 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨3571, 0, 0, 0⟩) bodyAcc13 PRE_first_tail_x15_r0_body.bodyRunSeg4 bodyAcc14 bodyHalt14 PRE_first_tail_x15_r0_body.bodyStepA5 bodyTop15 (fun _ hm => bodyO13 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr13).trans bodyInactive0) (bodyBr15.trans bodyBr13.symm) bodyCnt13 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
