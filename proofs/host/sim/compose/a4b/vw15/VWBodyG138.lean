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

kernel_rfl bodyO1324 : PRE_first_tail_x15_r0_body.S1324.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1324.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1324 : bridgeOf PRE_first_tail_x15_r0_body.s1324.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1324 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.S1324) = fun _ _ => true
kernel_rfl bodyAcc1326 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1326 PRE_first_tail_x15_r0_body.S1326) = fun _ _ => true
kernel_rfl bodyBr1327 : bridgeOf PRE_first_tail_x15_r0_body.s1327.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1326 : isHalt PRE_first_tail_x15_r0_body.s1326.ctl = false
kernel_rfl bodyTop1327 : noRetBlock PRE_first_tail_x15_r0_body.s1327 = true
kernel_rfl bodyCnt1324 : countersOkB PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.s1327 = true
kernel_rfl bodyO1327 : PRE_first_tail_x15_r0_body.S1327.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1327.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1328 : bridgeOf PRE_first_tail_x15_r0_body.s1328.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1327 : countersOkB PRE_first_tail_x15_r0_body.s1327 PRE_first_tail_x15_r0_body.s1328 = true
kernel_rfl bodyO1328 : PRE_first_tail_x15_r0_body.S1328.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1328.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1328 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1328 PRE_first_tail_x15_r0_body.S1328) = fun _ _ => true
kernel_rfl bodyAcc1329 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1329 PRE_first_tail_x15_r0_body.S1329) = fun _ _ => true
kernel_rfl bodyBr1330 : bridgeOf PRE_first_tail_x15_r0_body.s1330.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1329 : isHalt PRE_first_tail_x15_r0_body.s1329.ctl = false
kernel_rfl bodyTop1330 : noRetBlock PRE_first_tail_x15_r0_body.s1330 = true
kernel_rfl bodyCnt1328 : countersOkB PRE_first_tail_x15_r0_body.s1328 PRE_first_tail_x15_r0_body.s1330 = true
kernel_rfl bodyO1330 : PRE_first_tail_x15_r0_body.S1330.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1330.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1331 : bridgeOf PRE_first_tail_x15_r0_body.s1331.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1330 : countersOkB PRE_first_tail_x15_r0_body.s1330 PRE_first_tail_x15_r0_body.s1331 = true
kernel_rfl bodyO1331 : PRE_first_tail_x15_r0_body.S1331.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1331.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1331 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1331 PRE_first_tail_x15_r0_body.S1331) = fun _ _ => true
kernel_rfl bodyAcc1332 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1332 PRE_first_tail_x15_r0_body.S1332) = fun _ _ => true
kernel_rfl bodyBr1333 : bridgeOf PRE_first_tail_x15_r0_body.s1333.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1332 : isHalt PRE_first_tail_x15_r0_body.s1332.ctl = false
kernel_rfl bodyTop1333 : noRetBlock PRE_first_tail_x15_r0_body.s1333 = true
kernel_rfl bodyCnt1331 : countersOkB PRE_first_tail_x15_r0_body.s1331 PRE_first_tail_x15_r0_body.s1333 = true
kernel_rfl bodyO1333 : PRE_first_tail_x15_r0_body.S1333.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1333.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1334 : bridgeOf PRE_first_tail_x15_r0_body.s1334.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1333 : countersOkB PRE_first_tail_x15_r0_body.s1333 PRE_first_tail_x15_r0_body.s1334 = true
kernel_rfl bodyO1334 : PRE_first_tail_x15_r0_body.S1334.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1334.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1334 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1334 PRE_first_tail_x15_r0_body.S1334) = fun _ _ => true
kernel_rfl bodyAcc1335 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1335 PRE_first_tail_x15_r0_body.S1335) = fun _ _ => true
kernel_rfl bodyBr1336 : bridgeOf PRE_first_tail_x15_r0_body.s1336.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1335 : isHalt PRE_first_tail_x15_r0_body.s1335.ctl = false
kernel_rfl bodyTop1336 : noRetBlock PRE_first_tail_x15_r0_body.s1336 = true
kernel_rfl bodyCnt1334 : countersOkB PRE_first_tail_x15_r0_body.s1334 PRE_first_tail_x15_r0_body.s1336 = true
kernel_rfl bodyO1336 : PRE_first_tail_x15_r0_body.S1336.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1336.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1337 : bridgeOf PRE_first_tail_x15_r0_body.s1337.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1336 : countersOkB PRE_first_tail_x15_r0_body.s1336 PRE_first_tail_x15_r0_body.s1337 = true
kernel_rfl bodyO1337 : PRE_first_tail_x15_r0_body.S1337.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1337.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1337 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1337 PRE_first_tail_x15_r0_body.S1337) = fun _ _ => true
kernel_rfl bodyAcc1338 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1338 PRE_first_tail_x15_r0_body.S1338) = fun _ _ => true
kernel_rfl bodyBr1339 : bridgeOf PRE_first_tail_x15_r0_body.s1339.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1338 : isHalt PRE_first_tail_x15_r0_body.s1338.ctl = false
kernel_rfl bodyTop1339 : noRetBlock PRE_first_tail_x15_r0_body.s1339 = true
kernel_rfl bodyCnt1337 : countersOkB PRE_first_tail_x15_r0_body.s1337 PRE_first_tail_x15_r0_body.s1339 = true

