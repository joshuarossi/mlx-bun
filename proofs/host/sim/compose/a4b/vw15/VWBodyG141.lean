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

kernel_rfl bodyO1353 : PRE_first_tail_x15_r0_body.S1353.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1353.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1353 : bridgeOf PRE_first_tail_x15_r0_body.s1353.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1353 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.S1353) = fun _ _ => true
kernel_rfl bodyAcc1355 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1355 PRE_first_tail_x15_r0_body.S1355) = fun _ _ => true
kernel_rfl bodyBr1356 : bridgeOf PRE_first_tail_x15_r0_body.s1356.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1355 : isHalt PRE_first_tail_x15_r0_body.s1355.ctl = false
kernel_rfl bodyTop1356 : noRetBlock PRE_first_tail_x15_r0_body.s1356 = true
kernel_rfl bodyCnt1353 : countersOkB PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.s1356 = true
kernel_rfl bodyO1356 : PRE_first_tail_x15_r0_body.S1356.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1356.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1357 : bridgeOf PRE_first_tail_x15_r0_body.s1357.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1356 : countersOkB PRE_first_tail_x15_r0_body.s1356 PRE_first_tail_x15_r0_body.s1357 = true
kernel_rfl bodyO1357 : PRE_first_tail_x15_r0_body.S1357.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1357.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1357 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1357 PRE_first_tail_x15_r0_body.S1357) = fun _ _ => true
kernel_rfl bodyAcc1359 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1359 PRE_first_tail_x15_r0_body.S1359) = fun _ _ => true
kernel_rfl bodyBr1360 : bridgeOf PRE_first_tail_x15_r0_body.s1360.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1359 : isHalt PRE_first_tail_x15_r0_body.s1359.ctl = false
kernel_rfl bodyTop1360 : noRetBlock PRE_first_tail_x15_r0_body.s1360 = true
kernel_rfl bodyCnt1357 : countersOkB PRE_first_tail_x15_r0_body.s1357 PRE_first_tail_x15_r0_body.s1360 = true
kernel_rfl bodyO1360 : PRE_first_tail_x15_r0_body.S1360.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1360.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1361 : bridgeOf PRE_first_tail_x15_r0_body.s1361.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1360 : countersOkB PRE_first_tail_x15_r0_body.s1360 PRE_first_tail_x15_r0_body.s1361 = true
kernel_rfl bodyO1361 : PRE_first_tail_x15_r0_body.S1361.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1361.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1361 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1361 PRE_first_tail_x15_r0_body.S1361) = fun _ _ => true
kernel_rfl bodyAcc1362 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1362 PRE_first_tail_x15_r0_body.S1362) = fun _ _ => true
kernel_rfl bodyBr1363 : bridgeOf PRE_first_tail_x15_r0_body.s1363.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1362 : isHalt PRE_first_tail_x15_r0_body.s1362.ctl = false
kernel_rfl bodyTop1363 : noRetBlock PRE_first_tail_x15_r0_body.s1363 = true
kernel_rfl bodyCnt1361 : countersOkB PRE_first_tail_x15_r0_body.s1361 PRE_first_tail_x15_r0_body.s1363 = true
kernel_rfl bodyO1363 : PRE_first_tail_x15_r0_body.S1363.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1363.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1364 : bridgeOf PRE_first_tail_x15_r0_body.s1364.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1363 : countersOkB PRE_first_tail_x15_r0_body.s1363 PRE_first_tail_x15_r0_body.s1364 = true
kernel_rfl bodyO1364 : PRE_first_tail_x15_r0_body.S1364.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1364.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1364 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1364 PRE_first_tail_x15_r0_body.S1364) = fun _ _ => true
kernel_rfl bodyAcc1366 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1366 PRE_first_tail_x15_r0_body.S1366) = fun _ _ => true
kernel_rfl bodyBr1367 : bridgeOf PRE_first_tail_x15_r0_body.s1367.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1366 : isHalt PRE_first_tail_x15_r0_body.s1366.ctl = false
kernel_rfl bodyTop1367 : noRetBlock PRE_first_tail_x15_r0_body.s1367 = true
kernel_rfl bodyCnt1364 : countersOkB PRE_first_tail_x15_r0_body.s1364 PRE_first_tail_x15_r0_body.s1367 = true

