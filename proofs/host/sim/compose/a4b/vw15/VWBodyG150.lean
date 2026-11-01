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

kernel_rfl bodyO1439 : PRE_first_tail_x15_r0_body.S1439.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1439.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1439 : bridgeOf PRE_first_tail_x15_r0_body.s1439.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1439 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1439 PRE_first_tail_x15_r0_body.S1439) = fun _ _ => true
kernel_rfl bodyAcc1441 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1441 PRE_first_tail_x15_r0_body.S1441) = fun _ _ => true
kernel_rfl bodyBr1442 : bridgeOf PRE_first_tail_x15_r0_body.s1442.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1441 : isHalt PRE_first_tail_x15_r0_body.s1441.ctl = false
kernel_rfl bodyTop1442 : noRetBlock PRE_first_tail_x15_r0_body.s1442 = true
kernel_rfl bodyCnt1439 : countersOkB PRE_first_tail_x15_r0_body.s1439 PRE_first_tail_x15_r0_body.s1442 = true
kernel_rfl bodyO1442 : PRE_first_tail_x15_r0_body.S1442.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1442.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1443 : bridgeOf PRE_first_tail_x15_r0_body.s1443.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1442 : countersOkB PRE_first_tail_x15_r0_body.s1442 PRE_first_tail_x15_r0_body.s1443 = true
kernel_rfl bodyO1443 : PRE_first_tail_x15_r0_body.S1443.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1443.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1443 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1443 PRE_first_tail_x15_r0_body.S1443) = fun _ _ => true
kernel_rfl bodyAcc1444 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1444 PRE_first_tail_x15_r0_body.S1444) = fun _ _ => true
kernel_rfl bodyBr1445 : bridgeOf PRE_first_tail_x15_r0_body.s1445.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1444 : isHalt PRE_first_tail_x15_r0_body.s1444.ctl = false
kernel_rfl bodyTop1445 : noRetBlock PRE_first_tail_x15_r0_body.s1445 = true
kernel_rfl bodyCnt1443 : countersOkB PRE_first_tail_x15_r0_body.s1443 PRE_first_tail_x15_r0_body.s1445 = true
kernel_rfl bodyO1445 : PRE_first_tail_x15_r0_body.S1445.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1445.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1446 : bridgeOf PRE_first_tail_x15_r0_body.s1446.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1445 : countersOkB PRE_first_tail_x15_r0_body.s1445 PRE_first_tail_x15_r0_body.s1446 = true
kernel_rfl bodyO1446 : PRE_first_tail_x15_r0_body.S1446.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1446.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1446 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1446 PRE_first_tail_x15_r0_body.S1446) = fun _ _ => true
kernel_rfl bodyAcc1447 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1447 PRE_first_tail_x15_r0_body.S1447) = fun _ _ => true
kernel_rfl bodyBr1448 : bridgeOf PRE_first_tail_x15_r0_body.s1448.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1447 : isHalt PRE_first_tail_x15_r0_body.s1447.ctl = false
kernel_rfl bodyTop1448 : noRetBlock PRE_first_tail_x15_r0_body.s1448 = true
kernel_rfl bodyCnt1446 : countersOkB PRE_first_tail_x15_r0_body.s1446 PRE_first_tail_x15_r0_body.s1448 = true
kernel_rfl bodyO1448 : PRE_first_tail_x15_r0_body.S1448.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1448.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1449 : bridgeOf PRE_first_tail_x15_r0_body.s1449.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1448 : countersOkB PRE_first_tail_x15_r0_body.s1448 PRE_first_tail_x15_r0_body.s1449 = true
kernel_rfl bodyO1449 : PRE_first_tail_x15_r0_body.S1449.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1449.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1449 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1449 PRE_first_tail_x15_r0_body.S1449) = fun _ _ => true
kernel_rfl bodyAcc1450 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1450 PRE_first_tail_x15_r0_body.S1450) = fun _ _ => true
kernel_rfl bodyBr1451 : bridgeOf PRE_first_tail_x15_r0_body.s1451.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1450 : isHalt PRE_first_tail_x15_r0_body.s1450.ctl = false
kernel_rfl bodyTop1451 : noRetBlock PRE_first_tail_x15_r0_body.s1451 = true
kernel_rfl bodyCnt1449 : countersOkB PRE_first_tail_x15_r0_body.s1449 PRE_first_tail_x15_r0_body.s1451 = true
kernel_rfl bodyO1451 : PRE_first_tail_x15_r0_body.S1451.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1451.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1452 : bridgeOf PRE_first_tail_x15_r0_body.s1452.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1451 : countersOkB PRE_first_tail_x15_r0_body.s1451 PRE_first_tail_x15_r0_body.s1452 = true
kernel_rfl bodyO1452 : PRE_first_tail_x15_r0_body.S1452.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1452.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1452 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1452 PRE_first_tail_x15_r0_body.S1452) = fun _ _ => true
kernel_rfl bodyAcc1453 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1453 PRE_first_tail_x15_r0_body.S1453) = fun _ _ => true
kernel_rfl bodyBr1454 : bridgeOf PRE_first_tail_x15_r0_body.s1454.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1453 : isHalt PRE_first_tail_x15_r0_body.s1453.ctl = false
kernel_rfl bodyTop1454 : noRetBlock PRE_first_tail_x15_r0_body.s1454 = true
kernel_rfl bodyCnt1452 : countersOkB PRE_first_tail_x15_r0_body.s1452 PRE_first_tail_x15_r0_body.s1454 = true

