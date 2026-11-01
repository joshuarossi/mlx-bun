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

kernel_rfl bodyO1611 : PRE_first_tail_x15_r0_body.S1611.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1611.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1611 : bridgeOf PRE_first_tail_x15_r0_body.s1611.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1611 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1611 PRE_first_tail_x15_r0_body.S1611) = fun _ _ => true
kernel_rfl bodyAcc1613 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1613 PRE_first_tail_x15_r0_body.S1613) = fun _ _ => true
kernel_rfl bodyBr1614 : bridgeOf PRE_first_tail_x15_r0_body.s1614.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1613 : isHalt PRE_first_tail_x15_r0_body.s1613.ctl = false
kernel_rfl bodyTop1614 : noRetBlock PRE_first_tail_x15_r0_body.s1614 = true
kernel_rfl bodyCnt1611 : countersOkB PRE_first_tail_x15_r0_body.s1611 PRE_first_tail_x15_r0_body.s1614 = true
kernel_rfl bodyO1614 : PRE_first_tail_x15_r0_body.S1614.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1614.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1615 : bridgeOf PRE_first_tail_x15_r0_body.s1615.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1614 : countersOkB PRE_first_tail_x15_r0_body.s1614 PRE_first_tail_x15_r0_body.s1615 = true
kernel_rfl bodyO1615 : PRE_first_tail_x15_r0_body.S1615.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1615.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1615 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1615 PRE_first_tail_x15_r0_body.S1615) = fun _ _ => true
kernel_rfl bodyAcc1616 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1616 PRE_first_tail_x15_r0_body.S1616) = fun _ _ => true
kernel_rfl bodyBr1617 : bridgeOf PRE_first_tail_x15_r0_body.s1617.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1616 : isHalt PRE_first_tail_x15_r0_body.s1616.ctl = false
kernel_rfl bodyTop1617 : noRetBlock PRE_first_tail_x15_r0_body.s1617 = true
kernel_rfl bodyCnt1615 : countersOkB PRE_first_tail_x15_r0_body.s1615 PRE_first_tail_x15_r0_body.s1617 = true
kernel_rfl bodyO1617 : PRE_first_tail_x15_r0_body.S1617.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1617.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1618 : bridgeOf PRE_first_tail_x15_r0_body.s1618.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1617 : countersOkB PRE_first_tail_x15_r0_body.s1617 PRE_first_tail_x15_r0_body.s1618 = true
kernel_rfl bodyO1618 : PRE_first_tail_x15_r0_body.S1618.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1618.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1618 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1618 PRE_first_tail_x15_r0_body.S1618) = fun _ _ => true
kernel_rfl bodyAcc1619 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1619 PRE_first_tail_x15_r0_body.S1619) = fun _ _ => true
kernel_rfl bodyBr1620 : bridgeOf PRE_first_tail_x15_r0_body.s1620.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1619 : isHalt PRE_first_tail_x15_r0_body.s1619.ctl = false
kernel_rfl bodyTop1620 : noRetBlock PRE_first_tail_x15_r0_body.s1620 = true
kernel_rfl bodyCnt1618 : countersOkB PRE_first_tail_x15_r0_body.s1618 PRE_first_tail_x15_r0_body.s1620 = true
kernel_rfl bodyO1620 : PRE_first_tail_x15_r0_body.S1620.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1620.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1621 : bridgeOf PRE_first_tail_x15_r0_body.s1621.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1620 : countersOkB PRE_first_tail_x15_r0_body.s1620 PRE_first_tail_x15_r0_body.s1621 = true
kernel_rfl bodyO1621 : PRE_first_tail_x15_r0_body.S1621.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1621.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1621 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1621 PRE_first_tail_x15_r0_body.S1621) = fun _ _ => true
kernel_rfl bodyAcc1622 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1622 PRE_first_tail_x15_r0_body.S1622) = fun _ _ => true
kernel_rfl bodyBr1623 : bridgeOf PRE_first_tail_x15_r0_body.s1623.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1622 : isHalt PRE_first_tail_x15_r0_body.s1622.ctl = false
kernel_rfl bodyTop1623 : noRetBlock PRE_first_tail_x15_r0_body.s1623 = true
kernel_rfl bodyCnt1621 : countersOkB PRE_first_tail_x15_r0_body.s1621 PRE_first_tail_x15_r0_body.s1623 = true
kernel_rfl bodyO1623 : PRE_first_tail_x15_r0_body.S1623.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1623.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1624 : bridgeOf PRE_first_tail_x15_r0_body.s1624.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1623 : countersOkB PRE_first_tail_x15_r0_body.s1623 PRE_first_tail_x15_r0_body.s1624 = true
kernel_rfl bodyO1624 : PRE_first_tail_x15_r0_body.S1624.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1624.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1624 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1624 PRE_first_tail_x15_r0_body.S1624) = fun _ _ => true
kernel_rfl bodyAcc1625 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1625 PRE_first_tail_x15_r0_body.S1625) = fun _ _ => true
kernel_rfl bodyBr1626 : bridgeOf PRE_first_tail_x15_r0_body.s1626.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1625 : isHalt PRE_first_tail_x15_r0_body.s1625.ctl = false
kernel_rfl bodyTop1626 : noRetBlock PRE_first_tail_x15_r0_body.s1626 = true
kernel_rfl bodyCnt1624 : countersOkB PRE_first_tail_x15_r0_body.s1624 PRE_first_tail_x15_r0_body.s1626 = true

