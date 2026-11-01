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

kernel_rfl bodyO749 : PRE_first_tail_x15_r0_body.S749.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S749.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr749 : bridgeOf PRE_first_tail_x15_r0_body.s749.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc749 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s749 PRE_first_tail_x15_r0_body.S749) = fun _ _ => true
kernel_rfl bodyAcc751 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s751 PRE_first_tail_x15_r0_body.S751) = fun _ _ => true
kernel_rfl bodyBr752 : bridgeOf PRE_first_tail_x15_r0_body.s752.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt751 : isHalt PRE_first_tail_x15_r0_body.s751.ctl = false
kernel_rfl bodyTop752 : noRetBlock PRE_first_tail_x15_r0_body.s752 = true
kernel_rfl bodyCnt749 : countersOkB PRE_first_tail_x15_r0_body.s749 PRE_first_tail_x15_r0_body.s752 = true
kernel_rfl bodyO752 : PRE_first_tail_x15_r0_body.S752.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S752.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr753 : bridgeOf PRE_first_tail_x15_r0_body.s753.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt752 : countersOkB PRE_first_tail_x15_r0_body.s752 PRE_first_tail_x15_r0_body.s753 = true
kernel_rfl bodyO753 : PRE_first_tail_x15_r0_body.S753.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S753.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc753 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s753 PRE_first_tail_x15_r0_body.S753) = fun _ _ => true
kernel_rfl bodyAcc754 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s754 PRE_first_tail_x15_r0_body.S754) = fun _ _ => true
kernel_rfl bodyBr755 : bridgeOf PRE_first_tail_x15_r0_body.s755.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt754 : isHalt PRE_first_tail_x15_r0_body.s754.ctl = false
kernel_rfl bodyTop755 : noRetBlock PRE_first_tail_x15_r0_body.s755 = true
kernel_rfl bodyCnt753 : countersOkB PRE_first_tail_x15_r0_body.s753 PRE_first_tail_x15_r0_body.s755 = true
kernel_rfl bodyO755 : PRE_first_tail_x15_r0_body.S755.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S755.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr756 : bridgeOf PRE_first_tail_x15_r0_body.s756.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt755 : countersOkB PRE_first_tail_x15_r0_body.s755 PRE_first_tail_x15_r0_body.s756 = true
kernel_rfl bodyO756 : PRE_first_tail_x15_r0_body.S756.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S756.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc756 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s756 PRE_first_tail_x15_r0_body.S756) = fun _ _ => true
kernel_rfl bodyAcc757 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s757 PRE_first_tail_x15_r0_body.S757) = fun _ _ => true
kernel_rfl bodyBr758 : bridgeOf PRE_first_tail_x15_r0_body.s758.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt757 : isHalt PRE_first_tail_x15_r0_body.s757.ctl = false
kernel_rfl bodyTop758 : noRetBlock PRE_first_tail_x15_r0_body.s758 = true
kernel_rfl bodyCnt756 : countersOkB PRE_first_tail_x15_r0_body.s756 PRE_first_tail_x15_r0_body.s758 = true
kernel_rfl bodyO758 : PRE_first_tail_x15_r0_body.S758.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S758.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr759 : bridgeOf PRE_first_tail_x15_r0_body.s759.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt758 : countersOkB PRE_first_tail_x15_r0_body.s758 PRE_first_tail_x15_r0_body.s759 = true
kernel_rfl bodyO759 : PRE_first_tail_x15_r0_body.S759.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S759.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc759 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s759 PRE_first_tail_x15_r0_body.S759) = fun _ _ => true
kernel_rfl bodyAcc760 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s760 PRE_first_tail_x15_r0_body.S760) = fun _ _ => true
kernel_rfl bodyBr761 : bridgeOf PRE_first_tail_x15_r0_body.s761.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt760 : isHalt PRE_first_tail_x15_r0_body.s760.ctl = false
kernel_rfl bodyTop761 : noRetBlock PRE_first_tail_x15_r0_body.s761 = true
kernel_rfl bodyCnt759 : countersOkB PRE_first_tail_x15_r0_body.s759 PRE_first_tail_x15_r0_body.s761 = true
kernel_rfl bodyO761 : PRE_first_tail_x15_r0_body.S761.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S761.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr762 : bridgeOf PRE_first_tail_x15_r0_body.s762.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt761 : countersOkB PRE_first_tail_x15_r0_body.s761 PRE_first_tail_x15_r0_body.s762 = true
kernel_rfl bodyO762 : PRE_first_tail_x15_r0_body.S762.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S762.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc762 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s762 PRE_first_tail_x15_r0_body.S762) = fun _ _ => true
kernel_rfl bodyAcc763 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s763 PRE_first_tail_x15_r0_body.S763) = fun _ _ => true
kernel_rfl bodyBr764 : bridgeOf PRE_first_tail_x15_r0_body.s764.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt763 : isHalt PRE_first_tail_x15_r0_body.s763.ctl = false
kernel_rfl bodyTop764 : noRetBlock PRE_first_tail_x15_r0_body.s764 = true
kernel_rfl bodyCnt762 : countersOkB PRE_first_tail_x15_r0_body.s762 PRE_first_tail_x15_r0_body.s764 = true

