import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.VWBodyBase
import host.sim.compose.a4b.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.Bridge
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSteps0
import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSeg0
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSeg1
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSeg2
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSeg3
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSteps1
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedSeg4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
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
kernel_rfl bodyAcc4 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s4 PRE_first_tail_x15_r0_body.S4) = fun _ _ => true
kernel_rfl bodyBr5 : bridgeOf PRE_first_tail_x15_r0_body.s5.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt4 : isHalt PRE_first_tail_x15_r0_body.s4.ctl = false
kernel_rfl bodyTop5 : noRetBlock PRE_first_tail_x15_r0_body.s5 = true
kernel_rfl bodyCnt3 : countersOkB PRE_first_tail_x15_r0_body.s3 PRE_first_tail_x15_r0_body.s5 = true
kernel_rfl bodyO5 : PRE_first_tail_x15_r0_body.S5.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S5.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr6 : bridgeOf PRE_first_tail_x15_r0_body.s6.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt5 : countersOkB PRE_first_tail_x15_r0_body.s5 PRE_first_tail_x15_r0_body.s6 = true
kernel_rfl bodyO6 : PRE_first_tail_x15_r0_body.S6.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S6.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc6 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s6 PRE_first_tail_x15_r0_body.S6) = fun _ _ => true
kernel_rfl bodyAcc7 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s7 PRE_first_tail_x15_r0_body.S7) = fun _ _ => true
kernel_rfl bodyBr8 : bridgeOf PRE_first_tail_x15_r0_body.s8.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt7 : isHalt PRE_first_tail_x15_r0_body.s7.ctl = false
kernel_rfl bodyTop8 : noRetBlock PRE_first_tail_x15_r0_body.s8 = true
kernel_rfl bodyCnt6 : countersOkB PRE_first_tail_x15_r0_body.s6 PRE_first_tail_x15_r0_body.s8 = true
kernel_rfl bodyO8 : PRE_first_tail_x15_r0_body.S8.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S8.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr9 : bridgeOf PRE_first_tail_x15_r0_body.s9.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt8 : countersOkB PRE_first_tail_x15_r0_body.s8 PRE_first_tail_x15_r0_body.s9 = true
kernel_rfl bodyO9 : PRE_first_tail_x15_r0_body.S9.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S9.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc9 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s9 PRE_first_tail_x15_r0_body.S9) = fun _ _ => true
kernel_rfl bodyAcc10 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s10 PRE_first_tail_x15_r0_body.S10) = fun _ _ => true
kernel_rfl bodyBr11 : bridgeOf PRE_first_tail_x15_r0_body.s11.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt10 : isHalt PRE_first_tail_x15_r0_body.s10.ctl = false
kernel_rfl bodyTop11 : noRetBlock PRE_first_tail_x15_r0_body.s11 = true
kernel_rfl bodyCnt9 : countersOkB PRE_first_tail_x15_r0_body.s9 PRE_first_tail_x15_r0_body.s11 = true
kernel_rfl bodyO11 : PRE_first_tail_x15_r0_body.S11.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S11.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr12 : bridgeOf PRE_first_tail_x15_r0_body.s12.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt11 : countersOkB PRE_first_tail_x15_r0_body.s11 PRE_first_tail_x15_r0_body.s12 = true
kernel_rfl bodyO12 : PRE_first_tail_x15_r0_body.S12.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S12.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc12 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s12 PRE_first_tail_x15_r0_body.S12) = fun _ _ => true
kernel_rfl bodyAcc13 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s13 PRE_first_tail_x15_r0_body.S13) = fun _ _ => true
kernel_rfl bodyBr14 : bridgeOf PRE_first_tail_x15_r0_body.s14.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt13 : isHalt PRE_first_tail_x15_r0_body.s13.ctl = false
kernel_rfl bodyTop14 : noRetBlock PRE_first_tail_x15_r0_body.s14 = true
kernel_rfl bodyCnt12 : countersOkB PRE_first_tail_x15_r0_body.s12 PRE_first_tail_x15_r0_body.s14 = true

