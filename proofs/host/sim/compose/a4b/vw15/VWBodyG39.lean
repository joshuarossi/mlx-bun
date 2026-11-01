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

kernel_rfl bodyO375 : PRE_first_tail_x15_r0_body.S375.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S375.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr375 : bridgeOf PRE_first_tail_x15_r0_body.s375.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc375 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s375 PRE_first_tail_x15_r0_body.S375) = fun _ _ => true
kernel_rfl bodyAcc377 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s377 PRE_first_tail_x15_r0_body.S377) = fun _ _ => true
kernel_rfl bodyBr378 : bridgeOf PRE_first_tail_x15_r0_body.s378.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt377 : isHalt PRE_first_tail_x15_r0_body.s377.ctl = false
kernel_rfl bodyTop378 : noRetBlock PRE_first_tail_x15_r0_body.s378 = true
kernel_rfl bodyCnt375 : countersOkB PRE_first_tail_x15_r0_body.s375 PRE_first_tail_x15_r0_body.s378 = true
kernel_rfl bodyO378 : PRE_first_tail_x15_r0_body.S378.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S378.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr379 : bridgeOf PRE_first_tail_x15_r0_body.s379.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt378 : countersOkB PRE_first_tail_x15_r0_body.s378 PRE_first_tail_x15_r0_body.s379 = true
kernel_rfl bodyO379 : PRE_first_tail_x15_r0_body.S379.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S379.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc379 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s379 PRE_first_tail_x15_r0_body.S379) = fun _ _ => true
kernel_rfl bodyAcc380 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s380 PRE_first_tail_x15_r0_body.S380) = fun _ _ => true
kernel_rfl bodyBr381 : bridgeOf PRE_first_tail_x15_r0_body.s381.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt380 : isHalt PRE_first_tail_x15_r0_body.s380.ctl = false
kernel_rfl bodyTop381 : noRetBlock PRE_first_tail_x15_r0_body.s381 = true
kernel_rfl bodyCnt379 : countersOkB PRE_first_tail_x15_r0_body.s379 PRE_first_tail_x15_r0_body.s381 = true
kernel_rfl bodyO381 : PRE_first_tail_x15_r0_body.S381.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S381.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr382 : bridgeOf PRE_first_tail_x15_r0_body.s382.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt381 : countersOkB PRE_first_tail_x15_r0_body.s381 PRE_first_tail_x15_r0_body.s382 = true
kernel_rfl bodyO382 : PRE_first_tail_x15_r0_body.S382.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S382.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc382 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s382 PRE_first_tail_x15_r0_body.S382) = fun _ _ => true
kernel_rfl bodyAcc383 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s383 PRE_first_tail_x15_r0_body.S383) = fun _ _ => true
kernel_rfl bodyBr384 : bridgeOf PRE_first_tail_x15_r0_body.s384.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt383 : isHalt PRE_first_tail_x15_r0_body.s383.ctl = false
kernel_rfl bodyTop384 : noRetBlock PRE_first_tail_x15_r0_body.s384 = true
kernel_rfl bodyCnt382 : countersOkB PRE_first_tail_x15_r0_body.s382 PRE_first_tail_x15_r0_body.s384 = true
kernel_rfl bodyO384 : PRE_first_tail_x15_r0_body.S384.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S384.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr385 : bridgeOf PRE_first_tail_x15_r0_body.s385.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt384 : countersOkB PRE_first_tail_x15_r0_body.s384 PRE_first_tail_x15_r0_body.s385 = true
kernel_rfl bodyO385 : PRE_first_tail_x15_r0_body.S385.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S385.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc385 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s385 PRE_first_tail_x15_r0_body.S385) = fun _ _ => true
kernel_rfl bodyAcc386 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s386 PRE_first_tail_x15_r0_body.S386) = fun _ _ => true
kernel_rfl bodyBr387 : bridgeOf PRE_first_tail_x15_r0_body.s387.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt386 : isHalt PRE_first_tail_x15_r0_body.s386.ctl = false
kernel_rfl bodyTop387 : noRetBlock PRE_first_tail_x15_r0_body.s387 = true
kernel_rfl bodyCnt385 : countersOkB PRE_first_tail_x15_r0_body.s385 PRE_first_tail_x15_r0_body.s387 = true
kernel_rfl bodyO387 : PRE_first_tail_x15_r0_body.S387.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S387.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr388 : bridgeOf PRE_first_tail_x15_r0_body.s388.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt387 : countersOkB PRE_first_tail_x15_r0_body.s387 PRE_first_tail_x15_r0_body.s388 = true
kernel_rfl bodyO388 : PRE_first_tail_x15_r0_body.S388.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S388.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc388 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s388 PRE_first_tail_x15_r0_body.S388) = fun _ _ => true
kernel_rfl bodyAcc389 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s389 PRE_first_tail_x15_r0_body.S389) = fun _ _ => true
kernel_rfl bodyBr390 : bridgeOf PRE_first_tail_x15_r0_body.s390.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt389 : isHalt PRE_first_tail_x15_r0_body.s389.ctl = false
kernel_rfl bodyTop390 : noRetBlock PRE_first_tail_x15_r0_body.s390 = true
kernel_rfl bodyCnt388 : countersOkB PRE_first_tail_x15_r0_body.s388 PRE_first_tail_x15_r0_body.s390 = true

