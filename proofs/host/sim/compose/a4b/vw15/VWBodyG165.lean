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

kernel_rfl bodyO1583 : PRE_first_tail_x15_r0_body.S1583.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1583.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1583 : bridgeOf PRE_first_tail_x15_r0_body.s1583.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1583 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.S1583) = fun _ _ => true
kernel_rfl bodyAcc1585 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1585 PRE_first_tail_x15_r0_body.S1585) = fun _ _ => true
kernel_rfl bodyBr1586 : bridgeOf PRE_first_tail_x15_r0_body.s1586.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1585 : isHalt PRE_first_tail_x15_r0_body.s1585.ctl = false
kernel_rfl bodyTop1586 : noRetBlock PRE_first_tail_x15_r0_body.s1586 = true
kernel_rfl bodyCnt1583 : countersOkB PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.s1586 = true
kernel_rfl bodyO1586 : PRE_first_tail_x15_r0_body.S1586.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1586.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1587 : bridgeOf PRE_first_tail_x15_r0_body.s1587.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1586 : countersOkB PRE_first_tail_x15_r0_body.s1586 PRE_first_tail_x15_r0_body.s1587 = true
kernel_rfl bodyO1587 : PRE_first_tail_x15_r0_body.S1587.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1587.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1587 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1587 PRE_first_tail_x15_r0_body.S1587) = fun _ _ => true
kernel_rfl bodyAcc1589 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1589 PRE_first_tail_x15_r0_body.S1589) = fun _ _ => true
kernel_rfl bodyBr1590 : bridgeOf PRE_first_tail_x15_r0_body.s1590.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1589 : isHalt PRE_first_tail_x15_r0_body.s1589.ctl = false
kernel_rfl bodyTop1590 : noRetBlock PRE_first_tail_x15_r0_body.s1590 = true
kernel_rfl bodyCnt1587 : countersOkB PRE_first_tail_x15_r0_body.s1587 PRE_first_tail_x15_r0_body.s1590 = true
kernel_rfl bodyO1590 : PRE_first_tail_x15_r0_body.S1590.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1590.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1591 : bridgeOf PRE_first_tail_x15_r0_body.s1591.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1590 : countersOkB PRE_first_tail_x15_r0_body.s1590 PRE_first_tail_x15_r0_body.s1591 = true
kernel_rfl bodyO1591 : PRE_first_tail_x15_r0_body.S1591.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1591.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1591 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1591 PRE_first_tail_x15_r0_body.S1591) = fun _ _ => true
kernel_rfl bodyAcc1592 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1592 PRE_first_tail_x15_r0_body.S1592) = fun _ _ => true
kernel_rfl bodyBr1593 : bridgeOf PRE_first_tail_x15_r0_body.s1593.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1592 : isHalt PRE_first_tail_x15_r0_body.s1592.ctl = false
kernel_rfl bodyTop1593 : noRetBlock PRE_first_tail_x15_r0_body.s1593 = true
kernel_rfl bodyCnt1591 : countersOkB PRE_first_tail_x15_r0_body.s1591 PRE_first_tail_x15_r0_body.s1593 = true
kernel_rfl bodyO1593 : PRE_first_tail_x15_r0_body.S1593.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1593.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1594 : bridgeOf PRE_first_tail_x15_r0_body.s1594.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1593 : countersOkB PRE_first_tail_x15_r0_body.s1593 PRE_first_tail_x15_r0_body.s1594 = true
kernel_rfl bodyO1594 : PRE_first_tail_x15_r0_body.S1594.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1594.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1594 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1594 PRE_first_tail_x15_r0_body.S1594) = fun _ _ => true
kernel_rfl bodyAcc1596 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1596 PRE_first_tail_x15_r0_body.S1596) = fun _ _ => true
kernel_rfl bodyBr1597 : bridgeOf PRE_first_tail_x15_r0_body.s1597.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1596 : isHalt PRE_first_tail_x15_r0_body.s1596.ctl = false
kernel_rfl bodyTop1597 : noRetBlock PRE_first_tail_x15_r0_body.s1597 = true
kernel_rfl bodyCnt1594 : countersOkB PRE_first_tail_x15_r0_body.s1594 PRE_first_tail_x15_r0_body.s1597 = true