theorem bodyGlue141 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50009, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.S1353)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50009, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1367 PRE_first_tail_x15_r0_body.S1367) 17025 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50009, 943, 0, 747⟩) bodyAcc1353 PRE_first_tail_x15_r0_body.bodyRunSeg365 bodyAcc1355 bodyHalt1355 PRE_first_tail_x15_r0_body.bodyStepA366 bodyTop1356 (fun _ hm => bodyO1353 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1353).trans bodyInactive0) (bodyBr1356.trans bodyBr1353.symm) bodyCnt1353 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50009, 943, 0, 747⟩) PRE_first_tail_x15_r0_body.sizeA366 PRE_first_tail_x15_r0_body.sizeArgsA366 PRE_first_tail_x15_r0_body.sizeSymA366 PRE_first_tail_x15_r0_body.sizeMlxA366 PRE_first_tail_x15_r0_body.sizePayA366 PRE_first_tail_x15_r0_body.sizeTaA366 PRE_first_tail_x15_r0_body.sizeDecA366 PRE_first_tail_x15_r0_body.sizePreA366 PRE_first_tail_x15_r0_body.bodyPatchB366 (fun _ hm => bodyO1356 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1356).trans bodyInactive0) (bodyBr1357.trans bodyBr1356.symm) bodyCnt1356 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50009, 943, 0, 747⟩) bodyAcc1357 PRE_first_tail_x15_r0_body.bodyRunSeg366 bodyAcc1359 bodyHalt1359 PRE_first_tail_x15_r0_body.bodyStepA367 bodyTop1360 (fun _ hm => bodyO1357 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1357).trans bodyInactive0) (bodyBr1360.trans bodyBr1357.symm) bodyCnt1357 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50009, 943, 0, 747⟩) PRE_first_tail_x15_r0_body.sizeA367 PRE_first_tail_x15_r0_body.sizeArgsA367 PRE_first_tail_x15_r0_body.sizeSymA367 PRE_first_tail_x15_r0_body.sizeMlxA367 PRE_first_tail_x15_r0_body.sizePayA367 PRE_first_tail_x15_r0_body.sizeTaA367 PRE_first_tail_x15_r0_body.sizeDecA367 PRE_first_tail_x15_r0_body.sizePreA367 PRE_first_tail_x15_r0_body.bodyPatchB367 (fun _ hm => bodyO1360 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1360).trans bodyInactive0) (bodyBr1361.trans bodyBr1360.symm) bodyCnt1360 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50009, 943, 0, 747⟩) bodyAcc1361 PRE_first_tail_x15_r0_body.bodyRunSeg367 bodyAcc1362 bodyHalt1362 PRE_first_tail_x15_r0_body.bodyStepA368 bodyTop1363 (fun _ hm => bodyO1361 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1361).trans bodyInactive0) (bodyBr1363.trans bodyBr1361.symm) bodyCnt1361 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50009, 943, 0, 747⟩) PRE_first_tail_x15_r0_body.sizeA368 PRE_first_tail_x15_r0_body.sizeArgsA368 PRE_first_tail_x15_r0_body.sizeSymA368 PRE_first_tail_x15_r0_body.sizeMlxA368 PRE_first_tail_x15_r0_body.sizePayA368 PRE_first_tail_x15_r0_body.sizeTaA368 PRE_first_tail_x15_r0_body.sizeDecA368 PRE_first_tail_x15_r0_body.sizePreA368 PRE_first_tail_x15_r0_body.bodyPatchB368 (fun _ hm => bodyO1363 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1363).trans bodyInactive0) (bodyBr1364.trans bodyBr1363.symm) bodyCnt1363 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨50009, 943, 0, 747⟩) bodyAcc1364 PRE_first_tail_x15_r0_body.bodyRunSeg368 bodyAcc1366 bodyHalt1366 PRE_first_tail_x15_r0_body.bodyStepA369 bodyTop1367 (fun _ hm => bodyO1364 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1364).trans bodyInactive0) (bodyBr1367.trans bodyBr1364.symm) bodyCnt1364 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
