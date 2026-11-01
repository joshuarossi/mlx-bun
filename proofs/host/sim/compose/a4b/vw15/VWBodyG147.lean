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

kernel_rfl bodyO1410 : PRE_first_tail_x15_r0_body.S1410.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1410.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1410 : bridgeOf PRE_first_tail_x15_r0_body.s1410.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1410 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.S1410) = fun _ _ => true
kernel_rfl bodyAcc1412 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1412 PRE_first_tail_x15_r0_body.S1412) = fun _ _ => true
kernel_rfl bodyBr1413 : bridgeOf PRE_first_tail_x15_r0_body.s1413.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1412 : isHalt PRE_first_tail_x15_r0_body.s1412.ctl = false
kernel_rfl bodyTop1413 : noRetBlock PRE_first_tail_x15_r0_body.s1413 = true
kernel_rfl bodyCnt1410 : countersOkB PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.s1413 = true
kernel_rfl bodyO1413 : PRE_first_tail_x15_r0_body.S1413.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1413.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1414 : bridgeOf PRE_first_tail_x15_r0_body.s1414.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1413 : countersOkB PRE_first_tail_x15_r0_body.s1413 PRE_first_tail_x15_r0_body.s1414 = true
kernel_rfl bodyO1414 : PRE_first_tail_x15_r0_body.S1414.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1414.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1414 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1414 PRE_first_tail_x15_r0_body.S1414) = fun _ _ => true
kernel_rfl bodyAcc1415 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1415 PRE_first_tail_x15_r0_body.S1415) = fun _ _ => true
kernel_rfl bodyBr1416 : bridgeOf PRE_first_tail_x15_r0_body.s1416.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1415 : isHalt PRE_first_tail_x15_r0_body.s1415.ctl = false
kernel_rfl bodyTop1416 : noRetBlock PRE_first_tail_x15_r0_body.s1416 = true
kernel_rfl bodyCnt1414 : countersOkB PRE_first_tail_x15_r0_body.s1414 PRE_first_tail_x15_r0_body.s1416 = true
kernel_rfl bodyO1416 : PRE_first_tail_x15_r0_body.S1416.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1416.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1417 : bridgeOf PRE_first_tail_x15_r0_body.s1417.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1416 : countersOkB PRE_first_tail_x15_r0_body.s1416 PRE_first_tail_x15_r0_body.s1417 = true
kernel_rfl bodyO1417 : PRE_first_tail_x15_r0_body.S1417.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1417.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1417 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1417 PRE_first_tail_x15_r0_body.S1417) = fun _ _ => true
kernel_rfl bodyAcc1418 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1418 PRE_first_tail_x15_r0_body.S1418) = fun _ _ => true
kernel_rfl bodyBr1419 : bridgeOf PRE_first_tail_x15_r0_body.s1419.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1418 : isHalt PRE_first_tail_x15_r0_body.s1418.ctl = false
kernel_rfl bodyTop1419 : noRetBlock PRE_first_tail_x15_r0_body.s1419 = true
kernel_rfl bodyCnt1417 : countersOkB PRE_first_tail_x15_r0_body.s1417 PRE_first_tail_x15_r0_body.s1419 = true
kernel_rfl bodyO1419 : PRE_first_tail_x15_r0_body.S1419.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1419.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1420 : bridgeOf PRE_first_tail_x15_r0_body.s1420.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1419 : countersOkB PRE_first_tail_x15_r0_body.s1419 PRE_first_tail_x15_r0_body.s1420 = true
kernel_rfl bodyO1420 : PRE_first_tail_x15_r0_body.S1420.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1420.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1420 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1420 PRE_first_tail_x15_r0_body.S1420) = fun _ _ => true
kernel_rfl bodyAcc1421 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1421 PRE_first_tail_x15_r0_body.S1421) = fun _ _ => true
kernel_rfl bodyBr1422 : bridgeOf PRE_first_tail_x15_r0_body.s1422.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1421 : isHalt PRE_first_tail_x15_r0_body.s1421.ctl = false
kernel_rfl bodyTop1422 : noRetBlock PRE_first_tail_x15_r0_body.s1422 = true
kernel_rfl bodyCnt1420 : countersOkB PRE_first_tail_x15_r0_body.s1420 PRE_first_tail_x15_r0_body.s1422 = true
kernel_rfl bodyO1422 : PRE_first_tail_x15_r0_body.S1422.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1422.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1423 : bridgeOf PRE_first_tail_x15_r0_body.s1423.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1422 : countersOkB PRE_first_tail_x15_r0_body.s1422 PRE_first_tail_x15_r0_body.s1423 = true
kernel_rfl bodyO1423 : PRE_first_tail_x15_r0_body.S1423.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1423.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1423 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1423 PRE_first_tail_x15_r0_body.S1423) = fun _ _ => true
kernel_rfl bodyAcc1424 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1424 PRE_first_tail_x15_r0_body.S1424) = fun _ _ => true
kernel_rfl bodyBr1425 : bridgeOf PRE_first_tail_x15_r0_body.s1425.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1424 : isHalt PRE_first_tail_x15_r0_body.s1424.ctl = false
kernel_rfl bodyTop1425 : noRetBlock PRE_first_tail_x15_r0_body.s1425 = true
kernel_rfl bodyCnt1423 : countersOkB PRE_first_tail_x15_r0_body.s1423 PRE_first_tail_x15_r0_body.s1425 = true

