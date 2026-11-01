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

kernel_rfl bodyO1381 : PRE_first_tail_x15_r0_body.S1381.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1381.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1381 : bridgeOf PRE_first_tail_x15_r0_body.s1381.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1381 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.S1381) = fun _ _ => true
kernel_rfl bodyAcc1383 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1383 PRE_first_tail_x15_r0_body.S1383) = fun _ _ => true
kernel_rfl bodyBr1384 : bridgeOf PRE_first_tail_x15_r0_body.s1384.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1383 : isHalt PRE_first_tail_x15_r0_body.s1383.ctl = false
kernel_rfl bodyTop1384 : noRetBlock PRE_first_tail_x15_r0_body.s1384 = true
kernel_rfl bodyCnt1381 : countersOkB PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.s1384 = true
kernel_rfl bodyO1384 : PRE_first_tail_x15_r0_body.S1384.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1384.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1385 : bridgeOf PRE_first_tail_x15_r0_body.s1385.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1384 : countersOkB PRE_first_tail_x15_r0_body.s1384 PRE_first_tail_x15_r0_body.s1385 = true
kernel_rfl bodyO1385 : PRE_first_tail_x15_r0_body.S1385.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1385.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1385 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1385 PRE_first_tail_x15_r0_body.S1385) = fun _ _ => true
kernel_rfl bodyAcc1386 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1386 PRE_first_tail_x15_r0_body.S1386) = fun _ _ => true
kernel_rfl bodyBr1387 : bridgeOf PRE_first_tail_x15_r0_body.s1387.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1386 : isHalt PRE_first_tail_x15_r0_body.s1386.ctl = false
kernel_rfl bodyTop1387 : noRetBlock PRE_first_tail_x15_r0_body.s1387 = true
kernel_rfl bodyCnt1385 : countersOkB PRE_first_tail_x15_r0_body.s1385 PRE_first_tail_x15_r0_body.s1387 = true
kernel_rfl bodyO1387 : PRE_first_tail_x15_r0_body.S1387.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1387.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1388 : bridgeOf PRE_first_tail_x15_r0_body.s1388.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1387 : countersOkB PRE_first_tail_x15_r0_body.s1387 PRE_first_tail_x15_r0_body.s1388 = true
kernel_rfl bodyO1388 : PRE_first_tail_x15_r0_body.S1388.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1388.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1388 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1388 PRE_first_tail_x15_r0_body.S1388) = fun _ _ => true
kernel_rfl bodyAcc1389 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1389 PRE_first_tail_x15_r0_body.S1389) = fun _ _ => true
kernel_rfl bodyBr1390 : bridgeOf PRE_first_tail_x15_r0_body.s1390.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1389 : isHalt PRE_first_tail_x15_r0_body.s1389.ctl = false
kernel_rfl bodyTop1390 : noRetBlock PRE_first_tail_x15_r0_body.s1390 = true
kernel_rfl bodyCnt1388 : countersOkB PRE_first_tail_x15_r0_body.s1388 PRE_first_tail_x15_r0_body.s1390 = true
kernel_rfl bodyO1390 : PRE_first_tail_x15_r0_body.S1390.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1390.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1391 : bridgeOf PRE_first_tail_x15_r0_body.s1391.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1390 : countersOkB PRE_first_tail_x15_r0_body.s1390 PRE_first_tail_x15_r0_body.s1391 = true
kernel_rfl bodyO1391 : PRE_first_tail_x15_r0_body.S1391.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1391.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1391 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1391 PRE_first_tail_x15_r0_body.S1391) = fun _ _ => true
kernel_rfl bodyAcc1392 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1392 PRE_first_tail_x15_r0_body.S1392) = fun _ _ => true
kernel_rfl bodyBr1393 : bridgeOf PRE_first_tail_x15_r0_body.s1393.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1392 : isHalt PRE_first_tail_x15_r0_body.s1392.ctl = false
kernel_rfl bodyTop1393 : noRetBlock PRE_first_tail_x15_r0_body.s1393 = true
kernel_rfl bodyCnt1391 : countersOkB PRE_first_tail_x15_r0_body.s1391 PRE_first_tail_x15_r0_body.s1393 = true
kernel_rfl bodyO1393 : PRE_first_tail_x15_r0_body.S1393.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1393.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1394 : bridgeOf PRE_first_tail_x15_r0_body.s1394.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1393 : countersOkB PRE_first_tail_x15_r0_body.s1393 PRE_first_tail_x15_r0_body.s1394 = true
kernel_rfl bodyO1394 : PRE_first_tail_x15_r0_body.S1394.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1394.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1394 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1394 PRE_first_tail_x15_r0_body.S1394) = fun _ _ => true
kernel_rfl bodyAcc1395 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1395 PRE_first_tail_x15_r0_body.S1395) = fun _ _ => true
kernel_rfl bodyBr1396 : bridgeOf PRE_first_tail_x15_r0_body.s1396.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1395 : isHalt PRE_first_tail_x15_r0_body.s1395.ctl = false
kernel_rfl bodyTop1396 : noRetBlock PRE_first_tail_x15_r0_body.s1396 = true
kernel_rfl bodyCnt1394 : countersOkB PRE_first_tail_x15_r0_body.s1394 PRE_first_tail_x15_r0_body.s1396 = true