theorem bodyGlue138 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨48839, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.S1324)
      (bodyCut NB T tk π i x0 bodyΘ ⟨48839, 918, 0, 729⟩ bodyM PRE_first_tail_x15_r0_body.s1339 PRE_first_tail_x15_r0_body.S1339) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) bodyAcc1324 PRE_first_tail_x15_r0_body.bodyRunSeg357 bodyAcc1326 bodyHalt1326 PRE_first_tail_x15_r0_body.bodyStepA358 bodyTop1327 (fun _ hm => bodyO1324 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1324).trans bodyInactive0) (bodyBr1327.trans bodyBr1324.symm) bodyCnt1324 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) PRE_first_tail_x15_r0_body.sizeA358 PRE_first_tail_x15_r0_body.sizeArgsA358 PRE_first_tail_x15_r0_body.sizeSymA358 PRE_first_tail_x15_r0_body.sizeMlxA358 PRE_first_tail_x15_r0_body.sizePayA358 PRE_first_tail_x15_r0_body.sizeTaA358 PRE_first_tail_x15_r0_body.sizeDecA358 PRE_first_tail_x15_r0_body.sizePreA358 PRE_first_tail_x15_r0_body.bodyPatchB358 (fun _ hm => bodyO1327 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1327).trans bodyInactive0) (bodyBr1328.trans bodyBr1327.symm) bodyCnt1327 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) bodyAcc1328 PRE_first_tail_x15_r0_body.bodyRunSeg358 bodyAcc1329 bodyHalt1329 PRE_first_tail_x15_r0_body.bodyStepA359 bodyTop1330 (fun _ hm => bodyO1328 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1328).trans bodyInactive0) (bodyBr1330.trans bodyBr1328.symm) bodyCnt1328 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) PRE_first_tail_x15_r0_body.sizeA359 PRE_first_tail_x15_r0_body.sizeArgsA359 PRE_first_tail_x15_r0_body.sizeSymA359 PRE_first_tail_x15_r0_body.sizeMlxA359 PRE_first_tail_x15_r0_body.sizePayA359 PRE_first_tail_x15_r0_body.sizeTaA359 PRE_first_tail_x15_r0_body.sizeDecA359 PRE_first_tail_x15_r0_body.sizePreA359 PRE_first_tail_x15_r0_body.bodyPatchB359 (fun _ hm => bodyO1330 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1330).trans bodyInactive0) (bodyBr1331.trans bodyBr1330.symm) bodyCnt1330 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) bodyAcc1331 PRE_first_tail_x15_r0_body.bodyRunSeg359 bodyAcc1332 bodyHalt1332 PRE_first_tail_x15_r0_body.bodyStepA360 bodyTop1333 (fun _ hm => bodyO1331 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1331).trans bodyInactive0) (bodyBr1333.trans bodyBr1331.symm) bodyCnt1331 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) PRE_first_tail_x15_r0_body.sizeA360 PRE_first_tail_x15_r0_body.sizeArgsA360 PRE_first_tail_x15_r0_body.sizeSymA360 PRE_first_tail_x15_r0_body.sizeMlxA360 PRE_first_tail_x15_r0_body.sizePayA360 PRE_first_tail_x15_r0_body.sizeTaA360 PRE_first_tail_x15_r0_body.sizeDecA360 PRE_first_tail_x15_r0_body.sizePreA360 PRE_first_tail_x15_r0_body.bodyPatchB360 (fun _ hm => bodyO1333 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1333).trans bodyInactive0) (bodyBr1334.trans bodyBr1333.symm) bodyCnt1333 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) bodyAcc1334 PRE_first_tail_x15_r0_body.bodyRunSeg360 bodyAcc1335 bodyHalt1335 PRE_first_tail_x15_r0_body.bodyStepA361 bodyTop1336 (fun _ hm => bodyO1334 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1334).trans bodyInactive0) (bodyBr1336.trans bodyBr1334.symm) bodyCnt1334 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) PRE_first_tail_x15_r0_body.sizeA361 PRE_first_tail_x15_r0_body.sizeArgsA361 PRE_first_tail_x15_r0_body.sizeSymA361 PRE_first_tail_x15_r0_body.sizeMlxA361 PRE_first_tail_x15_r0_body.sizePayA361 PRE_first_tail_x15_r0_body.sizeTaA361 PRE_first_tail_x15_r0_body.sizeDecA361 PRE_first_tail_x15_r0_body.sizePreA361 PRE_first_tail_x15_r0_body.bodyPatchB361 (fun _ hm => bodyO1336 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1336).trans bodyInactive0) (bodyBr1337.trans bodyBr1336.symm) bodyCnt1336 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨48839, 918, 0, 729⟩) bodyAcc1337 PRE_first_tail_x15_r0_body.bodyRunSeg361 bodyAcc1338 bodyHalt1338 PRE_first_tail_x15_r0_body.bodyStepA362 bodyTop1339 (fun _ hm => bodyO1337 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1337).trans bodyInactive0) (bodyBr1339.trans bodyBr1337.symm) bodyCnt1337 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