theorem bodyGlue147 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨51550, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.S1410)
      (bodyCut NB T tk π i x0 bodyΘ ⟨51550, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1425 PRE_first_tail_x15_r0_body.S1425) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) bodyAcc1410 PRE_first_tail_x15_r0_body.bodyRunSeg380 bodyAcc1412 bodyHalt1412 PRE_first_tail_x15_r0_body.bodyStepA381 bodyTop1413 (fun _ hm => bodyO1410 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1410).trans bodyInactive0) (bodyBr1413.trans bodyBr1410.symm) bodyCnt1410 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) PRE_first_tail_x15_r0_body.sizeA381 PRE_first_tail_x15_r0_body.sizeArgsA381 PRE_first_tail_x15_r0_body.sizeSymA381 PRE_first_tail_x15_r0_body.sizeMlxA381 PRE_first_tail_x15_r0_body.sizePayA381 PRE_first_tail_x15_r0_body.sizeTaA381 PRE_first_tail_x15_r0_body.sizeDecA381 PRE_first_tail_x15_r0_body.sizePreA381 PRE_first_tail_x15_r0_body.bodyPatchB381 (fun _ hm => bodyO1413 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1413).trans bodyInactive0) (bodyBr1414.trans bodyBr1413.symm) bodyCnt1413 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) bodyAcc1414 PRE_first_tail_x15_r0_body.bodyRunSeg381 bodyAcc1415 bodyHalt1415 PRE_first_tail_x15_r0_body.bodyStepA382 bodyTop1416 (fun _ hm => bodyO1414 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1414).trans bodyInactive0) (bodyBr1416.trans bodyBr1414.symm) bodyCnt1414 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) PRE_first_tail_x15_r0_body.sizeA382 PRE_first_tail_x15_r0_body.sizeArgsA382 PRE_first_tail_x15_r0_body.sizeSymA382 PRE_first_tail_x15_r0_body.sizeMlxA382 PRE_first_tail_x15_r0_body.sizePayA382 PRE_first_tail_x15_r0_body.sizeTaA382 PRE_first_tail_x15_r0_body.sizeDecA382 PRE_first_tail_x15_r0_body.sizePreA382 PRE_first_tail_x15_r0_body.bodyPatchB382 (fun _ hm => bodyO1416 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1416).trans bodyInactive0) (bodyBr1417.trans bodyBr1416.symm) bodyCnt1416 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) bodyAcc1417 PRE_first_tail_x15_r0_body.bodyRunSeg382 bodyAcc1418 bodyHalt1418 PRE_first_tail_x15_r0_body.bodyStepA383 bodyTop1419 (fun _ hm => bodyO1417 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1417).trans bodyInactive0) (bodyBr1419.trans bodyBr1417.symm) bodyCnt1417 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) PRE_first_tail_x15_r0_body.sizeA383 PRE_first_tail_x15_r0_body.sizeArgsA383 PRE_first_tail_x15_r0_body.sizeSymA383 PRE_first_tail_x15_r0_body.sizeMlxA383 PRE_first_tail_x15_r0_body.sizePayA383 PRE_first_tail_x15_r0_body.sizeTaA383 PRE_first_tail_x15_r0_body.sizeDecA383 PRE_first_tail_x15_r0_body.sizePreA383 PRE_first_tail_x15_r0_body.bodyPatchB383 (fun _ hm => bodyO1419 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1419).trans bodyInactive0) (bodyBr1420.trans bodyBr1419.symm) bodyCnt1419 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) bodyAcc1420 PRE_first_tail_x15_r0_body.bodyRunSeg383 bodyAcc1421 bodyHalt1421 PRE_first_tail_x15_r0_body.bodyStepA384 bodyTop1422 (fun _ hm => bodyO1420 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1420).trans bodyInactive0) (bodyBr1422.trans bodyBr1420.symm) bodyCnt1420 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) PRE_first_tail_x15_r0_body.sizeA384 PRE_first_tail_x15_r0_body.sizeArgsA384 PRE_first_tail_x15_r0_body.sizeSymA384 PRE_first_tail_x15_r0_body.sizeMlxA384 PRE_first_tail_x15_r0_body.sizePayA384 PRE_first_tail_x15_r0_body.sizeTaA384 PRE_first_tail_x15_r0_body.sizeDecA384 PRE_first_tail_x15_r0_body.sizePreA384 PRE_first_tail_x15_r0_body.bodyPatchB384 (fun _ hm => bodyO1422 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1422).trans bodyInactive0) (bodyBr1423.trans bodyBr1422.symm) bodyCnt1422 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51550, 970, 0, 774⟩) bodyAcc1423 PRE_first_tail_x15_r0_body.bodyRunSeg384 bodyAcc1424 bodyHalt1424 PRE_first_tail_x15_r0_body.bodyStepA385 bodyTop1425 (fun _ hm => bodyO1423 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1423).trans bodyInactive0) (bodyBr1425.trans bodyBr1423.symm) bodyCnt1423 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