theorem bodyGlue150 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨52720, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1439 PRE_first_tail_x15_r0_body.S1439)
      (bodyCut NB T tk π i x0 bodyΘ ⟨52720, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1454 PRE_first_tail_x15_r0_body.S1454) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) bodyAcc1439 PRE_first_tail_x15_r0_body.bodyRunSeg388 bodyAcc1441 bodyHalt1441 PRE_first_tail_x15_r0_body.bodyStepA389 bodyTop1442 (fun _ hm => bodyO1439 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1439).trans bodyInactive0) (bodyBr1442.trans bodyBr1439.symm) bodyCnt1439 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) PRE_first_tail_x15_r0_body.sizeA389 PRE_first_tail_x15_r0_body.sizeArgsA389 PRE_first_tail_x15_r0_body.sizeSymA389 PRE_first_tail_x15_r0_body.sizeMlxA389 PRE_first_tail_x15_r0_body.sizePayA389 PRE_first_tail_x15_r0_body.sizeTaA389 PRE_first_tail_x15_r0_body.sizeDecA389 PRE_first_tail_x15_r0_body.sizePreA389 PRE_first_tail_x15_r0_body.bodyPatchB389 (fun _ hm => bodyO1442 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1442).trans bodyInactive0) (bodyBr1443.trans bodyBr1442.symm) bodyCnt1442 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) bodyAcc1443 PRE_first_tail_x15_r0_body.bodyRunSeg389 bodyAcc1444 bodyHalt1444 PRE_first_tail_x15_r0_body.bodyStepA390 bodyTop1445 (fun _ hm => bodyO1443 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1443).trans bodyInactive0) (bodyBr1445.trans bodyBr1443.symm) bodyCnt1443 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) PRE_first_tail_x15_r0_body.sizeA390 PRE_first_tail_x15_r0_body.sizeArgsA390 PRE_first_tail_x15_r0_body.sizeSymA390 PRE_first_tail_x15_r0_body.sizeMlxA390 PRE_first_tail_x15_r0_body.sizePayA390 PRE_first_tail_x15_r0_body.sizeTaA390 PRE_first_tail_x15_r0_body.sizeDecA390 PRE_first_tail_x15_r0_body.sizePreA390 PRE_first_tail_x15_r0_body.bodyPatchB390 (fun _ hm => bodyO1445 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1445).trans bodyInactive0) (bodyBr1446.trans bodyBr1445.symm) bodyCnt1445 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) bodyAcc1446 PRE_first_tail_x15_r0_body.bodyRunSeg390 bodyAcc1447 bodyHalt1447 PRE_first_tail_x15_r0_body.bodyStepA391 bodyTop1448 (fun _ hm => bodyO1446 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1446).trans bodyInactive0) (bodyBr1448.trans bodyBr1446.symm) bodyCnt1446 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) PRE_first_tail_x15_r0_body.sizeA391 PRE_first_tail_x15_r0_body.sizeArgsA391 PRE_first_tail_x15_r0_body.sizeSymA391 PRE_first_tail_x15_r0_body.sizeMlxA391 PRE_first_tail_x15_r0_body.sizePayA391 PRE_first_tail_x15_r0_body.sizeTaA391 PRE_first_tail_x15_r0_body.sizeDecA391 PRE_first_tail_x15_r0_body.sizePreA391 PRE_first_tail_x15_r0_body.bodyPatchB391 (fun _ hm => bodyO1448 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1448).trans bodyInactive0) (bodyBr1449.trans bodyBr1448.symm) bodyCnt1448 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) bodyAcc1449 PRE_first_tail_x15_r0_body.bodyRunSeg391 bodyAcc1450 bodyHalt1450 PRE_first_tail_x15_r0_body.bodyStepA392 bodyTop1451 (fun _ hm => bodyO1449 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1449).trans bodyInactive0) (bodyBr1451.trans bodyBr1449.symm) bodyCnt1449 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) PRE_first_tail_x15_r0_body.sizeA392 PRE_first_tail_x15_r0_body.sizeArgsA392 PRE_first_tail_x15_r0_body.sizeSymA392 PRE_first_tail_x15_r0_body.sizeMlxA392 PRE_first_tail_x15_r0_body.sizePayA392 PRE_first_tail_x15_r0_body.sizeTaA392 PRE_first_tail_x15_r0_body.sizeDecA392 PRE_first_tail_x15_r0_body.sizePreA392 PRE_first_tail_x15_r0_body.bodyPatchB392 (fun _ hm => bodyO1451 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1451).trans bodyInactive0) (bodyBr1452.trans bodyBr1451.symm) bodyCnt1451 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52720, 995, 0, 792⟩) bodyAcc1452 PRE_first_tail_x15_r0_body.bodyRunSeg392 bodyAcc1453 bodyHalt1453 PRE_first_tail_x15_r0_body.bodyStepA393 bodyTop1454 (fun _ hm => bodyO1452 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1452).trans bodyInactive0) (bodyBr1454.trans bodyBr1452.symm) bodyCnt1452 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
