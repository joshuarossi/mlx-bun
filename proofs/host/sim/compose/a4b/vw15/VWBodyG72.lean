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

kernel_rfl bodyO691 : PRE_first_tail_x15_r0_body.S691.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S691.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr691 : bridgeOf PRE_first_tail_x15_r0_body.s691.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc691 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.S691) = fun _ _ => true
kernel_rfl bodyAcc693 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s693 PRE_first_tail_x15_r0_body.S693) = fun _ _ => true
kernel_rfl bodyBr694 : bridgeOf PRE_first_tail_x15_r0_body.s694.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt693 : isHalt PRE_first_tail_x15_r0_body.s693.ctl = false
kernel_rfl bodyTop694 : noRetBlock PRE_first_tail_x15_r0_body.s694 = true
kernel_rfl bodyCnt691 : countersOkB PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.s694 = true
kernel_rfl bodyO694 : PRE_first_tail_x15_r0_body.S694.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S694.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr695 : bridgeOf PRE_first_tail_x15_r0_body.s695.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt694 : countersOkB PRE_first_tail_x15_r0_body.s694 PRE_first_tail_x15_r0_body.s695 = true
kernel_rfl bodyO695 : PRE_first_tail_x15_r0_body.S695.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S695.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc695 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s695 PRE_first_tail_x15_r0_body.S695) = fun _ _ => true
kernel_rfl bodyAcc696 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s696 PRE_first_tail_x15_r0_body.S696) = fun _ _ => true
kernel_rfl bodyBr697 : bridgeOf PRE_first_tail_x15_r0_body.s697.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt696 : isHalt PRE_first_tail_x15_r0_body.s696.ctl = false
kernel_rfl bodyTop697 : noRetBlock PRE_first_tail_x15_r0_body.s697 = true
kernel_rfl bodyCnt695 : countersOkB PRE_first_tail_x15_r0_body.s695 PRE_first_tail_x15_r0_body.s697 = true
kernel_rfl bodyO697 : PRE_first_tail_x15_r0_body.S697.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S697.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr698 : bridgeOf PRE_first_tail_x15_r0_body.s698.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt697 : countersOkB PRE_first_tail_x15_r0_body.s697 PRE_first_tail_x15_r0_body.s698 = true
kernel_rfl bodyO698 : PRE_first_tail_x15_r0_body.S698.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S698.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc698 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s698 PRE_first_tail_x15_r0_body.S698) = fun _ _ => true
kernel_rfl bodyAcc699 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s699 PRE_first_tail_x15_r0_body.S699) = fun _ _ => true
kernel_rfl bodyBr700 : bridgeOf PRE_first_tail_x15_r0_body.s700.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt699 : isHalt PRE_first_tail_x15_r0_body.s699.ctl = false
kernel_rfl bodyTop700 : noRetBlock PRE_first_tail_x15_r0_body.s700 = true
kernel_rfl bodyCnt698 : countersOkB PRE_first_tail_x15_r0_body.s698 PRE_first_tail_x15_r0_body.s700 = true
kernel_rfl bodyO700 : PRE_first_tail_x15_r0_body.S700.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S700.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr701 : bridgeOf PRE_first_tail_x15_r0_body.s701.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt700 : countersOkB PRE_first_tail_x15_r0_body.s700 PRE_first_tail_x15_r0_body.s701 = true
kernel_rfl bodyO701 : PRE_first_tail_x15_r0_body.S701.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S701.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc701 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s701 PRE_first_tail_x15_r0_body.S701) = fun _ _ => true
kernel_rfl bodyAcc702 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s702 PRE_first_tail_x15_r0_body.S702) = fun _ _ => true
kernel_rfl bodyBr703 : bridgeOf PRE_first_tail_x15_r0_body.s703.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt702 : isHalt PRE_first_tail_x15_r0_body.s702.ctl = false
kernel_rfl bodyTop703 : noRetBlock PRE_first_tail_x15_r0_body.s703 = true
kernel_rfl bodyCnt701 : countersOkB PRE_first_tail_x15_r0_body.s701 PRE_first_tail_x15_r0_body.s703 = true
kernel_rfl bodyO703 : PRE_first_tail_x15_r0_body.S703.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S703.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr704 : bridgeOf PRE_first_tail_x15_r0_body.s704.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt703 : countersOkB PRE_first_tail_x15_r0_body.s703 PRE_first_tail_x15_r0_body.s704 = true
kernel_rfl bodyO704 : PRE_first_tail_x15_r0_body.S704.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S704.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc704 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s704 PRE_first_tail_x15_r0_body.S704) = fun _ _ => true
kernel_rfl bodyAcc705 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s705 PRE_first_tail_x15_r0_body.S705) = fun _ _ => true
kernel_rfl bodyBr706 : bridgeOf PRE_first_tail_x15_r0_body.s706.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt705 : isHalt PRE_first_tail_x15_r0_body.s705.ctl = false
kernel_rfl bodyTop706 : noRetBlock PRE_first_tail_x15_r0_body.s706 = true
kernel_rfl bodyCnt704 : countersOkB PRE_first_tail_x15_r0_body.s704 PRE_first_tail_x15_r0_body.s706 = true