theorem bodyGlue78 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨29569, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s749 PRE_first_tail_x15_r0_body.S749)
      (bodyCut NB T tk π i x0 bodyΘ ⟨29569, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s764 PRE_first_tail_x15_r0_body.S764) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) bodyAcc749 PRE_first_tail_x15_r0_body.bodyRunSeg202 bodyAcc751 bodyHalt751 PRE_first_tail_x15_r0_body.bodyStepA203 bodyTop752 (fun _ hm => bodyO749 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr749).trans bodyInactive0) (bodyBr752.trans bodyBr749.symm) bodyCnt749 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) PRE_first_tail_x15_r0_body.sizeA203 PRE_first_tail_x15_r0_body.sizeArgsA203 PRE_first_tail_x15_r0_body.sizeSymA203 PRE_first_tail_x15_r0_body.sizeMlxA203 PRE_first_tail_x15_r0_body.sizePayA203 PRE_first_tail_x15_r0_body.sizeTaA203 PRE_first_tail_x15_r0_body.sizeDecA203 PRE_first_tail_x15_r0_body.sizePreA203 PRE_first_tail_x15_r0_body.bodyPatchB203 (fun _ hm => bodyO752 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr752).trans bodyInactive0) (bodyBr753.trans bodyBr752.symm) bodyCnt752 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) bodyAcc753 PRE_first_tail_x15_r0_body.bodyRunSeg203 bodyAcc754 bodyHalt754 PRE_first_tail_x15_r0_body.bodyStepA204 bodyTop755 (fun _ hm => bodyO753 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr753).trans bodyInactive0) (bodyBr755.trans bodyBr753.symm) bodyCnt753 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) PRE_first_tail_x15_r0_body.sizeA204 PRE_first_tail_x15_r0_body.sizeArgsA204 PRE_first_tail_x15_r0_body.sizeSymA204 PRE_first_tail_x15_r0_body.sizeMlxA204 PRE_first_tail_x15_r0_body.sizePayA204 PRE_first_tail_x15_r0_body.sizeTaA204 PRE_first_tail_x15_r0_body.sizeDecA204 PRE_first_tail_x15_r0_body.sizePreA204 PRE_first_tail_x15_r0_body.bodyPatchB204 (fun _ hm => bodyO755 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr755).trans bodyInactive0) (bodyBr756.trans bodyBr755.symm) bodyCnt755 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) bodyAcc756 PRE_first_tail_x15_r0_body.bodyRunSeg204 bodyAcc757 bodyHalt757 PRE_first_tail_x15_r0_body.bodyStepA205 bodyTop758 (fun _ hm => bodyO756 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr756).trans bodyInactive0) (bodyBr758.trans bodyBr756.symm) bodyCnt756 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) PRE_first_tail_x15_r0_body.sizeA205 PRE_first_tail_x15_r0_body.sizeArgsA205 PRE_first_tail_x15_r0_body.sizeSymA205 PRE_first_tail_x15_r0_body.sizeMlxA205 PRE_first_tail_x15_r0_body.sizePayA205 PRE_first_tail_x15_r0_body.sizeTaA205 PRE_first_tail_x15_r0_body.sizeDecA205 PRE_first_tail_x15_r0_body.sizePreA205 PRE_first_tail_x15_r0_body.bodyPatchB205 (fun _ hm => bodyO758 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr758).trans bodyInactive0) (bodyBr759.trans bodyBr758.symm) bodyCnt758 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) bodyAcc759 PRE_first_tail_x15_r0_body.bodyRunSeg205 bodyAcc760 bodyHalt760 PRE_first_tail_x15_r0_body.bodyStepA206 bodyTop761 (fun _ hm => bodyO759 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr759).trans bodyInactive0) (bodyBr761.trans bodyBr759.symm) bodyCnt759 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) PRE_first_tail_x15_r0_body.sizeA206 PRE_first_tail_x15_r0_body.sizeArgsA206 PRE_first_tail_x15_r0_body.sizeSymA206 PRE_first_tail_x15_r0_body.sizeMlxA206 PRE_first_tail_x15_r0_body.sizePayA206 PRE_first_tail_x15_r0_body.sizeTaA206 PRE_first_tail_x15_r0_body.sizeDecA206 PRE_first_tail_x15_r0_body.sizePreA206 PRE_first_tail_x15_r0_body.bodyPatchB206 (fun _ hm => bodyO761 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr761).trans bodyInactive0) (bodyBr762.trans bodyBr761.symm) bodyCnt761 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29569, 533, 0, 414⟩) bodyAcc762 PRE_first_tail_x15_r0_body.bodyRunSeg206 bodyAcc763 bodyHalt763 PRE_first_tail_x15_r0_body.bodyStepA207 bodyTop764 (fun _ hm => bodyO762 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr762).trans bodyInactive0) (bodyBr764.trans bodyBr762.symm) bodyCnt762 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