theorem bodyGlue168 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨58106, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1611 PRE_first_tail_x15_r0_body.S1611)
      (bodyCut NB T tk π i x0 bodyΘ ⟨58106, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1626 PRE_first_tail_x15_r0_body.S1626) 14768 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) bodyAcc1611 PRE_first_tail_x15_r0_body.bodyRunSeg434 bodyAcc1613 bodyHalt1613 PRE_first_tail_x15_r0_body.bodyStepA435 bodyTop1614 (fun _ hm => bodyO1611 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1611).trans bodyInactive0) (bodyBr1614.trans bodyBr1611.symm) bodyCnt1611 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) PRE_first_tail_x15_r0_body.sizeA435 PRE_first_tail_x15_r0_body.sizeArgsA435 PRE_first_tail_x15_r0_body.sizeSymA435 PRE_first_tail_x15_r0_body.sizeMlxA435 PRE_first_tail_x15_r0_body.sizePayA435 PRE_first_tail_x15_r0_body.sizeTaA435 PRE_first_tail_x15_r0_body.sizeDecA435 PRE_first_tail_x15_r0_body.sizePreA435 PRE_first_tail_x15_r0_body.bodyPatchB435 (fun _ hm => bodyO1614 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1614).trans bodyInactive0) (bodyBr1615.trans bodyBr1614.symm) bodyCnt1614 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) bodyAcc1615 PRE_first_tail_x15_r0_body.bodyRunSeg435 bodyAcc1616 bodyHalt1616 PRE_first_tail_x15_r0_body.bodyStepA436 bodyTop1617 (fun _ hm => bodyO1615 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1615).trans bodyInactive0) (bodyBr1617.trans bodyBr1615.symm) bodyCnt1615 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) PRE_first_tail_x15_r0_body.sizeA436 PRE_first_tail_x15_r0_body.sizeArgsA436 PRE_first_tail_x15_r0_body.sizeSymA436 PRE_first_tail_x15_r0_body.sizeMlxA436 PRE_first_tail_x15_r0_body.sizePayA436 PRE_first_tail_x15_r0_body.sizeTaA436 PRE_first_tail_x15_r0_body.sizeDecA436 PRE_first_tail_x15_r0_body.sizePreA436 PRE_first_tail_x15_r0_body.bodyPatchB436 (fun _ hm => bodyO1617 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1617).trans bodyInactive0) (bodyBr1618.trans bodyBr1617.symm) bodyCnt1617 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) bodyAcc1618 PRE_first_tail_x15_r0_body.bodyRunSeg436 bodyAcc1619 bodyHalt1619 PRE_first_tail_x15_r0_body.bodyStepA437 bodyTop1620 (fun _ hm => bodyO1618 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1618).trans bodyInactive0) (bodyBr1620.trans bodyBr1618.symm) bodyCnt1618 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) PRE_first_tail_x15_r0_body.sizeA437 PRE_first_tail_x15_r0_body.sizeArgsA437 PRE_first_tail_x15_r0_body.sizeSymA437 PRE_first_tail_x15_r0_body.sizeMlxA437 PRE_first_tail_x15_r0_body.sizePayA437 PRE_first_tail_x15_r0_body.sizeTaA437 PRE_first_tail_x15_r0_body.sizeDecA437 PRE_first_tail_x15_r0_body.sizePreA437 PRE_first_tail_x15_r0_body.bodyPatchB437 (fun _ hm => bodyO1620 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1620).trans bodyInactive0) (bodyBr1621.trans bodyBr1620.symm) bodyCnt1620 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) bodyAcc1621 PRE_first_tail_x15_r0_body.bodyRunSeg437 bodyAcc1622 bodyHalt1622 PRE_first_tail_x15_r0_body.bodyStepA438 bodyTop1623 (fun _ hm => bodyO1621 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1621).trans bodyInactive0) (bodyBr1623.trans bodyBr1621.symm) bodyCnt1621 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) PRE_first_tail_x15_r0_body.sizeA438 PRE_first_tail_x15_r0_body.sizeArgsA438 PRE_first_tail_x15_r0_body.sizeSymA438 PRE_first_tail_x15_r0_body.sizeMlxA438 PRE_first_tail_x15_r0_body.sizePayA438 PRE_first_tail_x15_r0_body.sizeTaA438 PRE_first_tail_x15_r0_body.sizeDecA438 PRE_first_tail_x15_r0_body.sizePreA438 PRE_first_tail_x15_r0_body.bodyPatchB438 (fun _ hm => bodyO1623 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1623).trans bodyInactive0) (bodyBr1624.trans bodyBr1623.symm) bodyCnt1623 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58106, 1099, 0, 882⟩) bodyAcc1624 PRE_first_tail_x15_r0_body.bodyRunSeg438 bodyAcc1625 bodyHalt1625 PRE_first_tail_x15_r0_body.bodyStepA439 bodyTop1626 (fun _ hm => bodyO1624 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1624).trans bodyInactive0) (bodyBr1626.trans bodyBr1624.symm) bodyCnt1624 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