theorem bodyGlue72 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨27247, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.S691)
      (bodyCut NB T tk π i x0 bodyΘ ⟨27247, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s706 PRE_first_tail_x15_r0_body.S706) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) bodyAcc691 PRE_first_tail_x15_r0_body.bodyRunSeg186 bodyAcc693 bodyHalt693 PRE_first_tail_x15_r0_body.bodyStepA187 bodyTop694 (fun _ hm => bodyO691 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr691).trans bodyInactive0) (bodyBr694.trans bodyBr691.symm) bodyCnt691 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) PRE_first_tail_x15_r0_body.sizeA187 PRE_first_tail_x15_r0_body.sizeArgsA187 PRE_first_tail_x15_r0_body.sizeSymA187 PRE_first_tail_x15_r0_body.sizeMlxA187 PRE_first_tail_x15_r0_body.sizePayA187 PRE_first_tail_x15_r0_body.sizeTaA187 PRE_first_tail_x15_r0_body.sizeDecA187 PRE_first_tail_x15_r0_body.sizePreA187 PRE_first_tail_x15_r0_body.bodyPatchB187 (fun _ hm => bodyO694 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr694).trans bodyInactive0) (bodyBr695.trans bodyBr694.symm) bodyCnt694 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) bodyAcc695 PRE_first_tail_x15_r0_body.bodyRunSeg187 bodyAcc696 bodyHalt696 PRE_first_tail_x15_r0_body.bodyStepA188 bodyTop697 (fun _ hm => bodyO695 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr695).trans bodyInactive0) (bodyBr697.trans bodyBr695.symm) bodyCnt695 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) PRE_first_tail_x15_r0_body.sizeA188 PRE_first_tail_x15_r0_body.sizeArgsA188 PRE_first_tail_x15_r0_body.sizeSymA188 PRE_first_tail_x15_r0_body.sizeMlxA188 PRE_first_tail_x15_r0_body.sizePayA188 PRE_first_tail_x15_r0_body.sizeTaA188 PRE_first_tail_x15_r0_body.sizeDecA188 PRE_first_tail_x15_r0_body.sizePreA188 PRE_first_tail_x15_r0_body.bodyPatchB188 (fun _ hm => bodyO697 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr697).trans bodyInactive0) (bodyBr698.trans bodyBr697.symm) bodyCnt697 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) bodyAcc698 PRE_first_tail_x15_r0_body.bodyRunSeg188 bodyAcc699 bodyHalt699 PRE_first_tail_x15_r0_body.bodyStepA189 bodyTop700 (fun _ hm => bodyO698 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr698).trans bodyInactive0) (bodyBr700.trans bodyBr698.symm) bodyCnt698 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) PRE_first_tail_x15_r0_body.sizeA189 PRE_first_tail_x15_r0_body.sizeArgsA189 PRE_first_tail_x15_r0_body.sizeSymA189 PRE_first_tail_x15_r0_body.sizeMlxA189 PRE_first_tail_x15_r0_body.sizePayA189 PRE_first_tail_x15_r0_body.sizeTaA189 PRE_first_tail_x15_r0_body.sizeDecA189 PRE_first_tail_x15_r0_body.sizePreA189 PRE_first_tail_x15_r0_body.bodyPatchB189 (fun _ hm => bodyO700 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr700).trans bodyInactive0) (bodyBr701.trans bodyBr700.symm) bodyCnt700 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) bodyAcc701 PRE_first_tail_x15_r0_body.bodyRunSeg189 bodyAcc702 bodyHalt702 PRE_first_tail_x15_r0_body.bodyStepA190 bodyTop703 (fun _ hm => bodyO701 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr701).trans bodyInactive0) (bodyBr703.trans bodyBr701.symm) bodyCnt701 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) PRE_first_tail_x15_r0_body.sizeA190 PRE_first_tail_x15_r0_body.sizeArgsA190 PRE_first_tail_x15_r0_body.sizeSymA190 PRE_first_tail_x15_r0_body.sizeMlxA190 PRE_first_tail_x15_r0_body.sizePayA190 PRE_first_tail_x15_r0_body.sizeTaA190 PRE_first_tail_x15_r0_body.sizeDecA190 PRE_first_tail_x15_r0_body.sizePreA190 PRE_first_tail_x15_r0_body.bodyPatchB190 (fun _ hm => bodyO703 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr703).trans bodyInactive0) (bodyBr704.trans bodyBr703.symm) bodyCnt703 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27247, 483, 0, 378⟩) bodyAcc704 PRE_first_tail_x15_r0_body.bodyRunSeg190 bodyAcc705 bodyHalt705 PRE_first_tail_x15_r0_body.bodyStepA191 bodyTop706 (fun _ hm => bodyO704 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr704).trans bodyInactive0) (bodyBr706.trans bodyBr704.symm) bodyCnt704 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
