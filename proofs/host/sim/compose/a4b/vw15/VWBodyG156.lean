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

kernel_rfl bodyO1496 : PRE_first_tail_x15_r0_body.S1496.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1496.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1496 : bridgeOf PRE_first_tail_x15_r0_body.s1496.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1496 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.S1496) = fun _ _ => true
kernel_rfl bodyAcc1498 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1498 PRE_first_tail_x15_r0_body.S1498) = fun _ _ => true
kernel_rfl bodyBr1499 : bridgeOf PRE_first_tail_x15_r0_body.s1499.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1498 : isHalt PRE_first_tail_x15_r0_body.s1498.ctl = false
kernel_rfl bodyTop1499 : noRetBlock PRE_first_tail_x15_r0_body.s1499 = true
kernel_rfl bodyCnt1496 : countersOkB PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.s1499 = true
kernel_rfl bodyO1499 : PRE_first_tail_x15_r0_body.S1499.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1499.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1500 : bridgeOf PRE_first_tail_x15_r0_body.s1500.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1499 : countersOkB PRE_first_tail_x15_r0_body.s1499 PRE_first_tail_x15_r0_body.s1500 = true
kernel_rfl bodyO1500 : PRE_first_tail_x15_r0_body.S1500.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1500.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1500 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1500 PRE_first_tail_x15_r0_body.S1500) = fun _ _ => true
kernel_rfl bodyAcc1501 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1501 PRE_first_tail_x15_r0_body.S1501) = fun _ _ => true
kernel_rfl bodyBr1502 : bridgeOf PRE_first_tail_x15_r0_body.s1502.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1501 : isHalt PRE_first_tail_x15_r0_body.s1501.ctl = false
kernel_rfl bodyTop1502 : noRetBlock PRE_first_tail_x15_r0_body.s1502 = true
kernel_rfl bodyCnt1500 : countersOkB PRE_first_tail_x15_r0_body.s1500 PRE_first_tail_x15_r0_body.s1502 = true
kernel_rfl bodyO1502 : PRE_first_tail_x15_r0_body.S1502.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1502.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1503 : bridgeOf PRE_first_tail_x15_r0_body.s1503.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1502 : countersOkB PRE_first_tail_x15_r0_body.s1502 PRE_first_tail_x15_r0_body.s1503 = true
kernel_rfl bodyO1503 : PRE_first_tail_x15_r0_body.S1503.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1503.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1503 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1503 PRE_first_tail_x15_r0_body.S1503) = fun _ _ => true
kernel_rfl bodyAcc1504 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1504 PRE_first_tail_x15_r0_body.S1504) = fun _ _ => true
kernel_rfl bodyBr1505 : bridgeOf PRE_first_tail_x15_r0_body.s1505.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1504 : isHalt PRE_first_tail_x15_r0_body.s1504.ctl = false
kernel_rfl bodyTop1505 : noRetBlock PRE_first_tail_x15_r0_body.s1505 = true
kernel_rfl bodyCnt1503 : countersOkB PRE_first_tail_x15_r0_body.s1503 PRE_first_tail_x15_r0_body.s1505 = true
kernel_rfl bodyO1505 : PRE_first_tail_x15_r0_body.S1505.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1505.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1506 : bridgeOf PRE_first_tail_x15_r0_body.s1506.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1505 : countersOkB PRE_first_tail_x15_r0_body.s1505 PRE_first_tail_x15_r0_body.s1506 = true
kernel_rfl bodyO1506 : PRE_first_tail_x15_r0_body.S1506.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1506.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1506 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1506 PRE_first_tail_x15_r0_body.S1506) = fun _ _ => true
kernel_rfl bodyAcc1507 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1507 PRE_first_tail_x15_r0_body.S1507) = fun _ _ => true
kernel_rfl bodyBr1508 : bridgeOf PRE_first_tail_x15_r0_body.s1508.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1507 : isHalt PRE_first_tail_x15_r0_body.s1507.ctl = false
kernel_rfl bodyTop1508 : noRetBlock PRE_first_tail_x15_r0_body.s1508 = true
kernel_rfl bodyCnt1506 : countersOkB PRE_first_tail_x15_r0_body.s1506 PRE_first_tail_x15_r0_body.s1508 = true
kernel_rfl bodyO1508 : PRE_first_tail_x15_r0_body.S1508.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1508.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1509 : bridgeOf PRE_first_tail_x15_r0_body.s1509.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1508 : countersOkB PRE_first_tail_x15_r0_body.s1508 PRE_first_tail_x15_r0_body.s1509 = true
kernel_rfl bodyO1509 : PRE_first_tail_x15_r0_body.S1509.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1509.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1509 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1509 PRE_first_tail_x15_r0_body.S1509) = fun _ _ => true
kernel_rfl bodyAcc1510 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1510 PRE_first_tail_x15_r0_body.S1510) = fun _ _ => true
kernel_rfl bodyBr1511 : bridgeOf PRE_first_tail_x15_r0_body.s1511.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1510 : isHalt PRE_first_tail_x15_r0_body.s1510.ctl = false
kernel_rfl bodyTop1511 : noRetBlock PRE_first_tail_x15_r0_body.s1511 = true
kernel_rfl bodyCnt1509 : countersOkB PRE_first_tail_x15_r0_body.s1509 PRE_first_tail_x15_r0_body.s1511 = true