theorem bodyGlue144 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50380, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.S1381)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50380, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1396 PRE_first_tail_x15_r0_body.S1396) 14768 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) bodyAcc1381 PRE_first_tail_x15_r0_body.bodyRunSeg372 bodyAcc1383 bodyHalt1383 PRE_first_tail_x15_r0_body.bodyStepA373 bodyTop1384 (fun _ hm => bodyO1381 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1381).trans bodyInactive0) (bodyBr1384.trans bodyBr1381.symm) bodyCnt1381 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) PRE_first_tail_x15_r0_body.sizeA373 PRE_first_tail_x15_r0_body.sizeArgsA373 PRE_first_tail_x15_r0_body.sizeSymA373 PRE_first_tail_x15_r0_body.sizeMlxA373 PRE_first_tail_x15_r0_body.sizePayA373 PRE_first_tail_x15_r0_body.sizeTaA373 PRE_first_tail_x15_r0_body.sizeDecA373 PRE_first_tail_x15_r0_body.sizePreA373 PRE_first_tail_x15_r0_body.bodyPatchB373 (fun _ hm => bodyO1384 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1384).trans bodyInactive0) (bodyBr1385.trans bodyBr1384.symm) bodyCnt1384 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) bodyAcc1385 PRE_first_tail_x15_r0_body.bodyRunSeg373 bodyAcc1386 bodyHalt1386 PRE_first_tail_x15_r0_body.bodyStepA374 bodyTop1387 (fun _ hm => bodyO1385 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1385).trans bodyInactive0) (bodyBr1387.trans bodyBr1385.symm) bodyCnt1385 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) PRE_first_tail_x15_r0_body.sizeA374 PRE_first_tail_x15_r0_body.sizeArgsA374 PRE_first_tail_x15_r0_body.sizeSymA374 PRE_first_tail_x15_r0_body.sizeMlxA374 PRE_first_tail_x15_r0_body.sizePayA374 PRE_first_tail_x15_r0_body.sizeTaA374 PRE_first_tail_x15_r0_body.sizeDecA374 PRE_first_tail_x15_r0_body.sizePreA374 PRE_first_tail_x15_r0_body.bodyPatchB374 (fun _ hm => bodyO1387 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1387).trans bodyInactive0) (bodyBr1388.trans bodyBr1387.symm) bodyCnt1387 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) bodyAcc1388 PRE_first_tail_x15_r0_body.bodyRunSeg374 bodyAcc1389 bodyHalt1389 PRE_first_tail_x15_r0_body.bodyStepA375 bodyTop1390 (fun _ hm => bodyO1388 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1388).trans bodyInactive0) (bodyBr1390.trans bodyBr1388.symm) bodyCnt1388 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) PRE_first_tail_x15_r0_body.sizeA375 PRE_first_tail_x15_r0_body.sizeArgsA375 PRE_first_tail_x15_r0_body.sizeSymA375 PRE_first_tail_x15_r0_body.sizeMlxA375 PRE_first_tail_x15_r0_body.sizePayA375 PRE_first_tail_x15_r0_body.sizeTaA375 PRE_first_tail_x15_r0_body.sizeDecA375 PRE_first_tail_x15_r0_body.sizePreA375 PRE_first_tail_x15_r0_body.bodyPatchB375 (fun _ hm => bodyO1390 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1390).trans bodyInactive0) (bodyBr1391.trans bodyBr1390.symm) bodyCnt1390 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) bodyAcc1391 PRE_first_tail_x15_r0_body.bodyRunSeg375 bodyAcc1392 bodyHalt1392 PRE_first_tail_x15_r0_body.bodyStepA376 bodyTop1393 (fun _ hm => bodyO1391 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1391).trans bodyInactive0) (bodyBr1393.trans bodyBr1391.symm) bodyCnt1391 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) PRE_first_tail_x15_r0_body.sizeA376 PRE_first_tail_x15_r0_body.sizeArgsA376 PRE_first_tail_x15_r0_body.sizeSymA376 PRE_first_tail_x15_r0_body.sizeMlxA376 PRE_first_tail_x15_r0_body.sizePayA376 PRE_first_tail_x15_r0_body.sizeTaA376 PRE_first_tail_x15_r0_body.sizeDecA376 PRE_first_tail_x15_r0_body.sizePreA376 PRE_first_tail_x15_r0_body.bodyPatchB376 (fun _ hm => bodyO1393 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1393).trans bodyInactive0) (bodyBr1394.trans bodyBr1393.symm) bodyCnt1393 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50380, 945, 0, 756⟩) bodyAcc1394 PRE_first_tail_x15_r0_body.bodyRunSeg376 bodyAcc1395 bodyHalt1395 PRE_first_tail_x15_r0_body.bodyStepA377 bodyTop1396 (fun _ hm => bodyO1394 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1394).trans bodyInactive0) (bodyBr1396.trans bodyBr1394.symm) bodyCnt1394 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