theorem bodyGlue0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    ∃ n, CutStep (bodyCut NB T tk π i ⟨3571, 0, 0⟩ bodyM PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S0)
      (bodyCut NB T tk π i ⟨3571, 0, 0⟩ bodyM PRE_first_tail_x15_r0_body.s14 PRE_first_tail_x15_r0_body.S14) n :=
  ⟨_, ((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) bodyAcc0 PRE_first_tail_x15_r0_body.bodyRunSeg0 bodyAcc1 bodyHalt1 PRE_first_tail_x15_r0_body.bodyStepA1 bodyTop2 (fun _ hm => bodyO0 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr0).trans bodyInactive0) (bodyBr2.trans bodyBr0.symm) bodyCnt0).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) PRE_first_tail_x15_r0_body.sizeA1 PRE_first_tail_x15_r0_body.sizeArgsA1 PRE_first_tail_x15_r0_body.sizeSymA1 PRE_first_tail_x15_r0_body.sizeMlxA1 PRE_first_tail_x15_r0_body.sizePayA1 PRE_first_tail_x15_r0_body.sizeTaA1 PRE_first_tail_x15_r0_body.sizeDecA1 PRE_first_tail_x15_r0_body.sizePreA1 PRE_first_tail_x15_r0_body.bodyPatchB1 (fun _ hm => bodyO2 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr2).trans bodyInactive0) (bodyBr3.trans bodyBr2.symm) bodyCnt2)).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) bodyAcc3 PRE_first_tail_x15_r0_body.bodyRunSeg1 bodyAcc4 bodyHalt4 PRE_first_tail_x15_r0_body.bodyStepA2 bodyTop5 (fun _ hm => bodyO3 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr3).trans bodyInactive0) (bodyBr5.trans bodyBr3.symm) bodyCnt3)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) PRE_first_tail_x15_r0_body.sizeA2 PRE_first_tail_x15_r0_body.sizeArgsA2 PRE_first_tail_x15_r0_body.sizeSymA2 PRE_first_tail_x15_r0_body.sizeMlxA2 PRE_first_tail_x15_r0_body.sizePayA2 PRE_first_tail_x15_r0_body.sizeTaA2 PRE_first_tail_x15_r0_body.sizeDecA2 PRE_first_tail_x15_r0_body.sizePreA2 PRE_first_tail_x15_r0_body.bodyPatchB2 (fun _ hm => bodyO5 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr5).trans bodyInactive0) (bodyBr6.trans bodyBr5.symm) bodyCnt5)).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) bodyAcc6 PRE_first_tail_x15_r0_body.bodyRunSeg2 bodyAcc7 bodyHalt7 PRE_first_tail_x15_r0_body.bodyStepA3 bodyTop8 (fun _ hm => bodyO6 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr6).trans bodyInactive0) (bodyBr8.trans bodyBr6.symm) bodyCnt6)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) PRE_first_tail_x15_r0_body.sizeA3 PRE_first_tail_x15_r0_body.sizeArgsA3 PRE_first_tail_x15_r0_body.sizeSymA3 PRE_first_tail_x15_r0_body.sizeMlxA3 PRE_first_tail_x15_r0_body.sizePayA3 PRE_first_tail_x15_r0_body.sizeTaA3 PRE_first_tail_x15_r0_body.sizeDecA3 PRE_first_tail_x15_r0_body.sizePreA3 PRE_first_tail_x15_r0_body.bodyPatchB3 (fun _ hm => bodyO8 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr8).trans bodyInactive0) (bodyBr9.trans bodyBr8.symm) bodyCnt8)).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) bodyAcc9 PRE_first_tail_x15_r0_body.bodyRunSeg3 bodyAcc10 bodyHalt10 PRE_first_tail_x15_r0_body.bodyStepA4 bodyTop11 (fun _ hm => bodyO9 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr9).trans bodyInactive0) (bodyBr11.trans bodyBr9.symm) bodyCnt9)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) PRE_first_tail_x15_r0_body.sizeA4 PRE_first_tail_x15_r0_body.sizeArgsA4 PRE_first_tail_x15_r0_body.sizeSymA4 PRE_first_tail_x15_r0_body.sizeMlxA4 PRE_first_tail_x15_r0_body.sizePayA4 PRE_first_tail_x15_r0_body.sizeTaA4 PRE_first_tail_x15_r0_body.sizeDecA4 PRE_first_tail_x15_r0_body.sizePreA4 PRE_first_tail_x15_r0_body.bodyPatchB4 (fun _ hm => bodyO11 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr11).trans bodyInactive0) (bodyBr12.trans bodyBr11.symm) bodyCnt11)).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ⟨3571, 0, 0⟩) bodyAcc12 PRE_first_tail_x15_r0_body.bodyRunSeg4 bodyAcc13 bodyHalt13 PRE_first_tail_x15_r0_body.bodyStepA5 bodyTop14 (fun _ hm => bodyO12 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr12).trans bodyInactive0) (bodyBr14.trans bodyBr12.symm) bodyCnt12)⟩

end Host.Ts.Sim.Compose.VWFirst