theorem bodyGlue156 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨54243, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.S1496)
      (bodyCut NB T tk π i x0 bodyΘ ⟨54243, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1511 PRE_first_tail_x15_r0_body.S1511) 14733 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) bodyAcc1496 PRE_first_tail_x15_r0_body.bodyRunSeg403 bodyAcc1498 bodyHalt1498 PRE_first_tail_x15_r0_body.bodyStepA404 bodyTop1499 (fun _ hm => bodyO1496 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1496).trans bodyInactive0) (bodyBr1499.trans bodyBr1496.symm) bodyCnt1496 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) PRE_first_tail_x15_r0_body.sizeA404 PRE_first_tail_x15_r0_body.sizeArgsA404 PRE_first_tail_x15_r0_body.sizeSymA404 PRE_first_tail_x15_r0_body.sizeMlxA404 PRE_first_tail_x15_r0_body.sizePayA404 PRE_first_tail_x15_r0_body.sizeTaA404 PRE_first_tail_x15_r0_body.sizeDecA404 PRE_first_tail_x15_r0_body.sizePreA404 PRE_first_tail_x15_r0_body.bodyPatchB404 (fun _ hm => bodyO1499 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1499).trans bodyInactive0) (bodyBr1500.trans bodyBr1499.symm) bodyCnt1499 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) bodyAcc1500 PRE_first_tail_x15_r0_body.bodyRunSeg404 bodyAcc1501 bodyHalt1501 PRE_first_tail_x15_r0_body.bodyStepA405 bodyTop1502 (fun _ hm => bodyO1500 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1500).trans bodyInactive0) (bodyBr1502.trans bodyBr1500.symm) bodyCnt1500 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) PRE_first_tail_x15_r0_body.sizeA405 PRE_first_tail_x15_r0_body.sizeArgsA405 PRE_first_tail_x15_r0_body.sizeSymA405 PRE_first_tail_x15_r0_body.sizeMlxA405 PRE_first_tail_x15_r0_body.sizePayA405 PRE_first_tail_x15_r0_body.sizeTaA405 PRE_first_tail_x15_r0_body.sizeDecA405 PRE_first_tail_x15_r0_body.sizePreA405 PRE_first_tail_x15_r0_body.bodyPatchB405 (fun _ hm => bodyO1502 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1502).trans bodyInactive0) (bodyBr1503.trans bodyBr1502.symm) bodyCnt1502 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) bodyAcc1503 PRE_first_tail_x15_r0_body.bodyRunSeg405 bodyAcc1504 bodyHalt1504 PRE_first_tail_x15_r0_body.bodyStepA406 bodyTop1505 (fun _ hm => bodyO1503 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1503).trans bodyInactive0) (bodyBr1505.trans bodyBr1503.symm) bodyCnt1503 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) PRE_first_tail_x15_r0_body.sizeA406 PRE_first_tail_x15_r0_body.sizeArgsA406 PRE_first_tail_x15_r0_body.sizeSymA406 PRE_first_tail_x15_r0_body.sizeMlxA406 PRE_first_tail_x15_r0_body.sizePayA406 PRE_first_tail_x15_r0_body.sizeTaA406 PRE_first_tail_x15_r0_body.sizeDecA406 PRE_first_tail_x15_r0_body.sizePreA406 PRE_first_tail_x15_r0_body.bodyPatchB406 (fun _ hm => bodyO1505 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1505).trans bodyInactive0) (bodyBr1506.trans bodyBr1505.symm) bodyCnt1505 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) bodyAcc1506 PRE_first_tail_x15_r0_body.bodyRunSeg406 bodyAcc1507 bodyHalt1507 PRE_first_tail_x15_r0_body.bodyStepA407 bodyTop1508 (fun _ hm => bodyO1506 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1506).trans bodyInactive0) (bodyBr1508.trans bodyBr1506.symm) bodyCnt1506 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) PRE_first_tail_x15_r0_body.sizeA407 PRE_first_tail_x15_r0_body.sizeArgsA407 PRE_first_tail_x15_r0_body.sizeSymA407 PRE_first_tail_x15_r0_body.sizeMlxA407 PRE_first_tail_x15_r0_body.sizePayA407 PRE_first_tail_x15_r0_body.sizeTaA407 PRE_first_tail_x15_r0_body.sizeDecA407 PRE_first_tail_x15_r0_body.sizePreA407 PRE_first_tail_x15_r0_body.bodyPatchB407 (fun _ hm => bodyO1508 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1508).trans bodyInactive0) (bodyBr1509.trans bodyBr1508.symm) bodyCnt1508 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54243, 1022, 0, 819⟩) bodyAcc1509 PRE_first_tail_x15_r0_body.bodyRunSeg407 bodyAcc1510 bodyHalt1510 PRE_first_tail_x15_r0_body.bodyStepA408 bodyTop1511 (fun _ hm => bodyO1509 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1509).trans bodyInactive0) (bodyBr1511.trans bodyBr1509.symm) bodyCnt1509 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