theorem bodyGlue165 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨57735, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.S1583)
      (bodyCut NB T tk π i x0 bodyΘ ⟨57735, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1597 PRE_first_tail_x15_r0_body.S1597) 17025 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57735, 1097, 0, 873⟩) bodyAcc1583 PRE_first_tail_x15_r0_body.bodyRunSeg427 bodyAcc1585 bodyHalt1585 PRE_first_tail_x15_r0_body.bodyStepA428 bodyTop1586 (fun _ hm => bodyO1583 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1583).trans bodyInactive0) (bodyBr1586.trans bodyBr1583.symm) bodyCnt1583 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57735, 1097, 0, 873⟩) PRE_first_tail_x15_r0_body.sizeA428 PRE_first_tail_x15_r0_body.sizeArgsA428 PRE_first_tail_x15_r0_body.sizeSymA428 PRE_first_tail_x15_r0_body.sizeMlxA428 PRE_first_tail_x15_r0_body.sizePayA428 PRE_first_tail_x15_r0_body.sizeTaA428 PRE_first_tail_x15_r0_body.sizeDecA428 PRE_first_tail_x15_r0_body.sizePreA428 PRE_first_tail_x15_r0_body.bodyPatchB428 (fun _ hm => bodyO1586 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1586).trans bodyInactive0) (bodyBr1587.trans bodyBr1586.symm) bodyCnt1586 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57735, 1097, 0, 873⟩) bodyAcc1587 PRE_first_tail_x15_r0_body.bodyRunSeg428 bodyAcc1589 bodyHalt1589 PRE_first_tail_x15_r0_body.bodyStepA429 bodyTop1590 (fun _ hm => bodyO1587 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1587).trans bodyInactive0) (bodyBr1590.trans bodyBr1587.symm) bodyCnt1587 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57735, 1097, 0, 873⟩) PRE_first_tail_x15_r0_body.sizeA429 PRE_first_tail_x15_r0_body.sizeArgsA429 PRE_first_tail_x15_r0_body.sizeSymA429 PRE_first_tail_x15_r0_body.sizeMlxA429 PRE_first_tail_x15_r0_body.sizePayA429 PRE_first_tail_x15_r0_body.sizeTaA429 PRE_first_tail_x15_r0_body.sizeDecA429 PRE_first_tail_x15_r0_body.sizePreA429 PRE_first_tail_x15_r0_body.bodyPatchB429 (fun _ hm => bodyO1590 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1590).trans bodyInactive0) (bodyBr1591.trans bodyBr1590.symm) bodyCnt1590 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57735, 1097, 0, 873⟩) bodyAcc1591 PRE_first_tail_x15_r0_body.bodyRunSeg429 bodyAcc1592 bodyHalt1592 PRE_first_tail_x15_r0_body.bodyStepA430 bodyTop1593 (fun _ hm => bodyO1591 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1591).trans bodyInactive0) (bodyBr1593.trans bodyBr1591.symm) bodyCnt1591 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57735, 1097, 0, 873⟩) PRE_first_tail_x15_r0_body.sizeA430 PRE_first_tail_x15_r0_body.sizeArgsA430 PRE_first_tail_x15_r0_body.sizeSymA430 PRE_first_tail_x15_r0_body.sizeMlxA430 PRE_first_tail_x15_r0_body.sizePayA430 PRE_first_tail_x15_r0_body.sizeTaA430 PRE_first_tail_x15_r0_body.sizeDecA430 PRE_first_tail_x15_r0_body.sizePreA430 PRE_first_tail_x15_r0_body.bodyPatchB430 (fun _ hm => bodyO1593 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1593).trans bodyInactive0) (bodyBr1594.trans bodyBr1593.symm) bodyCnt1593 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨57735, 1097, 0, 873⟩) bodyAcc1594 PRE_first_tail_x15_r0_body.bodyRunSeg430 bodyAcc1596 bodyHalt1596 PRE_first_tail_x15_r0_body.bodyStepA431 bodyTop1597 (fun _ hm => bodyO1594 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1594).trans bodyInactive0) (bodyBr1597.trans bodyBr1594.symm) bodyCnt1594 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