theorem bodyGlue39 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16828, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s375 PRE_first_tail_x15_r0_body.S375)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16828, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s390 PRE_first_tail_x15_r0_body.S390) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) bodyAcc375 PRE_first_tail_x15_r0_body.bodyRunSeg101 bodyAcc377 bodyHalt377 PRE_first_tail_x15_r0_body.bodyStepA102 bodyTop378 (fun _ hm => bodyO375 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr375).trans bodyInactive0) (bodyBr378.trans bodyBr375.symm) bodyCnt375 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) PRE_first_tail_x15_r0_body.sizeA102 PRE_first_tail_x15_r0_body.sizeArgsA102 PRE_first_tail_x15_r0_body.sizeSymA102 PRE_first_tail_x15_r0_body.sizeMlxA102 PRE_first_tail_x15_r0_body.sizePayA102 PRE_first_tail_x15_r0_body.sizeTaA102 PRE_first_tail_x15_r0_body.sizeDecA102 PRE_first_tail_x15_r0_body.sizePreA102 PRE_first_tail_x15_r0_body.bodyPatchB102 (fun _ hm => bodyO378 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr378).trans bodyInactive0) (bodyBr379.trans bodyBr378.symm) bodyCnt378 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) bodyAcc379 PRE_first_tail_x15_r0_body.bodyRunSeg102 bodyAcc380 bodyHalt380 PRE_first_tail_x15_r0_body.bodyStepA103 bodyTop381 (fun _ hm => bodyO379 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr379).trans bodyInactive0) (bodyBr381.trans bodyBr379.symm) bodyCnt379 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) PRE_first_tail_x15_r0_body.sizeA103 PRE_first_tail_x15_r0_body.sizeArgsA103 PRE_first_tail_x15_r0_body.sizeSymA103 PRE_first_tail_x15_r0_body.sizeMlxA103 PRE_first_tail_x15_r0_body.sizePayA103 PRE_first_tail_x15_r0_body.sizeTaA103 PRE_first_tail_x15_r0_body.sizeDecA103 PRE_first_tail_x15_r0_body.sizePreA103 PRE_first_tail_x15_r0_body.bodyPatchB103 (fun _ hm => bodyO381 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr381).trans bodyInactive0) (bodyBr382.trans bodyBr381.symm) bodyCnt381 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) bodyAcc382 PRE_first_tail_x15_r0_body.bodyRunSeg103 bodyAcc383 bodyHalt383 PRE_first_tail_x15_r0_body.bodyStepA104 bodyTop384 (fun _ hm => bodyO382 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr382).trans bodyInactive0) (bodyBr384.trans bodyBr382.symm) bodyCnt382 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) PRE_first_tail_x15_r0_body.sizeA104 PRE_first_tail_x15_r0_body.sizeArgsA104 PRE_first_tail_x15_r0_body.sizeSymA104 PRE_first_tail_x15_r0_body.sizeMlxA104 PRE_first_tail_x15_r0_body.sizePayA104 PRE_first_tail_x15_r0_body.sizeTaA104 PRE_first_tail_x15_r0_body.sizeDecA104 PRE_first_tail_x15_r0_body.sizePreA104 PRE_first_tail_x15_r0_body.bodyPatchB104 (fun _ hm => bodyO384 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr384).trans bodyInactive0) (bodyBr385.trans bodyBr384.symm) bodyCnt384 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) bodyAcc385 PRE_first_tail_x15_r0_body.bodyRunSeg104 bodyAcc386 bodyHalt386 PRE_first_tail_x15_r0_body.bodyStepA105 bodyTop387 (fun _ hm => bodyO385 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr385).trans bodyInactive0) (bodyBr387.trans bodyBr385.symm) bodyCnt385 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) PRE_first_tail_x15_r0_body.sizeA105 PRE_first_tail_x15_r0_body.sizeArgsA105 PRE_first_tail_x15_r0_body.sizeSymA105 PRE_first_tail_x15_r0_body.sizeMlxA105 PRE_first_tail_x15_r0_body.sizePayA105 PRE_first_tail_x15_r0_body.sizeTaA105 PRE_first_tail_x15_r0_body.sizeDecA105 PRE_first_tail_x15_r0_body.sizePreA105 PRE_first_tail_x15_r0_body.bodyPatchB105 (fun _ hm => bodyO387 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr387).trans bodyInactive0) (bodyBr388.trans bodyBr387.symm) bodyCnt387 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16828, 277, 0, 207⟩) bodyAcc388 PRE_first_tail_x15_r0_body.bodyRunSeg105 bodyAcc389 bodyHalt389 PRE_first_tail_x15_r0_body.bodyStepA106 bodyTop390 (fun _ hm => bodyO388 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr388).trans bodyInactive0) (bodyBr390.trans bodyBr388.symm) bodyCnt388 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
